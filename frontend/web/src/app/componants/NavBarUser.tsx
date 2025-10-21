// components/NavBarUser.tsx
'use client';

import { useRouter } from 'next/navigation';
import Image from 'next/image';

interface NavBarUserProps {
  username?: string;
}

export default function NavBarUser({ username = 'PLAYER' }: NavBarUserProps) {
  const router = useRouter();

  const handleLogoClick = () => {
    router.push('/main');
  };

  const handleProfileClick = () => {
    router.push('/profile');
  };

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
                width: '60px',
                height: '60px',
              }}
            >
              <img
                src="/pic/logo.png"
                alt="Logo"
                className="w-full h-full object-cover"
                style={{ imageRendering: 'pixelated' }}
                onError={(e) => {
                  // Fallback เป็น emoji ถ้าโหลดรูปไม่ได้
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
                className="text-lg font-bold text-white tracking-wider"
                style={{
                  fontFamily: 'monospace',
                  textShadow: '2px 2px 0 rgba(0, 0, 0, 0.3)',
                }}
              >
                CAL-DEFICITS
              </span>
            </button>
          </div>

          {/* Right Side: Username + Profile */}
          <div className="flex items-center gap-3">
            {/* Username Box */}
            <div
              className="px-3 py-2 bg-white"
              style={{
                border: '3px solid black',
                boxShadow: '3px 3px 0 rgba(0, 0, 0, 0.3)',
              }}
            >
              <div className="flex items-center gap-1.5">
                {/* Pixel Square */}
                <div
                  className="w-2 h-2"
                  style={{
                    backgroundColor: '#6fa85e',
                    border: '1px solid black',
                  }}
                ></div>

                {/* Username */}
                <span
                  className="text-xs font-bold text-gray-800"
                  style={{
                    fontFamily: 'monospace',
                    letterSpacing: '0.05em',
                  }}
                >
                  {username.toUpperCase()}
                </span>
              </div>
            </div>

            {/* Profile Icon */}
            <button
              onClick={handleProfileClick}
              className="w-11 h-11 bg-white flex items-center justify-center"
              style={{
                border: '4px solid black',
                boxShadow: '3px 3px 0 rgba(0, 0, 0, 0.3)',
              }}
            >
              <Image
                src="/pic/person.png"
                alt="Profile"
                width={24}
                height={24}
                className="object-contain"
              />
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}