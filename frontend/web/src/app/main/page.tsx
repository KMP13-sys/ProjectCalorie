// app/main/page.tsx
'use client';

import NavBarUser from '../pages/componants/NavBarUser';

export default function MainPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#6fa85e] via-[#8bc273] to-[#a8d48f]">
      {/* NavBar */}
      <NavBarUser />
      
      {/* Main Content Area - ว่างไว้สำหรับเพิ่มเนื้อหาในภายหลัง */}
      <div className="container mx-auto px-4 py-8">
        <div 
          className="bg-white border-8 border-black p-8 text-center"
          style={{ 
            boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
            imageRendering: 'pixelated'
          }}
        >
          <h1 
            className="text-3xl font-bold text-gray-800 mb-4"
            style={{ 
              fontFamily: 'monospace',
              textShadow: '2px 2px 0px rgba(0,0,0,0.2)'
            }}
          >
            ◆ MAIN PAGE ◆
          </h1>
          
          <p 
            className="text-gray-600"
            style={{ fontFamily: 'monospace' }}
          >
            Content will be added here...
          </p>
          
          {/* Pixel Decorations */}
          <div className="flex justify-center gap-2 mt-6">
            <div className="w-4 h-4 bg-[#6fa85e]"></div>
            <div className="w-4 h-4 bg-[#8bc273]"></div>
            <div className="w-4 h-4 bg-[#a8d48f]"></div>
          </div>
        </div>
      </div>
    </div>
  );
}