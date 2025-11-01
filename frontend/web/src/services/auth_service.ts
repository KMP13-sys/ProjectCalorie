import axios from 'axios'
import { getNodeApiUrl } from '@/config/api.config'

// ฟังก์ชัน Decode JWT Token
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
    return null
  }
}

const API_BASE_URL = getNodeApiUrl()

// ประเภทข้อมูลผู้ใช้
export interface User {
  user_id: number
  username: string
  email: string
  role: 'user' | 'admin'
  phone_number?: string
  age?: number
  gender?: string
  height?: number
  weight?: number
  goal?: string
}

export interface LoginResponse {
  message: string
  role: 'user' | 'admin'
  userId: number
  accessToken: string
  expiresIn: string
}

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

// สร้าง Axios Instance พร้อม Config
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
})

// Request Interceptor - เพิ่ม token ทุก request
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

// Response Interceptor - จัดการ error และ token หมดอายุ
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401 || error.response?.status === 403) {
      localStorage.removeItem('accessToken')
      localStorage.removeItem('user')
      if (typeof window !== 'undefined') window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// Authentication API Services
export const authAPI = {
  // เข้าสู่ระบบ
  login: async (username: string, password: string): Promise<LoginResponse> => {
    try {
      const response = await api.post<LoginResponse>('/api/auth/login', { username, password, platform: 'web' })
      const { accessToken, role, userId } = response.data

      if (accessToken) {
        localStorage.setItem('accessToken', accessToken)
        const user: User = { user_id: userId || 0, username, email: '', role }
        localStorage.setItem('user', JSON.stringify(user))
      }

      return response.data
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ'
      throw new Error(errorMessage)
    }
  },

  // สมัครสมาชิก
  register: async (data: RegisterData): Promise<RegisterResponse> => {
    const response = await api.post<RegisterResponse>('/api/auth/register', data)
    return response.data
  },

  // ออกจากระบบ
  logout: () => {
    localStorage.removeItem('accessToken')
    localStorage.removeItem('user')
    if (typeof window !== 'undefined') window.location.href = '/login'
  },

  // ดึงข้อมูลผู้ใช้จาก localStorage
  getCurrentUser: (): User | null => {
    const userStr = localStorage.getItem('user')
    if (!userStr) return null
    try {
      return JSON.parse(userStr) as User
    } catch {
      return null
    }
  },

  // ตรวจสอบสถานะการเข้าสู่ระบบ
  isAuthenticated: (): boolean => !!localStorage.getItem('accessToken'),

  // ดึง Token
  getToken: (): string | null => localStorage.getItem('accessToken'),

  // ลบบัญชีผู้ใช้
  deleteAccount: async (): Promise<void> => {
    await api.delete('/api/auth/delete-account')
    localStorage.removeItem('accessToken')
    localStorage.removeItem('user')
  },

  // ดึงข้อมูลผู้ใช้จาก Backend
  fetchCurrentUser: async (): Promise<User | null> => {
    try {
      const currentUser = authAPI.getCurrentUser()
      if (!currentUser?.user_id) return null
      const response = await api.get<any>(`/api/profile/${currentUser.user_id}`)
      const userData: User = {
        user_id: response.data.user_id,
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
      localStorage.setItem('user', JSON.stringify(userData))
      return userData
    } catch (error) {
      return null
    }
  },

  // ดึงรายชื่อผู้ใช้ทั้งหมด (สำหรับ Admin)
  getAllUsers: async (): Promise<User[]> => {
    try {
      const response = await api.get<{ message: string; users: User[] }>('/api/admin/users')
      return response.data.users
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'ไม่สามารถดึงข้อมูลผู้ใช้ได้'
      throw new Error(errorMessage)
    }
  },
}

export default api
