// src/components/Activity.tsx
"use client";

import React, { useState } from "react";
import { AddActivityService } from "../services/add_activity_service";

type ActivityProps = {
  onSave: (caloriesBurned: number) => void;
};

const Activity: React.FC<ActivityProps> = ({ onSave }) => {
  const [selectedActivity, setSelectedActivity] = useState("วิ่ง");
  const [duration, setDuration] = useState(0);
  const [isLoading, setIsLoading] = useState(false);

  // รายการกีฬา 20 ชนิด (ต้องตรงกับชื่อใน database ตาราง Sports)
  const sports = [
    "เต้น",
    "บาสเก็ตบอล",
    "มวย",
    "กระโดดเชือก",
    "ปั่นจักรยาน",
    "ปิงปอง",
    "เทควันโด",
    "ว่ายน้ำ",
    "วิ่ง",
    "แบดมินตัน",
    "สเกตบอร์ด",
    "วอลเลย์บอล",
    "ฟุตบอล",
    "เซิร์ฟ",
    "ยกน้ำหนัก",
    "โยคะ",
    "แอโรบิค",
    "เครื่องเล่น Elliptical",
    "เทนนิส",
    "สควอช",
  ];

  const increaseTime = () => setDuration((prev) => prev + 5);
  const decreaseTime = () => setDuration((prev) => (prev > 0 ? prev - 5 : 0));

  const saveActivity = async () => {
    // ตรวจสอบว่าเลือกเวลามากกว่า 0 หรือไม่
    if (duration <= 0) {
      alert("กรุณาเลือกระยะเวลาที่มากกว่า 0 นาที");
      return;
    }

    setIsLoading(true);

    try {
      // เรียก API ผ่าน AddActivityService
      const result = await AddActivityService.logActivity(selectedActivity, duration);

      // ดึงค่าแคลอรี่จาก response
      const caloriesBurned = result.calories_burned;
      const totalBurned = result.total_burned;

      // เรียก callback เพื่ออัพเดท UI ของหน้า parent
      onSave(caloriesBurned);

      alert(
        `บันทึกแล้ว! เผาผลาญไป ${caloriesBurned} kcal\nรวมวันนี้: ${totalBurned} kcal`
      );

      // รีเซ็ตค่าเวลากลับเป็น 0
      setDuration(0);
    } catch (error: any) {
      alert(`เกิดข้อผิดพลาด: ${error.message}`);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="bg-white border-2 sm:border-4 border-black shadow-lg p-3 sm:p-4 md:p-6 w-[95%] sm:w-full max-w-[280px] xs:max-w-[320px] sm:max-w-md md:max-w-lg lg:max-w-xl mx-auto text-black">
      {/* Dropdown เลือกกิจกรรม */}
      <div className="mb-3 sm:mb-5">
        <select
          value={selectedActivity}
          onChange={(e) => setSelectedActivity(e.target.value)}
          className="w-full h-10 xs:h-11 sm:h-12 md:h-14 lg:h-16 px-2 border-2 border-black bg-[#FFCCBC] font-mono font-bold text-sm xs:text-base sm:text-lg md:text-xl text-black"
          disabled={isLoading}
        >
          {sports.map((activity) => (
            <option key={activity} value={activity} className="text-black">
              {activity}
            </option>
          ))}
        </select>
      </div>

      {/* ช่องเวลา + ปุ่มเพิ่ม/ลด */}
      <div className="flex justify-center items-center mb-3 sm:mb-4 space-x-2 xs:space-x-3 sm:space-x-4">
        <button
          onClick={decreaseTime}
          disabled={isLoading}
          className="aspect-square w-9 xs:w-10 sm:w-12 md:w-14 bg-[#FFFFAA] border-2 border-black font-bold text-lg xs:text-xl sm:text-2xl md:text-3xl text-black disabled:opacity-50 disabled:cursor-not-allowed hover:bg-[#FFFF88] transition-colors"
        >
          -
        </button>
        <div className="w-14 h-9 xs:w-16 xs:h-10 sm:w-20 sm:h-12 md:w-24 md:h-14 flex items-center justify-center text-lg xs:text-xl sm:text-2xl md:text-3xl font-bold font-mono text-black">
          {duration}
        </div>
        <button
          onClick={increaseTime}
          disabled={isLoading}
          className="aspect-square w-9 xs:w-10 sm:w-12 md:w-14 bg-[#B2DFDB] border-2 border-black font-bold text-lg xs:text-xl sm:text-2xl md:text-3xl text-black disabled:opacity-50 disabled:cursor-not-allowed hover:bg-[#80CBC4] transition-colors"
        >
          +
        </button>
      </div>

      {/* ปุ่ม SAVE */}
      <div className="flex justify-center">
        <button
          onClick={saveActivity}
          disabled={isLoading}
          className="px-5 py-2 xs:px-6 xs:py-2 sm:px-8 sm:py-3 md:px-10 md:py-4 border-2 border-black bg-[#B2DFDB] font-bold text-sm xs:text-base sm:text-lg md:text-xl text-black disabled:opacity-50 disabled:cursor-not-allowed hover:bg-[#80CBC4] transition-colors"
        >
          {isLoading ? "SAVING..." : "SAVE"}
        </button>
      </div>
    </div>
  );
};

export default Activity;
