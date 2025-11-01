'use client';
import React, { useEffect, useState } from 'react';
import recommendAPI, { FoodRecommendation } from '@/services/recommend_service';
import { authAPI } from '@/services/auth_service';

interface MenuItem {
  id: number;
  name: string;
  calories: number;
}

interface RacMenuProps {
  remainingCalories?: number;
  refreshTrigger?: number;
}

/**
 * Recommend Menu Component
 * แสดงเมนูอาหารที่แนะนำตามแคลอรี่ที่เหลือและประวัติการกิน
 * กรองเฉพาะอาหารที่มีแคลอรี่ไม่เกินที่เหลือ
 */
const RacMenu: React.FC<RacMenuProps> = ({ remainingCalories = 0, refreshTrigger = 0 }) => {
  const [menuList, setMenuList] = useState<MenuItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchRecommend = async () => {
    setLoading(true);
    setError(null);

    try {
      const user = authAPI.getCurrentUser();
      if (!user?.user_id) {
        setError('กรุณาเข้าสู่ระบบ');
        setLoading(false);
        return;
      }

      const response = await recommendAPI.getFoodRecommendations(user.user_id, 5);

      if (response.success && response.recommendations) {
        const items: MenuItem[] = response.recommendations
          .map((rec: FoodRecommendation) => ({
            id: rec.food_id,
            name: rec.name,
            calories: rec.calories,
          }))
          .filter((item) => remainingCalories === 0 || item.calories <= remainingCalories)
          .slice(0, 3);

        setMenuList(items);
      } else {
        setMenuList([]);
        setError(response.message || 'ไม่พบข้อมูลแนะนำ');
      }
    } catch (err: any) {
      console.error('Error fetching food recommendations:', err);
      setError(err.message || 'เกิดข้อผิดพลาดในการดึงข้อมูล');
      setMenuList([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRecommend();
  }, [remainingCalories, refreshTrigger]);

  return (
    <div
      className="h-full bg-[#fcfbc0] border-[5px] border-[#2a2a2a] shadow-[8px_8px_0_rgba(0,0,0,0.3)] p-5 flex flex-col"
      style={{ fontFamily: 'TA8bit' }}
    >
      {/* Header */}
      <div className="text-[24px] font-bold tracking-[4px] text-[#2a2a2a] text-center mb-3">
        RECOMMEND MENU
      </div>

      {/* Table Header */}
      <div className="flex justify-between text-[#2a2a2a] text-[15px] font-bold mb-2">
        <span className="flex-1">FOOD</span>
        <span className="w-[60px] text-center">KCAL</span>
      </div>

      <div className="h-[3px] bg-[#2a2a2a] mb-4" />

      {/* Menu List */}
      <div className="flex-1 overflow-y-auto">
        {loading ? (
          <div className="text-center text-[#2a2a2a] font-bold text-[16px] mt-5">
            กำลังโหลด...
          </div>
        ) : error ? (
          <div className="text-center text-[#2a2a2a] font-bold text-[14px] mt-5">
            {error}
          </div>
        ) : menuList.length > 0 ? (
          <div className="space-y-3">
            {menuList.map((item) => (
              <div
                key={item.id}
                className="flex justify-between items-center text-[16px] text-[#2a2a2a] font-bold"
              >
                <span className="flex-1 truncate pr-2">{item.name}</span>
                <span className="w-[60px] text-center">{item.calories}</span>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center text-[#2a2a2a] font-bold text-[14px] mt-5">
            ไม่มีเมนูที่เหมาะสม
          </div>
        )}
      </div>
    </div>
  );
};

export default RacMenu;
