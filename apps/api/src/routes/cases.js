import { Router } from "express";
import { z } from "zod";

import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

const createCaseSchema = z.object({
  clientId: z.string().uuid(),
  caseNumber: z.string().trim().min(1).max(50),
  title: z.string().trim().min(2).max(200),

  status: z.enum(["ACTIVE", "ON_HOLD", "CLOSED", "COMPLETED"]).optional(),

  caseType: z.string().trim().max(100).optional(),
  courtName: z.string().trim().max(200).optional(),
  courtLocation: z.string().trim().max(200).optional(),
  courtRoom: z.string().trim().max(100).optional(),
  judgeName: z.string().trim().max(150).optional(),
  opposingParty: z.string().trim().max(200).optional(),
  filingDate: z.coerce.date().optional(),
  description: z.string().trim().max(5000).optional(),
});

const updateCaseSchema = createCaseSchema
  .partial()
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field is required for an update",
  });

// CREATE CASE
router.post(
  "/:chamberId/cases",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = createCaseSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid case details",
          errors: parsed.error.flatten().fieldErrors,
        });
      }

      // Verify that the selected client belongs to this chamber
      const client = await prisma.client.findFirst({
        where: {
          id: parsed.data.clientId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
        },
      });

      if (!client) {
        return res.status(404).json({
          success: false,
          message: "Client not found in this chamber",
        });
      }

      const newCase = await prisma.case.create({
        data: {
          ...parsed.data,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
          chamberId: true,
          clientId: true,
          caseNumber: true,
          title: true,
          status: true,
          caseType: true,
          courtName: true,
          courtLocation: true,
          courtRoom: true,
          judgeName: true,
          opposingParty: true,
          filingDate: true,
          description: true,
          createdAt: true,
          updatedAt: true,
        },
      });

      return res.status(201).json({
        success: true,
        message: "Case created successfully",
        case: newCase,
      });
    } catch (error) {
      console.error("Create case error:", error);

      if (error.code === "P2002") {
        return res.status(409).json({
          success: false,
          message: "This case number already exists in this chamber",
        });
      }

      return res.status(500).json({
        success: false,
        message: "Failed to create case",
      });
    }
  }
);

// LIST ALL CASES
router.get(
  "/:chamberId/cases",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const cases = await prisma.case.findMany({
        where: {
          chamberId: req.chamber.id,
        },
        include: {
          client: {
            select: {
              id: true,
              clientNumber: true,
              fullName: true,
              phone: true,
              email: true,
            },
          },
        },
        orderBy: {
          createdAt: "desc",
        },
      });

      return res.json({
        success: true,
        total: cases.length,
        cases,
      });
    } catch (error) {
      console.error("List cases error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve cases",
      });
    }
  }
);

// GET SINGLE CASE
router.get(
  "/:chamberId/cases/:caseId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { caseId } = req.params;

      const caseRecord = await prisma.case.findFirst({
        where: {
          id: caseId,
          chamberId: req.chamber.id,
        },
        include: {
          client: {
            select: {
              id: true,
              clientNumber: true,
              fullName: true,
              phone: true,
              email: true,
              address: true,
            },
          },
        },
      });

      if (!caseRecord) {
        return res.status(404).json({
          success: false,
          message: "Case not found in this chamber",
        });
      }

      return res.json({
        success: true,
        case: caseRecord,
      });
    } catch (error) {
      console.error("Get single case error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve case",
      });
    }
  }
);

// UPDATE CASE
router.put(
  "/:chamberId/cases/:caseId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { caseId } = req.params;

      const parsed = updateCaseSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid case details",
          errors: parsed.error.flatten().fieldErrors,
        });
      }

      // Check whether the case belongs to this chamber
      const existingCase = await prisma.case.findFirst({
        where: {
          id: caseId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
        },
      });

      if (!existingCase) {
        return res.status(404).json({
          success: false,
          message: "Case not found in this chamber",
        });
      }

      // If clientId is being changed, verify the new client
      if (parsed.data.clientId) {
        const client = await prisma.client.findFirst({
          where: {
            id: parsed.data.clientId,
            chamberId: req.chamber.id,
          },
          select: {
            id: true,
          },
        });

        if (!client) {
          return res.status(404).json({
            success: false,
            message: "Client not found in this chamber",
          });
        }
      }

      await prisma.case.updateMany({
        where: {
          id: caseId,
          chamberId: req.chamber.id,
        },
        data: parsed.data,
      });

      const updatedCase = await prisma.case.findFirst({
        where: {
          id: caseId,
          chamberId: req.chamber.id,
        },
        include: {
          client: {
            select: {
              id: true,
              clientNumber: true,
              fullName: true,
              phone: true,
              email: true,
              address: true,
            },
          },
        },
      });

      return res.json({
        success: true,
        message: "Case updated successfully",
        case: updatedCase,
      });
    } catch (error) {
      console.error("Update case error:", error);

      if (error.code === "P2002") {
        return res.status(409).json({
          success: false,
          message: "This case number already exists in this chamber",
        });
      }

      return res.status(500).json({
        success: false,
        message: "Failed to update case",
      });
    }
  }
);

// DELETE CASE
router.delete(
  "/:chamberId/cases/:caseId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { caseId } = req.params;

      const caseRecord = await prisma.case.findFirst({
        where: {
          id: caseId,
          chamberId: req.chamber.id,
        },
        include: {
          _count: {
            select: {
              hearings: true,
              tasks: true,
              reminders: true,
              documents: true,
              notes: true,
              expenses: true,
              payments: true,
              notifications: true,
            },
          },
        },
      });

      if (!caseRecord) {
        return res.status(404).json({
          success: false,
          message: "Case not found in this chamber",
        });
      }

      const relatedRecords = caseRecord._count;

      const hasRelatedRecords = Object.values(relatedRecords).some(
        (count) => count > 0
      );

      if (hasRelatedRecords) {
        return res.status(409).json({
          success: false,
          message:
            "This case cannot be deleted because it has related records. Remove or resolve those records first.",
          relatedRecords,
        });
      }

      await prisma.case.deleteMany({
        where: {
          id: caseId,
          chamberId: req.chamber.id,
        },
      });

      return res.json({
        success: true,
        message: "Case deleted successfully",
      });
    } catch (error) {
      console.error("Delete case error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to delete case",
      });
    }
  }
);

export default router;