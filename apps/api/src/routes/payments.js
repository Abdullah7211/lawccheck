
import { Router } from "express";
import { z } from "zod";

import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

const paymentMethods = [
  "CASH",
  "BANK_TRANSFER",
  "MOBILE_BANKING",
  "CARD",
  "CHEQUE",
  "OTHER",
];

const createPaymentSchema = z.object({
  clientId: z.string().uuid(),
  caseId: z.union([z.string().uuid(), z.null()]).optional(),
  amount: z.coerce.number()
    .positive()
    .max(9999999999.99)
    .refine(
      (value) => Math.abs(value * 100 - Math.round(value * 100)) < 0.0000001,
      { message: "Amount must have at most two decimal places" }
    ),
  currency: z.string().trim().length(3)
    .transform((value) => value.toUpperCase())
    .optional(),
  method: z.enum(paymentMethods).optional(),
  reference: z.string().trim().max(200).optional(),
  description: z.string().trim().max(5000).optional(),
  paymentDate: z.coerce.date().optional(),
});

const updatePaymentSchema = createPaymentSchema
  .omit({ clientId: true })
  .partial()
  .refine(
    (data) => Object.keys(data).length > 0,
    { message: "At least one field must be provided" }
  );

const paymentInclude = {
  client: {
    select: {
      id: true,
      clientNumber: true,
      fullName: true,
    },
  },
  case: {
    select: {
      id: true,
      caseNumber: true,
      title: true,
    },
  },
};

async function validatePaymentRelations(clientId, caseId, chamberId) {
  const client = await prisma.client.findFirst({
    where: {
      id: clientId,
      chamberId,
    },
    select: {
      id: true,
    },
  });

  if (!client) {
    return {
      valid: false,
      message: "Client not found in this chamber",
    };
  }

  if (caseId) {
    const existingCase = await prisma.case.findFirst({
      where: {
        id: caseId,
        chamberId,
        clientId,
      },
      select: {
        id: true,
      },
    });

    if (!existingCase) {
      return {
        valid: false,
        message: "Case not found for this client in this chamber",
      };
    }
  }

  return { valid: true };
}

// CREATE PAYMENT
router.post(
  "/:chamberId/payments",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = createPaymentSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid payment data",
          errors: parsed.error.flatten(),
        });
      }

      const validRelations = await validatePaymentRelations(
        parsed.data.clientId,
        parsed.data.caseId,
        req.chamber.id
      );

      if (!validRelations.valid) {
        return res.status(404).json({
          success: false,
          message: validRelations.message,
        });
      }

      const payment = await prisma.payment.create({
        data: {
          ...parsed.data,
          chamberId: req.chamber.id,
        },
        include: paymentInclude,
      });

      return res.status(201).json({
        success: true,
        message: "Payment created successfully",
        payment,
      });
    } catch (error) {
      console.error("Create payment error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to create payment",
      });
    }
  }
);

// LIST PAYMENTS
router.get(
  "/:chamberId/payments",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const payments = await prisma.payment.findMany({
        where: {
          chamberId: req.chamber.id,
        },
        include: paymentInclude,
        orderBy: {
          paymentDate: "desc",
        },
      });

      return res.json({
        success: true,
        total: payments.length,
        payments,
      });
    } catch (error) {
      console.error("List payments error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to retrieve payments",
      });
    }
  }
);

// GET SINGLE PAYMENT
router.get(
  "/:chamberId/payments/:paymentId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const payment = await prisma.payment.findFirst({
        where: {
          id: req.params.paymentId,
          chamberId: req.chamber.id,
        },
        include: paymentInclude,
      });

      if (!payment) {
        return res.status(404).json({
          success: false,
          message: "Payment not found in this chamber",
        });
      }

      return res.json({
        success: true,
        payment,
      });
    } catch (error) {
      console.error("Get payment error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to retrieve payment",
      });
    }
  }
);

// UPDATE PAYMENT
router.patch(
  "/:chamberId/payments/:paymentId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = updatePaymentSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid payment data",
          errors: parsed.error.flatten(),
        });
      }

      const existingPayment = await prisma.payment.findFirst({
        where: {
          id: req.params.paymentId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
          clientId: true,
        },
      });

      if (!existingPayment) {
        return res.status(404).json({
          success: false,
          message: "Payment not found in this chamber",
        });
      }

      if (parsed.data.caseId !== undefined) {
        const validRelations = await validatePaymentRelations(
          existingPayment.clientId,
          parsed.data.caseId,
          req.chamber.id
        );

        if (!validRelations.valid) {
          return res.status(404).json({
            success: false,
            message: validRelations.message,
          });
        }
      }

      const payment = await prisma.payment.update({
        where: {
          id: existingPayment.id,
        },
        data: parsed.data,
        include: paymentInclude,
      });

      return res.json({
        success: true,
        message: "Payment updated successfully",
        payment,
      });
    } catch (error) {
      console.error("Update payment error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to update payment",
      });
    }
  }
);

// DELETE PAYMENT
router.delete(
  "/:chamberId/payments/:paymentId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const existingPayment = await prisma.payment.findFirst({
        where: {
          id: req.params.paymentId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
        },
      });

      if (!existingPayment) {
        return res.status(404).json({
          success: false,
          message: "Payment not found in this chamber",
        });
      }

      await prisma.payment.delete({
        where: {
          id: existingPayment.id,
        },
      });

      return res.json({
        success: true,
        message: "Payment deleted successfully",
      });
    } catch (error) {
      console.error("Delete payment error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to delete payment",
      });
    }
  }
);

export default router;
