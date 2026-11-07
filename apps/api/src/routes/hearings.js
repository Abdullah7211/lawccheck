import { Router } from "express";
import { z } from "zod";

import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

const createHearingSchema = z.object({
  caseId: z.string().uuid(),
  hearingDate: z.coerce.date(),

  courtName: z.string().trim().max(200).optional(),
  courtRoom: z.string().trim().max(100).optional(),
  judgeName: z.string().trim().max(150).optional(),
  purpose: z.string().trim().max(2000).optional(),
  outcome: z.string().trim().max(5000).optional(),
  nextDate: z.coerce.date().optional(),
  notes: z.string().trim().max(5000).optional(),
});

const updateHearingSchema = createHearingSchema
  .omit({ caseId: true })
  .partial()
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field is required for an update",
  });

// CREATE HEARING
router.post(
  "/:chamberId/hearings",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = createHearingSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid hearing details",
          errors: parsed.error.flatten().fieldErrors,
        });
      }

      // Verify that the case belongs to this chamber
      const caseRecord = await prisma.case.findFirst({
        where: {
          id: parsed.data.caseId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
        },
      });

      if (!caseRecord) {
        return res.status(404).json({
          success: false,
          message: "Case not found in this chamber",
        });
      }

      const hearing = await prisma.hearing.create({
        data: {
          ...parsed.data,
          chamberId: req.chamber.id,
        },
      });

      return res.status(201).json({
        success: true,
        message: "Hearing created successfully",
        hearing,
      });
    } catch (error) {
      console.error("Create hearing error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to create hearing",
      });
    }
  }
);

// LIST ALL HEARINGS
router.get(
  "/:chamberId/hearings",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const hearings = await prisma.hearing.findMany({
        where: {
          chamberId: req.chamber.id,
        },
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
              status: true,
              client: {
                select: {
                  id: true,
                  clientNumber: true,
                  fullName: true,
                  phone: true,
                },
              },
            },
          },
        },
        orderBy: {
          hearingDate: "asc",
        },
      });

      return res.json({
        success: true,
        total: hearings.length,
        hearings,
      });
    } catch (error) {
      console.error("List hearings error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve hearings",
      });
    }
  }
);

// GET SINGLE HEARING
router.get(
  "/:chamberId/hearings/:hearingId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { hearingId } = req.params;

      const hearing = await prisma.hearing.findFirst({
        where: {
          id: hearingId,
          chamberId: req.chamber.id,
        },
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
              status: true,
              courtName: true,
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
          },
        },
      });

      if (!hearing) {
        return res.status(404).json({
          success: false,
          message: "Hearing not found in this chamber",
        });
      }

      return res.json({
        success: true,
        hearing,
      });
    } catch (error) {
      console.error("Get single hearing error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve hearing",
      });
    }
  }
);

// UPDATE HEARING
router.put(
  "/:chamberId/hearings/:hearingId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { hearingId } = req.params;

      const parsed = updateHearingSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid hearing details",
          errors: parsed.error.flatten().fieldErrors,
        });
      }

      const existingHearing = await prisma.hearing.findFirst({
        where: {
          id: hearingId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
        },
      });

      if (!existingHearing) {
        return res.status(404).json({
          success: false,
          message: "Hearing not found in this chamber",
        });
      }

      await prisma.hearing.updateMany({
        where: {
          id: hearingId,
          chamberId: req.chamber.id,
        },
        data: parsed.data,
      });

      const updatedHearing = await prisma.hearing.findFirst({
        where: {
          id: hearingId,
          chamberId: req.chamber.id,
        },
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
              client: {
                select: {
                  id: true,
                  clientNumber: true,
                  fullName: true,
                },
              },
            },
          },
        },
      });

      return res.json({
        success: true,
        message: "Hearing updated successfully",
        hearing: updatedHearing,
      });
    } catch (error) {
      console.error("Update hearing error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to update hearing",
      });
    }
  }
);

// DELETE HEARING
router.delete(
  "/:chamberId/hearings/:hearingId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { hearingId } = req.params;

      const existingHearing = await prisma.hearing.findFirst({
        where: {
          id: hearingId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
        },
      });

      if (!existingHearing) {
        return res.status(404).json({
          success: false,
          message: "Hearing not found in this chamber",
        });
      }

      await prisma.hearing.deleteMany({
        where: {
          id: hearingId,
          chamberId: req.chamber.id,
        },
      });

      return res.json({
        success: true,
        message: "Hearing deleted successfully",
      });
    } catch (error) {
      console.error("Delete hearing error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to delete hearing",
      });
    }
  }
);

export default router;