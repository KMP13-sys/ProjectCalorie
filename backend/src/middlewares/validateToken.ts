import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

//ใช้ตรวจสอบ JWT Token ว่าถูกต้องหรือไม่ ก่อนจะให้ API ทำงานต่อ 😾

export const validateToken = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers["authorization"]?.split(" ")[1];
  if (!token) {
    return res.status(401).json({ message: "No token provided" });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET as string);
    (req as any).user = decoded;  // ใส่ข้อมูล user ลงไปใน req
    next(); // ส่งต่อไป controller
  } catch (err) {
    return res.status(403).json({ message: "Invalid token" });
  }
};
