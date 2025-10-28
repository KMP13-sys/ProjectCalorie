// ใช้ axios instance จาก auth_service เพื่อใช้ interceptor ร่วมกัน
import api, { authAPI } from './auth_service';

// ========================================
// Types สำหรับข้อมูลที่ได้จาก API
// ========================================
export interface MealItem {
  food_name: string;
  calories: number;
}

export interface ActivityItem {
  sport_name: string;
  time: number;
  calories_burned: number;
}

export interface TodayMealsResponse {
  date: string;
  meals: MealItem[];
}

export interface TodayActivitiesResponse {
  date: string;
  activities: ActivityItem[];
}

// ========================================
// List API (Services)
// ========================================
export const listAPI = {
  /**
   * ดึงรายการอาหารทั้งหมดของวันปัจจุบัน
   * ใช้ userId จาก localStorage (ไม่ต้องส่ง parameter)
   * token จะถูกเพิ่มอัตโนมัติผ่าน interceptor
   */
  getTodayMeals: async (): Promise<TodayMealsResponse> => {
    try {
      // ดึง userId จาก localStorage
      const user = authAPI.getCurrentUser();
      if (!user || !user.id) {
        throw new Error('กรุณาเข้าสู่ระบบก่อนใช้งาน');
      }

      const response = await api.get<TodayMealsResponse>(
        `/api/daily/meals/${user.id}`
      );
      return response.data;
    } catch (error: any) {
      console.error('Error fetching today meals:', error);
      if (error.response?.status === 404) {
        // ถ้าไม่มีข้อมูล ให้ return ข้อมูลว่าง
        return {
          date: new Date().toISOString().split('T')[0],
          meals: [],
        };
      }
      throw error;
    }
  },

  /**
   * ดึงรายการกิจกรรม/กีฬาทั้งหมดของวันปัจจุบัน
   * ใช้ userId จาก localStorage (ไม่ต้องส่ง parameter)
   * token จะถูกเพิ่มอัตโนมัติผ่าน interceptor
   */
  getTodayActivities: async (): Promise<TodayActivitiesResponse> => {
    try {
      // ดึง userId จาก localStorage
      const user = authAPI.getCurrentUser();
      if (!user || !user.id) {
        throw new Error('กรุณาเข้าสู่ระบบก่อนใช้งาน');
      }

      const response = await api.get<TodayActivitiesResponse>(
        `/api/daily/activities/${user.id}`
      );
      return response.data;
    } catch (error: any) {
      console.error('Error fetching today activities:', error);
      if (error.response?.status === 404) {
        // ถ้าไม่มีข้อมูล ให้ return ข้อมูลว่าง
        return {
          date: new Date().toISOString().split('T')[0],
          activities: [],
        };
      }
      throw error;
    }
  },
};
