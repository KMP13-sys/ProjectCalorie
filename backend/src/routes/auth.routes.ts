// src/routes/auth.routes.ts
import { Router } from "express";
import { register, login, refreshToken, logout, deleteOwnAccount } from "../controllers/auth.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

router.post("/register", register);
router.post("/login", login);
router.post("/refresh", refreshToken);
router.post("/logout", validateToken, logout);  // ✅ เพิ่ม route นี้
router.delete("/delete-account", validateToken, deleteOwnAccount);

export default router;