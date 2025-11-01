// components/admin/EditFoodModal.tsx

'use client';

import { useState } from 'react';
import { adminService, Food } from '@/app/services/adminService';

type EditFoodModalProps = {
  food: Food;
  onClose: () => void;
  onSave: () => void;
};

export default function EditFoodModal({ food, onClose, onSave }: EditFoodModalProps) {
  const [formData, setFormData] = useState({
    food_name: food.food_name,
    calories: food.calories,
    protein_gram: food.protein_gram,
    carbohydrate_gram: food.carbohydrate_gram,
    fat_gram: food.fat_gram,
  });
  const [saving, setSaving] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setSaving(true);
      await adminService.updateFood(food.food_id, formData);
      alert('บันทึกสำเร็จ!');
      onSave();
    } catch (error: any) {
      const errorMessage = error.message || 'เกิดข้อผิดพลาด!';
      alert(errorMessage);
      console.error(error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white border-4 border-black shadow-lg max-w-md w-full p-6 text-black">
        <div className="flex items-center gap-3 mb-4">
          <img
            src="/pic/edit.png"
            alt="Edit"
            className="w-8 h-8 object-contain"
            style={{ imageRendering: 'pixelated' }}
          />
          <h2 className="text-2xl font-bold">แก้ไขข้อมูลอาหาร</h2>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Food Name */}
          <div>
            <label className="block font-bold mb-2">ชื่ออาหาร</label>
            <input
              type="text"
              value={formData.food_name}
              onChange={(e) => setFormData({...formData, food_name: e.target.value})}
              className="w-full border-2 border-black p-2"
              required
            />
          </div>

          {/* Calories */}
          <div>
            <label className="block font-bold mb-2">แคลอรี่ (kcal)</label>
            <input
              type="number"
              value={formData.calories}
              onChange={(e) => setFormData({...formData, calories: Number(e.target.value)})}
              className="w-full border-2 border-black p-2"
              required
              min="0"
            />
          </div>

          {/* Protein */}
          <div>
            <label className="block font-bold mb-2">โปรตีน (g)</label>
            <input
              type="number"
              step="0.1"
              value={formData.protein_gram}
              onChange={(e) => setFormData({...formData, protein_gram: Number(e.target.value)})}
              className="w-full border-2 border-black p-2"
              required
              min="0"
            />
          </div>

          {/* Carbs */}
          <div>
            <label className="block font-bold mb-2">คาร์โบไฮเดรต (g)</label>
            <input
              type="number"
              step="0.1"
              value={formData.carbohydrate_gram}
              onChange={(e) => setFormData({...formData, carbohydrate_gram: Number(e.target.value)})}
              className="w-full border-2 border-black p-2"
              required
              min="0"
            />
          </div>

          {/* Fat */}
          <div>
            <label className="block font-bold mb-2">ไขมัน (g)</label>
            <input
              type="number"
              step="0.1"
              value={formData.fat_gram}
              onChange={(e) => setFormData({...formData, fat_gram: Number(e.target.value)})}
              className="w-full border-2 border-black p-2"
              required
              min="0"
            />
          </div>

          {/* Buttons */}
          <div className="flex gap-4 mt-6">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 bg-gray-300 border-2 border-black p-2 font-bold hover:bg-gray-400"
              disabled={saving}
            >
              ยกเลิก
            </button>
            <button
              type="submit"
              className="flex-1 bg-green-400 border-2 border-black p-2 font-bold hover:bg-green-500"
              disabled={saving}
            >
              {saving ? 'กำลังบันทึก...' : 'บันทึก'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}