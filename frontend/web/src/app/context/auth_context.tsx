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

  // เช็ค authentication เมื่อ mount
  useEffect(() => {
    const checkAuth = async () => {
      if (typeof window === 'undefined') {
        setIsLoading(false);
        return;
      }

      const token = localStorage.getItem('accessToken');
      if (token) {
        // ดึง user จาก authAPI
        const currentUser = await authAPI.getCurrentUser();
        setUser(currentUser);
      }
      
      setIsLoading(false);
    };

    checkAuth();
  }, []);

  // Login function
  const login = async (username: string, password: string) => {
    try {
      // ระบุ type ของ response ให้ชัดเจน
      const response: { token?: string; role: 'user' | 'admin' } = await authAPI.login(username, password);

      // เก็บ token ใน localStorage
      if (response.token) {
        localStorage.setItem('accessToken', response.token);
        localStorage.setItem('adminToken', response.token); // สำหรับหน้า admin
      }

      // ดึงข้อมูล user จาก authAPI
      const currentUser = await authAPI.getCurrentUser();
      if (currentUser) {
        setUser(currentUser);
      } else {
        // fallback ถ้า authAPI.getCurrentUser() ยังว่าง
        const userData: User = {
          id: 0,
          username: username,
          email: '',
          role: response.role,
        };
        setUser(userData);
      }

    } catch (error) {
      throw error; // ให้ component จัดการ error
    }
  };

  // Logout function
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

// Custom Hook
export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

export default AuthContext;
