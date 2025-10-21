// src/controllers/auth.controller.ts
import { Request, Response } from "express";
import db from "../config/db";
import { User } from "../models/userModel";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken"; // สร้างและตรวจสอบ token

// สมัครสมาชิก
export const register = async (req: Request, res: Response) => {
  // ตรวจสอบ JWT_SECRET
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET environment variable is not set");
  }
  
  try {
    const { username, email, phone_number, password, age, gender, height, weight, goal } = req.body;

    // validation username - ต้องมีตัวอักษรอย่างน้อย 1 ตัว
    const usernameRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9]{3,}$/;
    if (!usernameRegex.test(username)) {
      return res.status(400).json({ 
        message: "Username must contain at least one letter and only alphanumeric characters, minimum 3 characters" 
      });
    }
    // ตรวจสอบว่าไม่ใช่ตัวเลขอย่างเดียว
    if (/^\d+$/.test(username)) {
      return res.status(400).json({ 
        message: "Username must contain at least one letter" 
      });
    }

    // validation phone number - ตรวจสอบหมายเลขโทรศัพท์ (ต้องเป็นตัวเลข 0-9 และ 10 หลัก)
    const phoneRegex = /^[0-9]{10}$/;
    if (!phoneRegex.test(phone_number)) {
      return res.status(400).json({ 
        message: "Phone number must be 10 digits (0-9 only)" 
      });
    }

    // validation age - ต้องมีอายุอย่างน้อย 13 ปีขึ้นไป
    if (!age || age < 13) {
      return res.status(400).json({ 
        message: "You must be at least 13 years old to register" 
      });
    }

    // validation password - ต้องมีอย่างน้อย 8 ตัว, มีตัวอักษร 1 ตัว
    if (password.length < 8) {
      return res.status(400).json({ 
        message: "Password must be at least 8 characters long" 
      });
    }
    if (!/[a-zA-Z]/.test(password)) {
      return res.status(400).json({ 
        message: "Password must contain at least one letter" 
      });
    }

    // ตรวจสอบว่า username หรือ email มีอยู่แล้วหรือไม่
    const [rows]: any = await db.query(
      "SELECT * FROM users WHERE username = ? OR email = ?",
      [username, email]
    );
    if (rows.length > 0) {
      return res.status(400).json({ message: "Username or email already exists" });
    }
    
    // เข้ารหัสรหัสผ่านก่อนเก็บลง DB
    const passwordPepper = process.env.PASSWORD_PEPPER || '';
    const pepperedPassword = password + passwordPepper;
    const hashedPassword = await bcrypt.hash(pepperedPassword, 10);

    // INSERT user ใหม่ (เพิ่ม age, gender, height, weight, goal)
    const [result]: any = await db.query(
      "INSERT INTO users (username, email, phone_number, password, age, gender, height, weight, goal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [username, email, phone_number, hashedPassword, age, gender, height, weight, goal]
    );


    // สร้าง token ให้ user หลังจากสมัครสำเร็จ 
    const token = jwt.sign(
      { userId: result.insertId, email }, // payload ที่จะเก็บใน token (xxxxx.yyyyy.zzzzz)
      process.env.JWT_SECRET as string, // กุญแจลับ
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
    const { username, password } = req.body;

    // ค้นหา user ตาม email
    const [rows]: any = await db.query("SELECT * FROM users WHERE username = ?", [
      username,
    ]);
    if (rows.length === 0) {
      return res.status(400).json({ message: "Invalid username or password" });
    }

    const user: User = rows[0];

    // ตรวจสอบรหัสผ่าน
    const passwordPepper = process.env.PASSWORD_PEPPER || '';
    const pepperedPassword = password + passwordPepper;
    const isPasswordValid = await bcrypt.compare(pepperedPassword, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ message: "Invalid username or password" });
    }

    // สร้าง token ให้ user
    const token = jwt.sign(
      { userId: user.user_id, username: user.username }, // payload
      process.env.JWT_SECRET as string, // กุญแจลับ
      { expiresIn: "1h" }                          // อายุ token
    );

    // ส่ง token กลับไปให้ client ใช้เก็บใน localStorage หรือ cookie
    res.json({ 
      message: "Login successful", 
      user: { 
        id: user.user_id,
        email: user.email, 
        username: user.username, 
        phone_number: user.phone_number, 
        age: user.age, 
        gender: user.gender, 
        height: user.height, 
        weight: user.weight, 
        goal: user.goal },
      token
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};