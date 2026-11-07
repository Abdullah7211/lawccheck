import { prisma } from "../prisma.js";

export async function requireChamberMember(req, res, next) {
  try {
    const { chamberId } = req.params;

    if (!chamberId) {
      return res.status(400).json({
        success: false,
        message: "Chamber ID is required",
      });
    }

    const membership = await prisma.chamberMember.findFirst({
      where: {
        userId: req.user.id,
        chamberId,
        isActive: true,
      },
      include: {
        chamber: {
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
            address: true,
            },
        },
      },
    });

    if (!membership) {
      return res.status(403).json({
        success: false,
        message: "You do not have access to this chamber",
      });
    }

    req.chamberMembership = membership;
    req.chamber = membership.chamber;

    next();
  } catch (error) {
    console.error("Chamber authorization error:", error);

    return res.status(500).json({
      success: false,
      message: "Chamber authorization failed",
    });
  }
}

export function requireChamberRole(allowedRoles) {
  return (req, res, next) => {
    if (!req.chamberMembership) {
      return res.status(500).json({
        success: false,
        message: "Chamber membership check is missing",
      });
    }

    if (!allowedRoles.includes(req.chamberMembership.role)) {
      return res.status(403).json({
        success: false,
        message: "You do not have permission to perform this action",
      });
    }

    next();
  };
}