import express from "express";
import { deleteUserByAdmin, getAllUsersByAdmin, getAllFoodsByAdmin, updateFoodByAdmin } from "../controllers/admin.controller";
import { validateToken } from "../middlewares/validateToken";

const router = express.Router();

// ========== USER MANAGEMENT ==========
// ดึงผู้ใช้ทั้งหมด (ไม่เอารูป/พาสเวิด)
router.get("/users", validateToken, getAllUsersByAdmin);

// ลบผู้ใช้โดยแอดมิน
router.delete("/users/:id", validateToken, deleteUserByAdmin);

// ========== FOOD MANAGEMENT ==========
// ดึงข้อมูลอาหารทั้งหมด (สำหรับแอดมิน)
router.get("/foods", validateToken, getAllFoodsByAdmin);

// แก้ไขข้อมูลอาหาร (สำหรับแอดมิน)
router.put("/foods/:id", validateToken, updateFoodByAdmin);

export default router;
