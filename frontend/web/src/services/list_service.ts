import api, { authAPI } from './auth_service';

// ประเภทข้อมูลที่ได้จาก API
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

// Service สำหรับดึงรายการอาหารและกิจกรรม
export const listAPI = {
  // ดึงรายการอาหารทั้งหมดของวันปัจจุบัน
  getTodayMeals: async (): Promise<TodayMealsResponse> => {
    try {
      const user = authAPI.getCurrentUser();
      const userId = user?.id ?? user?.user_id;

      if (!user || !userId) {
        throw new Error('กรุณาเข้าสู่ระบบก่อนใช้งาน');
      }

      const response = await api.get<TodayMealsResponse>(
        `/api/daily/meals/${userId}`
      );

      return response.data;
    } catch (error: any) {
      if (error.response?.status === 404) {
        return {
          date: new Date().toISOString().split('T')[0],
          meals: [],
        };
      }
      throw error;
    }
  },

  // ดึงรายการกิจกรรม/กีฬาทั้งหมดของวันปัจจุบัน
  getTodayActivities: async (): Promise<TodayActivitiesResponse> => {
    try {
      const user = authAPI.getCurrentUser();
      const userId = user?.id ?? user?.user_id;

      if (!user || !userId) {
        throw new Error('กรุณาเข้าสู่ระบบก่อนใช้งาน');
      }

      const response = await api.get<TodayActivitiesResponse>(
        `/api/daily/activities/${userId}`
      );

      return response.data;
    } catch (error: any) {
      if (error.response?.status === 404) {
        return {
          date: new Date().toISOString().split('T')[0],
          activities: [],
        };
      }
      throw error;
    }
  },
};
