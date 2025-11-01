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
  console.log('[File Filter] Original filename:', file.originalname);
  console.log('[File Filter] Mimetype:', file.mimetype);
  console.log('[File Filter] Extension:', path.extname(file.originalname).toLowerCase());

  // รองรับ mimetype ทั้งแบบ image/jpeg และ image/jpg
  const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp'
  ];

  const allowedExtensions = /\.(jpg|jpeg|png|gif|webp)$/i;

  const hasValidExtension = allowedExtensions.test(file.originalname);
  const hasValidMimetype = allowedMimeTypes.includes(file.mimetype.toLowerCase());

  console.log('[File Filter] Has valid extension:', hasValidExtension);
  console.log('[File Filter] Has valid mimetype:', hasValidMimetype);

  if (hasValidExtension && hasValidMimetype) {
    console.log('[File Filter] ✅ File accepted');
    cb(null, true);
  } else {
    console.error('[File Filter] ❌ File rejected');
    console.error('[File Filter] Received mimetype:', file.mimetype);
    console.error('[File Filter] Received extension:', path.extname(file.originalname));
    cb(new Error(`Invalid file type. Received: ${file.mimetype}`));
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

    // ไม่ส่ง password, refresh_token, และ refresh_token_expires_at กลับไป
    const { password, refresh_token, refresh_token_expires_at, ...userData } = user;

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

// Function สำหรับลบไฟล์เก่า
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
    const authenticatedUserId = (req as any).user?.id; // ✅ เปลี่ยนจาก userId เป็น id

    console.log('[Update Profile Image] ============ START ============');
    console.log('[Update Profile Image] Request params.id:', req.params.id);
    console.log('[Update Profile Image] Parsed userId:', userId);
    console.log('[Update Profile Image] Authenticated user object:', (req as any).user);
    console.log('[Update Profile Image] Authenticated user ID:', authenticatedUserId);
    console.log('[Update Profile Image] Uploaded file:', req.file?.filename);
    console.log('[Update Profile Image] File size:', req.file?.size);
    console.log('[Update Profile Image] File mimetype:', req.file?.mimetype);

    // ตรวจสอบว่ามี user object หรือไม่
    if (!authenticatedUserId) {
      console.error('[Update Profile Image] ERROR: No authenticated user ID found');
      return res.status(401).json({ message: "Authentication failed - no user ID" });
    }

    // ตรวจสอบสิทธิ์
    if (userId !== authenticatedUserId) {
      console.error('[Update Profile Image] ERROR: Permission denied');
      console.error('[Update Profile Image] Expected userId:', userId);
      console.error('[Update Profile Image] Got authenticatedUserId:', authenticatedUserId);
      return res.status(403).json({ message: "Forbidden - you can only update your own profile" });
    }

    if (!userId || isNaN(userId)) {
      console.error('[Update Profile Image] ERROR: Invalid user ID');
      return res.status(400).json({ message: "Invalid user id" });
    }

    if (!req.file) {
      console.error('[Update Profile Image] ERROR: No file uploaded');
      return res.status(400).json({ message: "No image uploaded" });
    }

    // ดึงข้อมูลผู้ใช้เพื่อเช็ครูปเก่า
    const user = await getUserById(userId);

    if (!user) {
      // ลบไฟล์ที่อัปโหลดมาใหม่ถ้าไม่เจอ user
      deleteOldImage(req.file.filename);
      return res.status(404).json({ message: "User not found" });
    }

    console.log('[Update Profile Image] Old image:', user.image_profile);

    // ลบรูปเก่าถ้ามี
    if (user.image_profile) {
      console.log('[Update Profile Image] Deleting old image:', user.image_profile);
      deleteOldImage(user.image_profile);
    }

    const imageName = req.file.filename;
    console.log('[Update Profile Image] New image:', imageName);

    // อัปเดทฐานข้อมูล
    await db.query("UPDATE users SET image_profile = ? WHERE user_id = ?", [imageName, userId]);

    console.log('[Update Profile Image] Success!');

    res.json({
      message: "Profile image updated successfully",
      image_url: `${req.protocol}://${req.get("host")}/uploads/${imageName}`,
    });
  } catch (error) {
    console.error("[Update Profile Image] ============ ERROR ============");
    console.error("[Update Profile Image] Error type:", error instanceof Error ? error.constructor.name : typeof error);
    console.error("[Update Profile Image] Error message:", error instanceof Error ? error.message : String(error));
    console.error("[Update Profile Image] Error stack:", error instanceof Error ? error.stack : 'No stack trace');
    console.error("[Update Profile Image] Full error object:", error);

    // ลบไฟล์ที่อัปโหลดมาใหม่ถ้าเกิด error
    if (req.file) {
      console.log("[Update Profile Image] Cleaning up uploaded file:", req.file.filename);
      deleteOldImage(req.file.filename);
    }

    // ส่ง error message ที่ละเอียดกลับไปให้ client (เฉพาะ development)
    const isDevelopment = process.env.NODE_ENV !== 'production';
    const errorMessage = error instanceof Error ? error.message : 'Server error';

    res.status(500).json({
      message: isDevelopment ? `Server error: ${errorMessage}` : "Server error",
      ...(isDevelopment && { error: String(error) })
    });
  }
};