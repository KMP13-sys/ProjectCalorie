// src/models/userModel.ts

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
