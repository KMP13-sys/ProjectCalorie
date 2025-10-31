import express from "express";
import { deleteUserByAdmin, getAllUsersByAdmin, getAllFoodsByAdmin, updateFoodByAdmin } from "../controllers/admin.controller";
import { validateToken } from "../middlewares/validateToken";

const router = express.Router();

// ลบผู้ใช้โดยแอดมิน
router.delete("/delete-user/:id", validateToken, deleteUserByAdmin);

// ดึงผู้ใช้ทั้งหมด (ไม่เอารูป/พาสเวิด)
router.get("/users", validateToken, getAllUsersByAdmin);

// ดึงข้อมูลอาหารทั้งหมด (สำหรับแอดมิน)
router.get("/foods", validateToken, getAllFoodsByAdmin);

// แก้ไขข้อมูลอาหาร (สำหรับแอดมิน)
router.put("/foods/:id", validateToken, updateFoodByAdmin);

export default router;
