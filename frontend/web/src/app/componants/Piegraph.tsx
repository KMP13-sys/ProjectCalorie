'use client';

import { useEffect, useState } from 'react';
import { PieChart, Pie, Cell } from 'recharts';
import { kalService } from '@/app/services/kal_service';

interface MacrosData {
  carbs: number;
  fats: number;
  protein: number;
}

export default function NutritionPieChart() {
  const [macros, setMacros] = useState<MacrosData>({ carbs: 0, fats: 0, protein: 0 });
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  // ดึงข้อมูล macros จาก API
  useEffect(() => {
    const fetchMacros = async () => {
      try {
        console.log('🥧 [Piegraph] Fetching macros data...');
        setLoading(true);
        setError(null);
        const data = await kalService.getDailyMacros();

        console.log('🥧 [Piegraph] Received data:', data);

        // API ส่งกลับมาเป็น protein, fat, carbohydrate (อาจเป็น string หรือ number)
        // ต้อง convert เป็น number เพื่อความปลอดภัย
        const carbs = typeof data.carbohydrate === 'string' ? parseFloat(data.carbohydrate) : data.carbohydrate;
        const fats = typeof data.fat === 'string' ? parseFloat(data.fat) : data.fat;
        const protein = typeof data.protein === 'string' ? parseFloat(data.protein) : data.protein;

        setMacros({
          carbs: carbs || 0,
          fats: fats || 0,
          protein: protein || 0,
        });

        console.log('🥧 [Piegraph] Macros set:', {
          carbs: carbs || 0,
          fats: fats || 0,
          protein: protein || 0,
        });
      } catch (err: any) {
        console.error('❌ [Piegraph] Error fetching macros:', err);
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

  console.log('🥧 [Piegraph] Render state:', { loading, error, total, macros });

  // แสดง Loading
  if (loading) {
    console.log('🥧 [Piegraph] Showing loading state');

    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-black font-mono text-sm">Loading...</p>
      </div>
    );
  }

  // แสดง Error
  if (error) {
    console.log('🥧 [Piegraph] Showing error state:', error);
    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-red-600 font-mono text-sm text-center">{error}</p>
      </div>
    );
  }

  // แสดงข้อความเมื่อไม่มีข้อมูล
  if (total === 0) {
    console.log('🥧 [Piegraph] Showing no data state (total = 0)');
    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-black font-mono text-sm text-center">ยังไม่มีข้อมูลโภชนาการวันนี้</p>
      </div>
    );
  }

  console.log('🥧 [Piegraph] Rendering chart with data:', data);

  return (
    <div className="w-full h-full flex items-center justify-center">
      {/* Pie Chart */}
      <div style={{ width: 500, height: 500 }}>
        <PieChart width={500} height={500}>
          <Pie
            data={data}
            cx={240}
            cy={220}
            labelLine={false}
            label={({
              cx,
              cy,
              midAngle,
              innerRadius,
              outerRadius,
              percent,
              index,
            }: any) => {
              const RADIAN = Math.PI / 180;
              const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
              const x = cx + radius * Math.cos(-midAngle * RADIAN);
              const y = cy + radius * Math.sin(-midAngle * RADIAN);

              return (
                <text
                  x={x}
                  y={y}
                  fill="#000000"
                  textAnchor={x > cx ? 'start' : 'end'}
                  dominantBaseline="central"
                  style={{ fontSize: 14, fontWeight: 'bold' }}
                >
                  {`${data[index].name} ${(percent * 100).toFixed(0)}%`}
                </text>
              );
            }}
            outerRadius={150}
            fill="#8884d8"
            dataKey="value"
          >
            {data.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={entry.color} />
            ))}
          </Pie>
        </PieChart>
      </div>
    </div>
  );
}
