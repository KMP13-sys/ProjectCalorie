// src/config/db.ts
// สร้าง MySQL connection pool ด้วย mysql2/promise
// ใช้ค่า config จาก .env ถ้าไม่มีใช้ค่า default

import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

const db = mysql.createPool({
  host: process.env.DB_HOST || "localhost",       // hostname ของ database
  user: process.env.DB_USER || "root",            // username สำหรับเชื่อมต่อ
  password: process.env.DB_PASSWORD || "1234",    // password
  database: process.env.DB_NAME || "calories_app",// ชื่อ database
  port: Number(process.env.DB_PORT) || 3306,      // port ของ MySQL
});

export default db;
