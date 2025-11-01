import { Request, Response } from "express";
import { getUserById } from "../models/userModel";
import db from "../config/db";
import path from "path";
import multer from "multer";
import fs from "fs";

// ==============================
// ตั้งค่า multer สำหรับอัปโหลดไฟล์
// ==============================
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "src/uploads/");
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, `${uniqueSuffix}${path.extname(file.originalname)}`);
  },
});

// ตรวจสอบชนิดไฟล์ (รองรับ image และ octet-stream จาก Flutter)
const fileFilter = (req: any, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const allowedExtensions = /\.(jpg|jpeg|png|gif|webp)$/i;
  const isValid = allowedExtensions.test(file.originalname);
  if (isValid) cb(null, true);
  else cb(new Error("Invalid file type. Only image files (jpg, jpeg, png, gif, webp) are allowed."));
};

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
});

// ==============================
// ดึงข้อมูลโปรไฟล์ผู้ใช้
// ==============================
export const getUserProfile = async (req: Request, res: Response) => {
  try {
    const userId = Number(req.params.id);
    if (!userId) return res.status(400).json({ message: "Invalid user id" });

    const user = await getUserById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // ไม่ส่ง password และ refresh_token กลับไป
    const { password, refresh_token, refresh_token_expires_at, ...userData } = user;

    if (user.image_profile) {
      (userData as any).image_profile_url = `${req.protocol}://${req.get("host")}/uploads/${user.image_profile}`;
    }

    res.json(userData);
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

// ==============================
// ฟังก์ชันลบไฟล์เก่า
// ==============================
const deleteOldImage = (imageName: string) => {
  const imagePath = path.join(__dirname, "../uploads", imageName);
  if (fs.existsSync(imagePath)) {
    try { fs.unlinkSync(imagePath); } catch {}
  }
};

// ==============================
// อัปเดทรูปโปรไฟล์
// ==============================
export const updateProfileImage = async (req: Request, res: Response) => {
  try {
    const userId = Number(req.params.id);
    const authenticatedUserId = (req as any).user?.id;

    if (!authenticatedUserId) return res.status(401).json({ message: "Authentication failed" });
    if (userId !== authenticatedUserId) return res.status(403).json({ message: "Forbidden" });
    if (!req.file) return res.status(400).json({ message: "No image uploaded" });

    const user = await getUserById(userId);
    if (!user) {
      deleteOldImage(req.file.filename);
      return res.status(404).json({ message: "User not found" });
    }

    // ลบรูปเก่าถ้ามี
    if (user.image_profile) deleteOldImage(user.image_profile);

    // อัปเดทฐานข้อมูล
    const imageName = req.file.filename;
    await db.query("UPDATE users SET image_profile = ? WHERE user_id = ?", [imageName, userId]);

    res.json({
      message: "Profile image updated successfully",
      image_url: `${req.protocol}://${req.get("host")}/uploads/${imageName}`,
    });
  } catch (error) {
    // ลบไฟล์ที่อัปโหลดมาใหม่ถ้าเกิด error
    if (req.file) deleteOldImage(req.file.filename);
    res.status(500).json({ message: "Server error" });
  }
};
