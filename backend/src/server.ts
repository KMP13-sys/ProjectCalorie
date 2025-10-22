import dotenv from "dotenv";
dotenv.config();

import path from "path";
import express from "express";
import cors from "cors";

// import routes
import authRoutes from "./routes/auth.routes";
import userRoutes from "./routes/profile.routes";
import updateRoutes from "./routes/update.routes";
import profileRoutes from "./routes/profile.routes";
import dailyRoutes from "./routes/daily.routes";
import adminRoutes from "./routes/admin.routes";

const app = express();
app.use(cors());
app.use(express.json());

// ====== Middlewares ======
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// เสิร์ฟไฟล์ static สำหรับรูปที่อัปโหลด
app.use("/uploads", express.static("src/uploads"));

app.use(express.urlencoded({ extended: true }));

// ====== Routes ======
app.use("/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/update", updateRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/daily", dailyRoutes);
app.use("/daily", dailyRoutes);
app.use("/api/admin", adminRoutes);

// ====== Root test route ======
app.get("/", (req, res) => {
  res.send("Server is running...");
});

// ====== Server Start ======
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
