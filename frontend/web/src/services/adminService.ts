import api from './auth_service';

// ประเภทข้อมูลผู้ใช้
export type User = {
  user_id: number;
  username: string;
  email: string;
  phone_number?: string;
  age?: number;
  gender?: 'male' | 'female';
  height?: number;
  weight?: number;
  goal?: 'lose weight' | 'maintain weight' | 'gain weight';
  last_login_at?: string;
};

// ประเภทข้อมูลอาหาร
export type Food = {
  food_id: number;
  food_name: string;
  protein_gram: number;
  fat_gram: number;
  carbohydrate_gram: number;
  calories: number;
};

// ประเภทข้อมูล Response
export type GetUsersResponse = {
  users: User[];
};

export type GetFoodsResponse = {
  message: string;
  count: number;
  data: Food[];
};

export type DeleteUserResponse = {
  message: string;
};

export type UpdateFoodResponse = {
  message: string;
};

// Service สำหรับ Admin จัดการผู้ใช้และอาหาร
export const adminService = {
  // ดึงรายชื่อผู้ใช้ทั้งหมด
  getAllUsers: async (): Promise<User[]> => {
    try {
      const response = await api.get<GetUsersResponse>('/api/admin/users');
      return response.data.users;
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'Failed to fetch users';
      throw new Error(errorMessage);
    }
  },

  // ลบผู้ใช้ตาม ID
  deleteUser: async (id: number): Promise<DeleteUserResponse> => {
    try {
      const response = await api.delete<DeleteUserResponse>(`/api/admin/users/${id}`);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'Failed to delete user';
      throw new Error(errorMessage);
    }
  },

  // ดึงรายการอาหารทั้งหมด
  getAllFoods: async (): Promise<Food[]> => {
    try {
      const response = await api.get<GetFoodsResponse>('/api/admin/foods');
      return response.data.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'Failed to fetch foods';
      throw new Error(errorMessage);
    }
  },

  // แก้ไขข้อมูลอาหารตาม ID
  updateFood: async (id: number, data: Partial<Food>): Promise<UpdateFoodResponse> => {
    try {
      const response = await api.put<UpdateFoodResponse>(`/api/admin/foods/${id}`, data);
      return response.data;
    } catch (error: any) {
      const errorMessage = error.response?.data?.message || 'Failed to update food';
      throw new Error(errorMessage);
    }
  }
};
