'use client';

import { useState, useEffect } from 'react';
import { kalService } from '../services/kal_service';

interface ActivityFactorButtonProps {
  onSaved?: (level: number, label: string) => void;
  onCaloriesUpdated?: () => void; // Callback เมื่ออัปเดตแคลอรี่สำเร็จ
}

const ACTIVITY_LEVELS = [
  { level: 1, label: 'น้อยมาก', description: 'นอนเฉยๆ', factor: 1.2 },
  { level: 2, label: 'น้อย', description: 'ทำงานเบาๆ เดินเล่น', factor: 1.4 },
  { level: 3, label: 'ปานกลาง', description: 'ยืน เดิน ยกของเล็กน้อย', factor: 1.6 },
  { level: 4, label: 'มาก', description: 'ออกกำลังกายหนัก', factor: 1.7 },
  { level: 5, label: 'มากที่สุด', description: 'นักกีฬา', factor: 1.9 },
];

// แปลง activity factor (1.2-1.9) เป็น level (1-5) และ label
function getLevelFromActivityFactor(factor: number): { level: number; label: string } {
  if (factor === 1.2) return { level: 1, label: 'น้อยมาก' };
  if (factor === 1.4) return { level: 2, label: 'น้อย' };
  if (factor === 1.6) return { level: 3, label: 'ปานกลาง' };
  if (factor === 1.7) return { level: 4, label: 'มาก' };
  if (factor === 1.9) return { level: 5, label: 'มากที่สุด' };
  return { level: 0, label: 'ไม่ทราบ' };
}

export default function ActivityFactorButton({ onSaved, onCaloriesUpdated }: ActivityFactorButtonProps) {
  const [savedLevel, setSavedLevel] = useState<number | null>(null);
  const [savedLabel, setSavedLabel] = useState<string | null>(null);
  const [isLocked, setIsLocked] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedLevel, setSelectedLevel] = useState<number | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    loadSavedData();
  }, []);

  // โหลดข้อมูลจาก API
  const loadSavedData = async () => {
    try {
      // เช็คจาก API ว่ามีข้อมูลวันนี้หรือไม่
      const status = await kalService.getCalorieStatus();

      console.log('🔍 Activity Level Check:');
      console.log('  - API activityLevel:', status.activity_level);
      console.log('  - API targetCalories:', status.target_calories);

      if (status.target_calories > 0 && status.activity_level > 0) {
        // มีข้อมูลใน API - ดึง activity level จาก DB
        const levelData = getLevelFromActivityFactor(status.activity_level);
        const level = levelData.level;
        const label = levelData.label;

        console.log(`✅ Found in API - Level ${level}: ${label} (factor: ${status.activity_level})`);

        setSavedLevel(level);
        setSavedLabel(label);
        setIsLocked(true);

        // บันทึกลง localStorage สำหรับ fallback
        localStorage.setItem('activity_level', level.toString());
        localStorage.setItem('activity_label', label);
        localStorage.setItem('activity_timestamp', new Date().toISOString());
      } else {
        // ยังไม่มีข้อมูล - ปลดล็อค
        setIsLocked(false);
        setSavedLevel(null);
        setSavedLabel(null);
      }
    } catch (e) {
      console.error('Error loading activity level status:', e);
      // ถ้า error ให้เช็คจาก localStorage แทน
      const storedLevel = localStorage.getItem('activity_level');
      const storedLabel = localStorage.getItem('activity_label');
      const storedTimestamp = localStorage.getItem('activity_timestamp');

      if (storedLevel && storedLabel && storedTimestamp) {
        const savedDate = new Date(storedTimestamp);
        const now = new Date();
        const isSameDay =
          savedDate.getFullYear() === now.getFullYear() &&
          savedDate.getMonth() === now.getMonth() &&
          savedDate.getDate() === now.getDate();

        setSavedLevel(parseInt(storedLevel));
        setSavedLabel(storedLabel);
        setIsLocked(isSameDay);
      }
    }
  };

  const handleSave = async () => {
    if (selectedLevel == null) {
      alert('⚠️ เลือกระดับก่อนนะ!');
      return;
    }

    const levelData = ACTIVITY_LEVELS.find((item) => item.level === selectedLevel)!;
    const activityFactor = levelData.factor;

    // แสดง loading
    setIsLoading(true);

    try {
      // คำนวณและบันทึก BMR, TDEE, Target Calories ทีเดียว
      console.log('🔢 Calculating and saving calories with factor:', activityFactor);
      const result = await kalService.calculateAndSaveCalories(activityFactor);
      console.log(`✅ Successfully calculated: BMR=${result.bmr}, TDEE=${result.tdee}, Target=${result.target_calories}`);

      // รอสักครู่เพื่อให้ DB commit เสร็จ
      await new Promise(resolve => setTimeout(resolve, 300));

      // บันทึก localStorage
      localStorage.setItem('activity_level', levelData.level.toString());
      localStorage.setItem('activity_label', levelData.label);
      localStorage.setItem('activity_timestamp', new Date().toISOString());

      setSavedLevel(levelData.level);
      setSavedLabel(levelData.label);
      setIsLocked(true);
      setModalOpen(false);
      setIsLoading(false);

      onSaved?.(levelData.level, levelData.label);
      onCaloriesUpdated?.(); // เรียก callback เพื่ออัปเดต Kcalbar
      alert(`✨ บันทึก LV.${levelData.level}: ${levelData.label} แล้ว!`);
    } catch (e: any) {
      console.error('❌ Error in calculateCalories:', e);
      setIsLoading(false);
      alert(`❌ เกิดข้อผิดพลาด: ${e.message}`);
    }
  };

  const handleClick = () => {
    if (isLocked) {
      alert('⭐ เลือกได้อีกครั้งพรุ่งนี้นะ!');
      return;
    }
    setModalOpen(true);
  };

  return (
    <>
      {/* ปุ่มหลัก */}
      <div
        onClick={handleClick}
        className={`cursor-pointer flex items-center h-15 px-4 border-4 border-black
          ${savedLevel ? 'bg-[#FFF9BD]' : 'bg-gray-200'}
          text-black shadow-[3px_3px_0_0_black]`}
      >
        {/* LV Box */}
        <div className="w-10 h-10 border-2 border-black bg-transparent flex items-center justify-center mr-2 text-white">
          {savedLevel ? (
            <div className="text-center text-[#000000]">
              <div className="text-[9px] font-bold font-mono">LV</div>
              <div className="text-[17px] font-bold font-mono">{savedLevel}</div>
            </div>
          ) : (
            <span className="text-xl text-[#000000]">🏃</span>
          )}
        </div>

        {/* Activity Text */}
        <div className="flex-1 flex flex-col justify-center">
          <span className="text-[11px] font-bold font-mono tracking-wider">ACTIVITY</span>
          <span className="text-[14px] font-bold font-mono">{savedLabel ?? 'กดเพื่อเลือก'}</span>
        </div>

        <span className="text-sm ml-2">▶</span>
      </div>

      {/* Modal */}
      {modalOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-70 z-50">
          <div className="bg-white border-4 border-black max-w-md w-full p-4 text-black">
            <h2 className="font-mono font-bold text-center bg-[#FFF9BD] py-2 mb-4">
              ACTIVITY LEVEL
            </h2>
            <div className="space-y-2 max-h-80 overflow-y-auto">
              {ACTIVITY_LEVELS.map((item) => (
                <div
                  key={item.level}
                  onClick={() => setSelectedLevel(item.level)}
                  className={`flex items-center p-2 cursor-pointer ${
                    selectedLevel === item.level ? 'bg-[#FFF9BD]' : 'bg-gray-200'
                  }`}
                >
                  <div className="w-9 h-9 border-2 border-black bg-white flex items-center justify-center mr-2 font-mono font-bold">
                    {item.level}
                  </div>
                  <div className="flex-1">
                    <div className="font-mono font-bold">{item.label}</div>
                    <div className="text-xs font-mono">{item.description}</div>
                  </div>
                  {selectedLevel === item.level && (
                    <div className="w-4 h-4 bg-black text-yellow-400 flex items-center justify-center font-mono text-[10px]">
                      ✔
                    </div>
                  )}
                </div>
              ))}
            </div>
            <div className="flex mt-4 gap-2">
              <button
                onClick={() => setModalOpen(false)}
                disabled={isLoading}
                className="flex-1 h-9 bg-gray-300 border border-black font-mono font-bold disabled:opacity-50"
              >
                ยกเลิก
              </button>
              <button
                onClick={handleSave}
                disabled={isLoading}
                className="flex-1 h-9 bg-[#FFF9BD] border border-black font-mono font-bold disabled:opacity-50"
              >
                {isLoading ? 'กำลังบันทึก...' : 'บันทึก'}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
