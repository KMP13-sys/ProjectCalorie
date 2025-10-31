// src/app/services/auth_service.ts

import axios from 'axios'

// ========================================
// Helper: Decode JWT
// ========================================
function decodeJWT(token: string): any {
  try {
    const base64Url = token.split('.')[1]
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    )
    return JSON.parse(jsonPayload)
  } catch (error) {
    console.error('Error decoding JWT:', error)
    return null
  }
}

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
  role: 'user' | 'admin' // ✅ เพิ่ม role
  phone_number?: string
  age?: number
  gender?: string
  height?: number
  weight?: number
  goal?: string
}

// ✅ ตรงกับ Backend Response
export interface LoginResponse {
  message: string
  role: 'user' | 'admin'
  accessToken: string
  expiresIn: string
  // ไม่มี refreshToken สำหรับ web
}

// ✅ Register ไม่ส่ง token กลับมา
export interface RegisterResponse {
  message: string
}

export interface RegisterData {
  username: string
  email: string
  phone_number: string
  password: string
  age: number
  gender: string
  height: number
  weight: number
  goal: string
}

// ใน src/app/services/auth_service.ts
// ...
export { api }; // เพิ่มบรรทัดนี้ถ้าต้องการ Named Import ด้วย



// ========================================
// Axios Instance
// ========================================
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
})

// ========================================
// Request Interceptor (เพิ่ม token ทุก request)
// ========================================
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken') // ✅ เปลี่ยนจาก 'token'
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
    if (error.response?.status === 401 || error.response?.status === 403) {
      // ✅ Clear session
      localStorage.removeItem('accessToken')
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
      const response = await api.post<any>('/api/auth/login', {
        username,
        password,
        platform: 'web', // ✅ เพิ่ม platform
      })

      console.log('🔐 Login response:', response.data);

      // ✅ บันทึก accessToken และ user ลง localStorage
      if (response.data.accessToken) {
        localStorage.setItem('accessToken', response.data.accessToken)

        // ✅ ใช้ userId จาก response โดยตรง (backend ส่งมาให้แล้ว)
        const userId = response.data.userId || 0;

        console.log('🔐 Saving user with ID:', userId);

        // สร้าง user object จาก response
        const user: User = {
          id: userId, // ✅ ดึงจาก response.data.userId
          username: username,
          email: '',
          role: response.data.role,
        }
        localStorage.setItem('user', JSON.stringify(user))

        console.log('✅ User saved to localStorage:', user);
      }

      return response.data
    } catch (error: any) {
      console.error('❌ Login error:', error);
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ'
      throw new Error(errorMessage)
    }
  },

  /**
   * สมัครสมาชิก
   */
  register: async (data: RegisterData): Promise<RegisterResponse> => {
    try {
      console.log('Calling API:', `${API_BASE_URL}/api/auth/register`)
      console.log('Register data:', data)
      
      const response = await api.post<RegisterResponse>('/api/auth/register', data)

      // ✅ Register ไม่ส่ง token กลับมา ไม่ต้อง save
      return response.data
    } catch (error: any) {
      console.error('Register Error Details:', {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status,
      })
      
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการสมัครสมาชิก'
      throw new Error(errorMessage)
    }
  },

  /**
   * ออกจากระบบ (Web - แค่ clear localStorage)
   */
  logout: () => {
    // ✅ Web ไม่ต้องเรียก API logout
    localStorage.removeItem('accessToken')
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
    return !!localStorage.getItem('accessToken') // ✅ เปลี่ยนจาก 'token'
  },

  /**
   * ดึง token
   */
  getToken: (): string | null => {
    if (typeof window === 'undefined') return null
    return localStorage.getItem('accessToken') // ✅ เปลี่ยนจาก 'token'
  },

  /**
   * ลบบัญชีผู้ใช้
   */
  deleteAccount: async (): Promise<void> => {
    try {
      await api.delete('/api/auth/delete-account')

      // ลบข้อมูลออกจาก localStorage
      localStorage.removeItem('accessToken')
      localStorage.removeItem('user')
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการลบบัญชี'
      throw new Error(errorMessage)
    }
  },

  /**
   * ดึงข้อมูล user จาก API โดยใช้ userId จาก localStorage
   */
  fetchCurrentUser: async (): Promise<User | null> => {
    try {
      const currentUser = authAPI.getCurrentUser()
      if (!currentUser || !currentUser.id) {
        console.warn('No user ID found in localStorage')
        return null
      }

      const userId = currentUser.id
      const response = await api.get<any>(`/api/profile/${userId}`)

      // แปลงข้อมูลจาก backend format เป็น User type
      const userData: User = {
        id: response.data.user_id,
        username: response.data.username,
        email: response.data.email,
        role: response.data.role || 'user',
        phone_number: response.data.phone_number,
        age: response.data.age,
        gender: response.data.gender,
        height: response.data.height,
        weight: response.data.weight,
        goal: response.data.goal,
      }

      // บันทึกข้อมูล user ใหม่
      localStorage.setItem('user', JSON.stringify(userData))

      return userData
    } catch (error) {
      console.error('Failed to fetch user:', error)
      return null
    }
  },
}

export default api