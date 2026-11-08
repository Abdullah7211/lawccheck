
import { Router } from "express";
import { z } from "zod";
import path from "node:path";

import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

import {
  receiveDocumentUpload,
  validateDocumentFile,
} from "../middleware/documentUpload.js";

import {
  saveDocumentFile,
  deleteDocumentFile,
  getDocumentFilePath,
} from "../utils/documentStorage.js";

const router = Router();

const createDocumentSchema = z.object({
  title: z.string().trim().min(2).max(200),

  category: z.enum([
    "PLEADING",
    "EVIDENCE",
    "AGREEMENT",
    "COURT_ORDER",
    "CORRESPONDENCE",
    "OTHER",
  ]).optional(),

  description: z.string().trim().max(5000).optional(),

  caseId: z.preprocess(
    (value) => value === "" ? undefined : value,
    z.string().uuid().optional()
  ),
});

// Convert BigInt into a JSON-safe string
function serializeDocument(document) {
  return {
    ...document,
    fileSize: document.fileSize.toString(),
  };
}

// UPLOAD DOCUMENT
router.post(
  "/:chamberId/documents",
  requireAuth,
  requireChamberMember,
  receiveDocumentUpload,
  validateDocumentFile,
  async (req, res) => {
    let savedStorageKey = null;

    try {
      const validation = createDocumentSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid document information",
          errors: validation.error.flatten(),
        });
      }

      const data = validation.data;

      // Verify that the linked case belongs to this chamber
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

      // Save the validated file privately
      const savedFile = await saveDocumentFile(
        req.file,
        req.detectedFileType
      );

      savedStorageKey = savedFile.storageKey;

      // Sanitize the original filename for display
      const fileName = path
        .basename(req.file.originalname)
        .replace(/[\u0000-\u001f\u007f]/g, "")
        .trim()
        .slice(0, 255) ||
        `document.${req.detectedFileType.extension}`;

      // Save document metadata in PostgreSQL
      const document = await prisma.document.create({
        data: {
          chamberId: req.chamber.id,
          caseId: data.caseId,
          title: data.title,
          fileName,
          storageKey: savedFile.storageKey,
          mimeType: req.detectedFileType.mimeType,
          fileSize: BigInt(req.file.size),
          category: data.category || "OTHER",
          description: data.description,
          uploadedById: req.user.id,
        },
        include: {
          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
            },
          },
          uploadedBy: {
            select: {
              id: true,
              name: true,
            },
          },
        },
      });

      return res.status(201).json({
        success: true,
        message: "Document uploaded successfully",
        document: serializeDocument(document),
      });
    } catch (error) {
      console.error("Document upload error:", error);

      // Remove the physical file if database saving failed
      if (savedStorageKey) {
        try {
          await deleteDocumentFile(savedStorageKey);
        } catch (cleanupError) {
          console.error("Document cleanup error:", cleanupError);
        }
      }

      return res.status(500).json({
        success: false,
        message: "Unable to upload document",
      });
    }
  }
);


const listDocumentsQuerySchema = z.object({
  caseId: z.string().uuid().optional(),

  category: z.enum([
    "PLEADING",
    "EVIDENCE",
    "AGREEMENT",
    "COURT_ORDER",
    "CORRESPONDENCE",
    "OTHER",
  ]).optional(),

  page: z.coerce.number().int().min(1).default(1),

  limit: z.coerce.number().int().min(1).max(100).default(20),
});

// LIST DOCUMENTS
router.get(
  "/:chamberId/documents",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const validation = listDocumentsQuerySchema.safeParse(req.query);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid document filters",
          errors: validation.error.flatten(),
        });
      }

      const { caseId, category, page, limit } = validation.data;

      const where = {
        chamberId: req.chamber.id,
        ...(caseId && { caseId }),
        ...(category && { category }),
      };

      const skip = (page - 1) * limit;

      const [documents, total] = await Promise.all([
        prisma.document.findMany({
          where,
          skip,
          take: limit,
          orderBy: {
            createdAt: "desc",
          },
          select: {
            id: true,
            caseId: true,
            title: true,
            fileName: true,
            mimeType: true,
            fileSize: true,
            category: true,
            description: true,
            createdAt: true,
            updatedAt: true,

            case: {
              select: {
                id: true,
                caseNumber: true,
                title: true,
              },
            },

            uploadedBy: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        }),

        prisma.document.count({ where }),
      ]);

      return res.json({
        success: true,
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        documents: documents.map(serializeDocument),
      });
    } catch (error) {
      console.error("List documents error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to retrieve documents",
      });
    }
  }
);


// GET SINGLE DOCUMENT
router.get(
  "/:chamberId/documents/:documentId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { documentId } = req.params;

      const document = await prisma.document.findFirst({
        where: {
          id: documentId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
          caseId: true,
          title: true,
          fileName: true,
          mimeType: true,
          fileSize: true,
          category: true,
          description: true,
          createdAt: true,
          updatedAt: true,

          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
            },
          },

          uploadedBy: {
            select: {
              id: true,
              name: true,
            },
          },
        },
      });

      if (!document) {
        return res.status(404).json({
          success: false,
          message: "Document not found in this chamber",
        });
      }

      return res.json({
        success: true,
        document: serializeDocument(document),
      });
    } catch (error) {
      console.error("Get document error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to retrieve document",
      });
    }
  }
);


const updateDocumentSchema = createDocumentSchema
  .partial()
  .refine((data) => Object.keys(data).length > 0, {
    message: "At least one field is required",
  });

// UPDATE DOCUMENT DETAILS
router.patch(
  "/:chamberId/documents/:documentId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { documentId } = req.params;

      const validation = updateDocumentSchema.safeParse(req.body);

      if (!validation.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid document information",
          errors: validation.error.flatten(),
        });
      }

      const existingDocument = await prisma.document.findFirst({
        where: {
          id: documentId,
          chamberId: req.chamber.id,
        },
      });

      if (!existingDocument) {
        return res.status(404).json({
          success: false,
          message: "Document not found in this chamber",
        });
      }

      const data = validation.data;

      // Verify the new case belongs to this chamber
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

      const document = await prisma.document.update({
        where: {
          id: existingDocument.id,
        },
        data,
        select: {
          id: true,
          caseId: true,
          title: true,
          fileName: true,
          mimeType: true,
          fileSize: true,
          category: true,
          description: true,
          createdAt: true,
          updatedAt: true,

          case: {
            select: {
              id: true,
              caseNumber: true,
              title: true,
            },
          },

          uploadedBy: {
            select: {
              id: true,
              name: true,
            },
          },
        },
      });

      return res.json({
        success: true,
        message: "Document details updated successfully",
        document: serializeDocument(document),
      });
    } catch (error) {
      console.error("Update document error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to update document details",
      });
    }
  }
);


 // DOWNLOAD DOCUMENT
router.get(
  "/:chamberId/documents/:documentId/download",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { documentId } = req.params;

      const document = await prisma.document.findFirst({
        where: {
          id: documentId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
          storageKey: true,
          fileName: true,
          mimeType: true,
        },
      });

      if (!document) {
        return res.status(404).json({
          success: false,
          message: "Document not found in this chamber",
        });
      }

      const filePath = getDocumentFilePath(document.storageKey);

      res.setHeader("Cache-Control", "private, no-store");
      res.setHeader("X-Content-Type-Options", "nosniff");

      res.download(
        filePath,
        document.fileName,
        {
          headers: {
            "Content-Type": document.mimeType,
          },
        },
        (error) => {
          if (error) {
            console.error("Document download error:", error);

            if (!res.headersSent) {
              res.status(error.code === "ENOENT" ? 404 : 500).json({
                success: false,
                message: error.code === "ENOENT"
                  ? "Document file is missing from storage"
                  : "Unable to download document",
              });
            }
          }
        }
      );
    } catch (error) {
      console.error("Download document error:", error);

      if (!res.headersSent) {
        return res.status(500).json({
          success: false,
          message: "Unable to download document",
        });
      }
    }
  }
);


 // DELETE DOCUMENT
router.delete(
  "/:chamberId/documents/:documentId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const { documentId } = req.params;

      const existingDocument = await prisma.document.findFirst({
        where: {
          id: documentId,
          chamberId: req.chamber.id,
        },
        select: {
          id: true,
          storageKey: true,
        },
      });

      if (!existingDocument) {
        return res.status(404).json({
          success: false,
          message: "Document not found in this chamber",
        });
      }

      // Delete the database record first
      await prisma.document.delete({
        where: {
          id: existingDocument.id,
        },
      });

      // Then remove the physical file
      try {
        await deleteDocumentFile(existingDocument.storageKey);
      } catch (fileError) {
        // The database record is already deleted.
        // Log the orphaned file for later cleanup.
        console.error(
          "Document file cleanup failed:",
          existingDocument.storageKey,
          fileError
        );

        return res.json({
          success: true,
          message: "Document record deleted, but its stored file requires cleanup",
        });
      }

      return res.json({
        success: true,
        message: "Document deleted successfully",
      });
    } catch (error) {
      console.error("Delete document error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to delete document",
      });
    }
  }
);


export default router;
