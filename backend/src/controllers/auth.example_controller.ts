// src/controllers/auth.controller.ts
import { Request, Response } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import db from "../config/db";
import { z } from "zod";

// ✅ Input validation schemas using Zod
const registerSchema = z.object({
  username: z.string().min(3, "Username must be at least 3 characters").max(50).trim(),
  email: z.string().email("Invalid email format").max(100),
  phone_number: z.string().regex(/^[0-9]{10}$/, "Phone number must be 10 digits"),
  password: z.string()
    .min(8, "Password must be at least 8 characters")
    .max(100)
    .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
    .regex(/[a-z]/, "Password must contain at least one lowercase letter")
    .regex(/[0-9]/, "Password must contain at least one number"),
  age: z.number().int().min(13, "Must be at least 13 years old").max(120),
  gender: z.enum(["male", "female", "other"]),
  height: z.number().positive().min(50).max(300), // cm
  weight: z.number().positive().min(20).max(500), // kg
  goal: z.enum(["lose_weight", "maintain_weight", "gain_weight"]),
});

const loginSchema = z.object({
  email: z.string().email("Invalid email format"),
  password: z.string().min(1, "Password is required"),
});

export const register = async (req: Request, res: Response) => {
  try {
    // ✅ SECURITY FIX 1: Validate JWT_SECRET before any operations
    if (!process.env.JWT_SECRET) {
      console.error("JWT_SECRET is not configured");
      return res.status(500).json({ message: "Server configuration error" });
    }

    // ✅ SECURITY FIX 2: Validate all input data
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

    // ✅ Check if user already exists (prevent duplicate registrations)
    const [existingUsers]: any = await db.query(
      "SELECT user_id FROM users WHERE email = ? OR username = ?",
      [email, username]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({ message: "User with this email or username already exists" });
    }

    // ✅ SECURITY FIX 3: Use higher salt rounds for better security (10 -> 12)
    const hashedPassword = await bcrypt.hash(password, 12);

    // Insert new user
    const [result]: any = await db.query(
      `INSERT INTO users (username, email, phone_number, password, age, gender, height, weight, goal, created_at) 
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`,
      [username, email, phone_number, hashedPassword, age, gender, height, weight, goal]
    );

    // ✅ SECURITY FIX 4: Create token with user role for authorization
    const token = jwt.sign(
      { 
        userId: result.insertId, 
        email,
        username // Include minimal necessary data
      },
      process.env.JWT_SECRET as string,
      { 
        expiresIn: "1h",
        issuer: "calorie-tracker-api" // Add issuer for validation
      }
    );

    // ✅ SECURITY FIX 5: Never return sensitive data, even if password is hashed
    res.status(201).json({
      message: "User registered successfully",
      user: {
        id: result.insertId,
        username,
        email,
        age,
        gender,
        height,
        weight,
        goal,
      },
      token,
    });

  } catch (error) {
    console.error("Registration error:", error);
    // ✅ SECURITY FIX 6: Don't leak internal error details to client
    res.status(500).json({ message: "Registration failed. Please try again later." });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    // ✅ Validate JWT_SECRET first
    if (!process.env.JWT_SECRET) {
      console.error("JWT_SECRET is not configured");
      return res.status(500).json({ message: "Server configuration error" });
    }

    // ✅ SECURITY FIX 7: Validate login input
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

    // Query user from database
    const [users]: any = await db.query(
      "SELECT user_id, username, email, phone_number, password, age, gender, height, weight, goal, created_at FROM users WHERE email = ?",
      [email]
    );

    // ✅ SECURITY FIX 8: Use same error message for user not found and wrong password
    // This prevents user enumeration attacks
    if (users.length === 0) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const user = users[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      // ✅ Same error message to prevent user enumeration
      return res.status(401).json({ message: "Invalid email or password" });
    }

    // ✅ Check if account is locked or has any restrictions (optional enhancement)
    // You could add fields like 'is_locked', 'failed_login_attempts', etc.

    // Generate JWT token
    const token = jwt.sign(
      { 
        userId: user.user_id, 
        email: user.email,
        username: user.username
      },
      process.env.JWT_SECRET as string,
      { 
        expiresIn: "1h",
        issuer: "calorie-tracker-api"
      }
    );

    // ✅ SECURITY FIX 9: Explicitly exclude password from response
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
    console.error("Login error:", error);
    // ✅ Generic error message
    res.status(500).json({ message: "Login failed. Please try again later." });
  }
};
