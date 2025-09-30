import express from "express";
import authRoutes from "./routes/auth.routes";

const app = express();

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
