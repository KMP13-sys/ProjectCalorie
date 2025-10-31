// services/food_service.ts

const API_URL = 'http://localhost:4000/api';

export const foodService = {
  // ดึงข้อมูลอาหารทั้งหมด
  getAllFoods: async () => {
    const response = await fetch(`${API_URL}/foods`);
    return response.json();
  },

  // อัพเดทข้อมูลอาหาร
  updateFood: async (id: number, data: any) => {
    const response = await fetch(`${API_URL}/foods/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    return response.json();
  },

  // ลบอาหาร
  deleteFood: async (id: number) => {
    const response = await fetch(`${API_URL}/foods/${id}`, {
      method: 'DELETE'
    });
    return response.json();
  }
};