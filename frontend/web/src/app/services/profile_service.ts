// src/app/services/profile_service.ts

import axios from 'axios';

// ========================================
// Configuration
// ========================================
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000';

// ========================================
// Types
// ========================================
export interface UserProfile {
  user_id: number;
  username: string;
  email: string;
  image_profile?: string;
  image_profile_url?: string;
  phone_number?: string;
  age?: number;
  gender?: 'male' | 'female';
  height?: number;
  weight?: number;
  goal?: 'lose weight' | 'maintain weight' | 'gain weight';
  created_at?: string;
  updated_at?: string;
}

export interface UpdateProfileImageResponse {
  message: string;
  image_url: string;
}

export interface UpdateProfileData {
  age?: number;
  gender?: 'male' | 'female';
  height?: number;
  weight?: number;
  goal?: 'lose weight' | 'maintain weight' | 'gain weight';
}

export interface UpdateProfileResponse {
  message: string;
  user: UserProfile;
}

// ========================================
// Axios Instance
// ========================================
const profileAPI = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// ========================================
// Request Interceptor (เพิ่ม token ทุก request)
// ========================================
profileAPI.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken'); // ✅ เปลี่ยนจาก 'token'
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// ========================================
// Response Interceptor (จัดการ error)
// ========================================
profileAPI.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('[Profile API] Error:', {
      status: error.response?.status,
      message: error.response?.data?.message,
      url: error.config?.url,
    });

    // Token หมดอายุ (401 Unauthorized)
    if (error.response?.status === 401 || error.response?.status === 403) {
      console.log('[Profile API] Token expired or forbidden, redirecting to login...');
      localStorage.removeItem('accessToken'); // ✅ เปลี่ยนจาก 'token'
      localStorage.removeItem('user');

      if (typeof window !== 'undefined') {
        window.location.href = '/login';
      }
    }

    // Network Error
    if (!error.response) {
      console.error('[Profile API] Network Error:', error.message);
    }

    return Promise.reject(error);
  }
);

// ========================================
// Profile API Services
// ========================================
export const profileService = {
  /**
   * ดึงข้อมูลโปรไฟล์ผู้ใช้ตาม ID
   */
  getUserProfile: async (userId: number): Promise<UserProfile> => {
    try {
      const response = await profileAPI.get<UserProfile>(`/api/profile/${userId}`);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการดึงข้อมูลโปรไฟล์';
      throw new Error(errorMessage);
    }
  },

  /**
   * ดึงข้อมูลโปรไฟล์ของผู้ใช้ปัจจุบัน
   */
  getCurrentUserProfile: async (): Promise<UserProfile | null> => {
    try {
      const userStr = localStorage.getItem('user');
      if (!userStr) {
        console.warn('👤 [getCurrentUserProfile] User not found in localStorage');
        return null;
      }

      const user = JSON.parse(userStr);
      console.log('👤 [getCurrentUserProfile] User from localStorage:', user);

      // ตรวจสอบว่ามี id หรือไม่
      if (!user.id && !user.user_id) {
        console.error('❌ [getCurrentUserProfile] User ID not found in localStorage');
        return null;
      }

      const userId = user.id || user.user_id;
      console.log('👤 [getCurrentUserProfile] Fetching profile for user ID:', userId);

      const profile = await profileService.getUserProfile(userId);

      console.log('✅ [getCurrentUserProfile] Profile fetched:', profile);

      // อัปเดท localStorage ด้วยข้อมูลล่าสุด
      const updatedUser = {
        ...user,
        id: profile.user_id,
        username: profile.username,
        email: profile.email,
      };
      localStorage.setItem('user', JSON.stringify(updatedUser));

      console.log('✅ [getCurrentUserProfile] Updated user in localStorage:', updatedUser);

      return profile;
    } catch (error) {
      console.error('❌ [getCurrentUserProfile] Error:', error);
      return null;
    }
  },

  /**
   * อัปเดทข้อมูลโปรไฟล์
   */
  updateProfile: async (userId: number, data: UpdateProfileData): Promise<UpdateProfileResponse> => {
    try {
      const response = await profileAPI.put<UpdateProfileResponse>(
        `/api/update/${userId}`,
        data
      );

      // ✅ อัปเดท user ใน localStorage ด้วย
      const userStr = localStorage.getItem('user');
      if (userStr) {
        const currentUser = JSON.parse(userStr);
        const updatedUser = {
          ...currentUser,
          id: response.data.user.user_id,
          username: response.data.user.username,
          email: response.data.user.email,
          age: response.data.user.age,
          gender: response.data.user.gender,
          height: response.data.user.height,
          weight: response.data.user.weight,
          goal: response.data.user.goal,
        };
        localStorage.setItem('user', JSON.stringify(updatedUser));
      }

      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการอัปเดทโปรไฟล์';
      throw new Error(errorMessage);
    }
  },

  /**
   * อัปเดทรูปโปรไฟล์
   */
  updateProfileImage: async (userId: number, imageFile: File): Promise<UpdateProfileImageResponse> => {
    try {
      const formData = new FormData();
      formData.append('profile_image', imageFile);

      const response = await profileAPI.put<UpdateProfileImageResponse>(
        `/api/profile/${userId}/image`,
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        }
      );

      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการอัปเดทรูปโปรไฟล์';
      throw new Error(errorMessage);
    }
  },

  /**
   * ดึง URL รูปโปรไฟล์เต็ม
   */
  getProfileImageUrl: (imageName?: string): string => {
    if (!imageName) {
      return '/pic/person.png'; // รูป default
    }
    return `${API_BASE_URL}/uploads/${imageName}`;
  },
};

export default profileService;