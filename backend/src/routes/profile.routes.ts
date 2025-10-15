import { Router } from "express";
import { getUserProfile, updateProfileImage, upload } from "../controllers/profile.controller";
import { validateToken } from "../middlewares/validateToken";

const router = Router();

// ดึงโปรไฟล์
router.get("/:id", validateToken, getUserProfile);

// อัปเดทรูปโปรไฟล์
router.put("/:id/image", validateToken, upload.single("profile_image"), updateProfileImage);

export default router;
