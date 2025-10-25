// components/NavBarAdmin.tsx
'use client';

import { useRouter } from 'next/navigation';
import { useAuth } from '../context/auth_context';

export default function NavBarAdmin() {
  const router = useRouter();
  const { user, isLoading } = useAuth();

  const handleLogoClick = () => {
    router.push('/AdminMain');
  };

  // แสดง username ของผู้ดูแลจาก AuthContext
  const displayUsername = user?.username || 'ADMIN';

  return (
    <nav 
      className="w-full relative"
      style={{
        background: 'linear-gradient(to right, #6fa85e, #8bc273)',
        borderBottom: '6px solid black',
        boxShadow: '0 6px 0 rgba(0, 0, 0, 0.3)',
        imageRendering: 'pixelated',
      }}
    >
      <div className="safe-area-inset px-4 py-3">
        <div className="flex items-center justify-between">
          {/* Left Side: Logo + App Name */}
          <div className="flex items-center gap-3">
            {/* Logo */}
            <button
              onClick={handleLogoClick}
              className="relative"
              style={{
                width: '80px',
                height: '80px',
              }}
            >
              <img
                src="/pic/logo.png"
                alt="Logo"
                className="w-full h-full object-cover"
                style={{ imageRendering: 'pixelated' }}
                onError={(e) => {
                  e.currentTarget.style.display = 'none';
                  e.currentTarget.parentElement!.innerHTML = '<span style="font-size: 24px">🥗</span>';
                }}
              />
            </button>

            {/* App Name */}
            <button
              onClick={handleLogoClick}
              className="flex flex-col items-start"
            >
              {/* Pixel Dots */}
              <div className="flex gap-0.5 mb-1">
                <div 
                  className="w-1.5 h-1.5"
                  style={{ 
                    backgroundColor: 'rgba(255, 255, 255, 0.8)',
                    border: '1px solid black',
                  }}
                ></div>
                <div 
                  className="w-1.5 h-1.5"
                  style={{ 
                    backgroundColor: 'rgba(255, 255, 255, 0.6)',
                    border: '1px solid black',
                  }}
                ></div>
                <div 
                  className="w-1.5 h-1.5"
                  style={{ 
                    backgroundColor: 'rgba(255, 255, 255, 0.4)',
                    border: '1px solid black',
                  }}
                ></div>
              </div>

              {/* Title */}
              <span
                className="font-bold text-white tracking-wider"
                style={{
                  fontFamily: 'monospace',
                  textShadow: '2px 2px 0 rgba(0, 0, 0, 0.3)',
                  fontSize: '30px',
                }}
              >
                CAL-DEFICITS
              </span>
            </button>
          </div>

          {/* Right Side: Username Only (Admin) */}
          <div className="flex items-center gap-3">
            {/* Username Box */}
            <div
              className="px-4 py-2 bg-white"
              style={{
                border: '3px solid black',
                boxShadow: '3px 3px 0 rgba(0, 0, 0, 0.3)',
              }}
            >
              <div className="flex items-center gap-2">
                {/* Admin Badge */}
                <div
                  className="px-2 py-0.5 text-xs font-bold text-white"
                  style={{
                    backgroundColor: '#ff6b6b',
                    border: '2px solid black',
                    fontFamily: 'monospace',
                  }}
                >
                  ADMIN
                </div>

                {/* Username */}
                <span
                  className="text-lg font-bold text-gray-800"
                  style={{
                    fontFamily: 'monospace',
                    letterSpacing: '0.05em',
                  }}
                >
                  {isLoading ? 'LOADING...' : displayUsername.toUpperCase()}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
}