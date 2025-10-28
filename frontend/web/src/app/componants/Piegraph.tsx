'use client';

import { useEffect, useState } from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer } from 'recharts';
import { kalService } from '@/app/services/kal_service';

interface NutritionPieChartProps {
  // ไม่ต้องรับ props แล้ว เพราะดึงข้อมูลจาก API
}

export default function NutritionPieChart({}: NutritionPieChartProps = {}) {
  const [macros, setMacros] = useState({ carbs: 0, fats: 0, protein: 0 });
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // ดึงข้อมูล macros จาก API
  useEffect(() => {
    const fetchMacros = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await kalService.getDailyMacros();

        // API ส่งกลับมาเป็น protein, fat, carbohydrate
        setMacros({
          carbs: data.carbohydrate || 0,
          fats: data.fat || 0,
          protein: data.protein || 0,
        });
      } catch (err: any) {
        console.error('Error fetching macros:', err);
        setError(err.message || 'ไม่สามารถดึงข้อมูลได้');
        // ตั้งค่าเริ่มต้นเมื่อเกิด error
        setMacros({ carbs: 0, fats: 0, protein: 0 });
      } finally {
        setLoading(false);
      }
    };

    fetchMacros();
  }, []);

  const total = macros.carbs + macros.fats + macros.protein;

  const data = [
    { name: 'Carbs', value: macros.carbs, color: '#98CEFB' },
    { name: 'Fat', value: macros.fats, color: '#F37A71' },
    { name: 'Protein', value: macros.protein, color: '#F3C767' },
  ];

  // ฟังก์ชันทำให้ label อยู่ข้างนอกวงกลม
  const renderLabel = ({ cx, cy, midAngle, outerRadius, percent, index }: any) => {
    const RADIAN = Math.PI / 180;
    const labelRadius = outerRadius + 10; // ลดระยะ label ให้อยู่ใกล้วงมากขึ้น
    const x = cx + labelRadius * Math.cos(-midAngle * RADIAN);
    const y = cy + labelRadius * Math.sin(-midAngle * RADIAN);

    const label = `${data[index].name} ${(percent * 100).toFixed(0)}%`;

    return (
      <text
        x={x}
        y={y}
        fill="black"
        textAnchor={x > cx ? 'start' : 'end'}
        dominantBaseline="central"
        fontSize={12} // ลดขนาดตัวอักษร
        fontFamily="monospace"
      >
        {label}
      </text>
    );
  };

  // แสดง Loading
  if (loading) {
    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-black font-mono text-sm">Loading...</p>
      </div>
    );
  }

  // แสดง Error
  if (error) {
    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-red-600 font-mono text-sm text-center">{error}</p>
      </div>
    );
  }

  // แสดงข้อความเมื่อไม่มีข้อมูล
  if (total === 0) {
    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-black font-mono text-sm text-center">ยังไม่มีข้อมูลโภชนาการวันนี้</p>
      </div>
    );
  }

  return (
    <div className="w-full h-full"> {/* แก้ไขเป็น h-full เพื่อเติมเต็มพื้นที่ของ parent */}
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={data}
            dataKey="value"
            cx="50%"
            cy="50%"
            innerRadius={0}
            outerRadius={150} // ลดขนาดวงกลม
            label={renderLabel}
          >
            {data.map((entry, index) => (
              <Cell key={index} fill={entry.color} />
            ))}
          </Pie>
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
