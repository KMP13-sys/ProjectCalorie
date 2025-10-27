'use client';
import React from 'react';

interface ListMenuProps {
  name?: string;
  calories?: number;
}

const ListMenu: React.FC<ListMenuProps> = ({
  name = 'เมนูอาหาร',
  calories = 250,
}) => {
  return (
    <div
      className="h-[70vh] bg-[#fcfbc0] border-[5px] border-[#2a2a2a] shadow-[8px_8px_0_rgba(0,0,0,0.3)] p-5 flex flex-col"
      style={{ fontFamily: 'TA8bit, monospace' }}
    >
      {/* Header */}
      <div className="text-[24px] font-bold tracking-[4px] text-[#2a2a2a] text-center">
        LIST MENU
      </div>

            {/* 🔹 หัวตาราง */}
      <div className="mt-3 flex justify-between text-[#2a2a2a] text-[10px] font-bold">
        <span className="flex-1">Food</span>
        <span className="w-[40px] text-center">Kcal</span>
      </div>

      {/* 🔹 เส้นคั่น */}
      <div className="h-[3px] bg-[#2a2a2a] my-2" />

      <div className="overflow-y-auto flex-1">
        {Array.from({ length: 15 }).map((_, index) => (
          <div
            key={index}
            className="flex justify-between items-center mb-3 text-[#2a2a2a]"
          >
            {/* ชื่ออาหาร */}
            <span className="font-bold text-[16px] truncate">
              {name} {index + 1}
            </span>

            {/* แคลอรี่ */}
            <span className="font-bold text-[16px]">
              {calories}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ListMenu;
