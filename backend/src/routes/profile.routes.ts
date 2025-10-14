import { Router } from "express";
import { getUserProfile, updateProfileImage, upload } from "../controllers/profile.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

// ดึงข้อมูลโปรไฟล์ผู้ใช้
router.get("/:id", validateToken, getUserProfile);

// อัปโหลด/อัปเดทรูปโปรไฟล์
router.put("/:id/image", validateToken, upload.single("profile_image"), updateProfileImage);

export default router;
