import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

// ตรวจสอบ JWT Token ว่าถูกต้องหรือไม่ ก่อนให้ API ทำงานต่อ
export const validateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers["authorization"];

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ message: "No token provided" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET as string);
    (req as any).user = decoded; // ใส่ข้อมูล user ลง req
    console.log("Decoded user from token:", decoded); // <-- Debug ดูว่า user_id มีไหม
    next();
  } catch (err) {
    console.error("JWT error:", err);
    return res.status(403).json({ message: "Invalid token" });
  }
};
