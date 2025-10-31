'use client';

import { useState, useEffect } from 'react';
import FoodTable from '../AboutFood/FoodTable';
import { foodService } from '@/app/services/food_service';

export default function AdminFoodPage() {
  const [foods, setFoods] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadFoods();
  }, []);

  const loadFoods = async () => {
    try {
      setLoading(true);
      const data = await foodService.getAllFoods();
      setFoods(data);
    } catch (error) {
      console.error('Error loading foods:', error);
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
        <FoodTable 
          foods={foods}
          loading={loading}
          onUpdate={handleUpdate}
        />
      </div>
    </div>
  );
}
