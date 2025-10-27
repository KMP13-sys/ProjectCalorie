'use client';

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

// ข้อมูลจำลอง (Mock Data): แคลอรี่สุทธิ (Net Calories: Intake - Burned) ในแต่ละวัน
// ในการใช้งานจริง คุณจะต้องดึงข้อมูลนี้มาจาก API หรือ Database
const weeklyData = [
  { name: 'Mon', NetCal: 1850 },
  { name: 'Tue', NetCal: 2100 },
  { name: 'Wed', NetCal: 1500 },
  { name: 'Thu', NetCal: 2400 },
  { name: 'Fri', NetCal: 1950 },
  { name: 'Sat', NetCal: 2600 },
  { name: 'Sun', NetCal: 1700 },
];

export default function WeeklyGraph() {
  return (
    <div className="w-full h-full bg-white rounded-lg shadow-md">
      {/* ResponsiveContainer ช่วยให้กราฟปรับขนาดตาม div แม่ */}
      <ResponsiveContainer width="100%" height="90%">
        <LineChart
          data={weeklyData}
          margin={{
            top: 5,
            right: 30,
            left: 20,
            bottom: 0,
          }}
        >
          {/* เส้น Grid แนวตั้งและแนวนอน */}
          <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
          
          {/* แกน X (แสดงวันในสัปดาห์) */}
          <XAxis dataKey="name" stroke="#555" />
          
          {/* แกน Y (แสดงค่าแคลอรี่) */}
          <YAxis stroke="#555" />
          
          {/* Tooltip (แสดงค่าเมื่อผู้ใช้เลื่อนเมาส์ไปที่จุด) */}
          <Tooltip 
            formatter={(value, name) => [`${value} Kcal`, 'แคลอรี่สุทธิ']} 
            contentStyle={{ borderRadius: '8px', border: '1px solid #ccc' }}
          />
          
          {/* Legend (คำอธิบายสีของเส้น) */}
          <Legend />
          
          {/* เส้นกราฟหลัก */}
          <Line 
            type="monotone" // รูปแบบเส้นโค้ง
            dataKey="NetCal" 
            name="แคลอรี่สุทธิ"
            stroke="#4caf50" // สีเขียวที่ดูสุขภาพดี
            strokeWidth={3}
            dot={{ r: 5, fill: '#4caf50' }} // จุดแสดงข้อมูล
            activeDot={{ r: 8 }} // จุดเมื่อ hover
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}