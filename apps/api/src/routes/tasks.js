import { Router } from "express";
import { z } from "zod";

import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

const createTaskSchema = z.object({
  caseId: z.string().uuid().optional(),

  title: z.string().trim().min(2).max(200),

  description: z.string().trim().max(5000).optional(),

  status: z.enum([
    "TODO",
    "IN_PROGRESS",
    "COMPLETED",
    "CANCELLED",
  ]).optional(),

  priority: z.enum([
    "LOW",
    "MEDIUM",
    "HIGH",
    "URGENT",
  ]).optional(),

  dueDate: z.coerce.date().optional(),

  assignedToId: z.string().uuid().optional(),
});

const updateTaskSchema = createTaskSchema
  .partial()
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field is required",
  });

  // UPDATE TASK
router.patch(
  "/:chamberId/tasks/:taskId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { taskId } = req.params;

      const validation = updateTaskSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid task data",
          errors: validation.error.flatten(),
        });
      }

      const existingTask = await prisma.task.findFirst({
        where: {
          id: taskId,
          chamberId: req.chamber.id,
        },
      });

      if (!existingTask) {
        return res.status(404).json({
          success: false,
          message: "Task not found in this chamber",
        });
      }

      const data = validation.data;

      // Verify the case belongs to this chamber
      if (data.caseId) {
        const relatedCase = await prisma.case.findFirst({
          where: {
            id: data.caseId,
            chamberId: req.chamber.id,
          },
        });

        if (!relatedCase) {
          return res.status(400).json({
            success: false,
            message: "Case not found in this chamber",
          });
        }
      }

      // Verify the assigned user is an active chamber member
      if (data.assignedToId) {
        const membership = await prisma.chamberMember.findFirst({
          where: {
            userId: data.assignedToId,
            chamberId: req.chamber.id,
            isActive: true,
          },
        });

        if (!membership) {
          return res.status(400).json({
            success: false,
            message: "Assigned user is not an active chamber member",
          });
        }
      }

      // Manage completion timestamp
      if (data.status === "COMPLETED") {
        data.completedAt = new Date();
      } else if (
        data.status &&
        existingTask.status === "COMPLETED"
      ) {
        data.completedAt = null;
      }

      const updatedTask = await prisma.task.update({
        where: {
          id: existingTask.id,
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
          assignedTo: {
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
        message: "Task updated successfully",
        task: updatedTask,
      });
    } catch (error) {
      console.error("Update task error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to update task",
      });
    }
  }
);

// DELETE TASK
router.delete(
  "/:chamberId/tasks/:taskId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { taskId } = req.params;

      const task = await prisma.task.findFirst({
        where: {
          id: taskId,
          chamberId: req.chamber.id,
        },
        include: {
          _count: {
            select: {
              reminders: true,
            },
          },
        },
      });

      if (!task) {
        return res.status(404).json({
          success: false,
          message: "Task not found in this chamber",
        });
      }

      if (task._count.reminders > 0) {
        return res.status(409).json({
          success: false,
          message: "Cannot delete this task because it has associated reminders",
        });
      }

      await prisma.task.delete({
        where: {
          id: task.id,
        },
      });

      return res.json({
        success: true,
        message: "Task deleted successfully",
      });
    } catch (error) {
      console.error("Delete task error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to delete task",
      });
    }
  }
);

// GET SINGLE TASK
router.get(
  "/:chamberId/tasks/:taskId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { taskId } = req.params;

      const task = await prisma.task.findFirst({
        where: {
          id: taskId,
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
          assignedTo: {
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

      if (!task) {
        return res.status(404).json({
          success: false,
          message: "Task not found in this chamber",
        });
      }

      return res.json({
        success: true,
        task,
      });
    } catch (error) {
      console.error("Get task error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve task",
      });
    }
  }
);

// LIST TASKS
router.get(
  "/:chamberId/tasks",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const tasks = await prisma.task.findMany({
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
          assignedTo: {
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
        orderBy: [
          {
            dueDate: {
              sort: "asc",
              nulls: "last",
            },
          },
          {
            createdAt: "desc",
          },
        ],
      });

      return res.json({
        success: true,
        total: tasks.length,
        tasks,
      });
    } catch (error) {
      console.error("List tasks error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve tasks",
      });
    }
  }
);

// CREATE TASK
router.post(
  "/:chamberId/tasks",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = createTaskSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid task details",
          errors: parsed.error.flatten().fieldErrors,
        });
      }

      // Verify that the selected case belongs to this chamber
      if (parsed.data.caseId) {
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
      }

      // Verify that the assigned user is an active chamber member
      if (parsed.data.assignedToId) {
        const membership = await prisma.chamberMember.findFirst({
          where: {
            userId: parsed.data.assignedToId,
            chamberId: req.chamber.id,
            isActive: true,
          },
          select: {
            id: true,
          },
        });

        if (!membership) {
          return res.status(404).json({
            success: false,
            message: "Assigned user is not an active member of this chamber",
          });
        }
      }

      const task = await prisma.task.create({
        data: {
          ...parsed.data,
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
          assignedTo: {
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
        message: "Task created successfully",
        task,
      });
    } catch (error) {
      console.error("Create task error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to create task",
      });
    }
  }
);

export default router;