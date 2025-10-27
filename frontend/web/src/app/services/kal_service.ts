// src/app/services/kal_service.ts

import api from './auth_service'

// ========================================
// Configuration
// ========================================
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000'
const DAILY_API_URL = `${API_BASE_URL}/api/daily`

// ========================================
// Types / Models
// ========================================
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
  consumed_calories: number
  burned_calories: number
  net_calories: number
}

export interface WeeklyCaloriesResponse {
  message: string
  data: DailyCalorieData[]
}

// ========================================
// Helper: Get User ID from localStorage
// ========================================
function getUserId(): string | null {
  if (typeof window === 'undefined') return null

  const userStr = localStorage.getItem('user')
  if (!userStr) return null

  try {
    const user = JSON.parse(userStr)
    return user.id?.toString() || null
  } catch {
    return null
  }
}

// ========================================
// KalService - Calorie & Daily APIs
// ========================================
export const kalService = {
  /**
   * Calculate and save BMR, TDEE and Target Calories
   */
  calculateAndSaveCalories: async (activityLevel: number): Promise<CalculateCaloriesResponse> => {
    try {
      const userId = getUserId()
      if (!userId) {
        throw new Error('User ID not found. Please login again.')
      }

      console.log('[KalService] Calculating calories with activity level:', activityLevel)
      const url = `${DAILY_API_URL}/calculate-calories/${userId}`
      console.log('[KalService] API URL:', url)

      const response = await api.post<CalculateCaloriesResponse>(url, {
        activityLevel: activityLevel,
      })

      console.log('[KalService] Response:', response.data)
      console.log('[KalService] Successfully calculated calories')
      return response.data
    } catch (error: any) {
      console.error('[KalService] Exception in calculateAndSaveCalories:', error)
      const errorMessage = error.response?.data?.message || error.message || 'Failed to calculate calories'
      throw new Error(errorMessage)
    }
  },

  /**
   * Get calorie status (Target, Consumed, Burned, Net, Remaining)
   */
  getCalorieStatus: async (): Promise<CalorieStatus> => {
    try {
      const userId = getUserId()
      if (!userId) {
        throw new Error('User ID not found. Please login again.')
      }

      const url = `${DAILY_API_URL}/status/${userId}`

      const response = await api.get<CalorieStatus>(url)

      console.log('[KalService] Successfully fetched calorie status')
      return response.data
    } catch (error: any) {
      // If 404, no data found for today (this is expected when user hasn't selected activity level)
      if (error.response?.status === 404) {
        console.log('[KalService] No calorie data found for today (user needs to select activity level)')
        return {
          activity_level: 0,
          target_calories: 0,
          consumed_calories: 0,
          burned_calories: 0,
          net_calories: 0,
          remaining_calories: 0,
        }
      }

      // For other errors, log and rethrow
      console.error('[KalService] Error in getCalorieStatus:', error.response?.status || error.message)
      const errorMessage = error.response?.data?.message || error.message || 'Failed to fetch calorie status'
      throw new Error(errorMessage)
    }
  },

  /**
   * Get daily macros (Protein, Fat, Carbohydrate)
   */
  getDailyMacros: async (): Promise<DailyMacros> => {
    try {
      const userId = getUserId()
      if (!userId) {
        throw new Error('User ID not found. Please login again.')
      }

      console.log('[KalService] Fetching daily macros for user:', userId)
      const url = `${DAILY_API_URL}/macros/${userId}`

      const response = await api.get<DailyMacros>(url)

      console.log('[KalService] Response status:', response.status)
      console.log('[KalService] Successfully fetched daily macros')
      return response.data
    } catch (error: any) {
      console.error('[KalService] Exception in getDailyMacros:', error)
      const errorMessage = error.response?.data?.message || error.message || 'Failed to fetch daily macros'
      throw new Error(errorMessage)
    }
  },

  /**
   * Get weekly calories
   */
  getWeeklyCalories: async (): Promise<WeeklyCaloriesResponse> => {
    try {
      console.log('[KalService] Fetching weekly calories')
      const url = `${DAILY_API_URL}/weekly`

      const response = await api.get<WeeklyCaloriesResponse>(url)

      console.log('[KalService] Response status:', response.status)
      console.log('[KalService] Successfully fetched weekly calories')
      return response.data
    } catch (error: any) {
      console.error('[KalService] Exception in getWeeklyCalories:', error)
      const errorMessage = error.response?.data?.message || error.message || 'Failed to fetch weekly calories'
      throw new Error(errorMessage)
    }
  },
}

export default kalService
