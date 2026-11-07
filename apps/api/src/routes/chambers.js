import { Router } from "express";

import { requireAuth } from "../middleware/auth.js";
import {
  requireChamberMember,
  requireChamberRole,
} from "../middleware/chamber.js";

const router = Router();

// Get chamber details
router.get(
  "/:chamberId",
  requireAuth,
  requireChamberMember,
  (req, res) => {
    return res.json({
      success: true,
      chamber: {
        id: req.chamber.id,
        name: req.chamber.name,
        email: req.chamber.email,
        phone: req.chamber.phone,
        address: req.chamber.address,
        role: req.chamberMembership.role,
      },
    });
  }
);

// Example of an OWNER/ADMIN-only endpoint
router.get(
  "/:chamberId/admin-check",
  requireAuth,
  requireChamberMember,
  requireChamberRole(["OWNER", "ADMIN"]),
  (req, res) => {
    return res.json({
      success: true,
      message: "You have chamber administration permission",
      role: req.chamberMembership.role,
    });
  }
);

export default router;