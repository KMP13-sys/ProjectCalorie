'use client';
import React, { useEffect, useState } from 'react';
import { listAPI, ActivityItem } from '@/services/list_service';

interface ListSportProps {}

/**
 * List Sport Component
 * แสดงรายการกิจกรรมออกกำลังกายที่ทำในวันนี้พร้อมแคลอรี่ที่เผาผลาญ
 * อัพเดทอัตโนมัติทุก 30 วินาที
 */
const ListSport: React.FC<ListSportProps> = () => {
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchActivities = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await listAPI.getTodayActivities();
        setActivities(data.activities);
      } catch (err: any) {
        console.error('Error fetching activities:', err);
        setError(err.message || 'ไม่สามารถดึงข้อมูลได้');
      } finally {
        setLoading(false);
      }
    };

    fetchActivities();
    const intervalId = setInterval(fetchActivities, 30000);
    return () => clearInterval(intervalId);
  }, []);

  return (
    <div
      className="h-[70vh] bg-[#DBF9FF] border-[5px] border-[#2a2a2a] shadow-[8px_8px_0_rgba(0,0,0,0.3)] p-5 flex flex-col"
      style={{ fontFamily: 'TA8bit' }}
    >
      {/* Header */}
      <h2 className="text-[24px] font-bold tracking-[4px] text-[#2a2a2a] text-center">
        LIST SPORT
      </h2>

      {/* Table Header */}
      <div className="mt-3 flex justify-between text-[#2a2a2a] text-[15px] font-bold">
        <span className="flex-1">SPORT</span>
        <span className="w-[40px] text-center">TIME</span>
        <span className="w-[50px] text-right">BURN</span>
      </div>

      <div className="h-[3px] bg-[#2a2a2a] my-2" />

      {/* Activity List */}
      <div className="overflow-y flex-1">
        {loading && (
          <div className="text-center text-[#2a2a2a] font-bold text-[16px] mt-5">
            Loading...
          </div>
        )}

        {error && !loading && (
          <div className="text-center text-red-600 font-bold text-[14px] mt-5">
            {error}
          </div>
        )}

        {!loading && !error && activities.length === 0 && (
          <div className="text-center text-[#2a2a2a] font-bold text-[16px] mt-5">
            ยังไม่มีรายการกีฬาวันนี้
          </div>
        )}

        {!loading && !error && activities.length > 0 && activities.map((activity, index) => (
          <div
            key={index}
            className="flex justify-between items-center mb-2 text-[#2a2a2a]"
          >
            <span className="flex-1 font-bold text-[16px] truncate pr-2">
              {activity.sport_name}
            </span>

            <span className="w-[40px] text-center font-bold text-[16px]">
              {activity.time}
            </span>

            <span className="w-[50px] text-right font-bold text-[16px]">
              -{activity.calories_burned}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ListSport;
