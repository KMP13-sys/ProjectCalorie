'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { profileService, UserProfile } from '../services/profile_service';

// ========================================
// Types
// ========================================
interface UserContextType {
  userProfile: UserProfile | null;
  loading: boolean;
  error: string | null;
  refreshUserProfile: () => Promise<void>;
  updateUserProfile: (profile: UserProfile) => void;
  clearUserProfile: () => void;
}

// ========================================
// Create Context
// ========================================
const UserContext = createContext<UserContextType | undefined>(undefined);

// ========================================
// Provider Component
// ========================================
export function UserProvider({ children }: { children: ReactNode }) {
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // ฟังก์ชันดึงข้อมูล user profile
  const fetchUserProfile = async () => {
    try {
      setLoading(true);
      setError(null);
      
      // ตรวจสอบว่ามี token หรือไม่ ถ้าไม่มีก็ไม่ต้องดึงข้อมูล
      if (typeof window === 'undefined') {
        setLoading(false);
        return;
      }
      
      const token = localStorage.getItem('token');
      if (!token) {
        setUserProfile(null);
        setLoading(false);
        return;
      }
      
      const profile = await profileService.getCurrentUserProfile();
      setUserProfile(profile);
    } catch (err: any) {
      console.error('Error fetching user profile:', err);
      // ไม่ต้อง set error เพื่อไม่ให้กระทบกับหน้า login/register
      setUserProfile(null);
    } finally {
      setLoading(false);
    }
  };

  // ฟังก์ชัน refresh ข้อมูล (เรียกใช้เมื่อมีการอัปเดต)
  const refreshUserProfile = async () => {
    await fetchUserProfile();
  };

  // ฟังก์ชันอัปเดตข้อมูลโดยตรง (ไม่ต้องเรียก API)
  const updateUserProfile = (profile: UserProfile) => {
    setUserProfile(profile);
  };

  // ฟังก์ชัน clear ข้อมูล user (สำหรับ logout)
  const clearUserProfile = () => {
    setUserProfile(null);
    setError(null);
  };

  // ดึงข้อมูลครั้งแรกตอน mount
  useEffect(() => {
    fetchUserProfile();
  }, []);

  const value: UserContextType = {
    userProfile,
    loading,
    error,
    refreshUserProfile,
    updateUserProfile,
    clearUserProfile,
  };

  return <UserContext.Provider value={value}>{children}</UserContext.Provider>;
}

// ========================================
// Custom Hook
// ========================================
export function useUser() {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
}

export default UserContext;