import axios from 'axios';
import { getNodeApiUrl } from '@/config/api.config';

const API_BASE_URL = getNodeApiUrl();

// ประเภทข้อมูล Profile
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

// สร้าง Axios Instance สำหรับ Profile API
const profileAPI = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// Request Interceptor - เพิ่ม token ทุก request
profileAPI.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response Interceptor - จัดการ error และ token หมดอายุ
profileAPI.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401 || error.response?.status === 403) {
      localStorage.removeItem('accessToken');
      localStorage.removeItem('user');

      if (typeof window !== 'undefined') {
        window.location.href = '/login';
      }
    }

    return Promise.reject(error);
  }
);

// Profile Service
export const profileService = {
  // ดึงข้อมูล Profile ผู้ใช้ตาม ID
  getUserProfile: async (userId: number): Promise<UserProfile> => {
    try {
      const response = await profileAPI.get<UserProfile>(`/api/profile/${userId}`);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการดึงข้อมูลโปรไฟล์';
      throw new Error(errorMessage);
    }
  },

  // ดึงข้อมูล Profile ของผู้ใช้ปัจจุบัน
  getCurrentUserProfile: async (): Promise<UserProfile | null> => {
    try {
      const userStr = localStorage.getItem('user');
      if (!userStr) {
        return null;
      }

      const user = JSON.parse(userStr);

      if (!user.id && !user.user_id) {
        return null;
      }

      const userId = user.id || user.user_id;
      const profile = await profileService.getUserProfile(userId);

      const updatedUser = {
        ...user,
        id: profile.user_id,
        username: profile.username,
        email: profile.email,
      };
      localStorage.setItem('user', JSON.stringify(updatedUser));

      return profile;
    } catch (error) {
      return null;
    }
  },

  // อัปเดทข้อมูล Profile
  updateProfile: async (userId: number, data: UpdateProfileData): Promise<UpdateProfileResponse> => {
    try {
      const response = await profileAPI.put<UpdateProfileResponse>(
        `/api/update/${userId}`,
        data
      );

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

  // อัปเดทรูปภาพ Profile
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

  // ดึง URL รูป Profile แบบเต็ม
  getProfileImageUrl: (imageName?: string): string => {
    if (!imageName) {
      return '/pic/person.png';
    }
    return `${API_BASE_URL}/uploads/${imageName}`;
  },
};

export default profileService;