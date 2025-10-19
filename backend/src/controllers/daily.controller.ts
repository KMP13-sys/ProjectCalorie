import { Request, Response } from "express";
import db from "../config/db";

// API ดึงรายการอาหารของวันปัจจุบัน
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
    console.error("Error fetching today meals:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// API ดึงรายการกิจกรรมของวันปัจจุบัน
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
    console.error("Error fetching today activities:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// คำนวณและบันทึกค่า BMR ลงในตาราง DailyCalories
export const calculateBMR = async (req: Request, res: Response) => {
  const { userId } = req.params;
  try {
    const [user]: any = await db.query(
      "SELECT age, gender, height, weight FROM Users WHERE user_id = ?",
      [userId]
    );

    if (!user.length) return res.status(404).json({ message: "User not found" });

    const { age, gender, height, weight } = user[0];

    // สูตร BMR (Mifflin-St Jeor)
    let bmr = 0;
    if (gender === "male") bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    else bmr = 10 * weight + 6.25 * height - 5 * age - 161;

    // บันทึก BMR ลงตาราง DailyCalories (ของวันนี้)
    const today = new Date().toISOString().split("T")[0];
    await db.query(
      `INSERT INTO DailyCalories (user_id, date, bmr)
       VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE bmr = VALUES(bmr)`,
      [userId, today, bmr]
    );

    res.json({ message: "BMR calculated", bmr });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

// คำนวณ TDEE และ Target Calories
export const calculateTargetCalories = async (req: Request, res: Response) => {
  const { userId } = req.params;
  const { activityLevel } = req.body; // เช่น 1.3, 1.5, 1.7

  try {
    const [user]: any = await db.query(
      "SELECT goal FROM Users WHERE user_id = ?",
      [userId]
    );
    if (!user.length) return res.status(404).json({ message: "User not found" });

    const [daily]: any = await db.query(
      "SELECT bmr FROM DailyCalories WHERE user_id = ? AND date = CURDATE()",
      [userId]
    );
    if (!daily.length) return res.status(404).json({ message: "Please calculate BMR first" });

    let { goal } = user[0];
    let { bmr } = daily[0];

    const tdee = bmr * activityLevel;
    let target = tdee;

    // 🔹 ปรับตาม goal
    if (goal === "lose weight") target = tdee - 500;
    if (goal === "gain weight") target = tdee + 500;

    await db.query(
      `UPDATE DailyCalories SET target_calories = ? WHERE user_id = ? AND date = CURDATE()`,
      [target, userId]
    );

    res.json({ message: "Target calories calculated", target_calories: target });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

// รวมแคลอรี่ที่กินไปในวันปัจจุบัน แล้วบันทึกลง consumed_calories
export const updateConsumedCalories = async (req: Request, res: Response) => {
  const { userId } = req.params;
  try {
    const [rows]: any = await db.query(
      `SELECT SUM(f.calories) AS totalCalories
       FROM Meals m
       JOIN MealDetails md ON m.meal_id = md.meal_id
       JOIN Foods f ON md.food_id = f.food_id
       WHERE m.user_id = ? AND m.date = CURDATE()`,
      [userId]
    );

    const total = rows[0].totalCalories || 0;

    await db.query(
      `UPDATE DailyCalories SET consumed_calories = ? WHERE user_id = ? AND date = CURDATE()`,
      [total, userId]
    );

    res.json({ message: "Consumed calories updated", consumed_calories: total });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

// ดึงค่าทั้งหมดสำหรับ “หลอด Kcal” (target_calories, net_calories, remaining_calories)
export const getCalorieStatus = async (req: Request, res: Response) => {
  const { userId } = req.params;
  try {
    const [rows]: any = await db.query(
      `SELECT bmr, target_calories, consumed_calories, burned_calories, net_calories, remaining_calories
       FROM DailyCalories
       WHERE user_id = ? AND date = CURDATE()`,
      [userId]
    );

    if (!rows.length) return res.status(404).json({ message: "No daily data found" });

    res.json(rows[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};
