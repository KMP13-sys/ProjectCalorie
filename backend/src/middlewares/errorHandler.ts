import { Request, Response, NextFunction } from "express";

// Middleware สำหรับจัดการ error ของ API
// จะจับทุก error ที่เกิดขึ้นใน route และส่ง response กลับเป็น JSON
export const errorHandler = (err: any, req: Request, res: Response, next: NextFunction) => {
  // log stack trace สำหรับ debugging (สามารถปิดใน production)
  console.error(err.stack);

  // ส่ง response กลับ client
  res.status(500).json({
    success: false,
    message: err.message || "Something went wrong!",
  });
};
