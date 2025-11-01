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

      if (!user || !user.id) {
        throw new Error('กรุณาเข้าสู่ระบบก่อนใช้งาน');
      }

      const response = await api.get<TodayMealsResponse>(
        `/api/daily/meals/${user.id}`
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

      if (!user || !user.id) {
        throw new Error('กรุณาเข้าสู่ระบบก่อนใช้งาน');
      }

      const response = await api.get<TodayActivitiesResponse>(
        `/api/daily/activities/${user.id}`
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
