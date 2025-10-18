import { Request, Response } from "express";
import db from "../config/db";

// API ดึงรายการอาหารของวันปัจจุบัน
export const getTodayMeals = async (req: Request, res: Response) => {
  try {
    const userId = req.params.userId;
    if (!userId) return res.status(400).json({ message: "Missing userId" });

    const [rows]: any = await db.query(
      `
      SELECT f.food_name, f.calories, md.meal_time
      FROM Meals m
      JOIN MealDetails md ON m.meal_id = md.meal_id
      JOIN Foods f ON md.food_id = f.food_id
      WHERE m.user_id = ? AND m.date = CURDATE()
      ORDER BY md.meal_time ASC
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

