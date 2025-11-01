'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authAPI, User } from '../services/auth_service';
import { useRouter } from 'next/navigation';

// ประเภทข้อมูลของ Auth Context
interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  role: 'user' | 'admin' | null;
}

// สร้าง Context สำหรับ Authentication
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Provider Component - ครอบแอปเพื่อให้เข้าถึงข้อมูล Auth ได้ทุกหน้า
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  // ตรวจสอบสถานะการเข้าสู่ระบบเมื่อโหลดหน้า
  useEffect(() => {
    const checkAuth = async () => {
      if (typeof window === 'undefined') {
        setIsLoading(false);
        return;
      }

      const token = localStorage.getItem('accessToken');
      if (token) {
        const currentUser = await authAPI.getCurrentUser();
        setUser(currentUser);
      }

      setIsLoading(false);
    };

    checkAuth();
  }, []);

  // ฟังก์ชันเข้าสู่ระบบ
  const login = async (username: string, password: string) => {
    try {
      const response = await authAPI.login(username, password);

      const currentUser = authAPI.getCurrentUser();
      if (currentUser) {
        setUser(currentUser);
      } else {
        const userData: User = {
          user_id: response.userId || 0,
          username: username,
          email: '',
          role: response.role,
        };
        setUser(userData);
      }

    } catch (error) {
      throw error;
    }
  };

  // ฟังก์ชันออกจากระบบ
  const logout = () => {
    authAPI.logout();
    setUser(null);
    router.push('/login');
  };

  const value: AuthContextType = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    logout,
    role: user?.role || null,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

// Custom Hook สำหรับใช้งาน Auth Context
export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

export default AuthContext;
