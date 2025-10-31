// src/services/adminService.ts
import axios from "axios";
import { User } from "../services/userModel";

// ดึง token จาก localStorage หรือ state ของคุณ
const getAuthHeader = () => {
  const token = localStorage.getItem("token"); // ปรับตามวิธีคุณเก็บ token
  return { headers: { Authorization: `Bearer ${token}` } };
};

export const adminAPI = {
  // GET all users
  getAllUsers: async (): Promise<User[]> => {
    const res = await axios.get("/api/admin/users", getAuthHeader());
    return res.data.users; // ต้องตรงกับ backend { users: [...] }
  },

  // DELETE user
  deleteUser: async (user_id: number) => {
    const res = await axios.delete(`/api/admin/delete-user/${user_id}`, getAuthHeader());
    return res.data;
  },

  // UPDATE user
  updateUser: async (user_id: number, payload: Partial<User>) => {
    const res = await axios.put(`/api/admin/update-user/${user_id}`, payload, getAuthHeader());
    return res.data;
  },
};
