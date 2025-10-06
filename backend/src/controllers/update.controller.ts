import { Request, Response } from "express";
import db from "../config/db";
import bcrypt from "bcrypt";

export const updateUserProfile = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const userId = Number(id);

    if (!userId) {
      return res.status(400).json({ message: "Invalid user id" });
    }

    console.log("Update request for user_id:", userId);

    // ตรวจสอบว่าผู้ใช้มีอยู่จริง
    const [rows]: any = await db.query("SELECT * FROM users WHERE user_id = ?", [userId]);
    console.log("Query result:", rows);

    if (!rows || rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    const user = rows[0];

    // เข้ารหัสรหัสผ่านใหม่ถ้ามีการเปลี่ยน
    let hashedPassword = user.password;
    if (req.body.password) {
      hashedPassword = await bcrypt.hash(req.body.password, 10);
    }

    // อัปเดตข้อมูล
    await db.query(
      `UPDATE users 
       SET username = ?, email = ?, phone_number = ?, password = ?, 
           age = ?, gender = ?, height = ?, weight = ?, goal = ?
       WHERE user_id = ?`,
      [
        req.body.username || user.username,
        req.body.email || user.email,
        req.body.phone_number || user.phone_number,
        hashedPassword,
        req.body.age || user.age,
        req.body.gender || user.gender,
        req.body.height || user.height,
        req.body.weight || user.weight,
        req.body.goal || user.goal,
        userId,
      ]
    );

    res.json({ message: "Profile updated successfully" });
  } catch (err) {
    console.error("Error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};
