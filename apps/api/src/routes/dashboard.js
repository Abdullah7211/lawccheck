import { Router } from "express";
import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

// GET CHAMBER DASHBOARD
router.get(
  "/:chamberId/dashboard",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const chamberId = req.chamber.id;
      const userId = req.user.id;
      const now = new Date();

      const nextSevenDays = new Date(now);
      nextSevenDays.setDate(nextSevenDays.getDate() + 7);

      const [
        totalClients,
        totalCases,
        activeCases,
        onHoldCases,
        closedCases,
        completedCases,
        totalTasks,
        todoTasks,
        inProgressTasks,
        completedTasks,
        overdueTasks,
        urgentTasks,
        upcomingHearings,
        upcomingDeadlines,
        recentPayments,
        recentExpenses,
        unreadNotifications,
        paymentGroups,
        expenseGroups,
      ] = await Promise.all([
        prisma.client.count({
          where: { chamberId },
        }),

        prisma.case.count({
          where: { chamberId },
        }),

        prisma.case.count({
          where: { chamberId, status: "ACTIVE" },
        }),

        prisma.case.count({
          where: { chamberId, status: "ON_HOLD" },
        }),

        prisma.case.count({
          where: { chamberId, status: "CLOSED" },
        }),

        prisma.case.count({
          where: { chamberId, status: "COMPLETED" },
        }),

        prisma.task.count({
          where: { chamberId },
        }),

        prisma.task.count({
          where: { chamberId, status: "TODO" },
        }),

        prisma.task.count({
          where: { chamberId, status: "IN_PROGRESS" },
        }),

        prisma.task.count({
          where: { chamberId, status: "COMPLETED" },
        }),

        prisma.task.count({
          where: {
            chamberId,
            dueDate: { lt: now },
            status: { in: ["TODO", "IN_PROGRESS"] },
          },
        }),

        prisma.task.count({
          where: {
            chamberId,
            priority: "URGENT",
            status: { in: ["TODO", "IN_PROGRESS"] },
          },
        }),

        prisma.hearing.findMany({
          where: {
            chamberId,
            hearingDate: {
              gte: now,
              lte: nextSevenDays,
            },
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
                    fullName: true,
                  },
                },
              },
            },
          },
          orderBy: { hearingDate: "asc" },
          take: 10,
        }),

        prisma.task.findMany({
          where: {
            chamberId,
            dueDate: {
              gte: now,
              lte: nextSevenDays,
            },
            status: { in: ["TODO", "IN_PROGRESS"] },
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
              },
            },
          },
          orderBy: { dueDate: "asc" },
          take: 10,
        }),

        prisma.payment.findMany({
          where: { chamberId },
          include: {
            client: {
              select: {
                id: true,
                fullName: true,
                clientNumber: true,
              },
            },
          },
          orderBy: { paymentDate: "desc" },
          take: 5,
        }),

        prisma.expense.findMany({
          where: { chamberId },
          orderBy: { expenseDate: "desc" },
          take: 5,
        }),

        prisma.notification.count({
          where: {
            chamberId,
            recipientId: userId,
            isRead: false,
          },
        }),

        prisma.payment.groupBy({
          by: ["currency"],
          where: { chamberId },
          _sum: { amount: true },
        }),

        prisma.expense.groupBy({
          by: ["currency"],
          where: { chamberId },
          _sum: { amount: true },
        }),
      ]);

      return res.json({
        success: true,
        dashboard: {
          clients: {
            total: totalClients,
          },

          cases: {
            total: totalCases,
            active: activeCases,
            onHold: onHoldCases,
            closed: closedCases,
            completed: completedCases,
          },

          tasks: {
            total: totalTasks,
            todo: todoTasks,
            inProgress: inProgressTasks,
            completed: completedTasks,
            overdue: overdueTasks,
            urgent: urgentTasks,
          },

          upcomingHearings,
          upcomingDeadlines,

          recentPayments,
          recentExpenses,

          financialSummary: {
            paymentsByCurrency: paymentGroups.map((item) => ({
              currency: item.currency,
              total: item._sum.amount?.toString() ?? "0",
            })),

            expensesByCurrency: expenseGroups.map((item) => ({
              currency: item.currency,
              total: item._sum.amount?.toString() ?? "0",
            })),
          },

          unreadNotifications,
        },
      });
    } catch (error) {
      console.error("Dashboard error:", error);

      return res.status(500).json({
        success: false,
        message: "Failed to retrieve dashboard data",
      });
    }
  }
);

export default router;