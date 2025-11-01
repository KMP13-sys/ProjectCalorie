import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

// Middleware: ตรวจสอบ JWT token ก่อนให้ API ทำงานต่อ
export const validateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers["authorization"];

  // ถ้าไม่มี token หรือไม่ใช่ Bearer token
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ message: "No token provided" });
  }

  const token = authHeader.split(" ")[1];

  try {
    // ตรวจสอบความถูกต้องของ token
    const decoded = jwt.verify(token, process.env.JWT_SECRET as string);

    // เพิ่มข้อมูล user จาก token ลงใน req
    (req as any).user = decoded;

    next();
  } catch (err) {
    // token ไม่ถูกต้อง
    return res.status(403).json({ message: "Invalid token" });
  }
};
