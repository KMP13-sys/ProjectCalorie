// src/controllers/auth.controller.ts
import { Request, Response } from "express";
import db from "../config/db";
import { User } from "../models/userModel";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken"; // สร้างและตรวจสอบ token

// helper validation functions (simple, fast, no external deps)
const isNonEmptyString = (v: any) => typeof v === "string" && v.trim().length > 0;
const isEmail = (v: string) =>
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v.trim());
const isPhone = (v: string) =>
  /^[0-9+\-\s()]{7,20}$/.test(v.trim());
const toNumber = (v: any) => {
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
};
const allowedGenders = ["male", "female", "other"];
const allowedGoals = ["lose", "maintain", "gain"];

// สมัครสมาชิก
export const register = async (req: Request, res: Response) => {
  // ตรวจสอบ JWT_SECRET
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET environment variable is not set");
  }
  
  try {
    const body = req.body || {};

    // sanitize/trim basic fields
    const username = typeof body.username === "string" ? body.username.trim() : body.username;
    const email = typeof body.email === "string" ? body.email.trim() : body.email;
    const phone_number = typeof body.phone_number === "string" ? body.phone_number.trim() : body.phone_number;
    const password = body.password;
    const ageRaw = body.age;
    const gender = typeof body.gender === "string" ? body.gender.trim().toLowerCase() : body.gender;
    const heightRaw = body.height;
    const weightRaw = body.weight;
    const goal = typeof body.goal === "string" ? body.goal.trim().toLowerCase() : body.goal;

    // collect validation errors
    const errors: string[] = [];

    if (!isNonEmptyString(username)) errors.push("username is required");
    if (!isNonEmptyString(email) || !isEmail(email)) errors.push("valid email is required");
    if (!isNonEmptyString(password) || (typeof password === "string" && password.length < 6)) errors.push("password is required and must be at least 6 characters");
    if (phone_number && !isPhone(phone_number)) errors.push("phone_number is invalid");
    const age = toNumber(ageRaw);
    if (ageRaw !== undefined && (age === null || age <= 0 || !Number.isInteger(age))) errors.push("age must be a positive integer");
    const height = toNumber(heightRaw);
    if (heightRaw !== undefined && (height === null || height <= 0)) errors.push("height must be a positive number");
    const weight = toNumber(weightRaw);
    if (weightRaw !== undefined && (weight === null || weight <= 0)) errors.push("weight must be a positive number");
    if (gender !== undefined && gender !== "" && !allowedGenders.includes(String(gender))) errors.push(`gender must be one of: ${allowedGenders.join(", ")}`);
    if (goal !== undefined && goal !== "" && !allowedGoals.includes(String(goal))) errors.push(`goal must be one of: ${allowedGoals.join(", ")}`);

    if (errors.length > 0) {
      return res.status(400).json({ message: "Invalid input", errors });
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
    const hashedPassword = await bcrypt.hash(password, 10);

    // INSERT user ใหม่ (เพิ่ม age, gender, height, weight, goal)
    const [result]: any = await db.query(
      "INSERT INTO users (username, email, phone_number, password, age, gender, height, weight, goal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [username, email, phone_number || null, hashedPassword, age || null, gender || null, height || null, weight || null, goal || null]
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
    const body = req.body || {};
    const username = typeof body.username === "string" ? body.username.trim() : body.username;
    const password = body.password;

    const errors: string[] = [];
    if (!isNonEmptyString(username)) errors.push("username is required");
    if (!isNonEmptyString(password)) errors.push("password is required");

    if (errors.length > 0) {
      return res.status(400).json({ message: "Invalid input", errors });
    }

    // ค้นหา user ตาม username
    const [rows]: any = await db.query("SELECT * FROM users WHERE username = ?", [
      username,
    ]);
    if (rows.length === 0) {
      return res.status(400).json({ message: "Invalid username or password" });
    }

    const user: User = rows[0];

    // ตรวจสอบรหัสผ่าน
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ message: "Invalid username or password" });
    }

    // ตรวจ JWT_SECRET
    if (!process.env.JWT_SECRET) {
      throw new Error("JWT_SECRET environment variable is not set");
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
