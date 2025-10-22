import { Request, Response } from "express";
import db from "../config/db";

// === DELETE USER by ADMIN ===
export const deleteUserByAdmin = async (req: Request, res: Response) => {
  try {
    const adminRole = (req as any).user?.role;
    if (adminRole !== "admin") {
      return res.status(403).json({ message: "Forbidden: Admin only" });
    }

    const { id } = req.params;

    // ตรวจสอบว่าผู้ใช้มีอยู่จริงไหม
    const [rows]: any = await db.query("SELECT * FROM users WHERE user_id = ?", [id]);
    if (rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    // ลบผู้ใช้
    await db.query("DELETE FROM users WHERE user_id = ?", [id]);

    res.json({ message: "User deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};
