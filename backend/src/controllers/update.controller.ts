import { Request, Response } from "express";
import { getUserById, updateUserById } from "../models/userModel";

// ==============================
// อัปเดตข้อมูลผู้ใช้
// ==============================
export const updateUser = async (req: Request, res: Response) => {
  try {
    const userId = parseInt(req.params.id);
    if (isNaN(userId)) return res.status(400).json({ message: "Invalid user ID" });

    // ตรวจสอบว่าผู้ใช้มีอยู่ในระบบ
    const existingUser = await getUserById(userId);
    if (!existingUser) return res.status(404).json({ message: "User not found" });

    // รับข้อมูลที่จะอัปเดตจาก request body
    const { age, gender, height, weight, goal } = req.body;

    // อัปเดตข้อมูลผู้ใช้ในฐานข้อมูล
    const updatedUser = await updateUserById(userId, { age, gender, height, weight, goal });

    // ส่ง response กลับ
    return res.status(200).json({
      message: "User updated successfully",
      user: updatedUser,
    });
  } catch (error) {
    // จัดการ error และส่ง response ทั่วไป
    console.error("Error updating user:", error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
};
