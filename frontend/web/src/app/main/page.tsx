// app/main/page.tsx
'use client';

import NavBarUser from '../componants/NavBarUser';
import Kcalbar from '../componants/Kcalbar';
import Piegraph from '../componants/Piegraph';
import Activity from '../componants/activityfactor';
import Camera from  '../componants/camera';

export default function MainPage() {
  return (
    <div className="min-h-screen bg-gray-100">
      
      {/* NavBar */}
      <NavBarUser /> 

      {/* 🔹 MAIN LAYOUT AREA: จัดการองค์ประกอบทั้งหมด */}
      <div className="p-4 space-y-6">
        <div className="grid grid-cols-12 gap-6 h-[45vh]">
          
          {/* 1. row1 คอลัมม์1: Kcalbar & Pie Graph (col-span-4) */}
          <div className="col-span-4 flex flex-col space-y-4 bg-white rounded-lg shadow-md p-4">
            <div className="h-1/3">
              <Kcalbar /> 
            </div>
            <div className="flex-1">
              <Piegraph carbs={255} fats={14} protein={52} /> 
            </div>
          </div>
          
          {/* 2. row1 คอลัมม์2: Controls (activityfactor etc.) (col-span-2) */}
          <div className="col-span-2 flex flex-col space-y-8 bg-white rounded-lg shadow-md py-10 px-4">
              <div className=""> 
                  <Activity /> 
              </div>

              <div className="h-10 bg-gray-200 flex items-center justify-center rounded-md">
                  <Camera />
              </div>

              <div className="flex-1 border border-gray-300 p-2 rounded-md"> 
                  <p>ตัวนับ/เลือกกีฬาและเวลา</p>
              </div>
          </div>

          {/* 3. row1 คอลัมม์3: List MENU (col-span-3) */}
          <div className="col-span-3 bg-yellow-100 rounded-lg shadow-md p-4">
            <p className="font-bold">List MENU</p>
          </div>

          {/* 4. row1 คอลัมม์4: List sport (col-span-3) */}
          <div className="col-span-3 bg-yellow-100 rounded-lg shadow-md p-4">
            <p className="font-bold">List SPORT</p>
          </div>

        </div>

        <div className="grid grid-cols-4  h-[30vh]"></div>


        {/* ======================================================= */}
        {/* ROW 2: Grid 3 คอลัมน์ (1/2, 1/4, 1/4) - ยังคงใช้ Flexbox เพื่อรักษาความแม่นยำ 1/2 */}
        {/* ======================================================= */}
        
        {/* ลบ div กริดเปล่าที่เพิ่มมาเกินออกไป */}
        {/* <div className="grid grid-cols-4 h-[30vh]"></div> */} 

        <div className="flex space-x-6 h-[40vh] "> 
          
          {/* 5. row2 คอลัมม์ 1: กราฟสถิติ (มีความยาว 1/2 ของจอ) */}
          <div className="w-1/2 bg-white rounded-lg shadow-md p-4">
            <p className="font-bold">กราฟสถิติ</p>
          </div>

          {/* Container สำหรับคอลัมม์ 2 และ 3 (รวมกันเป็น 1/2 ของจอที่เหลือ) */}
          <div className="w-1/2 flex space-x-6">
            
            {/* 6. row2 คอลัมม์ 2: Recommend MENU (แบ่งครึ่งเท่าๆกันของครึ่งหน้าจอที่เหลือ = 1/4 ของจอ) */}
            <div className="flex-1 bg-white rounded-lg shadow-md p-4">
              <p className="font-bold">Recommend MENU</p>
            </div>
            
            {/* 7. row2 คอลัมม์ 3: Recommend sport (แบ่งครึ่งเท่าๆกันของครึ่งหน้าจอที่เหลือ = 1/4 ของจอ) */}
            <div className="flex-1 bg-white rounded-lg shadow-md p-4">
              <p className="font-bold">Recommend SPORT</p>
            </div>
            
          </div>
          
        </div>
        
      </div>
    </div>
  );
}