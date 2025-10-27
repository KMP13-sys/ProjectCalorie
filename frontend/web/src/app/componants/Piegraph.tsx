'use client';

import { PieChart, Pie, Cell, ResponsiveContainer } from 'recharts';

interface NutritionPieChartProps {
  carbs: number;
  fats: number;
  protein: number;
}

export default function NutritionPieChart({ carbs, fats, protein }: NutritionPieChartProps) {
  const total = carbs + fats + protein;

  const data = [
    { name: 'Carbs', value: carbs, color: '#98CEFB' },
    { name: 'Fat', value: fats, color: '#F37A71' },
    { name: 'Protein', value: protein, color: '#F3C767' },
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

  return (
    <div className="w-full h-90"> {/* ลดความสูง container */}
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
