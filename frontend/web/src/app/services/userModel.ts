// src/app/models/userModel.ts

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

export interface AllUsersResponse {
  message: string;
  users: User[];
}
