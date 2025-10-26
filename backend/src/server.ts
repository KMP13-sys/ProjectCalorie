import dotenv from "dotenv";
dotenv.config();

import express from "express";
import cors from "cors";

// Import routes
import authRoutes from "./routes/auth.routes";
import profileRoutes from "./routes/profile.routes";
import updateRoutes from "./routes/update.routes";
import dailyRoutes from "./routes/daily.routes";
import adminRoutes from "./routes/admin.routes";
import activityRoutes from "./routes/activity.routes";

const app = express();

// ====== Middlewares ======
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// เสิร์ฟไฟล์ static สำหรับรูปที่อัปโหลด
app.use("/uploads", express.static("src/uploads"));

// ====== Routes ======
app.use("/api/auth", authRoutes);        
app.use("/api/profile", profileRoutes);  
app.use("/api/update", updateRoutes);
app.use("/api/daily", dailyRoutes);      
app.use("/api/admin", adminRoutes);
app.use("/api/activity", activityRoutes);

// ====== Root test route ======
app.get("/", (req, res) => {
  res.send("Server is running...");
});

// ====== Error handling middleware ======
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ message: "Something went wrong!" });
});

// ====== Server Start ======
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});