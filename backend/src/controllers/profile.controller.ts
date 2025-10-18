import { Request, Response } from "express";
import { getUserById, updateUserById } from "../models/userModel";
import db from "../config/db";
import path from "path";
import multer from "multer";
import fs from "fs";

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

// ✅ เพิ่มการตรวจสอบประเภทไฟล์
const fileFilter = (req: any, file: Express.Multer.File, cb: multer.FileFilterCallback) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (extname && mimetype) {
    cb(null, true);
  } else {
    cb(new Error("Only image files (JPEG, JPG, PNG, GIF, WebP) are allowed!"));
  }
};

export const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // จำกัดขนาดไฟล์ 5MB
  },
});

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

// ✅ Function สำหรับลบไฟล์เก่า
const deleteOldImage = (imageName: string) => {
  const imagePath = path.join(__dirname, "../uploads", imageName);
  
  if (fs.existsSync(imagePath)) {
    try {
      fs.unlinkSync(imagePath);
      console.log(`Deleted old image: ${imageName}`);
    } catch (error) {
      console.error(`Error deleting old image: ${imageName}`, error);
    }
  }
};

// PUT: อัปเดทรูปโปรไฟล์
export const updateProfileImage = async (req: Request, res: Response) => {
  try {
    const userId = Number(req.params.id);
    const authenticatedUserId = (req as any).user.userId;

    // ตรวจสอบสิทธิ์
    if (userId !== authenticatedUserId) {
      return res.status(403).json({ message: "Forbidden" });
    }

    if (!userId) {
      return res.status(400).json({ message: "Invalid user id" });
    }

    if (!req.file) {
      return res.status(400).json({ message: "No image uploaded" });
    }

    // ✅ ดึงข้อมูลผู้ใช้เพื่อเช็ครูปเก่า
    const user = await getUserById(userId);
    
    if (!user) {
      // ลบไฟล์ที่อัปโหลดมาใหม่ถ้าไม่เจอ user
      deleteOldImage(req.file.filename);
      return res.status(404).json({ message: "User not found" });
    }

    // ✅ ลบรูปเก่าถ้ามี
    if (user.image_profile) {
      deleteOldImage(user.image_profile);
    }

    const imageName = req.file.filename;

    // อัปเดทฐานข้อมูล
    await db.query("UPDATE users SET image_profile = ? WHERE user_id = ?", [imageName, userId]);

    res.json({
      message: "Profile image updated successfully",
      image_url: `${req.protocol}://${req.get("host")}/uploads/${imageName}`,
    });
  } catch (error) {
    console.error("Error updating profile image:", error);
    
    // ลบไฟล์ที่อัปโหลดมาใหม่ถ้าเกิด error
    if (req.file) {
      deleteOldImage(req.file.filename);
    }
    
    res.status(500).json({ message: "Server error" });
  }
};