import { Request, Response } from "express";
import db from "../config/db";
import { RowDataPacket } from "mysql2";

export const logActivity = async (req: Request, res: Response) => {
  
  const user = (req as any).user;
  const userId = user?.user_id || user?.id;

  console.log("User from JWT:", user);

  if (!userId) {
    return res.status(401).json({ message: "Unauthorized: user_id missing in token" });
  }

  const { sport_name, time } = req.body;

  if (!sport_name || !time) {
    return res.status(400).json({ message: "Please provide sport_name and time" });
  }

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    // หา sport ในตาราง Sports
    const [sports] = await connection.query<RowDataPacket[]>(
      "SELECT sport_id, burn_out FROM Sports WHERE sport_name = ?",
      [sport_name]
    );

    if (sports.length === 0) {
      await connection.rollback();
      return res.status(404).json({ message: "Sport not found" });
    }

    const { sport_id, burn_out } = sports[0];
    const calories_burned = time * burn_out;

    // ตรวจสอบว่ามี Activity วันนี้ไหม
    const [activities] = await connection.query<RowDataPacket[]>(
      "SELECT activity_id FROM Activity WHERE user_id = ? AND date = CURDATE()",
      [userId]
    );

    let activity_id;
    if (activities.length === 0) {
      const [insertActivity]: any = await connection.query(
        "INSERT INTO Activity (user_id, date) VALUES (?, CURDATE())",
        [userId]
      );
      activity_id = insertActivity.insertId;
    } else {
      activity_id = activities[0].activity_id;
    }

    // บันทึก ActivityDetail
    await connection.query(
      `INSERT INTO ActivityDetail (activity_id, sport_id, time, calories_burned)
       VALUES (?, ?, ?, ?)`,
      [activity_id, sport_id, time, calories_burned]
    );

    // รวมแคลอรี่ของวันนั้นทั้งหมด
    const [sumResult] = await connection.query<RowDataPacket[]>(
      `SELECT SUM(calories_burned) AS total_burned
       FROM ActivityDetail
       WHERE activity_id = ?`,
      [activity_id]
    );

    const total_burned = sumResult[0].total_burned || 0;

    // ตรวจ DailyCalories วันนี้
    const [daily] = await connection.query<RowDataPacket[]>(
      "SELECT daily_calorie_id FROM DailyCalories WHERE user_id = ? AND date = CURDATE()",
      [userId]
    );

    if (daily.length === 0) {
      await connection.query(
        `INSERT INTO DailyCalories (user_id, date, burned_calories)
         VALUES (?, CURDATE(), ?)`,
        [userId, total_burned]
      );
    } else {
      await connection.query(
        `UPDATE DailyCalories SET burned_calories = ? WHERE user_id = ? AND date = CURDATE()`,
        [total_burned, userId]
      );
    }

    await connection.commit();
    return res.status(201).json({
      message: "Activity logged successfully ! เย้",
      data: { sport_name, time, calories_burned, total_burned },
    });
  } catch (error) {
    await connection.rollback();
    console.error("Error logging activity:", error);
    return res.status(500).json({ message: "Error logging activity" });
  } finally {
    connection.release();
  }
};
