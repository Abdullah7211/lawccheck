
import { Router } from "express";
import { z } from "zod";
import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

// CREATE REMINDER
const createReminderSchema = z.object({
  caseId: z.string().uuid().optional(),
  taskId: z.string().uuid().optional(),
  recipientId: z.string().uuid().optional(),
  title: z.string().trim().min(2).max(200),
  message: z.string().trim().max(5000).optional(),
  remindAt: z.coerce.date(),
  status: z.enum(["PENDING", "SENT", "CANCELLED"]).optional(),
});

// UPDATE REMINDER
const updateReminderSchema = createReminderSchema
  .partial()
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field is required",
  });

// Validate related records
async function validateReminderRelations(data, chamberId) {
  if (data.caseId) {
    const relatedCase = await prisma.case.findFirst({
      where: {
        id: data.caseId,
        chamberId,
      },
    });

    if (!relatedCase) {
      return "Case not found in this chamber";
    }
  }

  if (data.taskId) {
    const relatedTask = await prisma.task.findFirst({
      where: {
        id: data.taskId,
        chamberId,
      },
    });

    if (!relatedTask) {
      return "Task not found in this chamber";
    }
  }

  if (data.recipientId) {
    const membership = await prisma.chamberMember.findFirst({
      where: {
        userId: data.recipientId,
        chamberId,
        isActive: true,
      },
    });

    if (!membership) {
      return "Recipient is not an active chamber member";
    }
  }

  return null;
}

// CREATE REMINDER
router.post(
  "/:chamberId/reminders",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const validation = createReminderSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid reminder data",
          errors: validation.error.flatten(),
        });
      }

      const data = validation.data;

      const relationError = await validateReminderRelations(
        data,
        req.chamber.id
      );

      if (relationError) {
        return res.status(400).json({
          success: false,
          message: relationError,
        });
      }

      const reminder = await prisma.reminder.create({
        data: {
          ...data,
          chamberId: req.chamber.id,
          createdById: req.user.id,
        },
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
            },
          },
          task: {
            select: {
              id: true,
              title: true,
              status: true,
            },
          },
          recipient: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
          createdBy: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
        },
      });

      return res.status(201).json({
        success: true,
        message: "Reminder created successfully",
        reminder,
      });
    } catch (error) {
      console.error("Create reminder error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to create reminder",
      });
    }
  }
);

// LIST REMINDERS
router.get(
  "/:chamberId/reminders",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const reminders = await prisma.reminder.findMany({
        where: {
          chamberId: req.chamber.id,
        },
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
            },
          },
          task: {
            select: {
              id: true,
              title: true,
              status: true,
            },
          },
          recipient: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
          createdBy: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
        },
        orderBy: {
          remindAt: "asc",
        },
      });

      return res.json({
        success: true,
        total: reminders.length,
        reminders,
      });
    } catch (error) {
      console.error("List reminders error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve reminders",
      });
    }
  }
);

// GET SINGLE REMINDER
router.get(
  "/:chamberId/reminders/:reminderId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const reminder = await prisma.reminder.findFirst({
        where: {
          id: req.params.reminderId,
          chamberId: req.chamber.id,
        },
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
            },
          },
          task: {
            select: {
              id: true,
              title: true,
              status: true,
            },
          },
          recipient: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
          createdBy: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
        },
      });

      if (!reminder) {
        return res.status(404).json({
          success: false,
          message: "Reminder not found in this chamber",
        });
      }

      return res.json({
        success: true,
        reminder,
      });
    } catch (error) {
      console.error("Get reminder error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve reminder",
      });
    }
  }
);

// UPDATE REMINDER
router.patch(
  "/:chamberId/reminders/:reminderId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const validation = updateReminderSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid reminder data",
          errors: validation.error.flatten(),
        });
      }

      const existingReminder = await prisma.reminder.findFirst({
        where: {
          id: req.params.reminderId,
          chamberId: req.chamber.id,
        },
      });

      if (!existingReminder) {
        return res.status(404).json({
          success: false,
          message: "Reminder not found in this chamber",
        });
      }

      const data = validation.data;

      const relationError = await validateReminderRelations(
        data,
        req.chamber.id
      );

      if (relationError) {
        return res.status(400).json({
          success: false,
          message: relationError,
        });
      }

      if (data.status === "SENT") {
        data.sentAt = new Date();
      } else if (
        data.status &&
        existingReminder.status === "SENT"
      ) {
        data.sentAt = null;
      }

      const reminder = await prisma.reminder.update({
        where: {
          id: existingReminder.id,
        },
        data,
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
            },
          },
          task: {
            select: {
              id: true,
              title: true,
              status: true,
            },
          },
          recipient: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
          createdBy: {
            select: {
              id: true,
              name: true,
              email: true,
            },
          },
        },
      });

      return res.json({
        success: true,
        message: "Reminder updated successfully",
        reminder,
      });
    } catch (error) {
      console.error("Update reminder error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to update reminder",
      });
    }
  }
);

// DELETE REMINDER
router.delete(
  "/:chamberId/reminders/:reminderId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const reminder = await prisma.reminder.findFirst({
        where: {
          id: req.params.reminderId,
          chamberId: req.chamber.id,
        },
      });

      if (!reminder) {
        return res.status(404).json({
          success: false,
          message: "Reminder not found in this chamber",
        });
      }

      await prisma.reminder.delete({
        where: {
          id: reminder.id,
        },
      });

      return res.json({
        success: true,
        message: "Reminder deleted successfully",
      });
    } catch (error) {
      console.error("Delete reminder error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to delete reminder",
      });
    }
  }
);

export default router;
