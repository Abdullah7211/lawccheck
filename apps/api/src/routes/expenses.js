
import { Router } from "express";
import { z } from "zod";

import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

const expenseCategories = [
  "OFFICE",
  "TRAVEL",
  "COURT_FEES",
  "STAFF_SALARY",
  "UTILITIES",
  "OTHER",
];

const createExpenseSchema = z.object({
  title: z.string().trim().min(2).max(200),
  description: z.string().trim().max(5000).optional(),
  amount: z.coerce.number()
    .positive()
    .max(9999999999.99)
    .refine(
    (value) => Math.abs(value * 100 - Math.round(value * 100)) < 0.0000001,
    { message: "Amount must have at most two decimal places" }
    ),
  currency: z.string().trim().length(3).transform((value) => value.toUpperCase()).optional(),
  category: z.enum(expenseCategories).optional(),
  expenseDate: z.coerce.date().optional(),
  caseId: z.union([z.string().uuid(), z.null()]).optional(),
});

const updateExpenseSchema = createExpenseSchema
  .partial()
  .refine(
    (data) => Object.keys(data).length > 0,
    { message: "At least one field must be provided" }
  );

async function validateExpenseCase(caseId, chamberId) {
  if (caseId === undefined || caseId === null) {
    return true;
  }

  const existingCase = await prisma.case.findFirst({
    where: {
      id: caseId,
      chamberId,
    },
    select: {
      id: true,
    },
  });

  return Boolean(existingCase);
}

// CREATE EXPENSE
router.post(
  "/:chamberId/expenses",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = createExpenseSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid expense data",
          errors: parsed.error.flatten(),
        });
      }

      const validCase = await validateExpenseCase(
        parsed.data.caseId,
        req.chamber.id
      );

      if (!validCase) {
        return res.status(404).json({
          success: false,
          message: "Case not found in this chamber",
        });
      }

      const expense = await prisma.expense.create({
        data: {
          ...parsed.data,
          chamberId: req.chamber.id,
        },
      });

      return res.status(201).json({
        success: true,
        message: "Expense created successfully",
        expense,
      });
    } catch (error) {
      console.error("Create expense error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to create expense",
      });
    }
  }
);

// LIST EXPENSES
router.get(
  "/:chamberId/expenses",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const expenses = await prisma.expense.findMany({
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
        },
        orderBy: {
          expenseDate: "desc",
        },
      });

      return res.json({
        success: true,
        total: expenses.length,
        expenses,
      });
    } catch (error) {
      console.error("List expenses error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to retrieve expenses",
      });
    }
  }
);

// GET SINGLE EXPENSE
router.get(
  "/:chamberId/expenses/:expenseId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const expense = await prisma.expense.findFirst({
        where: {
          id: req.params.expenseId,
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
        },
      });

      if (!expense) {
        return res.status(404).json({
          success: false,
          message: "Expense not found in this chamber",
        });
      }

      return res.json({
        success: true,
        expense,
      });
    } catch (error) {
      console.error("Get expense error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to retrieve expense",
      });
    }
  }
);

// UPDATE EXPENSE
router.patch(
  "/:chamberId/expenses/:expenseId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = updateExpenseSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid expense data",
          errors: parsed.error.flatten(),
        });
      }

      const existingExpense = await prisma.expense.findFirst({
        where: {
          id: req.params.expenseId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
        },
      });

      if (!existingExpense) {
        return res.status(404).json({
          success: false,
          message: "Expense not found in this chamber",
        });
      }

      if (parsed.data.caseId !== undefined) {
        const validCase = await validateExpenseCase(
          parsed.data.caseId,
          req.chamber.id
        );

        if (!validCase) {
          return res.status(404).json({
            success: false,
            message: "Case not found in this chamber",
          });
        }
      }

      const expense = await prisma.expense.update({
        where: {
          id: existingExpense.id,
        },
        data: parsed.data,
      });

      return res.json({
        success: true,
        message: "Expense updated successfully",
        expense,
      });
    } catch (error) {
      console.error("Update expense error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to update expense",
      });
    }
  }
);

// DELETE EXPENSE
router.delete(
  "/:chamberId/expenses/:expenseId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const existingExpense = await prisma.expense.findFirst({
        where: {
          id: req.params.expenseId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
        },
      });

      if (!existingExpense) {
        return res.status(404).json({
          success: false,
          message: "Expense not found in this chamber",
        });
      }

      await prisma.expense.delete({
        where: {
          id: existingExpense.id,
        },
      });

      return res.json({
        success: true,
        message: "Expense deleted successfully",
      });
    } catch (error) {
      console.error("Delete expense error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to delete expense",
      });
    }
  }
);

export default router;
