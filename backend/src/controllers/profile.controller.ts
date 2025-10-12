import { Request, Response } from "express";
import { getUserById, updateUserById } from "../models/userModel";

// GET /api/users/:id → ดึงข้อมูลโปรไฟล์ผู้ใช้
export const getUserProfile = async (req: Request, res: Response) => {
  try {
    const userId = Number(req.params.id);
    if (!userId) return res.status(400).json({ message: "Invalid user id" });

    const user = await getUserById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // ไม่ส่ง password กลับไป
    const { password, ...userData } = user;
    res.json(userData);
  } catch (error) {
    console.error("Error fetching profile:", error);
    res.status(500).json({ message: "Server error" });
  }
};