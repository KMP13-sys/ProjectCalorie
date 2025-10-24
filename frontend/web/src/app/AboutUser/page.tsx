'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import NavBarAdmin from '../componants/NavBarAdmin';

export default function AboutUserPage() {
  const router = useRouter();
  const [users, setUsers] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(false);

  // TODO: ดึงข้อมูลจาก API
  useEffect(() => {
    // fetchUsers();
  }, []);

  const fetchUsers = async () => {
    setIsLoading(true);
    try {
      // const response = await fetch('/api/users');
      // const data = await response.json();
      // setUsers(data);
    } catch (error) {
      console.error('Error fetching users:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleDeleteUser = (userId: string) => {
    if (confirm('คุณต้องการลบผู้ใช้นี้หรือไม่?')) {
      // TODO: Call delete API
      alert(`ลบผู้ใช้ ID: ${userId}`);
    }
  };

  const handleBack = () => {
    router.push('/AdminMain');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#e8f5e9] via-[#f1f8e9] to-[#fff9c4] relative overflow-hidden">
      
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
      <NavBarAdmin/>

      {/* Main Content */}
      <div className="max-w-7xl mx-auto px-4 py-8 relative z-10">
        
        {/* Header Section */}
        <div className="flex items-center gap-4 mb-8">
          
          {/* Back Button */}
          <button
            onClick={handleBack}
            className="bg-white border-6 border-black p-4 hover:translate-x-[-2px] hover:translate-y-[-2px] transition-transform"
            style={{ 
              boxShadow: '6px 6px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            <span 
            className="text-2xl font-bold text-[#000000]">
              ◀</span>
          </button>

          {/* Title Box */}
          <div 
            className="bg-white border-6 border-black px-12 py-4"
            style={{ 
              boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            <div className="relative">
              {/* Decorative Corner Pixels */}
              <div className="absolute -top-6 -left-8 w-4 h-4 bg-[#8bc273]"></div>
              <div className="absolute -top-6 -right-8 w-4 h-4 bg-[#8bc273]"></div>
              <div className="absolute -bottom-6 -left-8 w-4 h-4 bg-[#8bc273]"></div>
              <div className="absolute -bottom-6 -right-8 w-4 h-4 bg-[#8bc273]"></div>

              <h2 
                className="text-3xl font-bold text-gray-900"
                style={{ 
                  fontFamily: 'monospace',
                  textShadow: '3px 3px 0px rgba(0,0,0,0.1)'
                }}
              >
                About User Account
              </h2>
            </div>
          </div>
        </div>

        {/* Table Container */}
        <div 
          className="bg-white border-8 border-black overflow-hidden relative"
          style={{ 
            boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
            imageRendering: 'pixelated'
          }}
        >
          {/* Decorative Corner Pixels */}
          <div className="absolute -top-2 -left-2 w-6 h-6 bg-[#8bc273]"></div>
          <div className="absolute -top-2 -right-2 w-6 h-6 bg-[#8bc273]"></div>
          <div className="absolute -bottom-2 -left-2 w-6 h-6 bg-[#8bc273]"></div>
          <div className="absolute -bottom-2 -right-2 w-6 h-6 bg-[#8bc273]"></div>

          {/* Table Header Bar */}
          <div className="bg-gradient-to-r from-[#8bc273] to-[#a8d48f] border-b-6 border-black py-3">
            <div className="flex justify-center gap-2">
              <div className="w-3 h-3 bg-white"></div>
              <div className="w-3 h-3 bg-white"></div>
              <div className="w-3 h-3 bg-white"></div>
            </div>
          </div>

          {/* Table */}
          <div className="overflow-x-auto">
            <table className="w-full" style={{ fontFamily: 'monospace' }}>
              <thead>
                <tr className="bg-gradient-to-r from-[#c8e6c9] to-[#dcedc8] border-b-4 border-black">
                  <th className="px-4 py-4 text-left font-bold text-gray-900 border-r-4 border-black w-20">
                    <span className="text-sm">Delete</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-sm">User Name</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-sm">E-Mail</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-sm">Phone No.</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-sm">weight</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-sm">age</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-sm">height</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-sm">gender</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-sm">goal</span>
                  </th>
                  <th className="px-6 py-4 text-left font-bold text-gray-900">
                    <span className="text-sm">Sign up date</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {/* Empty Rows for Demo */}
                {[...Array(8)].map((_, index) => (
                  <tr 
                    key={index}
                    className={`border-b-4 border-black ${
                      index % 2 === 0 ? 'bg-[#f1f8e9]' : 'bg-[#e8f5e9]'
                    } hover:bg-[#dcedc8] transition-colors`}
                  >
                    <td className="px-4 py-6 border-r-4 border-black">
                      <button
                        onClick={() => handleDeleteUser(`user-${index}`)}
                        className="bg-white border-4 border-black p-2 hover:bg-red-100 transition-colors"
                        style={{ boxShadow: '3px 3px 0px rgba(0,0,0,0.2)' }}
                      >
                        <span>
                          <Image
                            src="/pic/trash.png"
                            alt="trash Icon"
                            width={32}
                            height={32}
                          />
                        </span>
                      </button>
                    </td>
                    <td className="px-6 py-6 text-gray-700 border-r-4 border-black">
                      {/* ข้อมูลจาก API */}
                    </td>
                    <td className="px-6 py-6 text-gray-700 border-r-4 border-black">
                      {/* ข้อมูลจาก API */}
                    </td>
                    <td className="px-6 py-6 text-gray-700 border-r-4 border-black">
                      {/* ข้อมูลจาก API */}
                    </td>
                    <td className="px-6 py-6 text-gray-700 border-r-4 border-black">
                      {/* ข้อมูลจาก API */}
                    </td>
                    <td className="px-6 py-6 text-gray-700 border-r-4 border-black">
                      {/* ข้อมูลจาก API */}
                    </td>
                    <td className="px-6 py-6 text-gray-700 border-r-4 border-black">
                      {/* ข้อมูลจาก API */}
                    </td>
                    <td className="px-6 py-6 text-gray-700 border-r-4 border-black">
                      {/* ข้อมูลจาก API */}
                    </td>
                    <td className="px-6 py-6 text-gray-700 border-r-4 border-black">
                      {/* ข้อมูลจาก API */}
                    </td>
                    <td className="px-6 py-6 text-gray-700">
                      {/* ข้อมูลจาก API */}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Loading State */}
          {isLoading && (
            <div className="absolute inset-0 bg-white/80 flex items-center justify-center">
              <div className="text-center">
                <div className="bg-black border-4 border-[#6fa85e] p-2 mb-4">
                  <div className="bg-[#2d2d2d] h-6 w-48 relative overflow-hidden">
                    <div 
                      className="absolute top-0 left-0 h-full bg-gradient-to-r from-[#4ecdc4] to-[#44a3c4]"
                      style={{
                        animation: 'loadingBar 2s ease-in-out infinite',
                        width: '100%'
                      }}
                    >
                      <div className="absolute top-0 left-0 w-full h-2 bg-white opacity-30"></div>
                    </div>
                  </div>
                </div>
                <p 
                  className="text-sm text-gray-700 font-bold"
                  style={{ fontFamily: 'monospace' }}
                >
                  Loading users data...
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Info Box */}
        <div 
          className="mt-8 bg-white border-6 border-black p-6"
          style={{ 
            boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
            imageRendering: 'pixelated'
          }}
        >
          <div className="flex items-center gap-4">
            <div className="bg-[#8bc273] border-4 border-black p-3">
              <span className="text-2xl">ℹ️</span>
            </div>
            <div>
              <p 
                className="text-gray-900 font-bold"
                style={{ fontFamily: 'monospace' }}
              >
                &gt; Total Users: <span className="text-[#6fa85e]">{users.length}</span>
              </p>
              <p 
                className="text-gray-600 text-sm mt-1"
                style={{ fontFamily: 'monospace' }}
              >
                ข้อมูลจะถูกโหลดจาก Backend API
              </p>
            </div>
          </div>
        </div>
      </div>

      <style jsx>{`
        @keyframes loadingBar {
          0% { width: 0%; }
          50% { width: 100%; }
          100% { width: 0%; }
        }
      `}</style>
    </div>
  );
}