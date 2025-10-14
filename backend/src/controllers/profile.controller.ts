import { Request, Response } from "express";
import { getUserById, updateUserById } from "../models/userModel";
import db from "../config/db";
import path from "path";
import multer from "multer";

// ตั้งค่า multer สำหรับอัปโหลดไฟล์
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "src/uploads/"); // ที่อยู่โฟลเดอร์เก็บรูป
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, `${uniqueSuffix}${ext}`);
  },
});

export const upload = multer({ storage });

// GET: ดึงข้อมูลโปรไฟล์ผู้ใช้
export const getUserProfile = async (req: Request, res: Response) => {
  try {
    const userId = Number(req.params.id);
    if (!userId) return res.status(400).json({ message: "Invalid user id" });

    const user = await getUserById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // ไม่ส่ง password กลับไป
    const { password, ...userData } = user;

    // เพิ่ม URL สำหรับรูปโปรไฟล์ (กรณีมี)
  if (user.image_profile) {
    (userData as any).image_profile_url = `${req.protocol}://${req.get("host")}/uploads/${user.image_profile}`;
  }

    res.json(userData);
  } catch (error) {
    console.error("Error fetching profile:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// PUT: อัปเดทรูปโปรไฟล์
export const updateProfileImage = async (req: Request, res: Response) => {
  try {
    const userId = Number(req.params.id);
    if (!userId) return res.status(400).json({ message: "Invalid user id" });

    if (!req.file) return res.status(400).json({ message: "No image uploaded" });

    const imageName = req.file.filename;

    // ✅ เปลี่ยนชื่อฟิลด์ตรงนี้ให้ตรงกับตาราง
    await db.query("UPDATE users SET image_profile = ? WHERE user_id = ?", [imageName, userId]);

    res.json({
      message: "Profile image updated successfully",
      image_url: `${req.protocol}://${req.get("host")}/uploads/${imageName}`,
    });
  } catch (error) {
    console.error("Error updating profile image:", error);
    res.status(500).json({ message: "Server error" });
  }
};

