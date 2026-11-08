
import { Router } from "express";
import { z } from "zod";

import { prisma } from "../prisma.js";
import { requireAuth } from "../middleware/auth.js";
import { requireChamberMember } from "../middleware/chamber.js";

const router = Router();

const createNoteSchema = z.object({
  caseId: z.string().uuid(),
  content: z.string().trim().min(1).max(10000),
});

const updateNoteSchema = z.object({
  content: z.string().trim().min(1).max(10000),
}).partial().refine(
  (data) => Object.keys(data).length > 0,
  { message: "At least one field must be provided" }
);

const noteInclude = {
  author: {
    select: {
      id: true,
      name: true,
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

// CREATE NOTE
router.post(
  "/:chamberId/cases/:caseId/notes",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = createNoteSchema.safeParse({
        caseId: req.params.caseId,
        content: req.body.content,
      });

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid note data",
          errors: parsed.error.flatten(),
        });
      }

      const existingCase = await prisma.case.findFirst({
        where: {
          id: parsed.data.caseId,
          chamberId: req.chamber.id,
        },
        select: { id: true },
      });

      if (!existingCase) {
        return res.status(404).json({
          success: false,
          message: "Case not found in this chamber",
        });
      }

      const note = await prisma.caseNote.create({
        data: {
          chamberId: req.chamber.id,
          caseId: existingCase.id,
          authorId: req.user.id,
          content: parsed.data.content,
        },
        include: noteInclude,
      });

      return res.status(201).json({
        success: true,
        message: "Note created successfully",
        note,
      });
    } catch (error) {
      console.error("Create note error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to create note",
      });
    }
  }
);

// LIST NOTES FOR A CASE
router.get(
  "/:chamberId/cases/:caseId/notes",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const existingCase = await prisma.case.findFirst({
        where: {
          id: req.params.caseId,
          chamberId: req.chamber.id,
        },
        select: { id: true },
      });

      if (!existingCase) {
        return res.status(404).json({
          success: false,
          message: "Case not found in this chamber",
        });
      }

      const notes = await prisma.caseNote.findMany({
        where: {
          chamberId: req.chamber.id,
          caseId: existingCase.id,
        },
        include: noteInclude,
        orderBy: {
          createdAt: "desc",
        },
      });

      return res.json({
        success: true,
        total: notes.length,
        notes,
      });
    } catch (error) {
      console.error("List notes error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to retrieve notes",
      });
    }
  }
);

// GET SINGLE NOTE
router.get(
  "/:chamberId/notes/:noteId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const note = await prisma.caseNote.findFirst({
        where: {
          id: req.params.noteId,
          chamberId: req.chamber.id,
        },
        include: noteInclude,
      });

      if (!note) {
        return res.status(404).json({
          success: false,
          message: "Note not found in this chamber",
        });
      }

      return res.json({
        success: true,
        note,
      });
    } catch (error) {
      console.error("Get note error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to retrieve note",
      });
    }
  }
);

// UPDATE NOTE
router.patch(
  "/:chamberId/notes/:noteId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const parsed = updateNoteSchema.safeParse(req.body);

      if (!parsed.success) {
        return res.status(400).json({
          success: false,
          message: "Invalid note data",
          errors: parsed.error.flatten(),
        });
      }

      const existingNote = await prisma.caseNote.findFirst({
        where: {
          id: req.params.noteId,
          chamberId: req.chamber.id,
        },
        select: { id: true },
      });

      if (!existingNote) {
        return res.status(404).json({
          success: false,
          message: "Note not found in this chamber",
        });
      }

      const note = await prisma.caseNote.update({
        where: {
          id: existingNote.id,
        },
        data: parsed.data,
        include: noteInclude,
      });

      return res.json({
        success: true,
        message: "Note updated successfully",
        note,
      });
    } catch (error) {
      console.error("Update note error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to update note",
      });
    }
  }
);

// DELETE NOTE
router.delete(
  "/:chamberId/notes/:noteId",
  requireAuth,
  requireChamberMember,
  async (req, res) => {
    try {
      const existingNote = await prisma.caseNote.findFirst({
        where: {
          id: req.params.noteId,
          chamberId: req.chamber.id,
        },
        select: { id: true },
      });

      if (!existingNote) {
        return res.status(404).json({
          success: false,
          message: "Note not found in this chamber",
        });
      }

      await prisma.caseNote.delete({
        where: {
          id: existingNote.id,
        },
      });

      return res.json({
        success: true,
        message: "Note deleted successfully",
      });
    } catch (error) {
      console.error("Delete note error:", error);

      return res.status(500).json({
        success: false,
        message: "Unable to delete note",
      });
    }
  }
);

export default router;
