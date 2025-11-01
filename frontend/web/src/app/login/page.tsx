'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '../../context/auth_context';
import { useUser } from '../../context/user_context';

export default function LoginPage() {
  const router = useRouter();
  const { login, user } = useAuth();
  const { refreshUserProfile } = useUser();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [showSuccessModal, setShowSuccessModal] = useState(false);

  // เปลี่ยนหน้าอัตโนมัติหลัง login สำเร็จตาม role ของผู้ใช้
  useEffect(() => {
    if (showSuccessModal && user) {
      const timer = setTimeout(() => {
        if (user.role === 'admin') {
          router.push('/AdminMain');
        } else {
          router.push('/main');
        }
      }, 2000);
      return () => clearTimeout(timer);
    }
  }, [showSuccessModal, user, router]);

  // จำกัดการกรอก username ให้เป็นตัวอักษรและตัวเลขเท่านั้น
  const handleUsernameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value;
    const sanitized = value.replace(/[^a-zA-Z0-9]/g, '');
    setUsername(sanitized);
    if (error) setError('');
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // ตรวจสอบความถูกต้องของข้อมูล
    if (!username.trim()) {
      setError('กรุณากรอก Username');
      return;
    }

    if (!/[a-zA-Z]/.test(username)) {
      setError('Username ต้องมีตัวอักษร (a-z หรือ A-Z) อย่างน้อย 1 ตัว');
      return;
    }

    if (username.length < 3) {
      setError('Username ต้องมีอย่างน้อย 3 ตัวอักษร');
      return;
    }

    if (!password) {
      setError('กรุณากรอก Password');
      return;
    }

    setIsLoading(true);

    try {
      await login(username.trim(), password);
      await refreshUserProfile();
      setShowSuccessModal(true);
    } catch (err: any) {
      setError(err.message || 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ');
    } finally {
      setIsLoading(false);
    }
  };

  const handleNavigateToRegister = () => {
    router.push('/register');
  };

  return (
    <>
      <div className="min-h-screen bg-gradient-to-br from-[#6fa85e] via-[#8bc273] to-[#a8d48f] flex items-center justify-center p-4 relative overflow-hidden">
        {/* พื้นหลังลาย Pixel Grid */}
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

        {/* องค์ประกอบตะกร้าตกแต่งแบบ Pixel */}
        <div className="absolute top-10 left-10 w-6 h-6 bg-yellow-300 animate-bounce"></div>
        <div className="absolute top-20 right-16 w-4 h-4 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.3s' }}></div>
        <div className="absolute bottom-20 left-20 w-5 h-5 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.6s' }}></div>

        <div className="relative z-10 w-full max-w-md">
          <div 
            className="bg-white border-8 border-black relative"
            style={{ 
              boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Pixel มุมกล่องตกแต่ง */}
            <div className="absolute top-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute top-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>

            {/* ส่วนหัวของฟอร์ม */}
            <div className="bg-gradient-to-r from-[#6fa85e] to-[#8bc273] border-b-6 border-black py-3 px-6">
              <h2 
                className="text-2xl font-bold text-white text-center tracking-wider"
                style={{ 
                  fontFamily: 'TA8bit',
                  textShadow: '3px 3px 0px rgba(0,0,0,0.3)'
                }}
              >
                ◆ LOGIN ◆
              </h2>
            </div>

            <div className="p-8">
              {/* โลโก้และชื่อแอป */}
              <div className="flex flex-col items-center mb-6">
                <div 
                  className="bg-gradient-to-br from-[#a8d48f] to-[#8bc273] border-4 border-black p-3 mb-3"
                  style={{ boxShadow: '4px 4px 0px rgba(0,0,0,0.2)' }}
                >
                  <img
                    src="/pic/logo.png"
                    alt="Logo"
                    className="w-32 h-32 object-contain"
                    style={{ imageRendering: 'pixelated' }}
                  />
                </div>
                <p 
                  className="text-xl font-bold text-gray-800 tracking-wider"
                  style={{ fontFamily: 'TA8bit' }}
                >
                  CAL-DEFICITS
                </p>
                <div className="flex gap-1 mt-2">
                  <div className="w-2 h-2 bg-[#6fa85e]"></div>
                  <div className="w-2 h-2 bg-[#8bc273]"></div>
                  <div className="w-2 h-2 bg-[#a8d48f]"></div>
                </div>
              </div>

              {/* แสดงข้อความแจ้งเตือนข้อผิดพลาด */}
              {error && (
                <div 
                  className="mb-4 p-3 bg-red-200 border-4 border-red-600 text-red-800"
                  style={{ fontFamily: 'TA8bit' }}
                >
                  <div className="flex items-center gap-2">
                    <span className="text-xl">⚠</span>
                    <span className="text-sm font-bold">{error}</span>
                  </div>
                </div>
              )}

              {/* ฟอร์มเข้าสู่ระบบ */}
              <form onSubmit={handleLogin} className="space-y-4">
                <div>
                  <label
                    className="block text-sm font-bold text-gray-700 mb-2"
                    style={{ fontFamily: 'TA8bit' }}
                  >
                    &gt; USERNAME
                  </label>
                  <input
                    type="text"
                    placeholder="Enter username..."
                    value={username}
                    onChange={handleUsernameChange}
                    required
                    minLength={3}
                    className="w-full px-4 py-3 bg-gray-100 border-4 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono"
                    style={{ fontFamily: 'TA8bit' }}
                  />
                </div>

                <div>
                  <label
                    className="block text-sm font-bold text-gray-700 mb-2"
                    style={{ fontFamily: 'TA8bit' }}
                  >
                    &gt; PASSWORD
                  </label>
                  <input
                    type="password"
                    placeholder="Enter password..."
                    value={password}
                    onChange={(e) => {
                      setPassword(e.target.value);
                      if (error) setError('');
                    }}
                    required
                    className="w-full px-4 py-3 bg-gray-100 border-4 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono"
                    style={{ fontFamily: 'TA8bit' }}
                  />
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full py-4 bg-gradient-to-r from-[#6fa85e] to-[#8bc273] hover:from-[#8bc273] hover:to-[#a8d48f] border-4 border-black text-white font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed mt-6"
                  style={{
                    fontFamily: 'TA8bit',
                    boxShadow: '6px 6px 0px rgba(0,0,0,0.3)',
                    textShadow: '2px 2px 0px rgba(0,0,0,0.5)',
                    fontSize: '18px'
                  }}
                >
                  {isLoading ? '▶ LOGGING IN...' : '▶ LOGIN'}
                </button>
              </form>

              {/* ปุ่มนำไปหน้าสมัครสมาชิก */}
              <div className="mt-6 pt-6 border-t-4 border-dashed border-gray-300">
                <div className="flex justify-center items-center">
                  <button
                    onClick={handleNavigateToRegister}
                    className="px-4 py-2 bg-gray-800 hover:bg-gray-700 border-3 border-black text-white text-sm font-bold transition-all"
                    style={{
                      fontFamily: 'TA8bit',
                      boxShadow: '3px 3px 0px rgba(0,0,0,0.3)'
                    }}
                  >
                    ↗ SIGN UP
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* ข้อความแนะนำ */}
          <div className="text-center mt-6">
            <p
              className="text-white text-sm font-bold animate-pulse"
              style={{
                fontFamily: 'TA8bit',
                textShadow: '2px 2px 0px rgba(0,0,0,0.5)'
              }}
            >
              ▼ ENTER YOUR CREDENTIALS ▼
            </p>
          </div>
        </div>
      </div>

      {/* Modal แสดงความสำเร็จ */}
      {showSuccessModal && (
        <div className="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
          <div 
            className="bg-gradient-to-b from-[#a8d48f] to-[#8bc273] border-8 border-black w-full max-w-md relative"
            style={{ 
              boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Pixel มุมกล่องตกแต่ง */}
            <div className="absolute top-0 left-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute top-0 right-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 left-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 right-0 w-4 h-4 bg-[#6fa85e]"></div>

            <div className="p-8 text-center relative">
              <div className="bg-[#6fa85e] border-b-4 border-black -mx-8 -mt-8 mb-6 py-3">
                <h3 className="text-2xl font-bold text-white tracking-wider" style={{ textShadow: '3px 3px 0px rgba(0,0,0,0.3)' }}>
                  ★ SUCCESS! ★
                </h3>
              </div>

              {/* ไอคอนหัวใจ Pixel Art */}
              <div className="flex justify-center mb-4">
                <div className="relative w-16 h-16">
                  <div className="grid grid-cols-5 gap-0">
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    <div className="w-3 h-3 bg-[#ff8787]"></div>
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    <div className="w-3 h-3 bg-[#ff8787]"></div>
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    <div className="w-3 h-3 bg-[#ff8787]"></div>
                    <div className="w-3 h-3 bg-[#ff8787]"></div>
                    <div className="w-3 h-3 bg-[#ff8787]"></div>
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    <div className="w-3 h-3 bg-[#ff8787]"></div>
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-[#ff6b6b]"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                  </div>
                </div>
              </div>

              <div className="bg-white border-4 border-black p-4 mb-6">
                <p className="text-xl font-bold text-gray-800 mb-2" style={{ fontFamily: 'TA8bit' }}>
                  LOGIN COMPLETE!
                </p>
                <p className="text-sm text-gray-600" style={{ fontFamily: 'TA8bit' }}>
                  Welcome back, User!
                </p>
              </div>

              {/* แถบแสดงความคืบหน้า */}
              <div className="bg-black border-4 border-[#6fa85e] p-2">
                <div className="bg-[#2d2d2d] h-6 relative overflow-hidden">
                  <div
                    className="absolute top-0 left-0 h-full bg-gradient-to-r from-[#4ecdc4] to-[#44a3c4]"
                    style={{
                      animation: 'loadingBar 2s ease-in-out',
                      width: '100%'
                    }}
                  >
                    <div className="absolute top-0 left-0 w-full h-2 bg-white opacity-30"></div>
                  </div>
                </div>
              </div>

              <p className="text-xs text-white mt-3" style={{ fontFamily: 'TA8bit', textShadow: '2px 2px 0px rgba(0,0,0,0.5)' }}>
                Loading...
              </p>
            </div>
          </div>
        </div>
      )}

      <style jsx>{`
        @keyframes loadingBar {
          0% { width: 0%; }
          100% { width: 100%; }
        }
      `}</style>
    </>
  );
}