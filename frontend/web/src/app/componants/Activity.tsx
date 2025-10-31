// src/components/Activity.tsx
import React, { useState } from "react";

type ActivityProps = {
  onSave: (caloriesBurned: number) => void;
};

const Activity: React.FC<ActivityProps> = ({ onSave }) => {
  const [selectedActivity, setSelectedActivity] = useState("วิ่ง");
  const [duration, setDuration] = useState(0);

  // แคลอรี่ที่เผาผลาญต่อนาที (สมมติ)
  const caloriesPerMin: Record<string, number> = {
    วิ่ง: 10,
    ปั่นจักรยาน: 8,
    โยคะ: 4,
    เดิน: 5,
  };

  const increaseTime = () => setDuration((prev) => prev + 1);
  const decreaseTime = () => setDuration((prev) => (prev > 0 ? prev - 1 : 0));

  const saveActivity = () => {
    const burned = caloriesPerMin[selectedActivity] * duration;
    onSave(burned);
    alert(`บันทึกแล้ว! เผาผลาญไป ${burned} kcal`);
  };

  return (
    <div className="bg-white border-2 sm:border-4 border-black shadow-lg p-3 sm:p-4 md:p-6 w-[95%] sm:w-full max-w-[280px] xs:max-w-[320px] sm:max-w-md md:max-w-lg lg:max-w-xl mx-auto text-black">
      {/* Dropdown เลือกกิจกรรม */}
      <div className="mb-3 sm:mb-5">
        <select
          value={selectedActivity}
          onChange={(e) => setSelectedActivity(e.target.value)}
          className="w-full h-10 xs:h-11 sm:h-12 md:h-14 lg:h-16 px-2 border-2 border-black bg-orange-100 font-mono font-bold text-sm xs:text-base sm:text-lg md:text-xl text-black"
        >
          {Object.keys(caloriesPerMin).map((activity) => (
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
          className="aspect-square w-9 xs:w-10 sm:w-12 md:w-14 bg-yellow-200 border-2 border-black font-bold text-lg xs:text-xl sm:text-2xl md:text-3xl text-black"
        >
          -
        </button>
        <div className="w-14 h-9 xs:w-16 xs:h-10 sm:w-20 sm:h-12 md:w-24 md:h-14 flex items-center justify-center text-lg xs:text-xl sm:text-2xl md:text-3xl font-bold font-mono text-black">
          {duration}
        </div>
        <button
          onClick={increaseTime}
          className="aspect-square w-9 xs:w-10 sm:w-12 md:w-14 bg-teal-200 border-2 border-black font-bold text-lg xs:text-xl sm:text-2xl md:text-3xl text-black"
        >
          +
        </button>
      </div>

      {/* ปุ่ม SAVE */}
      <div className="flex justify-center">
        <button
          onClick={saveActivity}
          className="px-5 py-2 xs:px-6 xs:py-2 sm:px-8 sm:py-3 md:px-10 md:py-4 border-2 border-black bg-teal-200 font-bold text-sm xs:text-base sm:text-lg md:text-xl text-black"
        >
          SAVE
        </button>
      </div>
    </div>
  );
};

export default Activity;