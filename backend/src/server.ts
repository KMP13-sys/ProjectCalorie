import express from "express";
import cors from "cors"; // เพิ่มบรรทัดนี้
import authRoutes from "./routes/auth.routes";

const app = express();

// เพิ่ม CORS (ต้องอยู่ก่อน middleware อื่นๆ)
app.use(cors({
  origin: '*', // อนุญาตทุก origin (สำหรับ development)
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// route สำหรับ auth
app.use("/auth", authRoutes);

// route root สำหรับทดสอบ
app.get("/", (req, res) => {
  res.send("Tent Server is running...");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});