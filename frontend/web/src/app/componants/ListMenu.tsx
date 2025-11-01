'use client';
import React, { useEffect, useState } from 'react';
import { listAPI, MealItem } from '@/services/list_service';

interface ListMenuProps {
  // ไม่ต้องใช้ props แล้ว เพราะดึงข้อมูลจาก API
}

const ListMenu: React.FC<ListMenuProps> = () => {
  const [meals, setMeals] = useState<MealItem[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // ดึงข้อมูลรายการอาหารของวันนี้
  useEffect(() => {
    const fetchMeals = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await listAPI.getTodayMeals();
        setMeals(data.meals);
      } catch (err: any) {
        console.error('Error fetching meals:', err);
        setError(err.message || 'ไม่สามารถดึงข้อมูลได้');
      } finally {
        setLoading(false);
      }
    };

    fetchMeals();

    // รีเฟรชอัตโนมัติทุก 30 วินาที
    const intervalId = setInterval(fetchMeals, 30000);

    // ทำความสะอาด interval เมื่อ component ถูก unmount
    return () => clearInterval(intervalId);
  }, []);

  return (
    <div
      className="h-[70vh] bg-[#DBF9FF] border-[5px] border-[#2a2a2a] shadow-[8px_8px_0_rgba(0,0,0,0.3)] p-5 flex flex-col"
      style={{ fontFamily: 'TA8bit' }}
    >
      {/* Header */}
      <div className="text-[24px] font-bold tracking-[4px] text-[#2a2a2a] text-center">
        LIST MENU
      </div>

      {/* 🔹 หัวตาราง */}
      <div className="mt-3 flex justify-between text-[#2a2a2a] text-[15px] font-bold">
        <span className="flex-1">Food</span>
        <span className="w-[40px] text-center">Kcal</span>
      </div>

      {/* 🔹 เส้นคั่น */}
      <div className="h-[3px] bg-[#2a2a2a] my-2" />

      <div className="overflow-y flex-1">
        {/* แสดง Loading */}
        {loading && (
          <div className="text-center text-[#2a2a2a] font-bold text-[16px] mt-5">
            Loading...
          </div>
        )}

        {/* แสดง Error */}
        {error && !loading && (
          <div className="text-center text-red-600 font-bold text-[14px] mt-5">
            {error}
          </div>
        )}

        {/* แสดงรายการอาหาร */}
        {!loading && !error && meals.length === 0 && (
          <div className="text-center text-[#2a2a2a] font-bold text-[16px] mt-5">
            ยังไม่มีรายการอาหารวันนี้
          </div>
        )}

        {!loading && !error && meals.length > 0 && meals.map((meal, index) => (
          <div
            key={index}
            className="flex justify-between items-center mb-3 text-[#2a2a2a]"
          >
            {/* ชื่ออาหาร */}
            <span className="font-bold text-[16px] truncate flex-1 pr-2">
              {meal.food_name}
            </span>

            {/* แคลอรี่ */}
            <span className="font-bold text-[16px] w-[40px] text-center">
              {meal.calories}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ListMenu;
