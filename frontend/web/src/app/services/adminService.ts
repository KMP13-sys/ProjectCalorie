// services/adminService.ts

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
};

const API_URL = 'http://localhost:4000/api/admin';

export const adminService = {
  getAllUsers: async (token?: string) => {
    const response = await fetch(`${API_URL}/users`, {
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { 'Authorization': `Bearer ${token}` } : {})
      }
    });
    if (!response.ok) throw new Error('Failed to fetch users');
    return response.json();
  },

  createUser: async (data: any) => {
    const response = await fetch(`${API_URL}/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    if (!response.ok) throw new Error('Failed to create user');
    return response.json();
  },
  updateUser: async (id: string, data: any) => {
    const response = await fetch(`${API_URL}/users/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    if (!response.ok) throw new Error('Failed to update user');
    return response.json();
  },
  deleteUser: async (id: string) => {
    const response = await fetch(`${API_URL}/users/${id}`, {
      method: 'DELETE'
    });
    if (!response.ok) throw new Error('Failed to delete user');
    return response.json();
  }
};
