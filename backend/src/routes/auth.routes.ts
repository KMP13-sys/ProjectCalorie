// src/routes/auth.routes.ts
import { Router } from "express";
import { register, registerAdmin, login, refreshToken, logout, deleteOwnAccount } from "../controllers/auth.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

router.post("/register", register);
router.post("/register-admin", registerAdmin); // ✅ เพิ่ม route สำหรับ admin
router.post("/login", login);
router.post("/refresh", refreshToken);
router.post("/logout", validateToken, logout);
router.delete("/delete-account", validateToken, deleteOwnAccount);

export default router;