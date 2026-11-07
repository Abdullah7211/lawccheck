import express from "express";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    message: "Welcome to LawCCheck API",
    status: "running"
  });
});

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "LawCCheck backend is healthy"
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`LawCCheck API running on port ${PORT}`);
});