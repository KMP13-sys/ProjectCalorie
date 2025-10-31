import express from "express";
import { deleteUserByAdmin, getAllUsers } from "../controllers/admin.controller";
import { validateToken } from "../middlewares/validateToken";

const router = express.Router();

// ลบผู้ใช้โดยแอดมิน
router.delete("/delete-user/:id", validateToken, deleteUserByAdmin);

// ดึงผู้ใช้ทั้งหมด (ไม่เอารูป/พาสเวิด)
router.get("/users", validateToken, getAllUsers);

export default router;
