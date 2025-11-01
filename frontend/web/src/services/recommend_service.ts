// File: frontend/web/src/app/services/recommend_service.ts
// Purpose: Service for food and sport recommendations

import axios from 'axios';
import { getFlaskApiUrl } from '@/config/api.config';

// ====================================
// Configuration
// ====================================
const FLASK_API_URL = getFlaskApiUrl();

// ====================================
// Type Definitions
// ====================================
export interface FoodRecommendation {
  food_id: number;
  name: string;
  calories: number;
  similarity_score: number;
}

export interface FoodRecommendResponse {
  success: boolean;
  message: string;
  user_history: string[];
  remaining_calories: number;
  recommendations: FoodRecommendation[];
}

export interface SportRecommendResponse {
  success: boolean;
  message?: string;
  user_id?: number;
  recommendations?: string[];
  timestamp?: string;
  error?: string;
}

// ====================================
// Axios Instance for Flask API
// ====================================
const flaskAPI = axios.create({
  baseURL: FLASK_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// ====================================
// Request Interceptor (เพิ่ม token ทุก request)
// ====================================
flaskAPI.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken'); // ✅ ใช้ accessToken เหมือน auth_service
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// ====================================
// Response Interceptor (จัดการ error)
// ====================================
flaskAPI.interceptors.response.use(
  (response) => response,
  (error) => {
    // Token หมดอายุ (401 Unauthorized)
    if (error.response?.status === 401 || error.response?.status === 403) {
      // ✅ Clear session
      localStorage.removeItem('accessToken');
      localStorage.removeItem('user');

      // Redirect ไป login page
      if (typeof window !== 'undefined') {
        window.location.href = '/login';
      }
    }

    // Network Error
    if (!error.response) {
      console.error('Network Error:', error.message);
    }

    return Promise.reject(error);
  }
);

// ====================================
// Recommendation API (Services)
// ====================================
export const recommendAPI = {
  /**
   * Get food recommendations for a user
   * @param userId - User ID
   * @param topN - Number of recommendations to return (default: 3)
   * @param date - Optional date (YYYY-MM-DD), defaults to today
   */
  getFoodRecommendations: async (
    userId: number,
    topN: number = 3,
    date?: string
  ): Promise<FoodRecommendResponse> => {
    try {
      const params = new URLSearchParams();
      params.append('top_n', topN.toString());
      if (date) {
        params.append('date', date);
      }

      const response = await flaskAPI.get<FoodRecommendResponse>(
        `/api/food-recommend/${userId}?${params.toString()}`
      );

      return response.data;
    } catch (error: any) {
      console.error('Food recommendation error:', error);

      // ถ้าเป็น 404 (ไม่พบข้อมูล) ให้ return response จาก backend
      if (error.response?.status === 404 && error.response?.data) {
        return error.response.data;
      }

      // Error อื่นๆ
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการดึงข้อมูลแนะนำอาหาร';
      throw new Error(errorMessage);
    }
  },

  /**
   * Get sport recommendations for a user
   * @param userId - User ID
   * @param topN - Number of recommendations to return (default: 3)
   * @param kNeighbors - Number of neighbors for KNN algorithm (default: 5)
   */
  getSportRecommendations: async (
    userId: number,
    topN: number = 3,
    kNeighbors: number = 5
  ): Promise<SportRecommendResponse> => {
    try {
      const params = new URLSearchParams();
      params.append('top_n', topN.toString());
      params.append('k_neighbors', kNeighbors.toString());

      const response = await flaskAPI.get<SportRecommendResponse>(
        `/api/sport-recommend/${userId}?${params.toString()}`
      );

      return response.data;
    } catch (error: any) {
      console.error('Sport recommendation error:', error);

      // ถ้าเป็น 404 (ไม่พบข้อมูล) ให้ return response จาก backend
      if (error.response?.status === 404 && error.response?.data) {
        return error.response.data;
      }

      // Error อื่นๆ
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการดึงข้อมูลแนะนำกีฬา';
      throw new Error(errorMessage);
    }
  }
};

export default recommendAPI;
