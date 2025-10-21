// src/controllers/auth.controller.ts
import { Request, Response } from "express";
import db from "../config/db";
import { User } from "../models/userModel";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

// สมัครสมาชิก
export const register = async (req: Request, res: Response) => {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET environment variable is not set");
  }
  
  try {
    const { username, email, phone_number, password, age, gender, height, weight, goal } = req.body;

    // validation username
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

    // validation phone number
    const phoneRegex = /^[0-9]{10}$/;
    if (!phoneRegex.test(phone_number)) {
      return res.status(400).json({ 
        message: "Phone number must be 10 digits (0-9 only)" 
      });
    }

    // validation age
    if (!age || age < 13) {
      return res.status(400).json({ 
        message: "You must be at least 13 years old to register" 
      });
    }

    // validation password
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

    // ใช้ BINARY เพื่อให้การเปรียบเทียบเป็น case-sensitive
    const [rows]: any = await db.query(
      "SELECT * FROM users WHERE BINARY username = ? OR email = ?",
      [username, email]
    );
    if (rows.length > 0) {
      return res.status(400).json({ message: "Username or email already exists" });
    }
    
    const hashedPassword = await bcrypt.hash(password, 10);

    // INSERT user ใหม่
    const [result]: any = await db.query(
      "INSERT INTO users (username, email, phone_number, password, age, gender, height, weight, goal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [username, email, phone_number, hashedPassword, age, gender, height, weight, goal]
    );

    const token = jwt.sign(
      { userId: result.insertId, email },
      process.env.JWT_SECRET as string,
      { expiresIn: "1h" }
    );
    
    res.status(201).json({ 
      message: "User registered successfully", 
      token 
    });
  } catch (err: any) {
    console.error(err);
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

    // ✅ ใช้ BINARY เพื่อให้การเปรียบเทียบเป็น case-sensitive
    const [rows]: any = await db.query(
      "SELECT * FROM users WHERE BINARY username = ?", 
      [username]
    );
    
    if (rows.length === 0) {
      return res.status(400).json({ message: "Invalid username or password" });
    }

    const user: User = rows[0];

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ message: "Invalid username or password" });
    }

    const token = jwt.sign(
      { userId: user.user_id, username: user.username },
      process.env.JWT_SECRET as string,
      { expiresIn: "1h" }
    );

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
        goal: user.goal 
      },
      token
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};