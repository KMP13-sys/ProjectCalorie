'use client';
import React from 'react';

interface ListSportProps {
  sportName?: string;
  time?: number; // นาที
  caloriesBurned?: number; // แคลอรี่ที่เผาผลาญ
}

const ListSport: React.FC<ListSportProps> = ({
  sportName = 'วิ่ง',
  time = 30,
  caloriesBurned = 120,
}) => {
  return (
    <div
      className="h-[70vh] bg-[#fcfbc0] border-[5px] border-[#2a2a2a] shadow-[8px_8px_0_rgba(0,0,0,0.3)] p-5 flex flex-col"
      style={{ fontFamily: 'TA8bit, monospace' }}
    >
      {/* 🔹 Header */}
      <h2 className="text-[24px] font-bold tracking-[4px] text-[#2a2a2a] text-center">
        LIST SPORT
      </h2>

      {/* 🔹 หัวตาราง */}
      <div className="mt-3 flex justify-between text-[#2a2a2a] text-[10px] font-bold">
        <span className="flex-1">SPORT</span>
        <span className="w-[40px] text-center">TIME</span>
        <span className="w-[50px] text-right">BURN</span>
      </div>

      {/* 🔹 เส้นคั่น */}
      <div className="h-[3px] bg-[#2a2a2a] my-2" />

      {/* 🔹 รายการกีฬา */}
      <div className="overflow-y-auto flex-1">
        {Array.from({ length: 20 }).map((_, index) => (
          <div
            key={index}
            className="flex justify-between items-center mb-2 text-[#2a2a2a]"
          >
            {/* ชื่อกีฬา */}
            <span className="flex-1 font-bold text-[16px] truncate">
              {sportName} {index + 1}
            </span>

            {/* เวลา */}
            <span className="w-[40px] text-center font-bold text-[16px]">
              {time}
            </span>

            {/* แคลอรี่ */}
            <span className="w-[50px] text-right font-bold text-[16px]">
              -{caloriesBurned}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ListSport;
