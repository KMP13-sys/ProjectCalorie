import { Request, Response } from "express";
import db from "../config/db";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

// === REGISTER ===
export const register = async (req: Request, res: Response) => {
  try {
    const { username, email, phone_number, password, age, gender, height, weight, goal } = req.body;

    // Password Validation: อย่างน้อย 8 ตัว, มีอักษร, มีอักษรพิเศษ
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*[\W_]).{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        message: "Password must be at least 8 characters, include a letter and a special character."
      });
    }

    const [existing]: any = await db.query(
      "SELECT * FROM users WHERE BINARY username = ? OR email = ?",
      [username, email]
    );
    if (existing.length > 0) {
      return res.status(400).json({ message: "Username or email already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result]: any = await db.query(
      "INSERT INTO users (username, email, phone_number, password, age, gender, height, weight, goal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [username, email, phone_number, hashedPassword, age, gender, height, weight, goal]
    );

    res.status(201).json({ message: "User registered successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// === LOGIN (Admin/User) ===
export const login = async (req: Request, res: Response) => {
  try {
    const { username, password } = req.body;

    // ตรวจสอบก่อนว่าเป็น admin ไหม
    const [adminRows]: any = await db.query(
      "SELECT * FROM admin WHERE BINARY username = ?",
      [username]
    );

    let role = "user";
    let user: any;

    if (adminRows.length > 0) {
      user = adminRows[0];
      role = "admin";
    } else {
      const [userRows]: any = await db.query(
        "SELECT * FROM users WHERE BINARY username = ?",
        [username]
      );
      if (userRows.length === 0) {
        return res.status(400).json({ message: "Invalid username or password" });
      }
      user = userRows[0];
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(400).json({ message: "Invalid username or password" });
    }

    // === เจน Tokens ===
    const accessToken = jwt.sign(
      { id: user.user_id || user.admin_id, role },
      process.env.JWT_SECRET!,
      { expiresIn: "30m" } // Access Token หมดอายุใน 30 นาที
    );

    const refreshToken = jwt.sign(
      { id: user.user_id || user.admin_id, role },
      process.env.JWT_SECRET!,
      { expiresIn: "30d" } // Refresh Token หมดอายุใน 30 วัน
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

    const decoded: any = jwt.verify(refreshToken, process.env.JWT_SECRET!);

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
