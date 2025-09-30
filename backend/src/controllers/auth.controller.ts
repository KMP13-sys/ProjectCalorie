// src/controllers/auth.controller.ts
import { Request, Response } from "express";
import db from "../config/db";
import { User } from "../models/userModel";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken"; // สร้างและตรวจสอบ token

// สมัครสมาชิก
export const register = async (req: Request, res: Response) => {
  try {
    const { username, email, password, age, gender, height, weight, goal } = req.body;

    // ตรวจสอบว่า username หรือ email มีอยู่แล้วหรือไม่
    const [rows]: any = await db.query(
      "SELECT * FROM users WHERE username = ? OR email = ?",
      [username, email]
    );
    if (rows.length > 0) {
      return res.status(400).json({ message: "Username or email already exists" });
    }

    // เข้ารหัสรหัสผ่านก่อนเก็บลง DB
    const hashedPassword = await bcrypt.hash(password, 10);

    // INSERT user ใหม่
    const [result]: any = await db.query(
      "INSERT INTO users (username, email, password, age, gender, height, weight, goal) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
      [username, email, hashedPassword, age, gender, height, weight, goal]
    );

    // สร้าง token ให้ user หลังจากสมัครสำเร็จ 
    const token = jwt.sign(
      { userId: result.insertId, email }, // payload ที่จะเก็บใน token (xxxxx.yyyyy.zzzzz)
      process.env.JWT_SECRET || "secretkey", // กุญแจลับ
      { expiresIn: "1h" } // อายุของ token
    );

    res.status(201).json({ 
      message: "User registered successfully", 
      token 
    });
  } catch (err: any) {
    console.error(err);

    // ดัก Error 1062 กรณี UNIQUE ซ้ำ
    if (err.code === "ER_DUP_ENTRY") {
      return res.status(400).json({ message: "Username or email already exists" });
    }

    res.status(500).json({ message: "Internal server error" });
  }
};

// เข้าสู่ระบบ
export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    // ค้นหา user ตาม email
    const [rows]: any = await db.query("SELECT * FROM users WHERE email = ?", [
      email,
    ]);
    if (rows.length === 0) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    const user: User = rows[0];

    // ตรวจสอบรหัสผ่าน
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ message: "Invalid email or password" });
    }

    // สร้าง token ให้ user
    const token = jwt.sign(
      { userId: user.user_id, email: user.email }, // payload
      process.env.JWT_SECRET || "secretkey",       // กุญแจลับ
      { expiresIn: "1h" }                          // อายุ token
    );

    // ส่ง token กลับไปให้ client ใช้เก็บใน localStorage หรือ cookie
    res.json({ 
      message: "Login successful", 
      user: { id: user.user_id, email: user.email },
      token
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};
