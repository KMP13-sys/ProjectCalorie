import { Request, Response, NextFunction } from "express";
import db from "../config/db";

// GET /api/profile/:id
export const getProfile = async (req: Request, res: Response, next: NextFunction) => {
  const userId = req.params.id;
  const user = (req as any).user;

  if (Number(userId) !== user.user_id) {
    return res.status(403).json({ message: "Access denied", status: false });
  }

  try {
    const [rows]: any = await db.query(
      `
      SELECT 
        u.user_id, u.username, u.email, u.phone_number, u.age, u.gender,
        u.height, u.weight, u.allergies, g.goal_type,
        DATE_FORMAT(u.created_at, '%Y-%m-%d') as created_at
      FROM Users u
      LEFT JOIN Goal g ON u.goal_id = g.goal_id
      WHERE u.user_id = ?
      `,
      [userId]
    );

    if (!rows || rows.length === 0) {
      return res.status(404).json({ message: "User not found", status: false });
    }

    res.json({ data: rows[0], message: "Success", status: true });
  } catch (err) {
    next(err);
  }
};

// GET /api/profile/:id/summary
export const getProfileSummary = async (req: Request, res: Response, next: NextFunction) => {
  const userId = req.params.id;
  const user = (req as any).user;

  if (Number(userId) !== user.user_id) {
    return res.status(403).json({ message: "Access denied", status: false });
  }

  try {
    const [rows]: any = await db.query(
      `
      SELECT 
        m.date,
        SUM(f.calories) as total_calories
      FROM Meals m
      JOIN Meal_Details md ON m.meal_id = md.meal_id
      JOIN Foods f ON md.food_id = f.food_id
      WHERE m.user_id = ?
      GROUP BY m.date
      ORDER BY m.date DESC
      LIMIT 7
      `,
      [userId]
    );

    res.json({ data: rows, message: "Success", status: true });
  } catch (err) {
    next(err);
  }
};


