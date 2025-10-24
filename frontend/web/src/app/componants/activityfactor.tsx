'use client';

import { useState, useEffect } from 'react';

interface ActivityFactorButtonProps {
  onSaved?: (level: number, label: string) => void;
}

const ACTIVITY_LEVELS = [
  { level: 1, label: 'น้อยมาก', description: 'นอนเฉยๆ' },
  { level: 2, label: 'น้อย', description: 'ทำงานเบาๆ เดินเล่น' },
  { level: 3, label: 'ปานกลาง', description: 'ยืน เดิน ยกของเล็กน้อย' },
  { level: 4, label: 'มาก', description: 'ออกกำลังกายหนัก' },
  { level: 5, label: 'มากที่สุด', description: 'นักกีฬา' },
];

export default function ActivityFactorButton({ onSaved }: ActivityFactorButtonProps) {
  const [savedLevel, setSavedLevel] = useState<number | null>(null);
  const [savedLabel, setSavedLabel] = useState<string | null>(null);
  const [isLocked, setIsLocked] = useState(false);
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedLevel, setSelectedLevel] = useState<number | null>(null);

  useEffect(() => {
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
  }, []);

  const handleSave = () => {
    if (selectedLevel == null) {
      alert('⚠️ เลือกระดับก่อนนะ!');
      return;
    }

    const levelData = ACTIVITY_LEVELS.find((item) => item.level === selectedLevel)!;
    const now = new Date();

    localStorage.setItem('activity_level', levelData.level.toString());
    localStorage.setItem('activity_label', levelData.label);
    localStorage.setItem('activity_timestamp', now.toISOString());

    setSavedLevel(levelData.level);
    setSavedLabel(levelData.label);
    setIsLocked(true);
    setModalOpen(false);

    onSaved?.(levelData.level, levelData.label);
    alert(`✨ บันทึก LV.${levelData.level}: ${levelData.label} แล้ว!`);
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
          ${savedLevel ? 'bg-yellow-200' : 'bg-gray-700'} 
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
            <h2 className="font-mono font-bold text-center bg-yellow-200 py-2 mb-4">
              ACTIVITY LEVEL
            </h2>
            <div className="space-y-2 max-h-80 overflow-y-auto">
              {ACTIVITY_LEVELS.map((item) => (
                <div
                  key={item.level}
                  onClick={() => setSelectedLevel(item.level)}
                  className={`flex items-center p-2 cursor-pointer ${
                    selectedLevel === item.level ? 'bg-yellow-100' : 'bg-gray-200'
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
                className="flex-1 h-9 bg-gray-300 border border-black font-mono font-bold"
              >
                ยกเลิก
              </button>
              <button
                onClick={handleSave}
                className="flex-1 h-9 bg-yellow-100 border border-black font-mono font-bold"
              >
                บันทึก
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
