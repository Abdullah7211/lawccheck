import { Router } from "express";
import { z } from "zod";

import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

const createClientSchema = z.object({
  clientNumber: z.string().trim().min(1).max(50),
  fullName: z.string().trim().min(2).max(150),
  type: z.enum(["INDIVIDUAL", "ORGANIZATION"]).default("INDIVIDUAL"),
  phone: z.string().trim().max(30).optional(),
  email: z.string().trim().email().max(254).optional(),
  address: z.string().trim().max(500).optional(),
  notes: z.string().trim().max(5000).optional(),
});

// GET ALL CLIENTS
router.get(
  "/:chamberId/clients",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const clients = await prisma.client.findMany({
        where: {
          chamberId: req.chamber.id,
        },
        orderBy: {
          createdAt: "desc",
        },
        select: {
          id: true,
          chamberId: true,
          clientNumber: true,
          fullName: true,
          type: true,
          phone: true,
          email: true,
          address: true,
          notes: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      return res.json({
        success: true,
        total: clients.length,
        clients,
      });
    } catch (error) {
      console.error("Get clients error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve clients",
      });
    }
  }
);

// GET SINGLE CLIENT
router.get(
  "/:chamberId/clients/:clientId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { clientId } = req.params;

      const client = await prisma.client.findFirst({
        where: {
          id: clientId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
          chamberId: true,
          clientNumber: true,
          fullName: true,
          type: true,
          phone: true,
          email: true,
          address: true,
          notes: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      if (!client) {
        return res.status(404).json({
          success: false,
          message: "Client not found",
        });
      }

      return res.json({
        success: true,
        client,
      });
    } catch (error) {
      console.error("Get client error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve client",
      });
    }
  }
);

// UPDATE CLIENT
const updateClientSchema = createClientSchema.partial().refine(
  (data) => Object.keys(data).length > 0,
  {
    message: "At least one field must be provided",
  }
);

router.put(
  "/:chamberId/clients/:clientId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { clientId } = req.params;

      const parsed = updateClientSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid client details",
          errors: parsed.error.flatten().fieldErrors,
        });
      }

      const result = await prisma.client.updateMany({
        where: {
          id: clientId,
          chamberId: req.chamber.id,
        },
        data: parsed.data,
      });

      if (result.count === 0) {
        return res.status(404).json({
          success: false,
          message: "Client not found",
        });
      }

      const client = await prisma.client.findFirst({
        where: {
          id: clientId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
          chamberId: true,
          clientNumber: true,
          fullName: true,
          type: true,
          phone: true,
          email: true,
          address: true,
          notes: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      return res.json({
        success: true,
        message: "Client updated successfully",
        client,
      });
    } catch (error) {
      console.error("Update client error:", error);

      if (error.code === "P2002") {
        return res.status(409).json({
          success: false,
          message: "This client number already exists in this chamber",
        });
      }

      return res.status(500).json({
        success: false,
        message: "Failed to update client",
      });
    }
  }
);

// CREATE CLIENT
router.post(
  "/:chamberId/clients",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = createClientSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid client details",
          errors: parsed.error.flatten().fieldErrors,
        });
      }

      const client = await prisma.client.create({
        data: {
          ...parsed.data,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
          chamberId: true,
          clientNumber: true,
          fullName: true,
          type: true,
          phone: true,
          email: true,
          address: true,
          notes: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      return res.status(201).json({
        success: true,
        message: "Client created successfully",
        client,
      });
    } catch (error) {
      console.error("Create client error:", error);

      if (error.code === "P2002") {
        return res.status(409).json({
          success: false,
          message: "This client number already exists in this chamber",
        });
      }

      return res.status(500).json({
        success: false,
        message: "Failed to create client",
      });
    }
  }
);

// DELETE CLIENT
router.delete(
  "/:chamberId/clients/:clientId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { clientId } = req.params;
      const chamberId = req.chamber.id;

      const result = await prisma.$transaction(async (tx) => {
        // Check whether the client exists in this chamber
        const client = await tx.client.findFirst({
          where: {
            id: clientId,
            chamberId,
          },
          select: {
            id: true,
            clientNumber: true,
            fullName: true,
          },
        });

        if (!client) {
          return {
            notFound: true,
          };
        }

        // Check related cases
        const caseCount = await tx.case.count({
          where: {
            clientId,
            chamberId,
          },
        });

        // Check related payments
        const paymentCount = await tx.payment.count({
          where: {
            clientId,
            chamberId,
          },
        });

        if (caseCount > 0 || paymentCount > 0) {
          return {
            blocked: true,
            caseCount,
            paymentCount,
          };
        }

        // Delete client only if no related records exist
        await tx.client.deleteMany({
          where: {
            id: clientId,
            chamberId,
          },
        });

        return {
          deleted: true,
          client,
        };
      });

      if (result.notFound) {
        return res.status(404).json({
          success: false,
          message: "Client not found",
        });
      }

      if (result.blocked) {
        return res.status(409).json({
          success: false,
          message: "Client cannot be deleted because related records exist",
          relatedRecords: {
            cases: result.caseCount,
            payments: result.paymentCount,
          },
        });
      }

      return res.json({
        success: true,
        message: "Client deleted successfully",
        client: result.client,
      });
    } catch (error) {
      console.error("Delete client error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to delete client",
      });
    }
  }
);

export default router;