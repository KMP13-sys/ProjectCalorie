import { Request, Response } from "express";
import db from "../config/db";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import path from "path";
import fs from "fs";

// ==============================
// REGISTER USER
// ==============================
export const register = async (req: Request, res: Response) => {
  try {
    const { username, email, phone_number, password, age, gender, height, weight, goal } = req.body;

    if (!process.env.JWT_SECRET) throw new Error("JWT_SECRET not set");

    // Validate username, email, phone, age, password
    const usernameRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9]{3,}$/;
    if (!usernameRegex.test(username) || /^\d+$/.test(username)) {
      return res.status(400).json({ message: "Username must contain at least one letter and only alphanumeric characters, min 3 chars" });
    }
    const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) return res.status(400).json({ message: "Invalid email address" });
    const phoneRegex = /^[0-9]{10}$/;
    if (!phoneRegex.test(phone_number)) return res.status(400).json({ message: "Phone number must be 10 digits" });
    if (!age || age < 13) return res.status(400).json({ message: "Must be at least 13 years old" });
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*[\W_]).{8,}$/;
    if (!passwordRegex.test(password)) return res.status(400).json({ message: "Password must be 8+ chars, include letter & special char" });

    // Check if username/email already exists
    const [existing]: any = await db.query("SELECT * FROM users WHERE BINARY username = ? OR email = ?", [username, email]);
    if (existing.length > 0) return res.status(400).json({ message: "Username or email already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);

    await db.query(
      "INSERT INTO users (username, email, phone_number, password, age, gender, height, weight, goal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
      [username, email, phone_number, hashedPassword, age, gender, height, weight, goal]
    );

    res.status(201).json({ message: "User registered successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// ==============================
// REGISTER ADMIN
// ==============================
export const registerAdmin = async (req: Request, res: Response) => {
  try {
    const { username, email, phone_number, password, address } = req.body;
    if (!process.env.JWT_SECRET) throw new Error("JWT_SECRET not set");

    // Validation
    const usernameRegex = /^(?=.*[a-zA-Z])[a-zA-Z0-9]{3,}$/;
    if (!usernameRegex.test(username) || /^\d+$/.test(username)) {
      return res.status(400).json({ message: "Username must contain at least one letter and only alphanumeric chars, min 3 chars" });
    }
    const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) return res.status(400).json({ message: "Invalid email address" });
    const phoneRegex = /^[0-9]{10}$/;
    if (!phoneRegex.test(phone_number)) return res.status(400).json({ message: "Phone number must be 10 digits" });
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*[\W_]).{8,}$/;
    if (!passwordRegex.test(password)) return res.status(400).json({ message: "Password must be 8+ chars, include letter & special char" });

    const [existingAdmin]: any = await db.query("SELECT * FROM admin WHERE BINARY username = ? OR email = ?", [username, email]);
    if (existingAdmin.length > 0) return res.status(400).json({ message: "Username or email already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);

    await db.query(
      "INSERT INTO admin (username, email, phone_number, password, address) VALUES (?, ?, ?, ?, ?)",
      [username, email, phone_number, hashedPassword, address || null]
    );

    res.status(201).json({ message: "Admin registered successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// ==============================
// LOGIN (User/Admin)
// ==============================
export const login = async (req: Request, res: Response) => {
  try {
    const { username, password, platform } = req.body;

    let role = "user";
    let user: any;

    // Check admin first
    const [adminRows]: any = await db.query("SELECT * FROM admin WHERE BINARY username = ?", [username]);
    if (adminRows.length > 0) user = adminRows[0], role = "admin";
    else {
      const [userRows]: any = await db.query("SELECT * FROM users WHERE BINARY username = ?", [username]);
      if (userRows.length === 0) return res.status(400).json({ message: "Invalid username or password" });
      user = userRows[0];
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) return res.status(400).json({ message: "Invalid username or password" });

    // Create access token
    const tokenExpiry = platform === "web" ? "24h" : "30m";
    const accessToken = jwt.sign({ id: user.user_id || user.admin_id, role }, process.env.JWT_SECRET!, { expiresIn: tokenExpiry });

    const response: any = {
      message: "Login successful",
      role,
      userId: user.user_id || user.admin_id,
      accessToken,
      expiresIn: tokenExpiry
    };

    // Refresh token only for mobile users
    if (role === "user" && platform === "mobile") {
      const refreshToken = jwt.sign({ id: user.user_id, role: "user" }, process.env.JWT_SECRET!, { expiresIn: "30d" });
      const refreshExpires = new Date();
      refreshExpires.setDate(refreshExpires.getDate() + 30);

      await db.query(
        "UPDATE users SET refresh_token = ?, refresh_token_expires_at = ?, last_login_at = NOW() WHERE user_id = ?",
        [refreshToken, refreshExpires, user.user_id]
      );
      response.refreshToken = refreshToken;
    } else {
      // Update last login for web login
      if (role === "user") await db.query("UPDATE users SET last_login_at = NOW() WHERE user_id = ?", [user.user_id]);
      else await db.query("UPDATE admin SET last_login_at = NOW() WHERE admin_id = ?", [user.admin_id]);
    }

    res.json(response);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// ==============================
// REFRESH TOKEN (User only)
// ==============================
export const refreshToken = async (req: Request, res: Response) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(401).json({ message: "No refresh token provided" });

    const [rows]: any = await db.query(
      "SELECT * FROM users WHERE refresh_token = ? AND refresh_token_expires_at > NOW()",
      [refreshToken]
    );
    if (rows.length === 0) return res.status(403).json({ message: "Invalid or expired refresh token" });

    const user = rows[0];

    // Verify JWT signature
    try { jwt.verify(refreshToken, process.env.JWT_SECRET!); }
    catch (err) {
      await db.query("UPDATE users SET refresh_token = NULL, refresh_token_expires_at = NULL WHERE user_id = ?", [user.user_id]);
      return res.status(403).json({ message: "Invalid refresh token" });
    }

    const newAccessToken = jwt.sign({ id: user.user_id, role: "user" }, process.env.JWT_SECRET!, { expiresIn: "30m" });
    res.json({ accessToken: newAccessToken, expiresIn: "30m" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// ==============================
// LOGOUT (mobile only)
// ==============================
export const logout = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id;
    const role = (req as any).user?.role;
    if (!userId) return res.status(401).json({ message: "Unauthorized: Missing user ID" });

    // Remove refresh token for mobile users
    if (role === "user") {
      await db.query("UPDATE users SET refresh_token = NULL, refresh_token_expires_at = NULL WHERE user_id = ?", [userId]);
    }

    res.json({ message: "Logged out successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
};

// ==============================
// HELPER: delete profile image
// ==============================
const deleteProfileImage = (imageName: string) => {
  const imagePath = path.join(__dirname, "../uploads", imageName);
  if (fs.existsSync(imagePath)) {
    try { fs.unlinkSync(imagePath); }
    catch (error) { console.error(`Error deleting profile image: ${imageName}`, error); }
  }
};

// ==============================
// DELETE OWN ACCOUNT (user deletes themselves)
// ==============================
export const deleteOwnAccount = async (req: Request, res: Response) => {
  try {
    const userId = (req as any).user?.id;
    if (!userId) return res.status(401).json({ message: "Unauthorized: Missing user ID" });

    const [users]: any = await db.query("SELECT image_profile FROM Users WHERE user_id = ?", [userId]);
    if (users.length === 0) return res.status(404).json({ message: "User not found" });

    const imageProfile = users[0].image_profile;
    if (imageProfile) deleteProfileImage(imageProfile);

    // Delete related data before removing user (to satisfy foreign key constraints)
    await db.query("DELETE md FROM MealDetails md INNER JOIN Meals m ON md.meal_id = m.meal_id WHERE m.user_id = ?", [userId]);
    await db.query("DELETE FROM Meals WHERE user_id = ?", [userId]);
    await db.query("DELETE ad FROM ActivityDetail ad INNER JOIN Activity a ON ad.activity_id = a.activity_id WHERE a.user_id = ?", [userId]);
    await db.query("DELETE FROM Activity WHERE user_id = ?", [userId]);
    await db.query("DELETE FROM DailyCalories WHERE user_id = ?", [userId]);
    await db.query("DELETE FROM AIAnalysis WHERE user_id = ?", [userId]);
    await db.query("DELETE FROM Users WHERE user_id = ?", [userId]);

    res.json({ message: "Account deleted successfully" });
  } catch (err) {
    console.error("deleteOwnAccount error:", err);
    res.status(500).json({ message: "Internal server error" });
  }
};
