// components/admin/FoodTable.tsx
'use client';

import { useState } from 'react';
import FoodTableRow from './FoodTableRow';
import EditFoodModal from './EditFoodModal';

type Food = {
  id: number;
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
};

type FoodTableProps = {
  foods: Food[];
  loading: boolean;
  onUpdate: () => void;
};

export default function FoodTable({ foods, loading, onUpdate }: FoodTableProps) {
  const [editingFood, setEditingFood] = useState<Food | null>(null);

  return (
    <div className="w-full p-4 sm:p-6">
      {/* Container */}
      <div className="max-w-7xl mx-auto">
        
        {/* Header with Back Button */}
        <div className="flex items-center gap-3 sm:gap-4 mb-4 sm:mb-6 ">
          {/* Back Button */}
          <button 
            onClick={() => window.history.back()}
            className="w-12 h-12 sm:w-14 sm:h-14 md:w-16 md:h-16 border-3 sm:border-4 border-black bg-white hover:bg-gray-100 active:translate-y-1 transition-all shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] flex items-center justify-center group text-black "
          >
            <span className="text-2xl sm:text-3xl md:text-4xl group-hover:-translate-x-1 transition-transform">◀</span>
          </button>

          {/* Title */}
          <div className="flex-1 bg-gradient-to-r from-green-300 via-green-200 to-green-300 border-3 sm:border-4 border-black shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] p-3 sm:p-4 md:p-5">
            <h2 className="text-xl sm:text-2xl md:text-3xl lg:text-4xl font-bold text-center tracking-wider text-black">
              About Food
            </h2>
            
            {/* Pixel Dots */}
            <div className="flex justify-center gap-2 mt-2">
              <div className="w-2 h-2 sm:w-3 sm:h-3 bg-green-600"></div>
              <div className="w-2 h-2 sm:w-3 sm:h-3 bg-green-500"></div>
              <div className="w-2 h-2 sm:w-3 sm:h-3 bg-green-400"></div>
            </div>
          </div>
        </div>

        {/* Table Container */}
        <div className="bg-white border-3 sm:border-4 md:border-[6px] border-black shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] sm:shadow-[12px_12px_0px_0px_rgba(0,0,0,1)] overflow-hidden">
          
          {/* Corner Pixels */}
          <div className="relative">
            <div className="absolute top-0 left-0 w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 bg-green-400 z-10"></div>
            <div className="absolute top-0 right-0 w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 bg-green-400 z-10"></div>
            <div className="absolute bottom-0 left-0 w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 bg-green-400 z-10"></div>
            <div className="absolute bottom-0 right-0 w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 bg-green-400 z-10"></div>

            {/* Table */}
            <div className="overflow-x-auto">
              <table className="w-full border-collapse min-w-[640px]">
                <thead>
                  <tr className="bg-gradient-to-r from-green-200 via-green-300 to-green-200">
                    <th className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg lg:text-xl w-20 sm:w-24 md:w-28 text-black">
                      Edit
                    </th>
                    <th className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg lg:text-xl text-left text-black text-black">
                      Name
                    </th>
                    <th className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg lg:text-xl w-24 sm:w-28 md:w-32 text-black">
                      Kcal
                    </th>
                    <th className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg lg:text-xl w-24 sm:w-28 md:w-32 text-black">
                      Protein
                    </th>
                    <th className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg lg:text-xl w-24 sm:w-28 md:w-32 text-black">
                      Carb
                    </th>
                    <th className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg lg:text-xl w-24 sm:w-28 md:w-32 text-black">
                      Fat
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {loading ? (
                    <tr>
                      <td colSpan={6} className="text-center p-8 sm:p-12 md:p-16 bg-green-50">
                        <div className="flex flex-col items-center justify-center gap-3 sm:gap-4">
                          <div className="w-12 h-12 sm:w-16 sm:h-16 border-4 sm:border-[6px] border-gray-300 border-t-green-500 rounded-full animate-spin"></div>
                          <span className="text-base sm:text-lg md:text-xl font-bold text-gray-600">Loading...</span>
                        </div>
                      </td>
                    </tr>
                  ) : foods.length === 0 ? (
                    <tr>
                      <td colSpan={6} className="text-center p-8 sm:p-12 md:p-16 bg-green-50">
                        <div className="flex flex-col items-center gap-3 sm:gap-4">
                          <span className="text-4xl sm:text-5xl md:text-6xl">🍽️</span>
                          <span className="text-base sm:text-lg md:text-xl font-bold text-gray-600">ไม่มีข้อมูลอาหาร</span>
                          <span className="text-xs sm:text-sm md:text-base text-gray-500">กรุณาเพิ่มข้อมูลอาหาร</span>
                        </div>
                      </td>
                    </tr>
                  ) : (
                    foods.map((food, index) => (
                      <FoodTableRow
                        key={food.id}
                        food={food}
                        onEdit={() => setEditingFood(food)}
                        isEven={index % 2 === 0}
                      />
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      {/* Edit Modal */}
      {editingFood && (
        <EditFoodModal
          food={editingFood}
          onClose={() => setEditingFood(null)}
          onSave={() => {
            setEditingFood(null);
            onUpdate();
          }}
        />
      )}
    </div>
  );
}