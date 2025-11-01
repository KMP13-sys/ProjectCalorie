import api from './auth_service'
import { getNodeApiUrl } from '@/config/api.config'

const API_BASE_URL = getNodeApiUrl()
const DAILY_API_URL = `${API_BASE_URL}/api/daily`

// ประเภทข้อมูล Response และ Model
export interface CalculateCaloriesResponse {
  message: string
  activity_level: number
  bmr: number
  tdee: number
  target_calories: number
  goal: string
}

export interface CalorieStatus {
  activity_level: number
  target_calories: number
  consumed_calories: number
  burned_calories: number
  net_calories: number
  remaining_calories: number
}

export interface DailyMacros {
  message: string
  protein: number
  fat: number
  carbohydrate: number
}

export interface DailyCalorieData {
  date: string
  net_calories: number
}

export interface WeeklyCaloriesResponse {
  message: string
  data: DailyCalorieData[]
}

// ดึง User ID จาก localStorage
function getUserId(): string | null {
  if (typeof window === 'undefined') {
    return null;
  }

  const userStr = localStorage.getItem('user')
  if (!userStr) {
    return null;
  }

  try {
    const user = JSON.parse(userStr)
    if (!user.id) {
      return null;
    }
    return user.id?.toString() || null
  } catch (error) {
    return null
  }
}

// Service สำหรับคำนวณและจัดการแคลอรี่
export const kalService = {
  // คำนวณและบันทึก BMR, TDEE และแคลอรี่เป้าหมาย
  calculateAndSaveCalories: async (activityLevel: number): Promise<CalculateCaloriesResponse> => {
    try {
      const userId = getUserId()
      if (!userId) {
        throw new Error('User ID not found. Please login again.')
      }

      const url = `${DAILY_API_URL}/calculate-calories/${userId}`
      const response = await api.post<CalculateCaloriesResponse>(url, {
        activityLevel: activityLevel,
      })

      return response.data
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || error.message || 'Failed to calculate calories'
      throw new Error(errorMessage)
    }
  },

  // ดึงสถานะแคลอรี่ (เป้าหมาย, บริโภค, เผาผลาญ, คงเหลือ)
  getCalorieStatus: async (): Promise<CalorieStatus> => {
    try {
      const userId = getUserId()
      if (!userId) {
        throw new Error('User ID not found. Please login again.')
      }

      const url = `${DAILY_API_URL}/status/${userId}`
      const response = await api.get<CalorieStatus>(url)

      return response.data
    } catch (error: any) {
      if (error.response?.status === 404) {
        return {
          activity_level: 0,
          target_calories: 0,
          consumed_calories: 0,
          burned_calories: 0,
          net_calories: 0,
          remaining_calories: 0,
        }
      }

      const errorMessage = error.response?.data?.message || error.message || 'Failed to fetch calorie status'
      throw new Error(errorMessage)
    }
  },

  // ดึงข้อมูลสารอาหารรายวัน (โปรตีน, ไขมัน, คาร์โบไฮเดรต)
  getDailyMacros: async (): Promise<DailyMacros> => {
    try {
      const userId = getUserId()
      if (!userId) {
        throw new Error('User ID not found. Please login again.')
      }

      const url = `${DAILY_API_URL}/macros/${userId}`
      const response = await api.get<DailyMacros>(url)

      return response.data
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || error.message || 'Failed to fetch daily macros'
      throw new Error(errorMessage)
    }
  },

  // ดึงข้อมูลแคลอรี่รายสัปดาห์ (7 วันล่าสุด)
  getWeeklyCalories: async (): Promise<WeeklyCaloriesResponse> => {
    try {
      const userId = getUserId()
      if (!userId) {
        throw new Error('User ID not found. Please login again.')
      }

      const url = `${DAILY_API_URL}/weekly/${userId}`
      const response = await api.get<WeeklyCaloriesResponse>(url)

      return response.data
    } catch (error: any) {
      if (error.response?.status === 401) {
        throw new Error('Session expired. Please login again.')
      } else if (error.response?.status === 404) {
        return {
          message: 'No weekly data found',
          data: []
        }
      }

      const errorMessage = error.response?.data?.message || error.message || 'Failed to fetch weekly calories'
      throw new Error(errorMessage)
    }
  },
}

export default kalService
