'use client';

import React, { useState, useEffect } from 'react';
import Image from 'next/image';
import NavBarUser from '../componants/NavBarUser';
import { profileService, UserProfile } from '../../services/profile_service';
import { authAPI } from '../../services/auth_service';
import { useRouter } from 'next/navigation';
import { useUser } from '../../context/user_context';

// Pixel Grid Background Component
const PixelGridBackground = () => (
  <div className="fixed inset-0 pointer-events-none" style={{ zIndex: 0 }}>
    <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <pattern id="pixel-grid" x="0" y="0" width="50" height="50" patternUnits="userSpaceOnUse">
          <path d="M 50 0 L 0 0 0 50" fill="none" stroke="rgba(255,255,255,0.1)" strokeWidth="1"/>
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#pixel-grid)" />
    </svg>
  </div>
);

// Corner Pixels Component
const CornerPixels = () => (
  <>
    <div className="absolute top-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
    <div className="absolute top-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>
    <div className="absolute bottom-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
    <div className="absolute bottom-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>
  </>
);

// Pixel Heart Icon
const PixelHeart = () => (
  <div className="w-20 h-20 mx-auto">
    <div className="grid grid-cols-5 gap-0">
      <div className="w-4 h-4 bg-transparent"></div>
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      <div className="w-4 h-4 bg-transparent"></div>
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      <div className="w-4 h-4 bg-transparent"></div>
      
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      <div className="w-4 h-4 bg-[#ff8787]"></div>
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      <div className="w-4 h-4 bg-[#ff8787]"></div>
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      <div className="w-4 h-4 bg-[#ff8787]"></div>
      <div className="w-4 h-4 bg-[#ff8787]"></div>
      <div className="w-4 h-4 bg-[#ff8787]"></div>
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      
      <div className="w-4 h-4 bg-transparent"></div>
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      <div className="w-4 h-4 bg-[#ff8787]"></div>
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      <div className="w-4 h-4 bg-transparent"></div>
      
      <div className="w-4 h-4 bg-transparent"></div>
      <div className="w-4 h-4 bg-transparent"></div>
      <div className="w-4 h-4 bg-[#ff6b6b]"></div>
      <div className="w-4 h-4 bg-transparent"></div>
      <div className="w-4 h-4 bg-transparent"></div>
    </div>
  </div>
);

// Floating Pixels Animation Component
const FloatingPixels = () => {
  const pixels = Array.from({ length: 15 }, (_, i) => ({
    id: i,
    size: Math.random() * 8 + 4,
    left: Math.random() * 100,
    delay: Math.random() * 5,
    duration: Math.random() * 10 + 10,
    opacity: Math.random() * 0.3 + 0.1
  }));

  return (
    <div className="fixed inset-0 pointer-events-none overflow-hidden" style={{ zIndex: 0 }}>
      {pixels.map((pixel) => (
        <div
          key={pixel.id}
          className="absolute bg-white"
          style={{
            width: `${pixel.size}px`,
            height: `${pixel.size}px`,
            left: `${pixel.left}%`,
            opacity: pixel.opacity,
            animation: `float ${pixel.duration}s ease-in-out ${pixel.delay}s infinite`,
            top: '100%'
          }}
        />
      ))}
      <style>{`
        @keyframes float {
          0% {
            transform: translateY(0) rotate(0deg);
          }
          100% {
            transform: translateY(-100vh) rotate(360deg);
          }
        }
      `}</style>
    </div>
  );
};

export default function PixelProfilePage() {
  const router = useRouter();
  const { userProfile, loading, refreshUserProfile, clearUserProfile } = useUser();
  
  const [isEditing, setIsEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [showSuccessPopup, setShowSuccessPopup] = useState(false);
  const [showLogoutPopup, setShowLogoutPopup] = useState(false);
  const [showDeletePopup, setShowDeletePopup] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const [editData, setEditData] = useState({
    weight: '',
    height: '',
    age: '',
    gender: 'female' as 'male' | 'female',
    goal: 'gain weight' as 'lose weight' | 'maintain weight' | 'gain weight'
  });
  
  const [selectedImageFile, setSelectedImageFile] = useState<File | null>(null);
  const [selectedImagePreview, setSelectedImagePreview] = useState<string | null>(null);

  // ตั้งค่าข้อมูลเมื่อ userProfile เปลี่ยน
  useEffect(() => {
    if (userProfile) {
      setEditData({
        weight: userProfile.weight?.toString() || '',
        height: userProfile.height?.toString() || '',
        age: userProfile.age?.toString() || '',
        gender: userProfile.gender || 'female',
        goal: userProfile.goal || 'maintain weight'
      });
    }
  }, [userProfile]);

  // ถ้าไม่มี profile ให้ redirect ไปหน้า login (เฉพาะเมื่อ loading เสร็จแล้ว)
  useEffect(() => {
    if (!loading && !userProfile) {
      // ตรวจสอบว่ามี accessToken หรือไม่
      const token = localStorage.getItem('accessToken');
      if (!token) {
        router.push('/login');
      }
    }
  }, [loading, userProfile, router]);

  const handleEdit = () => {
    if (userProfile) {
      setEditData({
        weight: userProfile.weight?.toString() || '',
        height: userProfile.height?.toString() || '',
        age: userProfile.age?.toString() || '',
        gender: userProfile.gender || 'female',
        goal: userProfile.goal || 'maintain weight'
      });
    }
    setIsEditing(true);
    setSelectedImageFile(null);
    setSelectedImagePreview(null);
  };

  const handleCancel = () => {
    setEditData({
      weight: userProfile?.weight?.toString() || '',
      height: userProfile?.height?.toString() || '',
      age: userProfile?.age?.toString() || '',
      gender: userProfile?.gender || 'female',
      goal: userProfile?.goal || 'maintain weight'
    });
    setIsEditing(false);
    setSelectedImageFile(null);
    setSelectedImagePreview(null);
    setError(null);
  };

  const handleSave = async () => {
    if (!userProfile) return;

    try {
      setSaving(true);
      setError(null);

      // อัปเดทข้อมูลโปรไฟล์
      const updateData = {
        age: editData.age ? parseInt(editData.age) : undefined,
        gender: editData.gender,
        height: editData.height ? parseFloat(editData.height) : undefined,
        weight: editData.weight ? parseFloat(editData.weight) : undefined,
        goal: editData.goal
      };

      await profileService.updateProfile(userProfile.user_id, updateData);

      // อัปโหลดรูปถ้ามีการเลือกรูปใหม่
      if (selectedImageFile) {
        await profileService.updateProfileImage(userProfile.user_id, selectedImageFile);
      }

      // ⭐ Refresh ข้อมูล user ใน Context เพื่อให้ NavBar อัปเดตด้วย
      await refreshUserProfile();
      
      setIsEditing(false);
      setSelectedImageFile(null);
      setSelectedImagePreview(null);
      setShowSuccessPopup(true);
    } catch (error: any) {
      console.error('Error saving profile:', error);
      setError(error.message || 'ไม่สามารถบันทึกข้อมูลได้');
    } finally {
      setSaving(false);
    }
  };

  const handleLogout = () => {
    setShowLogoutPopup(true);
  };

  const confirmLogout = () => {
    authAPI.logout();
    clearUserProfile(); // Clear user profile from context
    router.push('/login'); // Redirect to login page
  };

  const handleDeleteAccount = () => {
    setShowDeletePopup(true);
  };

  const confirmDelete = async () => {
    try {
      // เรียก API ลบบัญชี
      await authAPI.deleteAccount();

      // Clear user profile from context
      clearUserProfile();

      // Redirect to login page
      router.push('/login');
    } catch (error: any) {
      console.error('Error deleting account:', error);
      setError(error.message || 'ไม่สามารถลบบัญชีได้');
      setShowDeletePopup(false);
    }
  };

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      // ตรวจสอบขนาดไฟล์ (ไม่เกิน 5MB)
      if (file.size > 5 * 1024 * 1024) {
        setError('ขนาดไฟล์ต้องไม่เกิน 5MB');
        return;
      }

      // ตรวจสอบประเภทไฟล์
      const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
      if (!allowedTypes.includes(file.type)) {
        setError('รองรับเฉพาะไฟล์ภาพ (JPEG, PNG, GIF, WebP)');
        return;
      }

      setSelectedImageFile(file);
      
      const reader = new FileReader();
      reader.onload = (e) => {
        setSelectedImagePreview(e.target?.result as string);
      };
      reader.readAsDataURL(file);
      setError(null);
    }
  };

  // แสดง loading
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center" style={{ 
        background: 'linear-gradient(135deg, #6fa85e 0%, #8bc273 50%, #a8d88e 100%)',
      }}>
        <div className="text-white text-2xl font-bold" style={{ fontFamily: 'TA8bit' }}>
          LOADING...
        </div>
      </div>
    );
  }

  // ถ้าไม่มี profile
  if (!userProfile) {
    return null;
  }

  // แสดงรูปโปรไฟล์
  const profileImageSrc = selectedImagePreview || 
    (userProfile.image_profile_url) || 
    '/pic/person.png';

  return (
    <div className="min-h-screen relative" style={{ 
      background: 'linear-gradient(135deg, #6fa85e 0%, #8bc273 50%, #a8d88e 100%)',
      fontFamily: 'TA8bit'
    }}>
      <PixelGridBackground />
      <FloatingPixels />

      <div style={{ position: 'relative', zIndex: 10 }}>
        <NavBarUser />
      </div>

      <div className="flex justify-center items-start p-4 mt-8" style={{ position: 'relative', zIndex: 1 }}>
        <div className="w-full max-w-2xl bg-white border-8 border-black relative" style={{ boxShadow: '12px 12px 0 rgba(0,0,0,0.3)' }}>
          <CornerPixels />

          <div className="bg-gradient-to-r from-[#6fa85e] to-[#8bc273] border-b-6 border-black p-6 relative">
            <h2 className="text-white text-3xl font-bold text-center tracking-wider" style={{textShadow: '3px 3px 0px rgba(0,0,0,0.5)'}}>
              ◆ PROFILE ◆
            </h2>
          </div>

          {/* แสดง Error */}
          {error && (
            <div className="mx-8 mt-6 p-4 bg-red-100 border-4 border-red-500 text-red-700 font-bold text-sm">
              ⚠ {error}
            </div>
          )}

          {!isEditing ? (
            // View Mode
            <div className="p-8">
              <div className="flex flex-col items-center mb-8">
                <div className="relative">
                  <div className="p-2 bg-gradient-to-br from-[#a8d88e] to-[#8bc273] border-4 border-black" 
                    style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.2)' }}>
                    <div className="bg-white border-2 border-black overflow-hidden" style={{ width: '200px', height: '200px' }}>
                      <img
                        src={profileImageSrc}
                        alt="Profile"
                        style={{ width: '200px', height: '200px', objectFit: 'cover' }}
                      />
                    </div>
                  </div>
                </div>
                
                <h3 className="text-2xl font-bold mt-6 mb-3" style={{ letterSpacing: '2px', color: '#1f2937' }}>
                  {userProfile.username.toUpperCase()}
                </h3>
                
                <div className="flex gap-2 mb-3">
                  <div className="w-2 h-2 bg-[#6fa85e] "></div>
                  <div className="w-2 h-2 bg-[#8bc273] "></div>
                  <div className="w-2 h-2 bg-[#a8d48f] "></div>
                </div>
              </div>
 
              <div className="border-4 border-gray-800 p-6 mb-6 bg-gray-100">
                <h4 className="text-lg font-bold mb-6 flex items-center gap-2" style={{ color: '#1f2937' }}>
                  ▶ PERSONAL INFO
                </h4>
 
                <div className="space-y-4">
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>WEIGHT *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {userProfile.weight || '-'} kg
                    </div>
                  </div>
 
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>HEIGHT *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {userProfile.height || '-'} cm
                    </div>
                  </div>
 
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>AGE *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {userProfile.age || '-'} years
                    </div>
                  </div>
 
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>GENDER *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {userProfile.gender ? userProfile.gender.toUpperCase() : '-'}
                    </div>
                  </div>
 
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>GOAL *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {userProfile.goal ? userProfile.goal.toUpperCase() : '-'}
                    </div>
                  </div>
                </div>
              </div>
 
              <div className="flex gap-3">
                <button 
                  onClick={() => router.push('/main')}
                  className="flex-1 bg-gray-800 text-white border-4 border-black p-4 font-bold text-sm hover:bg-gray-700 transition-colors" 
                  style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
                >
                  BACK
                </button>
                <button 
                  onClick={handleEdit}
                  className="flex-1 bg-[#6fa85e] text-white border-4 border-black p-4 font-bold text-sm hover:bg-[#5a8e3d] transition-colors"
                  style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
                >
                  EDIT
                </button>
                <button 
                  onClick={handleLogout}
                  className="flex-1 text-white border-4 border-black p-4 font-bold text-sm transition-colors hover:bg-[#cc5a5a]"
                  style={{ 
                    backgroundColor: '#FF6B6B',
                    boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', 
                    letterSpacing: '1px'
                  }}
                >
                  LOGOUT
                </button>
              </div>
            </div>
          ) : (
            // Edit Mode
            <div className="p-8">
              <div className="flex justify-between items-start mb-8">
                <div className="w-24"></div>
                
                <div className="flex flex-col items-center flex-1">
                  <div className="relative p-2 bg-gradient-to-br from-[#a8d88e] to-[#8bc273] border-4 border-black" 
                    style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.2)' }}>
                    <div className="bg-white border-2 border-black overflow-hidden" style={{ width: '200px', height: '200px' }}>
                      <img
                        src={profileImageSrc}
                        alt="Profile"
                        style={{ width: '200px', height: '200px', objectFit: 'cover' }}
                      />
                    </div>
                    
                    <label className="absolute bottom-0 right-0 w-10 h-10 bg-[#6fa85e] flex items-center justify-center cursor-pointer hover:bg-[#5a8e3d] transition-colors overflow-hidden" 
                      style={{ 
                        border: '3px solid black',
                        borderBottom: 'none',
                        borderRight: 'none',
                        boxShadow: '0 0 0 rgba(0,0,0,0.3)' 
                      }}>
                      <input
                        type="file"
                        accept="image/*"
                        onChange={handleImageUpload}
                        className="absolute inset-0 w-0 h-0 opacity-0 -z-10"
                        style={{ fontSize: 0 }}
                        tabIndex={-1}
                      />
                      <Image
                        src="/pic/camera.png"
                        alt="Upload Photo"
                        width={30}
                        height={30}
                        className="object-contain pointer-events-none relative z-10"
                      />
                    </label>
                  </div>
                  
                  <h3 className="text-2xl font-bold mt-6 mb-3" style={{ letterSpacing: '2px', color: '#1f2937' }}>
                    {userProfile.username.toUpperCase()}
                  </h3>
                  
                  <div className="flex gap-2 mb-3">
                    <div className="w-2 h-2 bg-[#6fa85e] "></div>
                    <div className="w-2 h-2 bg-[#8bc273] "></div>
                    <div className="w-2 h-2 bg-[#a8d48f] "></div>
                  </div>
                </div>
                
                <div className="w-24 flex justify-end">
                  <button 
                    onClick={handleDeleteAccount}
                    className="w-24 h-12 text-white border-4 border-black font-bold text-lg transition-colors hover:bg-[#B91C1C] flex items-center justify-center"
                    style={{ 
                      backgroundColor: '#FF6B6B',
                      boxShadow: '4px 4px 0 rgba(0,0,0,0.3)',
                      fontSize: '15px'
                    }}
                  >
                    DELETE ACCOUNT
                  </button>
                </div>
              </div>

              <div className="border-4 border-gray-800 p-6 mb-6 bg-gray-100">
                <h4 className="text-lg font-bold text-gray-800 mb-6 flex items-center gap-2">
                  ▶ PERSONAL INFO
                </h4>
                <div className="space-y-4">
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>
                      WEIGHT *
                    </label>
                    <input
                      type="number"
                      value={editData.weight}
                      onChange={(e) => setEditData({...editData, weight: e.target.value})}
                      className="w-full border-4 border-[#6fa85e] p-3 font-bold focus:outline-none focus:border-[#5a8e3d] bg-white"
                      style={{ color: '#1f2937' }}
                      placeholder="kg"
                      min="20"
                      max="300"
                    />
                  </div>
 
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>
                      HEIGHT *
                    </label>
                    <input
                      type="number"
                      value={editData.height}
                      onChange={(e) => setEditData({...editData, height: e.target.value})}
                      className="w-full border-4 border-[#6fa85e] p-3 font-bold focus:outline-none focus:border-[#5a8e3d] bg-white"
                      style={{ color: '#1f2937' }}
                      placeholder="cm"
                      min="50"
                      max="300"
                    />
                  </div>
 
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>
                      AGE *
                    </label>
                    <input
                      type="number"
                      value={editData.age}
                      onChange={(e) => setEditData({...editData, age: e.target.value})}
                      className="w-full border-4 border-[#6fa85e] p-3 font-bold focus:outline-none focus:border-[#5a8e3d] bg-white"
                      style={{ color: '#1f2937' }}
                      placeholder="years"
                      min="1"
                      max="120"
                    />
                  </div>
 
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>
                      GENDER *
                    </label>
                    <select
                      value={editData.gender}
                      onChange={(e) => setEditData({...editData, gender: e.target.value as 'male' | 'female'})}
                      className="w-full border-4 border-[#6fa85e] p-3 font-bold focus:outline-none focus:border-[#5a8e3d] bg-white"
                      style={{ color: '#1f2937' }}
                    >
                      <option value="female">FEMALE</option>
                      <option value="male">MALE</option>
                    </select>
                  </div>
 
                  <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>
                      GOAL *
                    </label>
                    <select
                      value={editData.goal}
                      onChange={(e) => setEditData({...editData, goal: e.target.value as any})}
                      className="w-full border-4 border-[#6fa85e] p-3 font-bold focus:outline-none focus:border-[#5a8e3d] bg-white"
                      style={{ color: '#1f2937' }}
                    >
                      <option value="gain weight">GAIN WEIGHT</option>
                      <option value="lose weight">LOSE WEIGHT</option>
                      <option value="maintain weight">MAINTAIN WEIGHT</option>
                    </select>
                  </div>
                </div>
              </div>
 
              <div className="flex gap-3">
                <button 
                  onClick={handleCancel}
                  disabled={saving}
                  className="flex-1 bg-gray-800 text-white border-4 border-black p-4 font-bold text-sm hover:bg-gray-700 transition-colors disabled:opacity-50"
                  style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
                >
                  ✗ CANCEL
                </button>
                <button 
                  onClick={handleSave}
                  disabled={saving}
                  className="flex-1 bg-[#6fa85e] text-white border-4 border-black p-4 font-bold text-sm hover:bg-[#5a8e3d] transition-colors disabled:opacity-50"
                  style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
                >
                  {saving ? 'SAVING...' : '✓ SAVE'}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Success Popup */}
      {showSuccessPopup && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4" style={{ zIndex: 50 }}>
          <div className="w-full max-w-md relative" style={{
            background: 'linear-gradient(180deg, #a8d88e 0%, #8bc273 100%)',
            border: '8px solid black',
            boxShadow: '8px 8px 0 rgba(0,0,0,0.5)'
          }}>
            <div className="absolute top-0 left-0 w-4 h-4 bg-[#10b981]"></div>
            <div className="absolute top-0 right-0 w-4 h-4 bg-[#10b981]"></div>
            <div className="absolute bottom-0 left-0 w-4 h-4 bg-[#10b981]"></div>
            <div className="absolute bottom-0 right-0 w-4 h-4 bg-[#10b981]"></div>

            <div className="bg-[#10b981] border-b-4 border-black p-4">
              <h3 className="text-white text-2xl font-bold text-center tracking-wider" style={{textShadow: '2px 2px 0px rgba(0,0,0,0.5)'}}>
                ★ SUCCESS! ★
              </h3>
            </div>
            
            <div className="p-8 flex flex-col items-center">
              <div className="mb-6">
                <PixelHeart />
              </div>
              
              <div className="bg-white border-4 border-black p-6 w-full mb-6">
                <p className="text-xl font-bold text-center text-gray-800 mb-2" style={{ letterSpacing: '1px' }}>PROFILE UPDATED!</p>
                <p className="text-center text-sm text-gray-800">Changes saved successfully!</p>
              </div>
              
              <button 
                onClick={() => setShowSuccessPopup(false)}
                className="w-full bg-[#6fa85e] text-white border-4 border-black p-4 font-bold text-sm hover:bg-[#5a8e3d] transition-colors"
                style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
              >
                ▶ CONTINUE
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Logout Popup */}
      {showLogoutPopup && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4" style={{ zIndex: 50 }}>
          <div className="bg-white border-8 border-black w-full max-w-md relative" style={{ boxShadow: '8px 8px 0 rgba(0,0,0,0.5)' }}>
            <div className="absolute top-0 left-0 w-4 h-4" style={{ backgroundColor: '#FF8787' }}></div>
            <div className="absolute top-0 right-0 w-4 h-4" style={{ backgroundColor: '#FF8787' }}></div>
            <div className="absolute bottom-0 left-0 w-4 h-4" style={{ backgroundColor: '#FF8787' }}></div>
            <div className="absolute bottom-0 right-0 w-4 h-4" style={{ backgroundColor: '#FF8787' }}></div>

            <div className="border-b-4 border-black p-4" style={{ backgroundColor: '#FF6B6B' }}>
              <h3 className="text-white text-2xl font-bold text-center tracking-wider" style={{textShadow: '2px 2px 0px rgba(0,0,0,0.5)'}}>
                ◆ WARNING ◆
              </h3>
            </div>

            <div className="flex justify-center mt-4 mb-8">
              <div className="w-16 h-16 border-4 border-black flex items-center justify-center" 
                style={{ 
                  backgroundColor: '#FF6B6B',
                  boxShadow: '4px 4px 0 rgba(0,0,0,0.2)' 
                }}>
                <span className="text-white text-4xl font-bold">?</span>
              </div>
            </div>

            <div className="text-center mb-1">
              <p className="text-center text-lg font-bold font-TA8bit text-gray-800" style={{ letterSpacing: '1px' }}>DO YOU WANT TO</p>
              <p className="text-center text-lg font-bold font-TA8bit text-gray-800">LOGOUT?</p>
            </div>

            <div className="flex gap-2 justify-center mt-2">
              <div className="w-2 h-2 " style={{ backgroundColor: '#f66e6eff' }}></div>
              <div className="w-2 h-2 " style={{ backgroundColor: '#f48080ff' }}></div>
              <div className="w-2 h-2 " style={{ backgroundColor: '#f49494ff' }}></div>
            </div>

            <div className="flex gap-3 p-8 pt-0">
              <button 
                onClick={() => setShowLogoutPopup(false)}
                className="flex-1 bg-gray-800 text-white border-4 border-black p-4 font-bold text-sm hover:bg-gray-700 transition-colors"
                style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
              >
                CANCEL
              </button>
              <button 
                onClick={confirmLogout}
                className="flex-1 text-white border-4 border-black p-4 font-bold text-sm transition-colors hover:bg-[#cc5a5a]"
                style={{ 
                  backgroundColor: '#FF6B6B',
                  boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', 
                  letterSpacing: '1px'
                }}
              >
                LOGOUT
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Delete Account Popup */}
      {showDeletePopup && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4" style={{ zIndex: 50 }}>
          <div className="bg-white border-8 border-black w-full max-w-md relative" style={{ boxShadow: '8px 8px 0 rgba(0,0,0,0.5)' }}>
            <div className="absolute top-0 left-0 w-4 h-4" style={{ backgroundColor: '#FF6B6B' }}></div>
            <div className="absolute top-0 right-0 w-4 h-4" style={{ backgroundColor: '#FF6B6B' }}></div>
            <div className="absolute bottom-0 left-0 w-4 h-4" style={{ backgroundColor: '#FF6B6B' }}></div>
            <div className="absolute bottom-0 right-0 w-4 h-4" style={{ backgroundColor: '#FF6B6B' }}></div>

            <div className="border-b-4 border-black p-4" style={{ backgroundColor: '#FF6B6B' }}>
              <h3 className="text-white text-2xl font-bold text-center tracking-wider" style={{textShadow: '2px 2px 0px rgba(0,0,0,0.5)'}}>
                ⚠ WARNING ⚠
              </h3>
            </div>

            <div className="flex justify-center mt-4 mb-8">
              <div className="w-16 h-16 border-4 border-black flex items-center justify-center" 
                style={{ 
                  backgroundColor: '#FF6B6B',
                  boxShadow: '4px 4px 0 rgba(0,0,0,0.2)' 
                }}>
                <span className="text-white text-4xl font-bold">!</span>
              </div>
            </div>

            <div className="text-center mb-1">
              <p className="text-center text-lg font-bold font-TA8bit text-gray-800" style={{ letterSpacing: '1px' }}>DELETE YOUR ACCOUNT?</p>
              <p className="text-center text-sm text-gray-600 mt-2">This action cannot be undone!</p>
            </div>

            <div className="flex gap-2 justify-center mt-2">
              <div className="w-2 h-2 " style={{ backgroundColor: '#f66e6eff' }}></div>
              <div className="w-2 h-2 " style={{ backgroundColor: '#f48080ff' }}></div>
              <div className="w-2 h-2 " style={{ backgroundColor: '#f49494ff' }}></div>
            </div>

            <div className="flex gap-3 p-8 pt-0">
              <button 
                onClick={() => setShowDeletePopup(false)}
                className="flex-1 bg-gray-800 text-white border-4 border-black p-4 font-bold text-sm hover:bg-gray-700 transition-colors"
                style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
              >
                CANCEL
              </button>
              <button 
                onClick={confirmDelete}
                className="flex-1 text-white border-4 border-black p-4 font-bold text-sm transition-colors hover:bg-[#B91C1C]"
                style={{ 
                  backgroundColor: '#FF6B6B',
                  boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', 
                  letterSpacing: '1px'
                }}
              >
                DELETE
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}