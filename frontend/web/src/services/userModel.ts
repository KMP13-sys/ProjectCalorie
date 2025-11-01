// Model ข้อมูลผู้ใช้
export interface User {
  user_id: number;
  username: string;
  email: string;
  role?: "user" | "admin";
  phone_number?: string;
  age?: number;
  gender?: "male" | "female";
  height?: number;
  weight?: number;
  goal?: "lose weight" | "maintain weight" | "gain weight";
  created_at?: Date;
  updated_at?: Date;
}

// Response สำหรับรายชื่อผู้ใช้ทั้งหมด
export interface AllUsersResponse {
  message: string;
  users: User[];
}
