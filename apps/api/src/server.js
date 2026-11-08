import express from "express";
import cors from "cors";

import { prisma } from "./prisma.js";
import authRoutes from "./routes/auth.js";
import chamberRoutes from "./routes/chambers.js";
import clientRoutes from "./routes/clients.js";
import caseRoutes from "./routes/cases.js";
import hearingRoutes from "./routes/hearings.js";
import taskRoutes from "./routes/tasks.js";
import reminderRoutes from "./routes/reminders.js";
import documentRoutes from "./routes/documents.js";
import noteRoutes from "./routes/notes.js";
import expenseRoutes from "./routes/expenses.js";
import paymentRoutes from "./routes/payments.js";
import notificationRoutes from "./routes/notifications.js";
import dashboardRoutes from "./routes/dashboard.js";

const app = express();

app.use(cors());
app.use(express.json({ limit: "1mb" }));

app.get("/", (req, res) => {
  res.json({
    message: "Welcome to LawCCheck API",
    status: "running",
  });
});

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "LawCCheck backend is healthy",
  });
});

// Database connection check
app.get("/api/db-check", async (req, res) => {
  try {
    const userCount = await prisma.user.count();

    res.json({
      success: true,
      message: "Database connection successful",
      database: "lawccheck_db",
      totalUsers: userCount,
    });
  } catch (error) {
    console.error("Database connection error:", error);

    res.status(500).json({
      success: false,
      message: "Database connection failed",
    });
  }
});

// Authentication routes
app.use("/api/auth", authRoutes);
app.use("/api/chambers", chamberRoutes);
app.use("/api/chambers", clientRoutes);
app.use("/api/chambers", caseRoutes);
app.use("/api/chambers", hearingRoutes);
app.use("/api/chambers", taskRoutes);
app.use("/api/chambers", reminderRoutes);
app.use("/api/chambers", documentRoutes);
app.use("/api/chambers", noteRoutes);
app.use("/api/chambers", expenseRoutes);
app.use("/api/chambers", paymentRoutes);
app.use("/api/chambers", notificationRoutes);
app.use("/api/chambers", dashboardRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`LawCCheck API running on port ${PORT}`);
});