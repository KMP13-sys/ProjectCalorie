// src/app/services/add_activity_service.ts
import api from './auth_service';
import { getNodeApiUrl } from '@/config/api.config';

const API_BASE_URL = getNodeApiUrl();

interface LogActivityResponse {
  success: boolean;
  message: string;
  sport_name: string;
  time: number;
  calories_burned: number;
  total_burned: number;
}

interface Sport {
  sport_id: number;
  sport_name: string;
  burn_out: number;
}

// ========================================
// Helper Functions
// ========================================
function getUserId(): number | null {
  if (typeof window === 'undefined') return null;

  const userStr = localStorage.getItem('user');
  if (!userStr) return null;

  try {
    const user = JSON.parse(userStr);
    return user.id || null;
  } catch {
    return null;
  }
}

// ========================================
// Activity Service
// ========================================
export const AddActivityService = {
  /**
   * Log an activity/sport session
   */
  async logActivity(sportName: string, time: number): Promise<LogActivityResponse> {
    try {
      const userId = getUserId();

      if (!userId) {
        throw new Error('User ID not found. Please login again.');
      }

      console.log('🏃 Calling activity API:', `${API_BASE_URL}/api/activity/${userId}`);
      console.log('📦 Request body:', { sport_name: sportName, time });

      // ใช้ axios instance จาก auth_service ที่มี interceptor อยู่แล้ว
      const response = await api.post(`/api/activity/${userId}`, {
        sport_name: sportName,
        time: time,
      });

      console.log('📡 Response data:', response.data);

      // แปลง response ให้ตรงกับ interface
      return {
        success: true,
        message: response.data.message || 'Activity logged successfully',
        sport_name: response.data.data?.sport_name || sportName,
        time: response.data.data?.time || time,
        calories_burned: parseFloat(response.data.data?.calories_burned) || 0,
        total_burned: parseFloat(response.data.data?.total_burned) || 0,
      };
    } catch (error: any) {
      console.error('❌ Error logging activity:', error);

      const errorMessage = error.response?.data?.message || error.message || 'Failed to log activity';
      throw new Error(errorMessage);
    }
  },

  /**
   * Get list of all sports
   */
  async getSportsList(): Promise<Sport[]> {
    try {
      const response = await api.get('/api/sports');

      if (Array.isArray(response.data)) {
        return response.data;
      } else if (response.data.sports && Array.isArray(response.data.sports)) {
        return response.data.sports;
      } else {
        throw new Error('Unexpected response format');
      }
    } catch (error: any) {
      console.error('❌ Error fetching sports list:', error);
      throw new Error(error.response?.data?.message || 'Failed to fetch sports list');
    }
  },
};
