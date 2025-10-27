'use client';
import React, { useEffect, useState } from 'react';

interface MenuItem {
  id: number;
  name: string;
  calories: number;
}

interface RacMenuProps {
  remainingCalories: number;
  refreshTrigger: number; // ตัวนี้จะเปลี่ยนเมื่อแนบรูปใหม่
}

const RacMenu: React.FC<RacMenuProps> = ({ remainingCalories, refreshTrigger }) => {
  const [menuList, setMenuList] = useState<MenuItem[]>([]);
  const [loading, setLoading] = useState(true);

  // 🧠 จำลองการดึงข้อมูลจาก API
  const fetchRecommend = async () => {
    setLoading(true);
    await new Promise((res) => setTimeout(res, 800)); // จำลองดีเลย์โหลด 0.8 วิ

    // ✅ จำลองเมนูแนะนำตามแคลที่เหลือ
    const mockMenu = [
      { id: 1, name: 'ข้าวผัดกุ้ง', calories: 450 },
      { id: 2, name: 'สลัดไก่ย่าง', calories: 250 },
      { id: 3, name: 'เกาเหลาหมูตุ๋น', calories: 300 },
    ];

    // 🧮 เลือกเมนูที่แคลอรีไม่เกินแคลที่เหลือ
    const filtered = mockMenu.filter((m) => m.calories <= remainingCalories);
    setMenuList(filtered.slice(0, 3));
    setLoading(false);
  };

  useEffect(() => {
    fetchRecommend();
  }, [remainingCalories, refreshTrigger]);

  return (
    <div
      className="h-full bg-[#fcfbc0] border-[5px] border-[#2a2a2a] shadow-[8px_8px_0_rgba(0,0,0,0.3)] p-5 flex flex-col"
      style={{ fontFamily: 'TA8bit, monospace' }}
    >
      <div className="text-[24px] font-bold tracking-[4px] text-[#2a2a2a] text-center mb-3">
        RECOMMEND MENU
      </div>
      <div className="h-[3px] bg-[#2a2a2a] mb-4" />

      {loading ? (
        <p className="text-center text-gray-600">กำลังโหลด...</p>
      ) : menuList.length > 0 ? (
        <div className="flex-1 py-3">
          {menuList.map((item) => (
            <div
              key={item.id}
              className="flex justify-between text-[16px] text-[#2a2a2a] mb-3 font-bold"
            >
              <span>🍽️ {item.name}</span>
              <span>{item.calories} kcal</span>
            </div>
          ))}
        </div>
      ) : (
        <p className="text-center text-gray-600">ไม่มีเมนูที่เหมาะสม</p>
      )}
    </div>
  );
};

export default RacMenu;
