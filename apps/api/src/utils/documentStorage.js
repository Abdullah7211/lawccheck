
import path from "node:path";
import { fileURLToPath } from "node:url";
import { randomUUID } from "node:crypto";
import { mkdir, writeFile, unlink } from "node:fs/promises";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PRIVATE_UPLOAD_DIR = path.resolve(
  __dirname,
  "../../private_uploads"
);

// Save a validated document using a generated storage key
export async function saveDocumentFile(file, detectedFileType) {
  if (!file?.buffer || !detectedFileType?.extension) {
    throw new Error("Invalid document file");
  }

  await mkdir(PRIVATE_UPLOAD_DIR, { recursive: true });

  const storageKey = `${randomUUID()}.${detectedFileType.extension}`;

  const filePath = path.join(PRIVATE_UPLOAD_DIR, storageKey);

  await writeFile(filePath, file.buffer, {
    flag: "wx",
    mode: 0o600,
  });

  return {
    storageKey,
    filePath,
  };
}

// Resolve a storage key without allowing directory traversal
export function getDocumentFilePath(storageKey) {
  if (
    typeof storageKey !== "string" ||
    !/^[0-9a-f-]{36}\.(pdf|png|jpg)$/i.test(storageKey)
  ) {
    throw new Error("Invalid document storage key");
  }

  return path.join(PRIVATE_UPLOAD_DIR, storageKey);
}

// Delete a document from private storage
export async function deleteDocumentFile(storageKey) {
  const filePath = getDocumentFilePath(storageKey);

  try {
    await unlink(filePath);
  } catch (error) {
    if (error.code !== "ENOENT") {
      throw error;
    }
  }
}
