'use client';

import { useRouter } from 'next/navigation';
import { useUser } from '../../context/user_context';

/**
 * NavBar User Component
 * แถบนำทางสำหรับหน้าผู้ใช้งาน
 * แสดงโลโก้ ชื่อแอป ชื่อผู้ใช้ และรูปโปรไฟล์
 */
export default function NavBarUser() {
  const router = useRouter();
  const { userProfile, loading } = useUser();

  const handleLogoClick = () => {
    router.push('/main');
  };

  const handleProfileClick = () => {
    router.push('/profile');
  };

  const displayUsername = userProfile?.username || 'USER';
  const profileImageSrc = userProfile?.image_profile_url || '/pic/person.png';

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
          {/* Logo & App Name */}
          <div className="flex items-center gap-3">
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

            <button
              onClick={handleLogoClick}
              className="flex flex-col items-start"
            >
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

              <span
                className="font-bold text-white tracking-wider"
                style={{
                  fontFamily: 'TA8bit',
                  textShadow: '2px 2px 0 rgba(0, 0, 0, 0.3)',
                  fontSize: '30px',
                }}
              >
                CAL-DEFICITS
              </span>
            </button>
          </div>

          {/* User Info */}
          <div className="flex items-center gap-3">
            <div
              className="px-3 py-2 bg-white"
              style={{
                border: '3px solid black',
                boxShadow: '3px 3px 0 rgba(0, 0, 0, 0.3)',
              }}
            >
              <div className="flex items-center gap-1.5">
                <div
                  className="w-2 h-2"
                  style={{
                    backgroundColor: '#6fa85e',
                    border: '1px solid black',
                  }}
                ></div>

                <span
                  className="text-lg font-bold text-gray-800"
                  style={{
                    fontFamily: 'TA8bit',
                    letterSpacing: '0.05em',
                  }}
                >
                  {loading ? 'LOADING...' : displayUsername.toUpperCase()}
                </span>
              </div>
            </div>

            <button
              onClick={handleProfileClick}
              className="w-18 h-18 bg-white flex items-center justify-center overflow-hidden"
              style={{
                border: '4px solid black',
                boxShadow: '3px 3px 0 rgba(0, 0, 0, 0.3)',
              }}
            >
              <img
                src={profileImageSrc}
                alt="Profile"
                className="w-full h-full object-cover"
                onError={(e) => {
                  e.currentTarget.src = '/pic/person.png';
                }}
              />
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
}