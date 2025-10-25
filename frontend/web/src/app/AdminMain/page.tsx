'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import NavbarAdmin from '../componants/NavBarAdmin';
import { authAPI } from '../services/auth_service';

export default function AdminMainPage() {
  const router = useRouter();
  const [showLogoutPopup, setShowLogoutPopup] = useState(false);

  const handleFoodClick = () => {
    router.push('/AboutFood');
  };

  const handleUserClick = () => {
    router.push('/AboutUser')
  };

  const handleLogout = () => {
    setShowLogoutPopup(true);
  };

  const confirmLogout = () => {
    authAPI.logout();
    router.push('/login');
  };

  const cancelLogout = () => {
    setShowLogoutPopup(false);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#6fa85e] via-[#8bc273] to-[#a8d48f] flex flex-col relative overflow-hidden">
      
      {/* Pixel Grid Background Pattern */}
      <div 
        className="absolute inset-0 opacity-10 pointer-events-none"
        style={{
          backgroundImage: `
            linear-gradient(0deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent),
            linear-gradient(90deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent)
          `,
          backgroundSize: '50px 50px'
        }}
      ></div>

      {/* Floating Pixel Decorations */}
      <div className="absolute top-20 left-10 w-6 h-6 bg-yellow-300 animate-bounce"></div>
      <div className="absolute top-32 right-16 w-4 h-4 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.3s' }}></div>
      <div className="absolute bottom-32 left-20 w-5 h-5 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.6s' }}></div>
      <div className="absolute top-1/2 right-24 w-4 h-4 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.9s' }}></div>

      {/* Navbar */}
      <div className="relative z-10">
        <NavbarAdmin />
      </div>

      {/* Main Content */}
      <div 
      className="flex-1 flex flex-col items-center justify-center px-4 py-12 b relative z-10"
      style={{ background: '#DBFFC8' }}
      >
         
        {/* Header with Pixel Art Style */}
        <div className="mb-12 relative">
          <div 
            className="bg-white border-8 border-black relative"
            style={{ 
              boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Decorative Corner Pixels */}
            <div className="absolute -top-2 -left-2 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute -top-2 -right-2 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute -bottom-2 -left-2 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute -bottom-2 -right-2 w-6 h-6 bg-[#6fa85e]"></div>

            {/* Header Bar */}
            <div className="bg-gradient-to-r from-[#6fa85e] to-[#8bc273] px-24 py-6">
              <h1 
                className="text-5xl font-bold text-white text-center tracking-[0.3em]"
                style={{ 
                  fontFamily: 'monospace',
                  textShadow: '4px 4px 0px rgba(0,0,0,0.3)'
                }}
              >
                ◆ ADMIN ◆
              </h1>
            </div>
          </div>
        </div>

        {/* Cards Container */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-10 max-w-5xl w-full mb-12">
          
          {/* About Food Card */}
          <div 
            onClick={handleFoodClick}
            className="bg-white border-8 border-black cursor-pointer hover:translate-x-1 hover:translate-y-1 transition-transform duration-100 relative group"
            style={{ 
              boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Decorative Corner Pixels */}
            <div className="absolute -top-2 -left-2 w-4 h-4 bg-yellow-300"></div>
            <div className="absolute -top-2 -right-2 w-4 h-4 bg-yellow-300"></div>
            <div className="absolute -bottom-2 -left-2 w-4 h-4 bg-yellow-300"></div>
            <div className="absolute -bottom-2 -right-2 w-4 h-4 bg-yellow-300"></div>

            {/* Header Bar */}
            <div className="bg-gradient-to-r from-[#FFEB3B] to-[#FFCCBC] border-b-6 border-black py-3">
              <div className="flex justify-center gap-2">
                <div className="w-3 h-3 bg-[#FFA726]"></div>
                <div className="w-3 h-3 bg-[#FF7043]"></div>
                <div className="w-3 h-3 bg-[#FFA726]"></div>
              </div>
            </div>

            {/* Content */}
            <div className="bg-gradient-to-br from-[#FFF9C4] to-[#FFCCBC] p-12 flex flex-col items-center justify-center space-y-6 min-h-[400px]">
              
              {/* Icon Container with Pixel Border */}
              <div 
                className="bg-white border-6 border-black p-6 relative"
                style={{ boxShadow: '6px 6px 0px rgba(0,0,0,0.2)' }}
              >
                <div className="absolute -top-1 -left-1 w-3 h-3 bg-[#FFA726]"></div>
                <div className="absolute -top-1 -right-1 w-3 h-3 bg-[#FFA726]"></div>
                <div className="absolute -bottom-1 -left-1 w-3 h-3 bg-[#FFA726]"></div>
                <div className="absolute -bottom-1 -right-1 w-3 h-3 bg-[#FFA726]"></div>
                
                <div className="relative w-32 h-32">
                  <Image
                    src="/pic/logo(dark).png"
                    alt="Food Icon"
                    fill
                    className="object-contain"
                    style={{ imageRendering: 'pixelated' }}
                  />
                </div>
              </div>
              
              {/* Title with Pixel Font */}
              <div className="text-center">
                <h2 
                  className="text-3xl font-bold text-gray-900 mb-2"
                  style={{ 
                    fontFamily: 'monospace',
                    textShadow: '3px 3px 0px rgba(0,0,0,0.2)'
                  }}
                >
                About Food
                </h2>
                <p 
                  className="text-gray-700 font-bold"
                  style={{ fontFamily: 'monospace' }}
                >
                  จัดการข้อมูลอาหาร
                </p>
              </div>

              {/* Pixel Arrow */}
              <div className="flex gap-1 opacity-50 group-hover:opacity-100 transition-opacity">
                <div className="w-3 h-3 bg-black"></div>
                <div className="w-3 h-3 bg-black"></div>
                <div className="w-3 h-3 bg-black"></div>
                <div className="w-3 h-3 bg-transparent"></div>
                <div className="w-3 h-3 bg-black"></div>
              </div>
            </div>
          </div>

          {/* About UserAccount Card */}
          <div 
            onClick={handleUserClick}
            className="bg-white border-8 border-black cursor-pointer hover:translate-x-1 hover:translate-y-1 transition-transform duration-100 relative group"
            style={{ 
              boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Decorative Corner Pixels */}
            <div className="absolute -top-2 -left-2 w-4 h-4 bg-[#8bc273]"></div>
            <div className="absolute -top-2 -right-2 w-4 h-4 bg-[#8bc273]"></div>
            <div className="absolute -bottom-2 -left-2 w-4 h-4 bg-[#8bc273]"></div>
            <div className="absolute -bottom-2 -right-2 w-4 h-4 bg-[#8bc273]"></div>

            {/* Header Bar */}
            <div className="bg-gradient-to-r from-[#C5E1A5] to-[#AED581] border-b-6 border-black py-3">
              <div className="flex justify-center gap-2">
                <div className="w-3 h-3 bg-[#8bc273]"></div>
                <div className="w-3 h-3 bg-[#9CCC65]"></div>
                <div className="w-3 h-3 bg-[#8bc273]"></div>
              </div>
            </div>

            {/* Content */}
            <div className="bg-gradient-to-br from-[#E8F5E9] to-[#C5E1A5] p-12 flex flex-col items-center justify-center space-y-6 min-h-[400px]">
              
              {/* Icon Container with Pixel Border */}
              <div 
                className="bg-white border-6 border-black p-6 relative"
                style={{ boxShadow: '6px 6px 0px rgba(0,0,0,0.2)' }}
              >
                <div className="absolute -top-1 -left-1 w-3 h-3 bg-[#8bc273]"></div>
                <div className="absolute -top-1 -right-1 w-3 h-3 bg-[#8bc273]"></div>
                <div className="absolute -bottom-1 -left-1 w-3 h-3 bg-[#8bc273]"></div>
                <div className="absolute -bottom-1 -right-1 w-3 h-3 bg-[#8bc273]"></div>
                
                <div className="relative w-32 h-32">
                  <Image
                    src="/pic/users.png"
                    alt="User Icon"
                    fill
                    className="object-contain"
                    style={{ imageRendering: 'pixelated' }}
                  />
                </div>
              </div>
              
              {/* Title with Pixel Font */}
              <div className="text-center">
                <h2 
                  className="text-3xl font-bold text-gray-900 mb-2"
                  style={{ 
                    fontFamily: 'monospace',
                    textShadow: '3px 3px 0px rgba(0,0,0,0.2)'
                  }}
                >
                About UserAccount
                </h2>
                <p 
                  className="text-gray-700 font-bold"
                  style={{ fontFamily: 'monospace' }}
                >
                  จัดการบัญชีผู้ใช้
                </p>
              </div>

              {/* Pixel Arrow */}
              <div className="flex gap-1 opacity-50 group-hover:opacity-100 transition-opacity">
                <div className="w-3 h-3 bg-black"></div>
                <div className="w-3 h-3 bg-black"></div>
                <div className="w-3 h-3 bg-black"></div>
                <div className="w-3 h-3 bg-transparent"></div>
                <div className="w-3 h-3 bg-black"></div>
              </div>
            </div>
          </div>
        </div>

        {/* Logout Button with Pixel Style */}
        <div className="w-full max-w-lg relative">
          <button
            onClick={handleLogout}
            className="w-full bg-gradient-to-r from-[#FF8A80] to-[#FF6B6B] hover:from-[#FF6B6B] hover:to-[#FF5252] border-8 border-black text-white font-bold py-8 px-12 text-2xl transition-all hover:translate-x-1 hover:translate-y-1 relative"
            style={{ 
              fontFamily: 'monospace',
              boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
              textShadow: '3px 3px 0px rgba(0,0,0,0.5)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Decorative Corner Pixels */}
            <div className="absolute -top-2 -left-2 w-6 h-6 bg-red-900"></div>
            <div className="absolute -top-2 -right-2 w-6 h-6 bg-red-900"></div>
            <div className="absolute -bottom-2 -left-2 w-6 h-6 bg-red-900"></div>
            <div className="absolute -bottom-2 -right-2 w-6 h-6 bg-red-900"></div>

            ▶ LOG OUT ◀
          </button>
        </div>
      </div>

      {/* Logout Confirmation Popup */}
      {showLogoutPopup && (
        <div className="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
          <div
            className="bg-gradient-to-b from-[#ff8787] to-[#ff6b6b] border-8 border-black w-full max-w-md relative"
            style={{
              boxShadow: '12px 12px 0px rgba(0,0,0,0.5)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Decorative Corner Pixels */}
            <div className="absolute -top-2 -left-2 w-6 h-6 bg-red-900"></div>
            <div className="absolute -top-2 -right-2 w-6 h-6 bg-red-900"></div>
            <div className="absolute -bottom-2 -left-2 w-6 h-6 bg-red-900"></div>
            <div className="absolute -bottom-2 -right-2 w-6 h-6 bg-red-900"></div>

            <div className="p-8 text-center relative">
              {/* Pixel Art Header Bar */}
              <div className="bg-red-900 border-b-4 border-black -mx-8 -mt-8 mb-6 py-3">
                <h3 className="text-2xl font-bold text-white tracking-wider" style={{ textShadow: '3px 3px 0px rgba(0,0,0,0.3)', fontFamily: 'monospace' }}>
                  ⚠ WARNING ⚠
                </h3>
              </div>

              {/* Warning Icon */}
              <div className="flex justify-center mb-4">
                <div className="relative w-20 h-20">
                  <div className="grid grid-cols-5 gap-0">
                    <div className="w-4 h-4 bg-transparent"></div>
                    <div className="w-4 h-4 bg-transparent"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-transparent"></div>
                    <div className="w-4 h-4 bg-transparent"></div>

                    <div className="w-4 h-4 bg-transparent"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-yellow-500"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-transparent"></div>

                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-yellow-500"></div>
                    <div className="w-4 h-4 bg-black"></div>
                    <div className="w-4 h-4 bg-yellow-500"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>

                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-yellow-500"></div>
                    <div className="w-4 h-4 bg-black"></div>
                    <div className="w-4 h-4 bg-yellow-500"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>

                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>
                    <div className="w-4 h-4 bg-yellow-400"></div>
                  </div>
                </div>
              </div>

              {/* Message */}
              <div className="bg-white border-4 border-black p-4 mb-6">
                <p className="text-xl font-bold text-gray-800 mb-2" style={{ fontFamily: 'monospace' }}>
                  ออกจากระบบ?
                </p>
                <p className="text-sm text-gray-600" style={{ fontFamily: 'monospace' }}>
                  คุณต้องการออกจากระบบหรือไม่?
                </p>
              </div>

              {/* Buttons */}
              <div className="flex gap-4 justify-center">
                <button
                  onClick={cancelLogout}
                  className="bg-gradient-to-r from-gray-400 to-gray-500 hover:from-gray-500 hover:to-gray-600 border-4 border-black text-white font-bold py-3 px-8 transition-all hover:translate-x-0.5 hover:translate-y-0.5"
                  style={{
                    fontFamily: 'monospace',
                    boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
                    textShadow: '2px 2px 0px rgba(0,0,0,0.5)'
                  }}
                >
                  ยกเลิก
                </button>
                <button
                  onClick={confirmLogout}
                  className="bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 border-4 border-black text-white font-bold py-3 px-8 transition-all hover:translate-x-0.5 hover:translate-y-0.5"
                  style={{
                    fontFamily: 'monospace',
                    boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
                    textShadow: '2px 2px 0px rgba(0,0,0,0.5)'
                  }}
                >
                  ออกจากระบบ
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}