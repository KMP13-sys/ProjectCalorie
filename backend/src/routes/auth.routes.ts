// src/routes/auth.routes.ts
// Routes สำหรับระบบ Authentication (ผู้ใช้และ admin)

import { Router } from "express";
import { 
  register, 
  registerAdmin, 
  login, 
  refreshToken, 
  logout, 
  deleteOwnAccount 
} from "../controllers/auth.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

// =======================
// Public routes
// =======================
router.post("/register", register);          // สมัครสมาชิกทั่วไป
router.post("/register-admin", registerAdmin); // สมัคร admin
router.post("/login", login);                // เข้าสู่ระบบ
router.post("/refresh", refreshToken);       // รีเฟรช access token

// =======================
// Protected routes (ต้องมี token)
// =======================
router.post("/logout", validateToken, logout);            // ออกจากระบบ
router.delete("/delete-account", validateToken, deleteOwnAccount); // ลบบัญชีตัวเอง

export default router;
