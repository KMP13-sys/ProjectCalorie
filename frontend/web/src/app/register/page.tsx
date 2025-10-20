'use client';

import { useState } from 'react';

interface ProfilePageProps {
  onNavigateToBack?: () => void;
  onNavigateToEdit?: () => void;
  onLogout?: () => void;
}

export default function ProfilePage({ onNavigateToBack, onNavigateToEdit, onLogout }: ProfilePageProps) {
  // ข้อมูลโปรไฟล์ตัวอย่าง (ในการใช้งานจริงจะดึงจาก API)
  const [profileData] = useState({
    username: 'TEST1',
    weight: '45 kg',
    height: '155 cm',
    age: '15 years',
    gender: 'FEMALE',
    goal: 'MAINTAIN WEIGHT'
  });

  const handleBack = () => {
    if (onNavigateToBack) {
      onNavigateToBack();
    }
  };

  const handleEdit = () => {
    if (onNavigateToEdit) {
      onNavigateToEdit();
    }
  };

  const handleLogout = () => {
    if (onLogout) {
      onLogout();
    } else {
      // ลบข้อมูล session/token และ redirect
      window.location.href = '/pages/login';
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#6fa85e] via-[#8bc273] to-[#a8d48f] flex items-center justify-center p-8 relative overflow-hidden">
      {/* Pixel Grid Background Pattern */}
      <div 
        className="absolute inset-0 opacity-10"
        style={{
          backgroundImage: `
            linear-gradient(0deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent),
            linear-gradient(90deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent)
          `,
          backgroundSize: '50px 50px'
        }}
      ></div>

      {/* Floating Pixel Decorations */}
      <div className="absolute top-10 left-10 w-6 h-6 bg-yellow-300 animate-bounce"></div>
      <div className="absolute top-20 right-16 w-4 h-4 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.3s' }}></div>
      <div className="absolute bottom-20 left-20 w-5 h-5 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.6s' }}></div>

      <div className="relative z-10 w-full max-w-2xl">
        <div 
          className="bg-white border-8 border-black relative"
          style={{ 
            boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
            imageRendering: 'pixelated'
          }}
        >
          {/* Decorative Corner Pixels */}
          <div className="absolute top-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
          <div className="absolute top-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>
          <div className="absolute bottom-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
          <div className="absolute bottom-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>

          {/* Header Bar */}
          <div className="bg-gradient-to-r from-[#6fa85e] to-[#8bc273] border-b-6 border-black py-3 px-6">
            <h2 
              className="text-2xl font-bold text-white text-center tracking-wider"
              style={{ 
                fontFamily: 'monospace',
                textShadow: '3px 3px 0px rgba(0,0,0,0.3)'
              }}
            >
              ◆ PROFILE ◆
            </h2>
          </div>

          <div className="p-8">
            {/* Profile Avatar Section */}
            <div className="flex flex-col items-center mb-6">
              <div 
                className="bg-gradient-to-br from-[#a8d48f] to-[#8bc273] border-4 border-black p-8 mb-3 relative"
                style={{ boxShadow: '6px 6px 0px rgba(0,0,0,0.2)' }}
              >
                {/* Pixel Art User Icon */}
                <div className="w-32 h-32 bg-white border-4 border-gray-800 flex items-center justify-center relative">
                  {/* Simple pixel art person */}
                  <div className="relative">
                    {/* Head */}
                    <div className="w-12 h-12 bg-gray-800 mx-auto mb-2"></div>
                    {/* Body */}
                    <div className="w-20 h-16 bg-gray-800"></div>
                  </div>
                </div>
                
                {/* Camera Icon */}
                <div 
                  className="absolute bottom-2 right-2 w-10 h-10 bg-[#6fa85e] border-3 border-black flex items-center justify-center cursor-pointer hover:bg-[#8bc273] transition-colors"
                  style={{ boxShadow: '2px 2px 0px rgba(0,0,0,0.3)' }}
                >
                  <svg className="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                    <circle cx="10" cy="10" r="3"/>
                    <path d="M10 2L8 5H4C2.9 5 2 5.9 2 7V16C2 17.1 2.9 18 4 18H16C17.1 18 18 17.1 18 16V7C18 5.9 17.1 5 16 5H12L10 2Z"/>
                  </svg>
                </div>
              </div>
              
              <p 
                className="text-2xl font-bold text-gray-800 tracking-wider mb-1"
                style={{ fontFamily: 'monospace' }}
              >
                {profileData.username}
              </p>
              
              <div className="flex gap-1 mt-2">
                <div className="w-2 h-2 bg-[#6fa85e]"></div>
                <div className="w-2 h-2 bg-[#8bc273]"></div>
                <div className="w-2 h-2 bg-[#a8d48f]"></div>
              </div>
            </div>

            {/* Personal Information Section */}
            <div className="bg-white border-4 border-gray-800 p-6 mb-6">
              <h3 
                className="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2"
                style={{ fontFamily: 'monospace' }}
              >
                <span className="text-orange-500">▶</span> PERSONAL INFO
              </h3>

              <div className="space-y-4">
                <div>
                  <label 
                    className="block text-xs font-bold text-gray-700 mb-2"
                    style={{ fontFamily: 'monospace' }}
                  >
                    WEIGHT *
                  </label>
                  <div
                    className="w-full px-4 py-3 bg-gray-50 text-gray-800 font-mono text-sm"
                    style={{ fontFamily: 'monospace' }}
                  >
                    {profileData.weight}
                  </div>
                </div>

                <div>
                  <label 
                    className="block text-xs font-bold text-gray-700 mb-2"
                    style={{ fontFamily: 'monospace' }}
                  >
                    HEIGHT *
                  </label>
                  <div
                    className="w-full px-4 py-3 bg-gray-50 text-gray-800 font-mono text-sm"
                    style={{ fontFamily: 'monospace' }}
                  >
                    {profileData.height}
                  </div>
                </div>

                <div>
                  <label 
                    className="block text-xs font-bold text-gray-700 mb-2"
                    style={{ fontFamily: 'monospace' }}
                  >
                    AGE *
                  </label>
                  <div
                    className="w-full px-4 py-3 bg-gray-50 text-gray-800 font-mono text-sm"
                    style={{ fontFamily: 'monospace' }}
                  >
                    {profileData.age}
                  </div>
                </div>

                <div>
                  <label 
                    className="block text-xs font-bold text-gray-700 mb-2"
                    style={{ fontFamily: 'monospace' }}
                  >
                    GENDER *
                  </label>
                  <div
                    className="w-full px-4 py-3 bg-gray-50 text-gray-800 font-mono text-sm"
                    style={{ fontFamily: 'monospace' }}
                  >
                    {profileData.gender}
                  </div>
                </div>

                <div>
                  <label 
                    className="block text-xs font-bold text-gray-700 mb-2"
                    style={{ fontFamily: 'monospace' }}
                  >
                    GOAL *
                  </label>
                  <div
                    className="w-full px-4 py-3 bg-gray-50 text-gray-800 font-mono text-sm"
                    style={{ fontFamily: 'monospace' }}
                  >
                    {profileData.goal}
                  </div>
                </div>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="grid grid-cols-3 gap-4">
              <button
                onClick={handleBack}
                className="py-3 px-4 bg-gray-800 hover:bg-gray-700 border-4 border-black text-white font-bold transition-all"
                style={{ 
                  fontFamily: 'monospace',
                  boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
                  textShadow: '2px 2px 0px rgba(0,0,0,0.5)',
                  fontSize: '14px'
                }}
              >
                <span className="flex items-center justify-center gap-1">
                  <span>◀</span> BACK
                </span>
              </button>

              <button
                onClick={handleEdit}
                className="py-3 px-4 bg-gradient-to-r from-[#6fa85e] to-[#8bc273] hover:from-[#8bc273] hover:to-[#a8d48f] border-4 border-black text-white font-bold transition-all"
                style={{ 
                  fontFamily: 'monospace',
                  boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
                  textShadow: '2px 2px 0px rgba(0,0,0,0.5)',
                  fontSize: '14px'
                }}
              >
                <span className="flex items-center justify-center gap-1">
                  <span>✎</span> EDIT
                </span>
              </button>

              <button
                onClick={handleLogout}
                className="py-3 px-4 bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 border-4 border-black text-white font-bold transition-all"
                style={{ 
                  fontFamily: 'monospace',
                  boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
                  textShadow: '2px 2px 0px rgba(0,0,0,0.5)',
                  fontSize: '14px'
                }}
              >
                <span className="flex items-center justify-center gap-1">
                  LOGOUT <span>▶</span>
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}