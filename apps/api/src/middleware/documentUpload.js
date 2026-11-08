
import multer from "multer";
import { fileTypeFromBuffer } from "file-type";

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10 MB

const allowedMimeTypes = {
  "application/pdf": "pdf",
  "image/png": "png",
  "image/jpeg": "jpg",
};

const upload = multer({
  storage: multer.memoryStorage(),

  limits: {
    fileSize: MAX_FILE_SIZE,
    files: 1,
  },
});

// Receive one file using the multipart field name "file"
export function receiveDocumentUpload(req, res, next) {
  upload.single("file")(req, res, (error) => {
    if (!error) {
      return next();
    }

    if (error instanceof multer.MulterError) {
      if (error.code === "LIMIT_FILE_SIZE") {
        return res.status(413).json({
          success: false,
          message: "File size must not exceed 10 MB",
        });
      }

      if (error.code === "LIMIT_FILE_COUNT") {
        return res.status(400).json({
          success: false,
          message: "Only one file can be uploaded at a time",
        });
      }

      if (error.code === "LIMIT_UNEXPECTED_FILE") {
        return res.status(400).json({
          success: false,
          message: 'Use the file field name "file"',
        });
      }
    }

    console.error("Document upload error:", error);

    return res.status(400).json({
      success: false,
      message: "Unable to receive uploaded file",
    });
  });
}

// Verify the actual file signature before saving it
export async function validateDocumentFile(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "A document file is required",
      });
    }

    const detectedType = await fileTypeFromBuffer(req.file.buffer);

    if (
      !detectedType ||
      !Object.prototype.hasOwnProperty.call(
        allowedMimeTypes,
        detectedType.mime
      )
    ) {
      return res.status(400).json({
        success: false,
        message: "Only PDF, PNG, and JPEG files are allowed",
      });
    }

    req.detectedFileType = {
      mimeType: detectedType.mime,
      extension: allowedMimeTypes[detectedType.mime],
    };

    next();
  } catch (error) {
    console.error("Document validation error:", error);

    return res.status(400).json({
      success: false,
      message: "Unable to validate the uploaded document",
    });
  }
}
