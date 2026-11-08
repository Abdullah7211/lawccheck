import { Router } from "express";
import { z } from "zod";
import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

// CREATE NOTIFICATION
const createNotificationSchema = z.object({
  recipientId: z.string().uuid(),
  caseId: z.string().uuid().optional(),
  title: z.string().trim().min(2).max(200),
  message: z.string().trim().max(5000).optional(),
  type: z
    .enum([
      "GENERAL",
      "TASK",
      "HEARING",
      "DEADLINE",
      "PAYMENT",
      "CASE_UPDATE",
    ])
    .optional(),
});

// UPDATE NOTIFICATION (read/unread only)
const updateNotificationSchema = z
  .object({
    isRead: z.boolean(),
  })
  .strict();

// Validate recipient and case
async function validateNotificationRelations(data, chamberId) {
  const membership = await prisma.chamberMember.findFirst({
    where: {
      userId: data.recipientId,
      chamberId,
      isActive: true,
    },
  });

  if (!membership) {
    return "Recipient is not an active member of this chamber";
  }

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

  return null;
}

// CREATE NOTIFICATION
router.post(
  "/:chamberId/notifications",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const validation = createNotificationSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid notification data",
          errors: validation.error.flatten(),
        });
      }

      const data = validation.data;

      const relationError = await validateNotificationRelations(
        data,
        req.chamber.id
      );

      if (relationError) {
        return res.status(400).json({
          success: false,
          message: relationError,
        });
      }

      const notification = await prisma.notification.create({
        data: {
          chamberId: req.chamber.id,
          recipientId: data.recipientId,
          caseId: data.caseId || null,
          title: data.title,
          message: data.message || null,
          type: data.type || "GENERAL",
        },
      });

      return res.status(201).json({
        success: true,
        message: "Notification created successfully",
        notification,
      });
    } catch (error) {
      console.error("Create notification error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to create notification",
      });
    }
  }
);

// LIST MY NOTIFICATIONS
router.get(
  "/:chamberId/notifications",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const where = {
        chamberId: req.chamber.id,
        recipientId: req.user.id,
      };

      if (req.query.isRead !== undefined) {
        if (!["true", "false"].includes(req.query.isRead)) {
          return res.status(400).json({
            success: false,
            message: "isRead must be true or false",
          });
        }

        where.isRead = req.query.isRead === "true";
      }

      const [notifications, total, unreadCount] = await Promise.all([
        prisma.notification.findMany({
          where,
          include: {
            case: {
              select: {
                id: true,
                caseNumber: true,
                title: true,
              },
            },
          },
          orderBy: {
            createdAt: "desc",
          },
        }),

        prisma.notification.count({
          where,
        }),

        prisma.notification.count({
          where: {
            chamberId: req.chamber.id,
            recipientId: req.user.id,
            isRead: false,
          },
        }),
      ]);

      return res.json({
        success: true,
        total,
        unreadCount,
        notifications,
      });
    } catch (error) {
      console.error("List notifications error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve notifications",
      });
    }
  }
);

// GET SINGLE NOTIFICATION
router.get(
  "/:chamberId/notifications/:notificationId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const notification = await prisma.notification.findFirst({
        where: {
          id: req.params.notificationId,
          chamberId: req.chamber.id,
          recipientId: req.user.id,
        },
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
            },
          },
        },
      });

      if (!notification) {
        return res.status(404).json({
          success: false,
          message: "Notification not found",
        });
      }

      return res.json({
        success: true,
        notification,
      });
    } catch (error) {
      console.error("Get notification error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve notification",
      });
    }
  }
);

// MARK NOTIFICATION AS READ OR UNREAD
router.patch(
  "/:chamberId/notifications/:notificationId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const validation = updateNotificationSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid notification update data",
          errors: validation.error.flatten(),
        });
      }

      const existingNotification = await prisma.notification.findFirst({
        where: {
          id: req.params.notificationId,
          chamberId: req.chamber.id,
          recipientId: req.user.id,
        },
      });

      if (!existingNotification) {
        return res.status(404).json({
          success: false,
          message: "Notification not found",
        });
      }

      const notification = await prisma.notification.update({
        where: {
          id: existingNotification.id,
        },
        data: {
          isRead: validation.data.isRead,
          readAt: validation.data.isRead ? new Date() : null,
        },
      });

      return res.json({
        success: true,
        message: "Notification updated successfully",
        notification,
      });
    } catch (error) {
      console.error("Update notification error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to update notification",
      });
    }
  }
);

// DELETE NOTIFICATION
router.delete(
  "/:chamberId/notifications/:notificationId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const existingNotification = await prisma.notification.findFirst({
        where: {
          id: req.params.notificationId,
          chamberId: req.chamber.id,
          recipientId: req.user.id,
        },
      });

      if (!existingNotification) {
        return res.status(404).json({
          success: false,
          message: "Notification not found",
        });
      }

      await prisma.notification.delete({
        where: {
          id: existingNotification.id,
        },
      });

      return res.json({
        success: true,
        message: "Notification deleted successfully",
      });
    } catch (error) {
      console.error("Delete notification error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to delete notification",
      });
    }
  }
);

export default router;