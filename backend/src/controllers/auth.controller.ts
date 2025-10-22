import { Request, Response } from "express";
import db from "../config/db";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

// === REGISTER ===
export const register = async (req: Request, res: Response) => {
  try {
    const { username, email, phone_number, password, age, gender, height, weight, goal } = req.body;

    //  ตรวจสอบ ENV
    if (!process.env.JWT_SECRET) {
      throw new Error("JWT_SECRET environment variable is not set");
    }

    //  Validation ต่าง ๆ
    const usernameRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9]{3,}$/;
    if (!usernameRegex.test(username) || /^\d+$/.test(username)) {
      return res.status(400).json({
        message: "Username must contain at least one letter and only alphanumeric characters, minimum 3 characters"
      });
    }

    const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ message: "Please provide a valid email address" });
    }

    const phoneRegex = /^[0-9]{10}$/;
    if (!phoneRegex.test(phone_number)) {
      return res.status(400).json({ message: "Phone number must be 10 digits (0-9 only)" });
    }

    if (!age || age < 13) {
      return res.status(400).json({ message: "You must be at least 13 years old to register" });
    }

    const passwordRegex = /^(?=.*[A-Za-z])(?=.*[\W_]).{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        message: "Password must be at least 8 characters and include a letter and a special character."
      });
    }

    // ตรวจ username / email ซ้ำ
    const [existing]: any = await db.query(
      "SELECT * FROM users WHERE BINARY username = ? OR email = ?",
      [username, email]
    );
    if (existing.length > 0) {
      return res.status(400).json({ message: "Username or email already exists" });
    }

    // Hash Password
    const hashedPassword = await bcrypt.hash(password, 10);

    const [result]: any = await db.query(
      "INSERT INTO users (username, email, phone_number, password, age, gender, height, weight, goal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [username, email, phone_number, hashedPassword, age, gender, height, weight, goal]
    );

    res.status(201).json({ message: "User registered successfully" });
  } catch (err: any) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// === LOGIN (Admin/User) ===
export const login = async (req: Request, res: Response) => {
  try {
    const { username, password } = req.body;

    let role = "user";
    let user: any;

    // ตรวจ admin ก่อน
    const [adminRows]: any = await db.query("SELECT * FROM admin WHERE BINARY username = ?", [username]);
    if (adminRows.length > 0) {
      user = adminRows[0];
      role = "admin";
    } else {
      const [userRows]: any = await db.query("SELECT * FROM users WHERE BINARY username = ?", [username]);
      if (userRows.length === 0) {
        return res.status(400).json({ message: "Invalid username or password" });
      }
      user = userRows[0];
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ message: "Invalid username or password" });
    }

    // เจน Access & Refresh Token
    const accessToken = jwt.sign(
      { id: user.user_id || user.admin_id, role },
      process.env.JWT_SECRET!,
      { expiresIn: "30m" }
    );

    const refreshToken = jwt.sign(
      { id: user.user_id || user.admin_id, role },
      process.env.JWT_SECRET!,
      { expiresIn: "30d" }
    );

    const refreshExpires = new Date();
    refreshExpires.setDate(refreshExpires.getDate() + 30);

    if (role === "user") {
      await db.query(
        "UPDATE users SET refresh_token = ?, refresh_token_expires_at = ?, last_login_at = NOW() WHERE user_id = ?",
        [refreshToken, refreshExpires, user.user_id]
      );
    } else {
      await db.query(
        "UPDATE admin SET last_login_at = NOW() WHERE admin_id = ?",
        [user.admin_id]
      );
    }

    res.json({
      message: "Login successful",
      role,
      accessToken,
      refreshToken,
      expiresIn: "30m"
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// === REFRESH TOKEN ===
export const refreshToken = async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(401).json({ message: "No refresh token provided" });

    const [rows]: any = await db.query("SELECT * FROM users WHERE refresh_token = ?", [refreshToken]);
    if (rows.length === 0) return res.status(403).json({ message: "Invalid refresh token" });

    const user = rows[0];
    jwt.verify(refreshToken, process.env.JWT_SECRET!);

    const newAccessToken = jwt.sign(
      { id: user.user_id, role: "user" },
      process.env.JWT_SECRET!,
      { expiresIn: "30m" }
    );

    res.json({
      accessToken: newAccessToken,
      expiresIn: "30m"
    });
  } catch (err) {
    console.error(err);
    res.status(403).json({ message: "Invalid or expired refresh token" });
  }
};
