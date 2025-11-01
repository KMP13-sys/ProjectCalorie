// src/controllers/auth.controller.ts
import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import db from "../config/db";
import { z } from "zod";

// ==============================
// Validation schemas using Zod
// ==============================
const registerSchema = z.object({
  username: z.string().min(3).max(50).trim(),
  email: z.string().email().max(100),
  phone_number: z.string().regex(/^[0-9]{10}$/),
  password: z.string().min(6).max(100)
    .regex(/[a-z]/)
    .regex(/[0-9]/),
  age: z.number().int().min(13).max(120),
  gender: z.enum(["male", "female"]),
  height: z.number().positive().min(50).max(300),
  weight: z.number().positive().min(20).max(500),
  goal: z.enum(["lose weight", "maintain weight", "gain weight"]),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

// ==============================
// REGISTER USER
// ==============================
export const register = async (req: Request, res: Response) => {
  try {
    if (!process.env.JWT_SECRET) {
      return res.status(500).json({ message: "Server configuration error" });
    }

    // Validate input
    const validationResult = registerSchema.safeParse(req.body);
    if (!validationResult.success) {
      return res.status(400).json({
        message: "Validation failed",
        errors: validationResult.error.issues.map(err => ({
          field: err.path.join('.'),
          message: err.message
        }))
      });
    }

    const { username, email, phone_number, password, age, gender, height, weight, goal } = validationResult.data;

    // Prevent duplicate registration
    const [existingUsers]: any = await db.query(
      "SELECT user_id FROM users WHERE email = ? OR username = ?",
      [email, username]
    );
    if (existingUsers.length > 0) {
      return res.status(409).json({ message: "User with this email or username already exists" });
    }

    // Hash password securely
    const hashedPassword = await bcrypt.hash(password, 12);

    // Insert new user into DB
    const [result]: any = await db.query(
      `INSERT INTO users (username, email, phone_number, password, age, gender, height, weight, goal, created_at) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [username, email, phone_number, hashedPassword, age, gender, height, weight, goal]
    );

    // Generate JWT token for authentication
    const token = jwt.sign(
      { userId: result.insertId, email, username },
      process.env.JWT_SECRET as string,
      { expiresIn: "1h", issuer: "calorie-tracker-api" }
    );

    // Return non-sensitive user info + token
    res.status(201).json({
      message: "User registered successfully",
      user: { id: result.insertId, username, email, age, gender, height, weight, goal },
      token,
    });

  } catch (error) {
    res.status(500).json({ message: "Registration failed. Please try again later." });
  }
};

// ==============================
// LOGIN USER
// ==============================
export const login = async (req: Request, res: Response) => {
  try {
    if (!process.env.JWT_SECRET) {
      return res.status(500).json({ message: "Server configuration error" });
    }

    // Validate input
    const validationResult = loginSchema.safeParse(req.body);
    if (!validationResult.success) {
      return res.status(400).json({
        message: "Validation failed",
        errors: validationResult.error.issues.map(err => ({
          field: err.path.join('.'),
          message: err.message
        }))
      });
    }

    const { email, password } = validationResult.data;

    // Fetch user from DB
    const [users]: any = await db.query(
      "SELECT user_id, username, email, phone_number, password, age, gender, height, weight, goal, created_at FROM users WHERE email = ?",
      [email]
    );

    // Uniform error message to prevent user enumeration
    if (users.length === 0) return res.status(401).json({ message: "Invalid email or password" });

    const user = users[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) return res.status(401).json({ message: "Invalid email or password" });

    // Generate JWT token
    const token = jwt.sign(
      { userId: user.user_id, email: user.email, username: user.username },
      process.env.JWT_SECRET as string,
      { expiresIn: "1h", issuer: "calorie-tracker-api" }
    );

    // Return user info without sensitive data
    res.json({
      message: "Login successful",
      user: {
        id: user.user_id,
        username: user.username,
        email: user.email,
        phone_number: user.phone_number,
        age: user.age,
        gender: user.gender,
        height: user.height,
        weight: user.weight,
        goal: user.goal,
        created_at: user.created_at,
      },
      token,
    });

  } catch (error) {
    res.status(500).json({ message: "Login failed. Please try again later." });
  }
};
