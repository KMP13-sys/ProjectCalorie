import { Request, Response } from "express";
import db from "../config/db";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

// === REGISTER USER ===
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

// === REGISTER ADMIN ===
export const registerAdmin = async (req: Request, res: Response) => {
  try {
    const { username, email, phone_number, password, address } = req.body;

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

    const passwordRegex = /^(?=.*[A-Za-z])(?=.*[\W_]).{8,}$/;
    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        message: "Password must be at least 8 characters and include a letter and a special character."
      });
    }

    // ตรวจ username / email ซ้ำในตาราง admin
    const [existingAdmin]: any = await db.query(
      "SELECT * FROM admin WHERE BINARY username = ? OR email = ?",
      [username, email]
    );
    if (existingAdmin.length > 0) {
      return res.status(400).json({ message: "Username or email already exists" });
    }

    // Hash Password
    const hashedPassword = await bcrypt.hash(password, 10);

    const [result]: any = await db.query(
      "INSERT INTO admin (username, email, phone_number, password, address) VALUES (?, ?, ?, ?, ?)",
      [username, email, phone_number, hashedPassword, address || null]
    );

    res.status(201).json({ message: "Admin registered successfully" });
  } catch (err: any) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// === LOGIN (Admin/User) ===
export const login = async (req: Request, res: Response) => {
  try {
    const { username, password, platform } = req.body; // ✅ เพิ่ม platform

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

    // เจน Access Token (Web = 24h, Mobile = 30m)
    const tokenExpiry = platform === "web" ? "24h" : "30m";
    const accessToken = jwt.sign(
      { id: user.user_id || user.admin_id, role },
      process.env.JWT_SECRET!,
      { expiresIn: tokenExpiry }
    );

    // สร้าง response object
    const response: any = {
      message: "Login successful",
      role,
      accessToken,
      expiresIn: tokenExpiry
    };

    // ✅ สร้าง Refresh Token เฉพาะ USER + MOBILE เท่านั้น
    if (role === "user" && platform === "mobile") {
      const refreshToken = jwt.sign(
        { id: user.user_id, role: "user" },
        process.env.JWT_SECRET!,
        { expiresIn: "30d" }
      );

      const refreshExpires = new Date();
      refreshExpires.setDate(refreshExpires.getDate() + 30);

      await db.query(
        "UPDATE users SET refresh_token = ?, refresh_token_expires_at = ?, last_login_at = NOW() WHERE user_id = ?",
        [refreshToken, refreshExpires, user.user_id]
      );

      response.refreshToken = refreshToken;
    } else {
      // ✅ Web login (user หรือ admin) → แค่อัพเดท last_login_at
      if (role === "user") {
        await db.query(
          "UPDATE users SET last_login_at = NOW() WHERE user_id = ?",
          [user.user_id]
        );
      } else {
        await db.query(
          "UPDATE admin SET last_login_at = NOW() WHERE admin_id = ?",
          [user.admin_id]
        );
      }
    }

    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// === REFRESH TOKEN ===
export const refreshToken = async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;
    
    if (!refreshToken) {
      return res.status(401).json({ message: "No refresh token provided" });
    }

    // ตรวจสอบว่ามี refresh token ในฐานข้อมูลและยังไม่หมดอายุ
    const [rows]: any = await db.query(
      "SELECT * FROM users WHERE refresh_token = ? AND refresh_token_expires_at > NOW()",
      [refreshToken]
    );

    if (rows.length === 0) {
      return res.status(403).json({ message: "Invalid or expired refresh token" });
    }

    const user = rows[0];

    // Verify JWT signature
    try {
      jwt.verify(refreshToken, process.env.JWT_SECRET!);
    } catch (err) {
      // ถ้า JWT ไม่ valid ให้ลบ refresh token ออกจาก DB
      await db.query(
        "UPDATE users SET refresh_token = NULL, refresh_token_expires_at = NULL WHERE user_id = ?",
        [user.user_id]
      );
      return res.status(403).json({ message: "Invalid refresh token" });
    }

    // สร้าง Access Token ใหม่
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
    res.status(500).json({ message: "Internal server error" });
  }
};

// === LOGOUT (สำหรับ MOBILE เท่านั้น) ===
export const logout = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id;
    const role = (req as any).user?.role;

    if (!userId) {
      return res.status(401).json({ message: "Unauthorized: Missing user ID" });
    }

    // ลบ refresh token เฉพาะ user (mobile เท่านั้นที่มี refresh token)
    if (role === "user") {
      await db.query(
        "UPDATE users SET refresh_token = NULL, refresh_token_expires_at = NULL WHERE user_id = ?",
        [userId]
      );
    }

    res.json({ message: "Logged out successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// === DELETE ACCOUNT (users ลบบัญชีตัวเอง) ===
export const deleteOwnAccount = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id;

    if (!userId) {
      return res.status(401).json({ message: "Unauthorized: Missing user ID" });
    }

    // ลบข้อมูลผู้ใช้
    await db.query("DELETE FROM users WHERE user_id = ?", [userId]);

    res.json({ message: "Account deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};