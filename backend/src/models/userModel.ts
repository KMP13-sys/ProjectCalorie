import pool from "../config/db";

// =======================
// User interface
// =======================
export interface User {
  user_id: number;               // Primary Key
  username: string;              // Unique username
  email: string;                 // Unique email
  password: string;
  image_profile?: string;        // Optional profile image
  phone_number?: string;         // Optional phone
  age?: number;                  // Optional (1-120)
  gender?: 'male' | 'female';    // Optional
  height?: number;               // Optional (50-300)
  weight?: number;               // Optional (20-300)
  goal?: 'lose weight' | 'maintain weight' | 'gain weight'; // Optional
  created_at?: Date;             // Auto timestamp
  updated_at?: Date;             // Auto timestamp
  refresh_token?: string;        // Optional refresh token
  refresh_token_expires_at?: Date; // Optional token expiry
  last_login_at?: Date;          // Optional last login
}

// =======================
// Fetch user by ID
// =======================
export const getUserById = async (id: number): Promise<User | null> => {
  const [rows]: any = await pool.query("SELECT * FROM users WHERE user_id = ?", [id]);
  return rows.length ? rows[0] : null;
};

// =======================
// Update user by ID
// =======================
// รองรับการอัปเดตข้อมูลบางส่วน (Partial User)
export const updateUserById = async (id: number, data: Partial<User>) => {
  const fields: string[] = [];
  const values: any[] = [];

  // สร้าง query dynamic จาก fields ที่ส่งมา
  for (const [key, value] of Object.entries(data)) {
    if (value !== undefined) {
      fields.push(`${key} = ?`);
      values.push(value);
    }
  }

  if (!fields.length) return null;

  const sql = `UPDATE users SET ${fields.join(", ")} WHERE user_id = ?`;
  values.push(id);
  await pool.query(sql, values);

  // ดึงข้อมูลล่าสุดกลับไป
  const [rows]: any = await pool.query("SELECT * FROM users WHERE user_id = ?", [id]);
  return rows[0];
};
