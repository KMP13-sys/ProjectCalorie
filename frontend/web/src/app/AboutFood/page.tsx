'use client';

import { useState, useEffect } from 'react';
import { adminService, Food } from '@/app/services/adminService';
import FoodTable from '../AboutFood/FoodTable';

export default function AdminFoodPage() {
  const [foods, setFoods] = useState<Food[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadFoods();
  }, []);

  const loadFoods = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await adminService.getAllFoods();
      setFoods(data);
    } catch (error: any) {
      console.error('Error loading foods:', error);
      const errorMessage = error.message || 'ไม่สามารถโหลดข้อมูลอาหารได้';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdate = () => {
    loadFoods();
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-100 to-green-200 flex items-center justify-center">
      <div className="container mx-auto p-6 bg-white border-4 border-green-400 rounded-2xl shadow-xl">
        {error && (
          <div className="mb-4 p-4 bg-red-100 border-2 border-red-400 text-red-700 rounded">
            <p className="font-bold">เกิดข้อผิดพลาด:</p>
            <p>{error}</p>
            <button
              onClick={loadFoods}
              className="mt-2 px-4 py-2 bg-red-500 text-white border-2 border-black hover:bg-red-600"
            >
              ลองอีกครั้ง
            </button>
          </div>
        )}
        <FoodTable
          foods={foods}
          loading={loading}
          onUpdate={handleUpdate}
        />
      </div>
    </div>
  );
}
