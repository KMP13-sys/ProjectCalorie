import { Request, Response } from "express";
import db from "../config/db";
import fs from "fs";
import path from "path";

// ==============================
// DELETE USER by Admin
// ==============================
export const deleteUserByAdmin = async (req: Request, res: Response) => {
  try {
    const adminRole = (req as any).user?.role;
    if (adminRole !== "admin") {
      return res.status(403).json({ message: "Forbidden: Admin only" });
    }

    const { id } = req.params;

    // ดึงข้อมูลผู้ใช้และรูปโปรไฟล์
    const [rows]: any = await db.query(
      "SELECT user_id, image_profile FROM users WHERE user_id = ?",
      [id]
    );
    if (rows.length === 0) return res.status(404).json({ message: "User not found" });

    const imageProfile = rows[0].image_profile;

    // ลบรูปโปรไฟล์ (ถ้ามี)
    if (imageProfile) {
      const imagePath = path.join(__dirname, "../../uploads", imageProfile);
      if (fs.existsSync(imagePath)) {
        try { fs.unlinkSync(imagePath); } 
        catch (err) { console.error(`Failed to delete profile image: ${imagePath}`, err); }
      }
    }

    // ลบข้อมูลที่เกี่ยวข้องทั้งหมดก่อนลบผู้ใช้
    await db.query(`DELETE md FROM MealDetails md INNER JOIN Meals m ON md.meal_id = m.meal_id WHERE m.user_id = ?`, [id]);
    await db.query("DELETE FROM Meals WHERE user_id = ?", [id]);
    await db.query(`DELETE ad FROM ActivityDetail ad INNER JOIN Activity a ON ad.activity_id = a.activity_id WHERE a.user_id = ?`, [id]);
    await db.query("DELETE FROM Activity WHERE user_id = ?", [id]);
    await db.query("DELETE FROM DailyCalories WHERE user_id = ?", [id]);
    await db.query("DELETE FROM AIAnalysis WHERE user_id = ?", [id]);
    await db.query("DELETE FROM Users WHERE user_id = ?", [id]);

    res.json({ message: "User deleted successfully" });
  } catch (err) {
    console.error("deleteUserByAdmin error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// ==============================
// GET ALL USERS (exclude password & image)
// ==============================
export const getAllUsersByAdmin = async (req: Request, res: Response) => {
  try {
    if ((req as any).user?.role !== "admin") return res.status(403).json({ message: "Admin only" });

    const [rows]: any = await db.query(`
      SELECT user_id, username, email, phone_number, age, gender, height, weight, goal, last_login_at
      FROM users
    `);

    res.json({ users: rows });
  } catch (err) {
    console.error("getAllUsersByAdmin error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// ==============================
// GET ALL FOODS (Admin only)
// ==============================
export const getAllFoodsByAdmin = async (req: Request, res: Response) => {
  try {
    if ((req as any).user?.role !== "admin") return res.status(403).json({ message: "Forbidden: Admin only" });

    const [foods]: any = await db.query(`
      SELECT food_id, food_name, protein_gram, fat_gram, carbohydrate_gram, calories
      FROM Foods
      ORDER BY food_id ASC
    `);

    if (!foods.length) return res.status(404).json({ message: "No foods found" });

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

// ==============================
// UPDATE FOOD (Admin only)
// ==============================
export const updateFoodByAdmin = async (req: Request, res: Response) => {
  try {
    if ((req as any).user?.role !== "admin") return res.status(403).json({ message: "Forbidden: Admin only" });
    const adminId = (req as any).user?.id;
    const { id } = req.params;
    const { food_name, protein_gram, fat_gram, carbohydrate_gram, calories } = req.body;

    // ตรวจสอบว่ามีอาหารนี้หรือไม่
    const [existing]: any = await db.query("SELECT * FROM Foods WHERE food_id = ?", [id]);
    if (existing.length === 0) return res.status(404).json({ message: "Food not found" });

    // Validation เบื้องต้น
    if (calories && calories <= 0) return res.status(400).json({ message: "Calories must be greater than 0" });
    if ((protein_gram && protein_gram < 0) || (fat_gram && fat_gram < 0) || (carbohydrate_gram && carbohydrate_gram < 0)) {
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
