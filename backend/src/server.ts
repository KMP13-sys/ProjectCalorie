import dotenv from "dotenv";
dotenv.config();

import path from "path";
import express from "express";
import cors from "cors";

// import routes
import authRoutes from "./routes/auth.routes";
import userRoutes from "./routes/profile.routes";
import updateRoutes from "./routes/update.routes";

const app = express();

// ====== Middlewares ======
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// ====== Routes ======
app.use("/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/update", updateRoutes);
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

// ====== Root test route ======
app.get("/", (req, res) => {
  res.send("Server is running...");
});

// ====== Server Start ======
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
