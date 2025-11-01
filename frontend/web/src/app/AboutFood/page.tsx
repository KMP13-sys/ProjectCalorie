'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import NavBarAdmin from '../componants/NavBarAdmin';
import { adminService, Food } from '../../services/adminService';

/**
 * Type สำหรับเก็บข้อมูลอาหารที่กำลังแก้ไข
 */
type EditingFood = {
  food_id: number;
  food_name: string;
  protein_gram: number;
  fat_gram: number;
  carbohydrate_gram: number;
  calories: number;
};

/**
 * หน้าจัดการข้อมูลอาหาร (About Food)
 * ใช้สำหรับแสดงและแก้ไขข้อมูลอาหารทั้งหมดในระบบ
 */
export default function AboutFoodPage() {
  const router = useRouter();
  const [foods, setFoods] = useState<Food[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null); // ID ของอาหารที่กำลังแก้ไข
  const [editingData, setEditingData] = useState<EditingFood | null>(null); // ข้อมูลชั่วคราวสำหรับการแก้ไข
  const [successModal, setSuccessModal] = useState(false); // สถานะการแสดง modal สำเร็จ

  /**
   * โหลดข้อมูลอาหารทั้งหมดเมื่อหน้าโหลดครั้งแรก
   */
  useEffect(() => {
    fetchFoods();
  }, []);

  /**
   * ดึงข้อมูลอาหารทั้งหมดจาก API
   */
  const fetchFoods = async () => {
    setIsLoading(true);
    try {
      const data = await adminService.getAllFoods();
      setFoods(data);
    } catch (error) {
      console.error('Error fetching foods:', error);
      alert('ไม่สามารถโหลดข้อมูลอาหารได้');
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * เริ่มโหมดแก้ไขข้อมูลอาหาร
   * @param food - ข้อมูลอาหารที่ต้องการแก้ไข
   */
  const handleEditClick = (food: Food) => {
    setEditingId(food.food_id);
    setEditingData({ ...food });
  };

  /**
   * ยกเลิกการแก้ไขและคืนค่าเป็นโหมดแสดงผล
   */
  const handleCancelEdit = () => {
    setEditingId(null);
    setEditingData(null);
  };

  /**
   * บันทึกการแก้ไขข้อมูลอาหารและอัพเดทไปยัง API
   */
  const handleSaveEdit = async () => {
    if (!editingData) return;

    try {
      await adminService.updateFood(editingData.food_id, {
        food_name: editingData.food_name,
        protein_gram: editingData.protein_gram,
        fat_gram: editingData.fat_gram,
        carbohydrate_gram: editingData.carbohydrate_gram,
        calories: editingData.calories,
      });
      setEditingId(null);
      setEditingData(null);
      setSuccessModal(true);
      fetchFoods(); // รีเฟรชข้อมูลอาหารหลังจากแก้ไขสำเร็จ
    } catch (error) {
      console.error('Error updating food:', error);
      alert('ไม่สามารถแก้ไขข้อมูลอาหารได้');
    }
  };

  /**
   * อัพเดทค่าของฟิลด์ที่กำลังแก้ไข
   * @param field - ชื่อฟิลด์ที่ต้องการแก้ไข
   * @param value - ค่าใหม่
   */
  const handleInputChange = (field: keyof EditingFood, value: string | number) => {
    if (!editingData) return;
    setEditingData({
      ...editingData,
      [field]: value,
    });
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
              <div className="absolute -top-6 -left-8 w-4 h-4 bg-[#ff9800]"></div>
              <div className="absolute -top-6 -right-8 w-4 h-4 bg-[#ff9800]"></div>
              <div className="absolute -bottom-6 -left-8 w-4 h-4 bg-[#ff9800]"></div>
              <div className="absolute -bottom-6 -right-8 w-4 h-4 bg-[#ff9800]"></div>

              <h2 
                className="text-3xl font-bold text-gray-900"
                style={{ 
                  fontFamily: 'TA8bit',
                  textShadow: '3px 3px 0px rgba(0,0,0,0.1)'
                }}
              >
                About Food
              </h2>
            </div>
          </div>
        </div>

        {/* กล่องตาราง */}
        <div
          className="bg-white border-8 border-[#ff9800] overflow-hidden relative"
          style={{
            boxShadow: '12px 12px 0px rgba(255,152,0,0.3)',
            imageRendering: 'pixelated'
          }}
        >
          {/* จุด Pixel ประดับมุม */}
          <div className="absolute -top-2 -left-2 w-6 h-6 bg-[#ff9800]"></div>
          <div className="absolute -top-2 -right-2 w-6 h-6 bg-[#ff9800]"></div>
          <div className="absolute -bottom-2 -left-2 w-6 h-6 bg-[#ff9800]"></div>
          <div className="absolute -bottom-2 -right-2 w-6 h-6 bg-[#ff9800]"></div>

          {/* ตารางข้อมูลอาหาร */}
          <div className="overflow-x-auto">
            <table className="w-full" style={{ fontFamily: 'TA8bit' }}>
              <thead>
                <tr className="bg-gradient-to-r from-[#ffecb3] to-[#ffe082] border-b-4 border-black">
                  <th className="px-4 py-4 text-center font-bold text-gray-900 border-r-4 border-black w-24">
                    <span className="text-xl">Edit</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Name</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Kcal</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Protein</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900 border-r-4 border-black">
                    <span className="text-xl">Carb</span>
                  </th>
                  <th className="px-8 py-4 text-left font-bold text-gray-900">
                    <span className="text-xl">Fat</span>
                  </th>
                </tr>
              </thead>
              <tbody>
                {foods.length > 0 ? (
                  foods.map((food, index) => {
                    const isEditing = editingId === food.food_id; // เช็คว่าแถวนี้อยู่ในโหมดแก้ไขหรือไม่
                    const displayData = isEditing && editingData ? editingData : food; // แสดงข้อมูลที่กำลังแก้ไข หรือข้อมูลจริง

                    return (
                      <tr
                        key={food.food_id}
                        className={`border-b-4 border-black ${
                          index % 2 === 0 ? 'bg-[#fff3e0]' : 'bg-[#ffe0b2]'
                        } ${isEditing ? 'bg-[#ffecb3]' : 'hover:bg-[#ffd54f]'} transition-colors`}
                      >
                        <td className="px-4 py-6 border-r-4 border-black text-center">
                          {isEditing ? (
                            <div className="flex gap-2 justify-center">
                              {/* ปุ่มยกเลิก */}
                              <button
                                onClick={handleCancelEdit}
                                className="bg-white border-4 border-black p-2 hover:bg-red-100 transition-colors inline-flex items-center justify-center"
                                style={{ boxShadow: '3px 3px 0px rgba(0,0,0,0.2)' }}
                              >
                                <span className="text-2xl font-bold text-red-600">✕</span>
                              </button>
                              {/* ปุ่มบันทึก */}
                              <button
                                onClick={handleSaveEdit}
                                className="bg-white border-4 border-black p-2 hover:bg-green-100 transition-colors inline-flex items-center justify-center"
                                style={{ boxShadow: '3px 3px 0px rgba(0,0,0,0.2)' }}
                              >
                                <span className="text-2xl font-bold text-green-600">✓</span>
                              </button>
                            </div>
                          ) : (
                            <button
                              onClick={() => handleEditClick(food)}
                              className="bg-white border-4 border-black p-2 hover:bg-blue-100 transition-colors inline-flex items-center justify-center"
                              style={{ boxShadow: '3px 3px 0px rgba(0,0,0,0.2)' }}
                            >
                              <span className="text-lg">
                                <Image
                                  src="/pic/edit.png"
                                  alt="edit Icon"
                                  width={32}
                                  height={32}
                                />
                              </span>
                            </button>
                          )}
                        </td>
                        <td className="px-8 py-6 text-gray-700 border-r-4 border-black">
                          {isEditing ? (
                            <input
                              type="text"
                              value={displayData.food_name}
                              onChange={(e) => handleInputChange('food_name', e.target.value)}
                              className="w-full px-3 py-2 border-4 border-black text-xl bg-white"
                              style={{ fontFamily: 'TA8bit' }}
                            />
                          ) : (
                            <span className="text-xl">{displayData.food_name}</span>
                          )}
                        </td>
                        <td className="px-8 py-6 text-gray-700 border-r-4 border-black">
                          {isEditing ? (
                            <input
                              type="number"
                              value={displayData.calories}
                              onChange={(e) => handleInputChange('calories', Number(e.target.value))}
                              className="w-full px-3 py-2 border-4 border-black text-xl bg-white"
                              style={{ fontFamily: 'TA8bit' }}
                            />
                          ) : (
                            <span className="text-xl">{displayData.calories}</span>
                          )}
                        </td>
                        <td className="px-8 py-6 text-gray-700 border-r-4 border-black">
                          {isEditing ? (
                            <input
                              type="number"
                              step="0.1"
                              value={displayData.protein_gram}
                              onChange={(e) => handleInputChange('protein_gram', Number(e.target.value))}
                              className="w-full px-3 py-2 border-4 border-black text-xl bg-white"
                              style={{ fontFamily: 'TA8bit' }}
                            />
                          ) : (
                            <span className="text-xl">{displayData.protein_gram}</span>
                          )}
                        </td>
                        <td className="px-8 py-6 text-gray-700 border-r-4 border-black">
                          {isEditing ? (
                            <input
                              type="number"
                              step="0.1"
                              value={displayData.carbohydrate_gram}
                              onChange={(e) => handleInputChange('carbohydrate_gram', Number(e.target.value))}
                              className="w-full px-3 py-2 border-4 border-black text-xl bg-white"
                              style={{ fontFamily: 'TA8bit' }}
                            />
                          ) : (
                            <span className="text-xl">{displayData.carbohydrate_gram}</span>
                          )}
                        </td>
                        <td className="px-8 py-6 text-gray-700">
                          {isEditing ? (
                            <input
                              type="number"
                              step="0.1"
                              value={displayData.fat_gram}
                              onChange={(e) => handleInputChange('fat_gram', Number(e.target.value))}
                              className="w-full px-3 py-2 border-4 border-black text-xl bg-white"
                              style={{ fontFamily: 'TA8bit' }}
                            />
                          ) : (
                            <span className="text-xl">{displayData.fat_gram}</span>
                          )}
                        </td>
                      </tr>
                    );
                  })
                ) : (
                  <tr>
                    <td colSpan={6} className="px-8 py-12 text-center text-gray-500">
                      {isLoading ? 'กำลังโหลดข้อมูล...' : 'ไม่พบข้อมูลอาหาร'}
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
                  Loading food data...
                </p>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Modal แสดงความสำเร็จ */}
      {successModal && (
        <div className="fixed inset-0 bg-black/70 flex items-center justify-center z-50 p-4">
          <div
            className="bg-[#fff9c4] border-8 border-black relative max-w-md w-full"
            style={{
              boxShadow: '20px 20px 0px rgba(0,0,0,0.5)',
              imageRendering: 'pixelated'
            }}
          >
            {/* จุด Pixel ประดับมุม */}
            <div className="absolute -top-3 -left-3 w-8 h-8 bg-[#ffd54f] border-4 border-black"></div>
            <div className="absolute -top-3 -right-3 w-8 h-8 bg-[#ffd54f] border-4 border-black"></div>
            <div className="absolute -bottom-3 -left-3 w-8 h-8 bg-[#ffd54f] border-4 border-black"></div>
            <div className="absolute -bottom-3 -right-3 w-8 h-8 bg-[#ffd54f] border-4 border-black"></div>

            {/* ส่วนหัว Modal */}
            <div className="bg-gradient-to-r from-[#ff9800] to-[#ff6f00] border-b-8 border-black px-8 py-6 relative">
              {/* จุด Pixel ประดับหัว */}
              <div className="absolute top-2 left-4 w-3 h-3 bg-[#ffb74d]"></div>
              <div className="absolute top-2 right-4 w-3 h-3 bg-[#ffb74d]"></div>

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
            <div className="p-10 bg-[#fffde7] border-b-8 border-black relative">
              {/* จุด Pixel ประดับเนื้อหา */}
              <div className="absolute top-0 left-0 w-full h-2 bg-gradient-to-r from-transparent via-[#ff9800] to-transparent opacity-30"></div>

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
                  textShadow: '2px 2px 0px rgba(255,152,0,0.2)'
                }}
              >
                แก้ไขข้อมูลอาหารสำเร็จ!
              </p>
              <p
                className="text-lg text-gray-700 text-center"
                style={{ fontFamily: 'TA8bit' }}
              >
                +100 XP
              </p>
            </div>

            {/* ส่วนท้าย Modal */}
            <div className="p-6 bg-[#fff9c4]">
              <button
                onClick={() => setSuccessModal(false)}
                className="w-full bg-gradient-to-b from-[#ff9800] to-[#f57c00] border-6 border-black px-8 py-4 hover:translate-x-[-3px] hover:translate-y-[-3px] transition-transform active:translate-x-[2px] active:translate-y-[2px]"
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