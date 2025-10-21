// src/app/services/auth_service.ts

import axios from 'axios'

// ========================================
// Configuration
// ========================================
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000'

// ========================================
// Types (ตรงกับ Backend)
// ========================================
export interface User {
  id: number
  username: string
  email: string
  phone_number: string
  age?: number
  gender?: string
  height?: number
  weight?: number
  goal?: string
}

export interface LoginResponse {
  message: string
  user: User
  token: string
}

export interface RegisterResponse {
  message: string
  token: string
}

export interface RegisterData {
  username: string
  email: string
  phone_number: string
  password: string
  age?: number
  gender?: string
  height?: number
  weight?: number
  goal?: string
}

// ========================================
// Axios Instance
// ========================================
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000, // 10 seconds
})

// ========================================
// Request Interceptor (เพิ่ม token ทุก request)
// ========================================
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// ========================================
// Response Interceptor (จัดการ error)
// ========================================
api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Token หมดอายุ (401 Unauthorized)
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      
      // Redirect ไป login page
      if (typeof window !== 'undefined') {
        window.location.href = '/login'
      }
    }

    // Network Error
    if (!error.response) {
      console.error('Network Error:', error.message)
    }

    return Promise.reject(error)
  }
)

// ========================================
// Authentication API (Services)
// ========================================
export const authAPI = {
  /**
   * เข้าสู่ระบบ
   */
  login: async (username: string, password: string): Promise<LoginResponse> => {
    try {
      const response = await api.post<LoginResponse>('/auth/login', {
        username,
        password,
      })

      // บันทึก token และ user ลง localStorage
      if (response.data.token) {
        localStorage.setItem('token', response.data.token)
        localStorage.setItem('user', JSON.stringify(response.data.user))
      }

      return response.data
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ'
      throw new Error(errorMessage)
    }
  },

  /**
   * สมัครสมาชิก
   */
  register: async (data: RegisterData): Promise<RegisterResponse> => {
    try {
      console.log('Calling API:', `${API_BASE_URL}/auth/register`);
      console.log('Register data:', data);
      
      const response = await api.post<RegisterResponse>('/auth/register', data)

      // บันทึก token ลง localStorage
      if (response.data.token) {
        localStorage.setItem('token', response.data.token)
      }

      return response.data
    } catch (error: any) {
      console.error('Register Error Details:', {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status,
      });
      
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการสมัครสมาชิก'
      throw new Error(errorMessage)
    }
  },

  /**
   * ออกจากระบบ
   */
  logout: () => {
    localStorage.removeItem('token')
    localStorage.removeItem('user')
    
    if (typeof window !== 'undefined') {
      window.location.href = '/login'
    }
  },

  /**
   * ดึงข้อมูล user จาก localStorage
   */
  getCurrentUser: (): User | null => {
    if (typeof window === 'undefined') return null
    
    const userStr = localStorage.getItem('user')
    if (!userStr) return null

    try {
      return JSON.parse(userStr) as User
    } catch {
      return null
    }
  },

  /**
   * ตรวจสอบว่า user login อยู่หรือไม่
   */
  isAuthenticated: (): boolean => {
    if (typeof window === 'undefined') return false
    return !!localStorage.getItem('token')
  },

  /**
   * ดึง token
   */
  getToken: (): string | null => {
    if (typeof window === 'undefined') return null
    return localStorage.getItem('token')
  },
}

export default api

// // ========================================
// // Calorie API (เพิ่มเติมตามที่ต้องการ)
// // ========================================
// export const calorieAPI = {
//   /**
//    * ดึงข้อมูล calories ทั้งหมด
//    */
//   getAll: async () => {
//     try {
//       const response = await api.get('/calories')
//       return response.data
//     } catch (error: any) {
//       const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาด'
//       throw new Error(errorMessage)
//     }
//   },

//   /**
//    * เพิ่มข้อมูล calorie
//    */
//   add: async (data: any) => {
//     try {
//       const response = await api.post('/calories', data)
//       return response.data
//     } catch (error: any) {
//       const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาด'
//       throw new Error(errorMessage)
//     }
//   },
// }

// export default api