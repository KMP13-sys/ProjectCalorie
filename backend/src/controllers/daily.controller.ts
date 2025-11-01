import { Request, Response } from "express";
import db from "../config/db";
import { RowDataPacket } from "mysql2";

// ==============================
// ดึงรายการอาหารของวันปัจจุบัน
// ==============================
export const getTodayMeals = async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId;
    if (!userId) return res.status(400).json({ message: "Missing userId" });

    const [rows]: any = await db.query(
      `
      SELECT f.food_name, f.calories
      FROM Meals m
      JOIN MealDetails md ON m.meal_id = md.meal_id
      JOIN Foods f ON md.food_id = f.food_id
      WHERE m.user_id = ? AND m.date = CURDATE()
      ORDER BY md.meal_detail_id ASC
      `,
      [userId]
    );

    if (rows.length === 0)
      return res.status(404).json({ message: "No meals found for today" });

    res.json({ date: new Date().toISOString().split("T")[0], meals: rows });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

// ==============================
// ดึงรายการกิจกรรมของวันปัจจุบัน
// ==============================
export const getTodayActivities = async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId;
    if (!userId) return res.status(400).json({ message: "Missing userId" });

    const [rows]: any = await db.query(
      `
      SELECT s.sport_name, ad.time, ad.calories_burned
      FROM Activity a
      JOIN ActivityDetail ad ON a.activity_id = ad.activity_id
      JOIN Sports s ON ad.sport_id = s.sport_id
      WHERE a.user_id = ? AND a.date = CURDATE()
      ORDER BY ad.activity_detail_id ASC
      `,
      [userId]
    );

    if (rows.length === 0)
      return res.status(404).json({ message: "No activities found for today" });

    res.json({ date: new Date().toISOString().split("T")[0], activities: rows });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

// ==============================
// คำนวณ BMR, TDEE และ Target Calories และบันทึกลง DailyCalories
// ==============================
export const calculateAndSaveCalories = async (req: Request, res: Response) => {
  const { userId } = req.params;
  const { activityLevel } = req.body;

  try {
    // ตรวจสอบ activityLevel
    if (!activityLevel || activityLevel < 1.2 || activityLevel > 2.0) {
      return res.status(400).json({ message: "Invalid activityLevel. Must be between 1.2 and 2.0" });
    }

    // ดึงข้อมูลผู้ใช้
    const [user]: any = await db.query(
      "SELECT age, gender, height, weight, goal FROM Users WHERE user_id = ?",
      [userId]
    );

    if (!user.length) return res.status(404).json({ message: "User not found" });

    const { age, gender, height, weight, goal } = user[0];

    // คำนวณ BMR (Mifflin-St Jeor)
    const bmr = gender === "male"
      ? 10 * weight + 6.25 * height - 5 * age + 5
      : 10 * weight + 6.25 * height - 5 * age - 161;

    // คำนวณ TDEE
    const tdee = bmr * activityLevel;

    // ปรับ Target Calories ตาม goal
    let targetCalories = tdee;
    if (goal === "lose weight") targetCalories -= 500;
    if (goal === "gain weight") targetCalories += 500;

    // บันทึกลง DailyCalories (CURDATE() เพื่อใช้วันปัจจุบันของ DB)
    await db.query(
      `INSERT INTO DailyCalories (user_id, date, activity_level, target_calories)
       VALUES (?, CURDATE(), ?, ?)
       ON DUPLICATE KEY UPDATE
         activity_level = VALUES(activity_level),
         target_calories = VALUES(target_calories)`,
      [userId, activityLevel, targetCalories]
    );

    res.json({
      message: "Calories calculated and saved successfully",
      activity_level: activityLevel,
      bmr: Math.round(bmr * 100) / 100,
      tdee: Math.round(tdee * 100) / 100,
      target_calories: Math.round(targetCalories * 100) / 100,
      goal: goal
    });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

// ==============================
// ดึงสถานะแคลอรีของวันปัจจุบัน
// ==============================
export const getCalorieStatus = async (req: Request, res: Response) => {
  const { userId } = req.params;
  try {
    const [rows]: any = await db.query(
      `SELECT activity_level, target_calories, consumed_calories, burned_calories, net_calories, remaining_calories
       FROM DailyCalories
       WHERE user_id = ? AND date = CURDATE()`,
      [userId]
    );

    if (!rows.length) return res.status(404).json({ message: "No daily data found" });

    // แปลง DECIMAL เป็น Number
    const data = rows[0];
    res.json({
      activity_level: parseFloat(data.activity_level) || 0,
      target_calories: parseFloat(data.target_calories) || 0,
      consumed_calories: parseFloat(data.consumed_calories) || 0,
      burned_calories: parseFloat(data.burned_calories) || 0,
      net_calories: parseFloat(data.net_calories) || 0,
      remaining_calories: parseFloat(data.remaining_calories) || 0,
    });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

// ==============================
// ดึงค่ามาแสดงกราฟวงกลม (macros) ของวันปัจจุบัน
// ==============================
export const getDailyMacros = async (req: Request, res: Response) => {
  const { userId } = req.params;
  try {
    const [rows]: any = await db.query(
      `SELECT 
         SUM(f.protein_gram) AS total_protein,
         SUM(f.fat_gram) AS total_fat,
         SUM(f.carbohydrate_gram) AS total_carbohydrate
       FROM Meals m
       JOIN MealDetails md ON m.meal_id = md.meal_id
       JOIN Foods f ON md.food_id = f.food_id
       WHERE m.user_id = ? AND m.date = CURDATE()`,
      [userId]
    );

    if (!rows[0].total_protein && !rows[0].total_fat && !rows[0].total_carbohydrate) {
      return res.status(200).json({ message: "No meal data for today", protein: 0, fat: 0, carbohydrate: 0 });
    }

    res.json({
      message: "Daily macros retrieved successfully",
      protein: rows[0].total_protein || 0,
      fat: rows[0].total_fat || 0,
      carbohydrate: rows[0].total_carbohydrate || 0
    });
  } catch (error) {
    res.status(500).json({ message: "Server error" });
  }
};

// ==============================
// ดึงข้อมูลแคลอรีรายสัปดาห์ (7 วันล่าสุด)
// ==============================
export const getWeeklyCalories = async (req: Request, res: Response) => {
  const user = (req as any).user;
  const userId = user?.user_id || user?.id;
  if (!userId) return res.status(401).json({ message: "Unauthorized: user_id missing in token" });

  try {
    const [rows] = await db.query<RowDataPacket[]>(
      `SELECT DATE_FORMAT(date, '%Y-%m-%d') AS date, net_calories
       FROM DailyCalories
       WHERE user_id = ? AND date >= CURDATE() - INTERVAL 6 DAY
       ORDER BY date ASC`,
      [userId]
    );

    res.status(200).json({ message: "Weekly calories summary fetched successfully", data: rows });
  } catch (error) {
    res.status(500).json({ message: "Error fetching weekly calories" });
  }
};
