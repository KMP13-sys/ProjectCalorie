'use client';

import React, { useState, useEffect } from 'react';
import { kalService, CalorieStatus } from '../services/kal_service';

interface KcalBarProps {
  progressColor?: string;
  backgroundColor?: string;
  onRefresh?: () => void;
}

const KcalBar: React.FC<KcalBarProps> = ({
  progressColor = '#8bc273',
  backgroundColor = '#d1d5db',
  onRefresh
}) => {
  const [calorieStatus, setCalorieStatus] = useState<CalorieStatus | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    loadCalorieStatus();
  }, []);

  const loadCalorieStatus = async () => {
    setIsLoading(true);
    setErrorMessage(null);

    try {
      console.log('📊 Loading calorie status...');
      const status = await kalService.getCalorieStatus();
      console.log('✅ Loaded calorie status:', status);
      setCalorieStatus(status);
      setIsLoading(false);
    } catch (e: any) {
      console.error('❌ Error loading calorie status:', e);
      setErrorMessage(e.message);
      setIsLoading(false);
    }
  };

  // ฟังก์ชันสำหรับ refresh จากภายนอก
  const refresh = () => {
    loadCalorieStatus();
    onRefresh?.();
  };

  // แสดง loading
  if (isLoading) {
    return (
      <div className="w-full h-24 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  // แสดง error
  if (errorMessage) {
    return (
      <div className="w-full p-4 bg-red-100 border-4 border-red-600">
        <div className="flex items-center gap-2">
          <span className="text-xl">⚠</span>
          <div>
            <div className="text-sm font-bold text-red-800 font-mono">ไม่สามารถโหลดข้อมูลได้</div>
            <div className="text-xs text-red-600 font-mono">{errorMessage}</div>
          </div>
          <button
            onClick={() => loadCalorieStatus()}
            className="ml-auto px-3 py-1 bg-red-600 text-white font-mono font-bold border-2 border-black"
          >
            ลองใหม่
          </button>
        </div>
      </div>
    );
  }

  // ไม่มีข้อมูล หรือ targetCalories = 0
  if (!calorieStatus || calorieStatus.target_calories === 0) {
    return (
      <div className="w-full p-4 bg-[#FFF9BD] border-4 border-black">
        <div className="flex items-center gap-3">
          <span className="text-2xl">⚠️</span>
          <div className="flex-1">
            <div className="text-sm font-bold font-mono text-black">
              กรุณาเลือกระดับกิจกรรมประจำวัน
            </div>
            <div className="text-xs font-mono text-black">
              เพื่อคำนวณแคลอรี่ที่เหมาะสมกับคุณ
            </div>
          </div>
        </div>
      </div>
    );
  }

  // คำนวณค่าต่างๆ
  const current = calorieStatus.net_calories; // ใช้ net_calories (consumed - burned)
  const target = calorieStatus.target_calories;
  const remaining = calorieStatus.remaining_calories;

  const progress = target > 0 ? current / target : 0;
  const displayProgress = Math.min(progress, 1.0) * 100;
  const barColor = progress > 1.0 ? '#ef4444' : progressColor;

  return (
    <div className="w-full">
      {/* หัวข้อด้านบน */}
      <div className="flex justify-between items-center mb-3 px-4">
        <span 
          className="text-lg font-bold text-black"
          style={{ fontFamily: 'monospace' }}
        >
          Kcal
        </span>
        <span 
          className="text-lg font-bold text-black"
          style={{ fontFamily: 'monospace' }}
        >
          {Math.round(current)} Kcal from {Math.round(target)} Kcal
        </span>
      </div>

      {/* Progress Bar */}
      <div className="relative w-full">
        <div 
          className="h-12 rounded-full relative overflow-hidden"
          style={{ border: '4px solid black' }}
        >
          {/* Background (สีเทา) */}
          <div 
            className="absolute inset-0"
            style={{ backgroundColor }}
          />
          
          {/* Progress Bar (สีเขียวหรือแดง) */}
          <div 
            className="absolute inset-0 transition-all duration-500 ease-out"
            style={{
              backgroundColor: barColor,
              width: `${displayProgress}%`
            }}
          />
          
          {/* ข้อความคงเหลือด้านขวา */}
          <div className="absolute inset-0 flex items-center justify-end pr-8">
            <span 
              className="text-xl font-bold"
              style={{ 
                fontFamily: 'monospace',
                color: remaining > 0 ? '#000' : '#060606ff'
              }}
            >
              {remaining > 0
                ? `${Math.round(remaining)} Kcal`
                : `Over ${Math.round(-remaining)} Kcal!`}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default KcalBar;