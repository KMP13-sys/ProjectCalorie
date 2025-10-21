'use client';

import React, { useState } from 'react';
import Image from 'next/image';
import NavBarUser from '../componants/NavBarUser';
import Link from 'next/link';

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
  const [isEditing, setIsEditing] = useState(false);
  const [showSuccessPopup, setShowSuccessPopup] = useState(false);
  const [showLogoutPopup, setShowLogoutPopup] = useState(false);
  const [showDeletePopup, setShowDeletePopup] = useState(false);
  
  const [profileData, setProfileData] = useState({
    username: 'TEST1',
    weight: '43',
    height: '156',
    age: '17',
    gender: 'FEMALE',
    goal: 'GAIN WEIGHT'
  });
  
  const [editData, setEditData] = useState({ ...profileData });
  const [selectedImage, setSelectedImage] = useState<string | null>(null);

  const handleEdit = () => {
    setEditData({ ...profileData });
    setIsEditing(true);
  };

  const handleCancel = () => {
    setEditData({ ...profileData });
    setIsEditing(false);
  };

  const handleSave = () => {
    setProfileData({ ...editData });
    setIsEditing(false);
    setShowSuccessPopup(true);
  };

  const handleLogout = () => {
    setShowLogoutPopup(true);
  };

  const confirmLogout = () => {
    console.log('Logging out...');
    setShowLogoutPopup(false);
  };

  const handleDeleteAccount = () => {
    setShowDeletePopup(true);
  };

  const confirmDelete = () => {
    console.log('Deleting account...');
    setShowDeletePopup(false);
  };

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        setSelectedImage(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  return (
    <div className="min-h-screen relative" style={{ 
      background: 'linear-gradient(135deg, #6fa85e 0%, #8bc273 50%, #a8d88e 100%)',
      fontFamily: 'monospace'
    }}>
      {/* Pixel Grid Background */}
      <PixelGridBackground />
      
      {/* Floating Pixels Animation */}
      <FloatingPixels />

      {/* Navigation Bar */}
      <div style={{ position: 'relative', zIndex: 10 }}>
        <NavBarUser username={profileData.username} />
      </div>

      {/* Main Content */}
      <div className="flex justify-center items-start p-4 mt-8" style={{ position: 'relative', zIndex: 1 }}>
        <div className="w-full max-w-2xl bg-white border-8 border-black relative" style={{ boxShadow: '12px 12px 0 rgba(0,0,0,0.3)' }}>
          {/* Corner Pixels */}
          <CornerPixels />

          {/* Profile Header */}
          <div className="bg-gradient-to-r from-[#6fa85e] to-[#8bc273] border-b-6 border-black p-6 relative">
            <h2 className="text-white text-3xl font-bold text-center tracking-wider" style={{textShadow: '3px 3px 0px rgba(0,0,0,0.5)'}}>
              ◆ PROFILE ◆
            </h2>
          </div>

          {!isEditing ? (
            // View Mode
            <div className="p-8">
              {/* Avatar and Username - ไม่มีปุ่มอัพโหลด */}
              <div className="flex flex-col items-center mb-8">
                <div className="relative">
                  <div className="p-3 bg-gradient-to-br from-[#a8d88e] to-[#8bc273] border-4 border-black" 
                    style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.2)' }}>
                    <div className="w-[100] h-[100] p-2 bg-white border-2 border-black flex items-center justify-center">
                      <Image
                        src="/pic/person.png"
                        alt="Default Profile"
                        width={60}
                        height={60}
                        className="object-contain"
                      />
                    </div>
                  </div>
                </div>
                
                <h3 className="text-2xl font-bold mt-6 mb-3" style={{ letterSpacing: '2px', color: '#1f2937' }}>
                  {profileData.username}
                </h3>
                
                <div className="flex gap-2 mb-3">
                  <div className="w-2 h-2 bg-[#6fa85e] border border-black"></div>
                  <div className="w-2 h-2 bg-[#8bc273] border border-black"></div>
                  <div className="w-2 h-2 bg-[#a8d88e] border border-black"></div>
                </div>
              </div>
 
               {/* Personal Info */}
               <div className="border-4 border-gray-800 p-6 mb-6 bg-gray-100">
                 <h4 className="text-lg font-bold mb-6 flex items-center gap-2" style={{ color: '#1f2937' }}>
                   ▶ PERSONAL INFO
                 </h4>
 
                 <div className="space-y-4">
                   <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>WEIGHT *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {profileData.weight} kg
                    </div>
                   </div>
 
                   <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>HEIGHT *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {profileData.height} cm
                    </div>
                   </div>
 
                   <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>AGE *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {profileData.age} years
                    </div>
                   </div>
 
                   <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>GENDER *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {profileData.gender}
                    </div>
                   </div>
 
                   <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>GOAL *</label>
                    <div className="border-4 border-gray-800 p-3 bg-white font-bold" style={{ color: '#1f2937' }}>
                      {profileData.goal}
                    </div>
                   </div>
                 </div>
               </div>
 
               {/* Buttons */}
               <div className="flex gap-3">
                
                 <button className="flex-1 bg-gray-800 text-white border-4 border-black p-4 font-bold text-sm hover:bg-gray-700 transition-colors" style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}>
                  <Link href="/main">
                    ◀ BACK
                  </Link>
                  </button>
                 <button 
                   onClick={handleEdit}
                   className="flex-1 bg-[#6fa85e] text-white border-4 border-black p-4 font-bold text-sm hover:bg-[#5a8e3d] transition-colors"
                   style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
                 >
                   ✎ EDIT
                 </button>
                 {/* ปุ่ม Logout */}
                 <button 
                   onClick={handleLogout}
                   className="flex-1 text-white border-4 border-black p-4 font-bold text-sm transition-colors"
                   style={{ 
                     backgroundColor: '#FF6B6B',
                     boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', 
                     letterSpacing: '1px'
                   }}
                 >
                   LOGOUT ▶
                 </button>
               </div>
             </div>
           ) : (
             // Edit Mode
             <div className="p-8">
              {/* Avatar and Username - มีปุ่มอัพโหลด และปุ่มลบบัญชี */}
               <div className="flex justify-between items-start mb-8">
                {/* Spacer ซ้าย */}
                <div className="w-24"></div>
                
                {/* Avatar and Username - ตรงกลาง */}
                <div className="flex flex-col items-center flex-1">
                  <div className="relative p-3 bg-gradient-to-br from-[#a8d88e] to-[#8bc273] border-4 border-black" 
                    style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.2)' }}>
                    <div className="w-[100px] h-[100px] p-2 bg-white border-2 border-black flex items-center justify-center">
                      {selectedImage ? (
                        <Image
                          src={selectedImage}
                          alt="User Profile"
                          width={100}
                          height={100}
                          className="object-cover w-full h-full"
                        />
                      ) : (
                        <Image
                          src="/pic/person.png"
                          alt="Default Profile"
                          width={60}
                          height={60}
                          className="object-contain"
                        />
                      )}
                    </div>
                    
                    {/* ปุ่มอัพโหลดรูป - ติดมุมขวาล่างของกรอบสีเขียว */}
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
                        width={24}
                        height={24}
                        className="object-contain pointer-events-none relative z-10"
                      />
                    </label>
                  </div>
                  
                  <h3 className="text-2xl font-bold mt-6 mb-3" style={{ letterSpacing: '2px', color: '#1f2937' }}>
                    {profileData.username}
                  </h3>
                  
                  <div className="flex gap-2 mb-3">
                    <div className="w-2 h-2 bg-[#6fa85e] border border-black"></div>
                    <div className="w-2 h-2 bg-[#8bc273] border border-black"></div>
                    <div className="w-2 h-2 bg-[#a8d88e] border border-black"></div>
                  </div>
                </div>
                
                {/* Delete Account Button */}
                <div className="w-24 flex justify-end">
                  <button 
                    onClick={handleDeleteAccount}
                    className="w-24 h-12 text-white border-4 border-black font-bold text-lg transition-colors hover:bg-[#B91C1C] flex items-center justify-center"
                    style={{ 
                      backgroundColor: '#FF6B6B',
                      boxShadow: '4px 4px 0 rgba(0,0,0,0.3)',
                      fontSize: '15px'
                    }}
                    title="Delete Account"
                  >DELETE ACCOUNT
                  </button>
                </div>
              </div>

               <div className="border-4 border-gray-800 p-6 mb-6 bg-gray-100">
                 <h4 className="text-lg font-bold text-gray-800 mb-6 flex items-center gap-2">
                   ▶ PERSONAL INFO
                 </h4>
                 <div className="space-y-4">
                   {/* Weight Input */}
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
                    />
                   </div>
 
                   {/* Height Input */}
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
                    />
                   </div>
 
                   {/* Age Input */}
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
                    />
                   </div>
 
                   {/* Gender Select */}
                   <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>
                      GENDER *
                    </label>
                     <select
                       value={editData.gender}
                       onChange={(e) => setEditData({...editData, gender: e.target.value})}
                       className="w-full border-4 border-[#6fa85e] p-3 font-bold focus:outline-none focus:border-[#5a8e3d] bg-white"
                       style={{ color: '#1f2937' }}
                     >
                       <option value="FEMALE">FEMALE</option>
                       <option value="MALE">MALE</option>
                     </select>
                   </div>
 
                   {/* Goal Select */}
                   <div>
                    <label className="text-xs font-bold mb-2 block" style={{ letterSpacing: '1px', color: '#1f2937' }}>
                      GOAL *
                    </label>
                     <select
                       value={editData.goal}
                       onChange={(e) => setEditData({...editData, goal: e.target.value})}
                       className="w-full border-4 border-[#6fa85e] p-3 font-bold focus:outline-none focus:border-[#5a8e3d] bg-white"
                       style={{ color: '#1f2937' }}
                     >
                       <option value="GAIN WEIGHT">GAIN WEIGHT</option>
                       <option value="LOSE WEIGHT">LOSE WEIGHT</option>
                       <option value="MAINTAIN WEIGHT">MAINTAIN WEIGHT</option>
                     </select>
                   </div>
                 </div>
               </div>
 
               {/* Edit Buttons */}
               <div className="flex gap-3">
                 <button 
                   onClick={handleCancel}
                   className="flex-1 bg-gray-800 text-white border-4 border-black p-4 font-bold text-sm hover:bg-gray-700 transition-colors"
                   style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
                 >
                   ✗ CANCEL
                 </button>
                 <button 
                   onClick={handleSave}
                   className="flex-1 bg-[#6fa85e] text-white border-4 border-black p-4 font-bold text-sm hover:bg-[#5a8e3d] transition-colors"
                   style={{ boxShadow: '4px 4px 0 rgba(0,0,0,0.3)', letterSpacing: '1px' }}
                 >
                   ✓ SAVE
                 </button>
               </div>
             </div>
           )}
         </div>
       </div>
 
      {/* Success Popup*/}
       {showSuccessPopup && (
         <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4" style={{ zIndex: 50 }}>
           <div className="w-full max-w-md relative" style={{
             background: 'linear-gradient(180deg, #a8d88e 0%, #8bc273 100%)',
             border: '8px solid black',
             boxShadow: '8px 8px 0 rgba(0,0,0,0.5)'
           }}>
             {/* Corner Pixels */}
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
            {/* Corner Pixels */}
            <div className="absolute top-0 left-0 w-4 h-4" style={{ backgroundColor: '#FF8787' }}></div>
            <div className="absolute top-0 right-0 w-4 h-4" style={{ backgroundColor: '#FF8787' }}></div>
            <div className="absolute bottom-0 left-0 w-4 h-4" style={{ backgroundColor: '#FF8787' }}></div>
            <div className="absolute bottom-0 right-0 w-4 h-4" style={{ backgroundColor: '#FF8787' }}></div>

            {/* Header */}
            <div className="border-b-4 border-black p-4" style={{ backgroundColor: '#FF6B6B' }}>
              <h3 className="text-white text-2xl font-bold text-center tracking-wider" style={{textShadow: '2px 2px 0px rgba(0,0,0,0.5)'}}>
                ◆ WARNING ◆
              </h3>
            </div>

            {/* Warning Icon Box */}
            <div className="flex justify-center mt-4 mb-8">
              <div className="w-16 h-16 border-4 border-black flex items-center justify-center" 
                style={{ 
                  backgroundColor: '#FF6B6B',
                  boxShadow: '4px 4px 0 rgba(0,0,0,0.2)' 
                }}>
                <span className="text-white text-4xl font-bold">?</span>
              </div>
            </div>

            {/* Warning Message */}
            <div className="text-center mb-1">
              <p className="text-center text-lg font-bold font-monospace text-gray-800" style={{ letterSpacing: '1px' }}>DO YOU WANT TO</p>
              <p className="text-center text-lg font-bold font-monospace text-gray-800">LOGOUT?</p>
            </div>

            {/* Pixel Dots */}
            <div className="flex gap-2 justify-center mt-2">
              <div className="w-2 h-2 border border-black" style={{ backgroundColor: '#ff7fbfff' }}></div>
              <div className="w-2 h-2 border border-black" style={{ backgroundColor: '#ff7fbfff' }}></div>
              <div className="w-2 h-2 border border-black" style={{ backgroundColor: '#ff7fbfff' }}></div>
            </div>

            {/* Buttons */}
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
                className="flex-1 text-white border-4 border-black p-4 font-bold text-sm transition-colors"
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
            {/* Corner Pixels */}
            <div className="absolute top-0 left-0 w-4 h-4" style={{ backgroundColor: '#FF6B6B' }}></div>
            <div className="absolute top-0 right-0 w-4 h-4" style={{ backgroundColor: '#FF6B6B' }}></div>
            <div className="absolute bottom-0 left-0 w-4 h-4" style={{ backgroundColor: '#FF6B6B' }}></div>
            <div className="absolute bottom-0 right-0 w-4 h-4" style={{ backgroundColor: '#FF6B6B' }}></div>

            {/* Header */}
            <div className="border-b-4 border-black p-4" style={{ backgroundColor: '#FF6B6B' }}>
              <h3 className="text-white text-2xl font-bold text-center tracking-wider" style={{textShadow: '2px 2px 0px rgba(0,0,0,0.5)'}}>
                ⚠ WARNING ⚠
              </h3>
            </div>

            {/* Warning Icon Box */}
            <div className="flex justify-center mt-4 mb-8">
              <div className="w-16 h-16 border-4 border-black flex items-center justify-center" 
                style={{ 
                  backgroundColor: '#FF6B6B',
                  boxShadow: '4px 4px 0 rgba(0,0,0,0.2)' 
                }}>
                <span className="text-white text-4xl font-bold">!</span>
              </div>
            </div>

            {/* Warning Message */}
            <div className="text-center mb-1">
              <p className="text-center text-lg font-bold font-monospace text-gray-800" style={{ letterSpacing: '1px' }}>DELETE YOUR ACCOUNT?</p>
              <p className="text-center text-sm text-gray-600 mt-2">This action cannot be undone!</p>
            </div>

            {/* Pixel Dots */}
            <div className="flex gap-2 justify-center mt-2">
              <div className="w-2 h-2 border border-black" style={{ backgroundColor: '#DC2626' }}></div>
              <div className="w-2 h-2 border border-black" style={{ backgroundColor: '#DC2626' }}></div>
              <div className="w-2 h-2 border border-black" style={{ backgroundColor: '#DC2626' }}></div>
            </div>

            {/* Buttons */}
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