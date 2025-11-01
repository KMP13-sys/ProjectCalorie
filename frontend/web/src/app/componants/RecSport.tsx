'use client';
import React, { useEffect, useState } from 'react';
import recommendAPI from '@/services/recommend_service';
import { authAPI } from '@/services/auth_service';

interface SportItem {
  id: number;
  name: string;
}

interface RacSportProps {
  remainingCalories?: number;
  refreshTrigger?: number;
}

/**
 * Recommend Sport Component
 * แสดงกีฬาที่แนะนำตามประวัติการออกกำลังกาย
 */
const RacSport: React.FC<RacSportProps> = ({ remainingCalories = 0, refreshTrigger = 0 }) => {
  const [sportList, setSportList] = useState<SportItem[]>([]);
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

      const response = await recommendAPI.getSportRecommendations(user.user_id, 5);

      if (response.success && response.recommendations) {
        const items: SportItem[] = response.recommendations
          .map((name, index) => ({
            id: index + 1,
            name: name,
          }))
          .slice(0, 3);

        setSportList(items);
      } else {
        setSportList([]);
        setError(response.message || 'ไม่พบข้อมูลแนะนำ');
      }
    } catch (err: any) {
      console.error('Error fetching sport recommendations:', err);
      setError(err.message || 'เกิดข้อผิดพลาดในการดึงข้อมูล');
      setSportList([]);
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
        RECOMMEND SPORT
      </div>

      {/* Table Header */}
      <div className="flex justify-between text-[#2a2a2a] text-[15px] font-bold mb-2">
        <span className="flex-1">SPORT</span>
      </div>

      <div className="h-[3px] bg-[#2a2a2a] mb-4" />

      {/* Sport List */}
      <div className="flex-1 overflow-y-auto">
        {loading ? (
          <div className="text-center text-[#2a2a2a] font-bold text-[16px] mt-5">
            กำลังโหลด...
          </div>
        ) : error ? (
          <div className="text-center text-[#2a2a2a] font-bold text-[14px] mt-5">
            {error}
          </div>
        ) : sportList.length > 0 ? (
          <div className="space-y-3">
            {sportList.map((item) => (
              <div
                key={item.id}
                className="flex items-center text-[16px] text-[#2a2a2a] font-bold"
              >
                <span className="flex-1 truncate">{item.name}</span>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center text-[#2a2a2a] font-bold text-[14px] mt-5">
            ไม่มีกีฬาที่เหมาะสม
          </div>
        )}
      </div>
    </div>
  );
};

export default RacSport;
