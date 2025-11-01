// components/admin/FoodTableRow.tsx

import { Food } from '@/app/services/adminService';

type FoodTableRowProps = {
  food: Food;
  onEdit: () => void;
  isEven?: boolean;
};

export default function FoodTableRow({ food, onEdit, isEven = false }: FoodTableRowProps) {
  return (
    <tr className={`border-2 sm:border-3 border-black transition-colors hover:bg-green-100 ${
      isEven ? 'bg-green-50' : 'bg-white'
    }`}>
      {/* Edit Button */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center">
        <button
          onClick={onEdit}
          className="w-10 h-10 sm:w-12 sm:h-12 md:w-14 md:h-14 border-2 sm:border-3 border-black bg-white hover:bg-green-200 active:translate-y-1 transition-all shadow-[3px_3px_0px_0px_rgba(0,0,0,1)] flex items-center justify-center mx-auto group"
          aria-label={`แก้ไข ${food.food_name}`}
        >
          <span className="text-xl sm:text-2xl md:text-3xl group-hover:scale-110 transition-transform">✏️</span>
        </button>
      </td>

      {/* Name */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-medium text-l sm:text-base md:text-lg">
        <span className="flex items-center gap-2 text-black">
          {food.food_name}
        </span>
      </td>

      {/* Calories */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block bg-orange-100 border-2 border-black px-2 py-1 text-orange-700">
          {food.calories}
        </span>
      </td>

      {/* Protein */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block bg-red-100 border-2 border-black px-2 py-1 text-red-700">
          {food.protein_gram}g
        </span>
      </td>

      {/* Carbs */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block bg-yellow-100 border-2 border-black px-2 py-1 text-yellow-700">
          {food.carbohydrate_gram}g
        </span>
      </td>

      {/* Fat */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block bg-purple-100 border-2 border-black px-2 py-1 text-purple-700">
          {food.fat_gram}g
        </span>
      </td>
    </tr>
  );
}