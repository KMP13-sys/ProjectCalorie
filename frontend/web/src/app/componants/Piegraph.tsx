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

  // ฟังก์ชันทำให้ label อยู่ตรงกลางของแต่ละ slice
  const renderLabel = ({ cx, cy, midAngle, innerRadius, outerRadius, percent, index }: any) => {
    const RADIAN = Math.PI / 180;
    const radius = innerRadius + (outerRadius - innerRadius) / 2;
    const x = cx + radius * Math.cos(-midAngle * RADIAN);
    const y = cy + radius * Math.sin(-midAngle * RADIAN);

    const label = `${data[index].name} ${(percent * 100).toFixed(0)}%`;

    return (
      <text
        x={x}
        y={y}
        fill="black"
        textAnchor="middle"
        dominantBaseline="central"
        fontSize={16}
        fontFamily="monospace"
        stroke="none"
      >
        {label}
      </text>
    );
  };

  return (
    <div className="w-full h-100">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart>
          <Pie
            data={data}
            dataKey="value"
            cx="50%"
            cy="50%"
            innerRadius={0}
            outerRadius={200}
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
