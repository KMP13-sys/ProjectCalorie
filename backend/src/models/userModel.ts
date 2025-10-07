import pool from "../config/db";

export interface User {
  user_id: number;              // INT, Primary Key, Auto Increment
  username: string;             // VARCHAR(50), NOT NULL, UNIQUE
  email: string;                // VARCHAR(100), NOT NULL, UNIQUE
  password: string;             // VARCHAR(255), NOT NULL
  phone_number?: string;        // VARCHAR(15), Optional
  age?: number;                  // INT, NOT NULL (with CHECK 1-120)
  gender?: 'male' | 'female';    // ENUM, NOT NULL
  height?: number;               // DECIMAL(5,2), NOT NULL (50-300)
  weight?: number;               // DECIMAL(5,2), NOT NULL (20-300)
  goal?: string;                // VARCHAR(50), Optional
  created_at?: Date;            // TIMESTAMP, Default CURRENT_TIMESTAMP
  updated_at?: Date;            // TIMESTAMP, Default CURRENT_TIMESTAMP ON UPDATE
}

// ดึงข้อมูลผู้ใช้ตาม ID
export const getUserById = async (id: number): Promise<User | null> => {
  const [rows]: any = await pool.query("SELECT * FROM users WHERE user_id = ?", [id]);
  return rows.length ? rows[0] : null;
};

// อัปเดตข้อมูลผู้ใช้
export const updateUserById = async (id: number, data: Partial<User>) => {
  const fields = [];
  const values: any[] = [];

  // สร้าง query update แบบ dynamic
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
