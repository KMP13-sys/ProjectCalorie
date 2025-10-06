import dotenv from "dotenv";
dotenv.config(); // โหลดไฟล์ .env ก่อนใช้งานทุกตัว

import express from "express";
import cors from "cors";

// import routes
import authRoutes from "./routes/auth.routes";
import userRoutes from "./routes/profile.routes";
import profileRoutes from "./routes/profile.routes";

const app = express();

// ====== Middlewares ======
// CORS *ต้องอยู่ก่อน middleware อื่นๆ*
app.use(cors({
  origin: '*', // อนุญาตทุก origin (สำหรับ development)
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// JSON body parser
app.use(express.json());

// ====== Routes ======
app.use("/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api", profileRoutes);

// route root สำหรับทดสอบ
app.get("/", (req, res) => {
  res.send("Calorie Server is running...");
});

// ====== Server Start ======
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
