import express from "express";
import cors from "cors";
import dotenv from "dotenv";

// routes
import authRoutes from "./routes/auth.routes";
import profileRoutes from "./routes/profile.routes";

// โหลด environment variables (.env)
dotenv.config();

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
app.use("/profile", profileRoutes);

// route root สำหรับทดสอบ
app.get("/", (req, res) => {
  res.send("Calorie Server is running...");
});

// ====== Server Start ======
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
