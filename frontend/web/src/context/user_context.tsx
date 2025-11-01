'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { profileService, UserProfile } from '../services/profile_service';

// ประเภทข้อมูลของ User Context
interface UserContextType {
  userProfile: UserProfile | null;
  loading: boolean;
  error: string | null;
  refreshUserProfile: () => Promise<void>;
  updateUserProfile: (profile: UserProfile) => void;
  clearUserProfile: () => void;
}

// สร้าง Context สำหรับ User Profile
const UserContext = createContext<UserContextType | undefined>(undefined);

// Provider Component - ครอบแอปเพื่อให้เข้าถึงข้อมูล User Profile ได้ทุกหน้า
export function UserProvider({ children }: { children: ReactNode }) {
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // ดึงข้อมูล User Profile จาก API
  const fetchUserProfile = async () => {
    try {
      setLoading(true);
      setError(null);

      if (typeof window === 'undefined') {
        setLoading(false);
        return;
      }

      const token = localStorage.getItem('accessToken');

      if (!token) {
        setUserProfile(null);
        setLoading(false);
        return;
      }

      const profile = await profileService.getCurrentUserProfile();
      setUserProfile(profile);
    } catch (err: any) {
      setUserProfile(null);
    } finally {
      setLoading(false);
    }
  };

  // รีเฟรชข้อมูล User Profile (เรียกใช้เมื่อมีการอัปเดต)
  const refreshUserProfile = async () => {
    await fetchUserProfile();
  };

  // อัปเดตข้อมูล Profile โดยตรงโดยไม่ต้องเรียก API
  const updateUserProfile = (profile: UserProfile) => {
    setUserProfile(profile);
  };

  // ล้างข้อมูล User Profile (ใช้ตอน logout)
  const clearUserProfile = () => {
    setUserProfile(null);
    setError(null);
  };

  // ดึงข้อมูลครั้งแรกเมื่อโหลดหน้า
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

// Custom Hook สำหรับใช้งาน User Context
export function useUser() {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
}

export default UserContext;