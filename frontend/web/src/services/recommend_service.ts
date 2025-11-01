import axios from 'axios';
import { getFlaskApiUrl } from '@/config/api.config';

const FLASK_API_URL = getFlaskApiUrl();

// ประเภทข้อมูลสำหรับ Recommendation
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

// สร้าง Axios Instance สำหรับ Flask API
const flaskAPI = axios.create({
  baseURL: FLASK_API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// Request Interceptor - เพิ่ม token ทุก request
flaskAPI.interceptors.request.use(
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
flaskAPI.interceptors.response.use(
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

// Recommendation Service
export const recommendAPI = {
  // ดึงคำแนะนำอาหาร
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
      if (error.response?.status === 404 && error.response?.data) {
        return error.response.data;
      }

      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการดึงข้อมูลแนะนำอาหาร';
      throw new Error(errorMessage);
    }
  },

  // ดึงคำแนะนำกีฬา
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
      if (error.response?.status === 404 && error.response?.data) {
        return error.response.data;
      }

      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการดึงข้อมูลแนะนำกีฬา';
      throw new Error(errorMessage);
    }
  }
};

export default recommendAPI;
