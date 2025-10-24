// app/main/page.tsx
'use client';

import NavBarUser from '../componants/NavBarUser';
import Kcalbar from '../componants/Kcalbar';
import Piegraph from '../componants/Piegraph';
import Activity from '../componants/activityfactor';

export default function MainPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#6fa85e] via-[#8bc273] to-[#a8d48f]">
      {/* 🔹 NavBar เต็มความกว้างด้านบน */}
      <NavBarUser />

      {/* 🔹 Main Area (แบ่งซ้าย-ขวาหลัง Navbar เท่านั้น) */}
      <div className="flex min-h-[calc(100vh-64px)]"> 
        {/* ↑ สมมติ NavBar สูง ~64px ปรับตามจริงได้ */}

        {/* ฝั่งซ้าย */}
        <div className="w-1/2 flex flex-col items-start justify-center bg-[#e5f4de]">
          <div className="text-center px-5 py-10 w-full">
            <Kcalbar />

            <div className="text-center py-10 w-full">
              <Piegraph carbs={255} fats={14} protein={52} />
            </div>

          </div>
        </div>


        {/* ฝั่งขวา */}
        <div className="w-1/2 flex flex-col items-start justify-start bg-[#e5f4de]">
          <div className="text-center px-5 py-12 w-full">
            <Activity />
          </div>
        </div>
      </div>
    </div>
  );
}
