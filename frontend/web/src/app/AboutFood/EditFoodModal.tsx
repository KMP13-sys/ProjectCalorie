// components/admin/EditFoodModal.tsx

'use client';

import { useState } from 'react';
import { foodService } from '@/app/services/food_service';

type Food = {
  id: number;
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
};

type EditFoodModalProps = {
  food: Food;
  onClose: () => void;
  onSave: () => void;
};

export default function EditFoodModal({ food, onClose, onSave }: EditFoodModalProps) {
  const [formData, setFormData] = useState(food);
  const [saving, setSaving] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setSaving(true);
      // ✅ เรียกใช้ foodService.updateFood เพื่อส่งข้อมูลไปยัง Backend
      await foodService.updateFood(formData.id, formData);
      alert('บันทึกสำเร็จ!');
      onSave();
    } catch (error) {
      alert('เกิดข้อผิดพลาด!');
      console.error(error);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div className="bg-white border-4 border-black shadow-lg max-w-md w-full">
        {/* Modal Content */}
        <form onSubmit={handleSubmit} className="p-6">
          <input
            type="text"
            value={formData.name}
            onChange={(e) => setFormData({...formData, name: e.target.value})}
            className="w-full border-2 border-black p-2"
          />
          {/* ... อื่นๆ ... */}
          
          <button type="submit" disabled={saving}>
            {saving ? 'SAVING...' : 'SAVE'}
          </button>
        </form>
      </div>
    </div>
  );
}
// ```

// **หน้าที่:** แสดง UI, รับข้อมูลจาก User, เรียกใช้ service

// ---

// ## 📊 เปรียบเทียบ:

// | | **food_service** | **EditFoodModal.tsx** |
// |---|---|---|
// | **ประเภท** | Service/Logic | Component/UI |
// | **ไฟล์** | `services/food_service.ts` | `components/admin/EditFoodModal.tsx` |
// | **หน้าที่** | ติดต่อ Backend API | แสดงหน้าจอ Modal |
// | **ทำอะไร** | GET, POST, PUT, DELETE ข้อมูล | รับ input จาก user |
// | **export** | `export const foodService = {...}` | `export default function EditFoodModal() {...}` |

// ---

// ## 🔄 ความสัมพันธ์:
// ```
// User กดปุ่ม Edit
//       ↓
// EditFoodModal.tsx (แสดง Modal)
//       ↓
// User แก้ไขข้อมูล และกด Save
//       ↓
// EditFoodModal เรียก foodService.updateFood()
//       ↓
// food_service ส่งข้อมูลไปยัง Backend API
//       ↓
// Backend บันทึกลง Database
//       ↓
// ส่งผลลัพธ์กลับมา
//       ↓
// EditFoodModal แสดงผลสำเร็จ