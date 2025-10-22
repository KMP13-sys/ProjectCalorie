import React from 'react';

interface KcalBarProps {
  current?: number;
  target?: number;
  progressColor?: string;
  backgroundColor?: string;
}

const KcalBar: React.FC<KcalBarProps> = ({
  current = 1006,
  target = 2200,
  progressColor = '#8bc273',
  backgroundColor = '#d1d5db'
}) => {
  const remaining = target - current;
  const progress = current / target;
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