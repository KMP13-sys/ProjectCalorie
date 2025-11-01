'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import NavBarAdmin from '../componants/NavBarAdmin';
import { adminService, User } from '../../services/adminService';

/**
 * หน้าจัดการข้อมูลผู้ใช้ (About User)
 * ใช้สำหรับแสดงและลบข้อมูลผู้ใช้ทั้งหมดในระบบ
 */
export default function AboutUserPage() {
  const router = useRouter();
  const [users, setUsers] = useState<User[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [deleteModal, setDeleteModal] = useState<{ show: boolean; user: User | null }>({
    show: false,
    user: null,
  }); // Modal ยืนยันการลบผู้ใช้
  const [successModal, setSuccessModal] = useState(false); // Modal แสดงความสำเร็จ

  /**
   * โหลดข้อมูลผู้ใช้ทั้งหมดเมื่อหน้าโหลดครั้งแรก
   */
  useEffect(() => {
    fetchUsers();
  }, []);

  /**
   * ดึงข้อมูลผู้ใช้ทั้งหมดจาก API
   */
  const fetchUsers = async () => {
    setIsLoading(true);
    try {
      const data = await adminService.getAllUsers();
      setUsers(data);
    } catch (error) {
      console.error('Error fetching users:', error);
      alert('ไม่สามารถโหลดข้อมูลผู้ใช้ได้');
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * เปิด Modal ยืนยันการลบผู้ใช้
   * @param user - ข้อมูลผู้ใช้ที่ต้องการลบ
   */
  const handleDeleteClick = (user: User) => {
    setDeleteModal({ show: true, user });
  };

  /**
   * ยืนยันการลบผู้ใช้และเรียก API
   */
  const handleConfirmDelete = async () => {
    if (!deleteModal.user) return;

    try {
      await adminService.deleteUser(deleteModal.user.user_id);
      setDeleteModal({ show: false, user: null });
      setSuccessModal(true);
      fetchUsers(); // รีเฟรชข้อมูลผู้ใช้หลังจากลบสำเร็จ
    } catch (error) {
      console.error('Error deleting user:', error);
      alert('ไม่สามารถลบผู้ใช้ได้');
      setDeleteModal({ show: false, user: null });
    }
  };

  /**
   * ยกเลิกการลบผู้ใช้และปิด Modal
   */
  const handleCancelDelete = () => {
    setDeleteModal({ show: false, user: null });
  };

  /**
   * กลับไปหน้า Admin Main
   */
  const handleBack = () => {
    router.push('/AdminMain');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#e8f5e9] via-[#f1f8e9] to-[#fff9c4] relative overflow-hidden">

      {/* พื้นหลังแบบ Pixel Grid */}
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

      {/* เนื้อหาหลัก */}
      <div className="max-w-7xl mx-auto px-4 py-8 relative z-10">

        {/* ส่วนหัวเพจ */}
        <div className="flex items-center gap-4 mb-8">

          {/* ปุ่มย้อนกลับ */}
          <button
            onClick={handleBack}
            className="bg-white border-6 border-black p-4 hover:translate-x-[-2px] hover:translate-y-[-2px] transition-transform"
            style={{ 
              boxShadow: '6px 6px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            <span className="text-2xl font-bold text-[#000000]">◀</span>
          </button>

          {/* กล่องหัวข้อหน้า */}
          <div
            className="bg-white border-6 border-black px-12 py-4"
            style={{
              boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            <div className="relative">
              {/* จุด Pixel ประดับมุม */}
              <div className="absolute -top-6 -left-8 w-4 h-4 bg-[#8bc273]"></div>
              <div className="absolute -top-6 -right-8 w-4 h-4 bg-[#8bc273]"></div>
              <div className="absolute -bottom-6 -left-8 w-4 h-4 bg-[#8bc273]"></div>
              <div className="absolute -bottom-6 -right-8 w-4 h-4 bg-[#8bc273]"></div>

              <h2
                className="text-3xl font-bold text-gray-900"
                style={{
                  fontFamily: 'TA8bit',
                  textShadow: '3px 3px 0px rgba(0,0,0,0.1)'
                }}
              >
                About User
              </h2>
            </div>
          </div>
        </div>

        {/* กล่องตาราง */}
        <div
          className="bg-white border-8 border-[#81c784] overflow-hidden relative"
          style={{
            boxShadow: '12px 12px 0px rgba(129,199,132,0.3)',
            imageRendering: 'pixelated'
          }}
        >
          {/* จุด Pixel ประดับมุม */}
          <div className="absolute -top-2 -left-2 w-6 h-6 bg-[#81c784]"></div>
          <div className="absolute -top-2 -right-2 w-6 h-6 bg-[#81c784]"></div>
          <div className="absolute -bottom-2 -left-2 w-6 h-6 bg-[#81c784]"></div>
          <div className="absolute -bottom-2 -right-2 w-6 h-6 bg-[#81c784]"></div>

          {/* ตารางข้อมูลผู้ใช้ */}
          <div className="overflow-x-auto">
            <table className="w-full" style={{ fontFamily: 'TA8bit' }}>
              <thead>
                <tr className="bg-gradient-to-r from-[#c8e6c9] to-[#dcedc8] border-b-4 border-black">
                  <th className="px-4 py-4 text-center font-bold text-gray-900 border-r-4 border-black w-24">
                    <span className="text-xl">Delete</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Username</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Email</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Phone</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Age</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Gender</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Goal</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900">
                    <span className="text-xl">Last Login</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {users.length > 0 ? (
                  users.map((user, index) => (
                    <tr
                      key={user.user_id}
                      className={`border-b-4 border-black ${
                        index % 2 === 0 ? 'bg-[#e8f5e9]' : 'bg-[#c8e6c9]'
                      } hover:bg-[#a5d6a7] transition-colors`}
                    >
                      <td className="px-4 py-6 border-r-4 border-black text-center">
                        <button
                          onClick={() => handleDeleteClick(user)}
                          className="bg-white border-4 border-black p-2 hover:bg-red-100 transition-colors inline-flex items-center justify-center"
                          style={{ boxShadow: '3px 3px 0px rgba(0,0,0,0.2)' }}
                        >
                          <span className="text-lg">
                            <Image
                              src="/pic/trash.png"
                              alt="delete Icon"
                              width={32}
                              height={32}
                            />
                          </span>
                        </button>
                      </td>
                      <td className="text-xl px-8 py-6 text-gray-700 border-r-4 border-black">
                        {user.username}
                      </td>
                      <td className="text-xl px-8 py-6 text-gray-700 border-r-4 border-black">
                        {user.email}
                      </td>
                      <td className="text-xl px-8 py-6 text-gray-700 border-r-4 border-black">
                        {user.phone_number || '-'}
                      </td>
                      <td className="text-xl px-8 py-6 text-gray-700 border-r-4 border-black">
                        {user.age || '-'}
                      </td>
                      <td className="text-xl px-8 py-6 text-gray-700 border-r-4 border-black">
                        {user.gender || '-'}
                      </td>
                      <td className="text-xl px-8 py-6 text-gray-700 border-r-4 border-black">
                        {user.goal || '-'}
                      </td>
                      <td className="text-xl px-8 py-6 text-gray-700">
                        {user.last_login_at ? new Date(user.last_login_at).toLocaleString('th-TH', {
                          year: 'numeric',
                          month: 'short',
                          day: 'numeric',
                          hour: '2-digit',
                          minute: '2-digit'
                        }) : '-'}
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan={8} className="px-8 py-12 text-center text-gray-500">
                      {isLoading ? 'กำลังโหลดข้อมูล...' : 'ไม่พบข้อมูลผู้ใช้'}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {/* สถานะกำลังโหลด */}
          {isLoading && (
            <div className="absolute inset-0 bg-white/80 flex items-center justify-center">
              <div className="text-center">
                <div className="bg-black border-4 border-[#4dd0e1] p-2 mb-4">
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
                  style={{ fontFamily: 'TA8bit' }}
                >
                  Loading user data...
                </p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Modal ยืนยันการลบผู้ใช้ */}
      {deleteModal.show && deleteModal.user && (
        <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
          <div
            className="bg-[#ffebee] border-8 border-black relative max-w-md w-full"
            style={{
              boxShadow: '20px 20px 0px rgba(0,0,0,0.5)',
              imageRendering: 'pixelated'
            }}
          >
            {/* จุด Pixel ประดับมุม */}
            <div className="absolute -top-3 -left-3 w-8 h-8 bg-[#ef5350] border-4 border-black"></div>
            <div className="absolute -top-3 -right-3 w-8 h-8 bg-[#ef5350] border-4 border-black"></div>
            <div className="absolute -bottom-3 -left-3 w-8 h-8 bg-[#ef5350] border-4 border-black"></div>
            <div className="absolute -bottom-3 -right-3 w-8 h-8 bg-[#ef5350] border-4 border-black"></div>

            {/* ส่วนหัว Modal */}
            <div className="bg-gradient-to-r from-[#f44336] to-[#d32f2f] border-b-8 border-black px-8 py-6 relative">
              {/* จุด Pixel ประดับหัว */}
              <div className="absolute top-2 left-4 w-3 h-3 bg-[#ff5252]"></div>
              <div className="absolute top-2 right-4 w-3 h-3 bg-[#ff5252]"></div>

              <h3
                className="text-3xl font-bold text-white text-center relative"
                style={{
                  fontFamily: 'TA8bit',
                  textShadow: '4px 4px 0px rgba(0,0,0,0.5)'
                }}
              >
                <span className="inline-block mr-3" style={{ fontSize: '2rem' }}>⚠</span>
                WARNING!
                <span className="inline-block ml-3" style={{ fontSize: '2rem' }}>⚠</span>
              </h3>
            </div>

            {/* เนื้อหา Modal */}
            <div className="p-10 bg-[#fff5f5] border-b-8 border-black relative">
              {/* จุด Pixel ประดับเนื้อหา */}
              <div className="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-transparent via-[#f44336] to-transparent opacity-30"></div>

              {/* ไอคอนคำเตือน */}
              <div className="flex justify-center mb-6">
                <div className="relative">
                  <div className="w-24 h-24 bg-[#ff9800] border-8 border-black relative"
                    style={{
                      boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
                      transform: 'rotate(45deg)'
                    }}
                  >
                    <div className="absolute inset-0 flex items-center justify-center" style={{ transform: 'rotate(-45deg)' }}>
                      <span className="text-6xl text-white font-bold">!</span>
                    </div>
                  </div>
                  {/* จุด Pixel อันตราย */}
                  <div className="absolute -top-2 -right-2 w-4 h-4 bg-[#f44336] border-2 border-black"></div>
                  <div className="absolute -bottom-2 -left-2 w-4 h-4 bg-[#f44336] border-2 border-black"></div>
                </div>
              </div>

              <p
                className="text-xl text-gray-800 text-center mb-3"
                style={{ fontFamily: 'TA8bit' }}
              >
                คุณต้องการลบผู้ใช้
              </p>
              <p
                className="text-2xl font-bold text-red-600 text-center mb-3"
                style={{
                  fontFamily: 'TA8bit',
                  textShadow: '2px 2px 0px rgba(244,67,54,0.2)'
                }}
              >
                &quot;{deleteModal.user.username}&quot;
              </p>
              <p
                className="text-lg text-gray-700 text-center"
                style={{ fontFamily: 'TA8bit' }}
              >
                หรือไม่?
              </p>
            </div>

            {/* ส่วนท้าย Modal */}
            <div className="flex gap-4 p-6 bg-[#ffebee]">
              <button
                onClick={handleCancelDelete}
                className="flex-1 bg-gradient-to-b from-[#9e9e9e] to-[#757575] border-6 border-black px-6 py-4 hover:translate-x-[-3px] hover:translate-y-[-3px] transition-transform active:translate-x-[2px] active:translate-y-[2px]"
                style={{
                  boxShadow: '6px 6px 0px rgba(0,0,0,0.4)',
                  fontFamily: 'TA8bit'
                }}
              >
                <span className="text-xl font-bold text-white" style={{ textShadow: '2px 2px 0px rgba(0,0,0,0.5)' }}>
                  ◀ ยกเลิก
                </span>
              </button>
              <button
                onClick={handleConfirmDelete}
                className="flex-1 bg-gradient-to-b from-[#f44336] to-[#c62828] border-6 border-black px-6 py-4 hover:translate-x-[-3px] hover:translate-y-[-3px] transition-transform active:translate-x-[2px] active:translate-y-[2px]"
                style={{
                  boxShadow: '6px 6px 0px rgba(0,0,0,0.4)',
                  fontFamily: 'TA8bit'
                }}
              >
                <span className="text-xl font-bold text-white" style={{ textShadow: '2px 2px 0px rgba(0,0,0,0.5)' }}>
                  ยืนยัน ▶
                </span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal แสดงความสำเร็จ */}
      {successModal && (
        <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
          <div
            className="bg-[#e8f5e9] border-8 border-black relative max-w-md w-full"
            style={{
              boxShadow: '20px 20px 0px rgba(0,0,0,0.5)',
              imageRendering: 'pixelated'
            }}
          >
            {/* จุด Pixel ประดับมุม */}
            <div className="absolute -top-3 -left-3 w-8 h-8 bg-[#66bb6a] border-4 border-black"></div>
            <div className="absolute -top-3 -right-3 w-8 h-8 bg-[#66bb6a] border-4 border-black"></div>
            <div className="absolute -bottom-3 -left-3 w-8 h-8 bg-[#66bb6a] border-4 border-black"></div>
            <div className="absolute -bottom-3 -right-3 w-8 h-8 bg-[#66bb6a] border-4 border-black"></div>

            {/* ส่วนหัว Modal */}
            <div className="bg-gradient-to-r from-[#4caf50] to-[#388e3c] border-b-8 border-black px-8 py-6 relative">
              {/* จุด Pixel ประดับหัว */}
              <div className="absolute top-2 left-4 w-3 h-3 bg-[#81c784]"></div>
              <div className="absolute top-2 right-4 w-3 h-3 bg-[#81c784]"></div>

              <h3
                className="text-3xl font-bold text-white text-center relative"
                style={{
                  fontFamily: 'TA8bit',
                  textShadow: '4px 4px 0px rgba(0,0,0,0.5)'
                }}
              >
                SUCCESS!
              </h3>
            </div>

            {/* เนื้อหา Modal */}
            <div className="p-10 bg-[#f1f8e9] border-b-8 border-black relative">
              {/* จุด Pixel ประดับเนื้อหา */}
              <div className="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-transparent via-[#4caf50] to-transparent opacity-30"></div>

              {/* ไอคอนสำเร็จ */}
              <div className="flex justify-center mb-6">
                <div className="relative">
                  <div className="w-24 h-24 bg-[#4caf50] border-8 border-black relative"
                    style={{ boxShadow: '8px 8px 0px rgba(0,0,0,0.3)' }}
                  >
                    <div className="absolute inset-0 flex items-center justify-center">
                      <span className="text-6xl text-white font-bold">✓</span>
                    </div>
                  </div>
                  {/* จุด Pixel ระยิบระยับ */}
                  <div className="absolute -top-2 -right-2 w-4 h-4 bg-[#ffeb3b] border-2 border-black"></div>
                  <div className="absolute -bottom-2 -left-2 w-4 h-4 bg-[#ffeb3b] border-2 border-black"></div>
                </div>
              </div>

              <p
                className="text-2xl font-bold text-gray-900 text-center mb-2"
                style={{
                  fontFamily: 'TA8bit',
                  textShadow: '2px 2px 0px rgba(76,175,80,0.2)'
                }}
              >
                ลบผู้ใช้สำเร็จ!
              </p>
              <p
                className="text-lg text-gray-700 text-center"
                style={{ fontFamily: 'TA8bit' }}
              >
                +50 XP
              </p>
            </div>

            {/* ส่วนท้าย Modal */}
            <div className="p-6 bg-[#e8f5e9]">
              <button
                onClick={() => setSuccessModal(false)}
                className="w-full bg-gradient-to-b from-[#4caf50] to-[#388e3c] border-6 border-black px-8 py-4 hover:translate-x-[-3px] hover:translate-y-[-3px] transition-transform active:translate-x-[2px] active:translate-y-[2px]"
                style={{
                  boxShadow: '6px 6px 0px rgba(0,0,0,0.4)',
                  fontFamily: 'TA8bit'
                }}
              >
                <span className="text-2xl font-bold text-white" style={{ textShadow: '2px 2px 0px rgba(0,0,0,0.5)' }}>
                  ▶ ตกลง ◀
                </span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}