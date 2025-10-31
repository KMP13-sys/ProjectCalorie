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

// === GET ALL USERS (without image and password) ===
export const getAllUsersByAdmin = async (req: Request, res: Response) => {
  try {
    const role = (req as any).user?.role;
    if (role !== "admin") {
      return res.status(403).json({ message: "Admin only" });
    }

    // ดึงเฉพาะฟิลด์ที่อนุญาต (ไม่เอา password, image_profile)
    const [rows]: any = await db.query(`
      SELECT user_id, username, email, phone_number, age, gender, height, weight, goal, last_login_at
      FROM users
    `);

    res.json({ users: rows });
  } catch (err) {
    console.error("getAllUsers error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// === GET ALL FOODS (for Admin only) ===
export const getAllFoodsByAdmin = async (req: Request, res: Response) => {
  try {
    const role = (req as any).user?.role;
    if (role !== "admin") {
      return res.status(403).json({ message: "Forbidden: Admin only" });
    }

    const [foods]: any = await db.query(`
      SELECT food_id, food_name, protein_gram, fat_gram, carbohydrate_gram, calories
      FROM Foods
      ORDER BY food_id ASC
    `);

    if (!foods.length) {
      return res.status(404).json({ message: "No foods found" });
    }

    res.status(200).json({
      message: "Foods fetched successfully",
      count: foods.length,
      data: foods
    });
  } catch (err) {
    console.error("getAllFoodsByAdmin error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// === UPDATE FOOD (for Admin only) ===
export const updateFoodByAdmin = async (req: Request, res: Response) => {
  try {
    const role = (req as any).user?.role;
    const adminId = (req as any).user?.id;

    if (role !== "admin") {
      return res.status(403).json({ message: "Forbidden: Admin only" });
    }

    const { id } = req.params;
    const { food_name, protein_gram, fat_gram, carbohydrate_gram, calories } = req.body;

    // ตรวจสอบว่ามีอาหารนี้หรือไม่
    const [existing]: any = await db.query("SELECT * FROM Foods WHERE food_id = ?", [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: "Food not found" });
    }

    // Validation เบื้องต้น
    if (calories && calories <= 0) {
      return res.status(400).json({ message: "Calories must be greater than 0" });
    }
    if (
      (protein_gram && protein_gram < 0) ||
      (fat_gram && fat_gram < 0) ||
      (carbohydrate_gram && carbohydrate_gram < 0)
    ) {
      return res.status(400).json({ message: "Macronutrient values cannot be negative" });
    }

    // อัปเดตเฉพาะค่าที่ส่งมา
    await db.query(
      `UPDATE Foods SET
        food_name = COALESCE(?, food_name),
        protein_gram = COALESCE(?, protein_gram),
        fat_gram = COALESCE(?, fat_gram),
        carbohydrate_gram = COALESCE(?, carbohydrate_gram),
        calories = COALESCE(?, calories),
        admin_id = ?
      WHERE food_id = ?`,
      [food_name, protein_gram, fat_gram, carbohydrate_gram, calories, adminId, id]
    );

    res.status(200).json({ message: "Food updated successfully" });
  } catch (err) {
    console.error("updateFoodByAdmin error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};


