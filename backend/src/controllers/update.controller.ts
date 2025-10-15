import { Request, Response } from "express";
import { getUserById, updateUserById } from "../models/userModel";

// อัปเดตข้อมูลผู้ใช้
export const updateUser = async (req: Request, res: Response) => {
  try {
    const userId = parseInt(req.params.id);

    if (isNaN(userId)) {
      return res.status(400).json({ message: "Invalid user ID" });
    }

    const existingUser = await getUserById(userId);
    if (!existingUser) {
      return res.status(404).json({ message: "User not found" });
    }

    // รับข้อมูลที่จะอัปเดตจาก body
    const {
      age,
      gender,
      height,
      weight,
      goal
    } = req.body;

    const updatedUser = await updateUserById(userId, {
      age,
      gender,
      height,
      weight,
      goal,
    });

    return res.status(200).json({
      message: "User updated successfully",
      user: updatedUser,
    });
  } catch (error) {
    console.error("Error updating user:", error);
    return res.status(500).json({ message: "Internal Server Error" });
  }
};
