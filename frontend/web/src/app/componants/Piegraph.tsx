'use client';

import { useEffect, useState } from 'react';
import { PieChart, Pie, Cell } from 'recharts';
import { kalService } from '@/services/kal_service';

interface MacrosData {
  carbs: number;
  fats: number;
  protein: number;
}

/**
 * Nutrition Pie Chart Component
 * แสดงกราฟวงกลมสัดส่วนสารอาหาร (Carbs, Fat, Protein) ที่รับประทานในวันนี้
 */
export default function NutritionPieChart() {
  const [macros, setMacros] = useState<MacrosData>({ carbs: 0, fats: 0, protein: 0 });
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchMacros = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await kalService.getDailyMacros();

        const carbs = typeof data.carbohydrate === 'string' ? parseFloat(data.carbohydrate) : data.carbohydrate;
        const fats = typeof data.fat === 'string' ? parseFloat(data.fat) : data.fat;
        const protein = typeof data.protein === 'string' ? parseFloat(data.protein) : data.protein;

        setMacros({
          carbs: carbs || 0,
          fats: fats || 0,
          protein: protein || 0,
        });
      } catch (err: any) {
        console.error('Error fetching macros:', err);
        setError(err.message || 'ไม่สามารถดึงข้อมูลได้');
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

  if (loading) {
    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-black font-mono text-sm">Loading...</p>
      </div>
    );
  }

  if (error) {
    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-red-600 font-mono text-sm text-center">{error}</p>
      </div>
    );
  }

  if (total === 0) {
    return (
      <div className="w-full h-full flex items-center justify-center">
        <p className="text-black font-mono text-sm text-center">ยังไม่มีข้อมูลโภชนาการวันนี้</p>
      </div>
    );
  }

  return (
    <div className="w-full h-full flex items-center justify-center">
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
