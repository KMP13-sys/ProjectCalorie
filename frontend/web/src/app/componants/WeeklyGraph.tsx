'use client';

import { useState, useEffect, useRef } from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';
import kalService, { DailyCalorieData } from '../services/kal_service';

interface WeeklyChartData {
  name: string;
  NetCal: number;
  date: string;
}

export default function WeeklyGraph() {
  const [dimensions, setDimensions] = useState({ width: 0, height: 0 });
  const [weeklyData, setWeeklyData] = useState<WeeklyChartData[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string>('');
  const containerRef = useRef<HTMLDivElement>(null);

  // ========== โหลดข้อมูลกราฟรายสัปดาห์ ==========
  useEffect(() => {
    const loadWeeklyData = async () => {
      try {
        setIsLoading(true);
        setError('');

        console.log('🌐 [WeeklyGraph] Fetching weekly calories data...');
        const response = await kalService.getWeeklyCalories();

        console.log('✅ [WeeklyGraph] Data received:', response.data);

        // แปลงข้อมูลให้อยู่ในรูปแบบที่ Recharts ใช้งานได้
        const formattedData: WeeklyChartData[] = response.data.map((item: DailyCalorieData) => {
          // แปลงวันที่เป็นชื่อวัน (Mon, Tue, Wed, ...)
          const date = new Date(item.date);
          const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
          const dayName = dayNames[date.getDay()];

          return {
            name: dayName,
            NetCal: Math.round(item.net_calories),
            date: item.date,
          };
        });

        console.log('✅ [WeeklyGraph] Formatted data:', formattedData);
        setWeeklyData(formattedData);
      } catch (err: any) {
        console.error('❌ [WeeklyGraph] Error loading weekly data:', err);

        // แยกประเภท error
        let errorMsg = 'Failed to load weekly data';
        if (err.message?.includes('Session expired') || err.message?.includes('login again')) {
          errorMsg = 'Please login again';
        } else if (err.message?.includes('Network') || err.message?.includes('fetch')) {
          errorMsg = 'Network connection error';
        }

        setError(errorMsg);
      } finally {
        setIsLoading(false);
      }
    };

    loadWeeklyData();
  }, []);

  // ========== จัดการขนาดหน้าจอ ==========
  useEffect(() => {
    const updateDimensions = () => {
      if (containerRef.current) {
        const { width, height } = containerRef.current.getBoundingClientRect();

        if (width > 0 && height > 0) {
          setDimensions({ width, height });
        } else {
          setTimeout(updateDimensions, 200);
        }
      }
    };

    setTimeout(updateDimensions, 100);
    window.addEventListener('resize', updateDimensions);
    return () => window.removeEventListener('resize', updateDimensions);
  }, []);

  // ========== Render Loading State ==========
  if (isLoading) {
    return (
      <div
        ref={containerRef}
        className="w-full h-full bg-white rounded-lg shadow-md p-4 flex items-center justify-center"
        style={{ minHeight: '300px' }}
      >
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-green-500 mb-4"></div>
          <p className="text-gray-600 font-medium">Loading weekly data...</p>
        </div>
      </div>
    );
  }

  // ========== Render Error State ==========
  if (error) {
    return (
      <div
        ref={containerRef}
        className="w-full h-full bg-white rounded-lg shadow-md p-4 flex items-center justify-center"
        style={{ minHeight: '300px' }}
      >
        <div className="text-center">
          <div className="text-red-500 text-5xl mb-4">⚠️</div>
          <p className="text-red-600 font-medium mb-4">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-6 py-2 bg-green-500 text-white rounded-lg hover:bg-green-600 transition-colors"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  // ========== Render Empty State ==========
  if (weeklyData.length === 0) {
    return (
      <div
        ref={containerRef}
        className="w-full h-full bg-white rounded-lg shadow-md p-4 flex items-center justify-center"
        style={{ minHeight: '300px' }}
      >
        <div className="text-center">
          <div className="text-gray-400 text-5xl mb-4">📊</div>
          <p className="text-gray-500 font-medium">No weekly data available</p>
          <p className="text-gray-400 text-sm mt-2">Start tracking your calories to see the graph</p>
        </div>
      </div>
    );
  }

  // ========== Render Chart ==========
  return (
    <div
      ref={containerRef}
      className="w-full h-full bg-white rounded-lg shadow-md p-4"
      style={{ minHeight: '300px' }}
    >
      {dimensions.width > 0 && dimensions.height > 0 ? (
        <ResponsiveContainer width="100%" height="100%" minHeight={250}>
          <LineChart
            data={weeklyData}
            margin={{
              top: 5,
              right: 30,
              left: 20,
              bottom: 5,
            }}
          >
            {/* เส้น Grid แนวตั้งและแนวนอน */}
            <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />

            {/* แกน X (แสดงวันในสัปดาห์) */}
            <XAxis
              dataKey="name"
              stroke="#555"
              style={{ fontSize: '14px', fontWeight: 500 }}
            />

            {/* แกน Y (แสดงค่าแคลอรี่) */}
            <YAxis
              stroke="#555"
              style={{ fontSize: '14px', fontWeight: 500 }}
            />

            {/* Tooltip (แสดงค่าเมื่อผู้ใช้เลื่อนเมาส์ไปที่จุด) */}
            <Tooltip
              formatter={(value, name) => [`${value} Kcal`, 'Net Calories']}
              contentStyle={{
                borderRadius: '8px',
                border: '1px solid #ccc',
                boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
              }}
            />

            {/* Legend (คำอธิบายสีของเส้น) */}
            <Legend />

            {/* เส้นกราฟหลัก */}
            <Line
              type="monotone"
              dataKey="NetCal"
              name="Net Calories (Kcal)"
              stroke="#4caf50"
              strokeWidth={3}
              dot={{ r: 5, fill: '#4caf50', strokeWidth: 2, stroke: '#fff' }}
              activeDot={{ r: 8, fill: '#4caf50', strokeWidth: 2, stroke: '#fff' }}
            />
          </LineChart>
        </ResponsiveContainer>
      ) : (
        <div className="w-full h-full flex items-center justify-center">
          <p className="text-gray-500 font-mono text-sm">Initializing chart...</p>
        </div>
      )}
    </div>
  );
}