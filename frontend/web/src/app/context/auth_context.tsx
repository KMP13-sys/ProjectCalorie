'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authAPI, User } from '../services/auth_service';
import { useRouter } from 'next/navigation';

// ========================================
// Types
// ========================================
interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (username: string, password: string) => Promise<void>;
  logout: () => void;
  role: 'user' | 'admin' | null;
}

// ========================================
// Create Context
// ========================================
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// ========================================
// Provider Component
// ========================================
export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const router = useRouter();

  // ✅ เช็ค authentication เมื่อ mount
  useEffect(() => {
    const checkAuth = () => {
      if (typeof window === 'undefined') {
        setIsLoading(false);
        return;
      }

      const token = localStorage.getItem('accessToken');
      if (token) {
        const currentUser = authAPI.getCurrentUser();
        setUser(currentUser);
      }
      
      setIsLoading(false);
    };

    checkAuth();
  }, []);

  // ✅ Login function
  const login = async (username: string, password: string) => {
    try {
      const response = await authAPI.login(username, password);

      // ดึงข้อมูล user จาก localStorage ที่ authAPI.login เพิ่งบันทึกไว้
      const currentUser = authAPI.getCurrentUser();

      if (currentUser) {
        setUser(currentUser);
      } else {
        // Fallback: สร้าง user object
        const userData: User = {
          id: 0,
          username: username,
          email: '',
          role: response.role,
        };
        setUser(userData);
      }

      // ✅ ไม่ navigate ที่นี่ - ให้ component (เช่น Login page) จัดการเอง
      // เพื่อให้สามารถแสดง Success Modal หรือ UI อื่นๆ ก่อน navigate ได้
    } catch (error) {
      throw error; // ให้ component จัดการ error
    }
  };

  // ✅ Logout function
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

// ========================================
// Custom Hook
// ========================================
export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

export default AuthContext;