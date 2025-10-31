// components/admin/UserTableRow.tsx
'use client';

import { userAPI } from '../services/userService';

type UserTableRowProps = {
  user: User;
  onEdit: () => void;
  isEven?: boolean;
};

export default function FoodTableRow({ user, onEdit, isEven = false }: FoodTableRowProps) {
  return (
    <tr className={`border-2 sm:border-3 border-black transition-colors hover:bg-green-100 ${
      isEven ? 'bg-green-50' : 'bg-white'
    }`}>
      {/* Edit Button */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center">
        <button
          onClick={onEdit}
          className="w-10 h-10 sm:w-12 sm:h-12 md:w-14 md:h-14 border-2 sm:border-3 border-black bg-white hover:bg-green-200 active:translate-y-1 transition-all shadow-[3px_3px_0px_0px_rgba(0,0,0,1)] flex items-center justify-center mx-auto group"
          aria-label={`แก้ไข ${user.username}`}
        >
          <span className="text-xl sm:text-2xl md:text-3xl group-hover:scale-110 transition-transform">                  
            <img
              src="/pic/edit.png"
              alt="Logo"
              className="w-15 h-15 object-contain"
              style={{ imageRendering: 'pixelated' }}
            /></span>
        </button>
      </td>
      
      {/* Name */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-medium text-sm sm:text-base md:text-lg ">
        <span className="flex items-center gap-2">
          <span className="text-lg sm:text-xl md:text-2xl text-black"></span>
          {user.username}
        </span>
      </td>

            {/* Calories */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg text-black">
        <span className="inline-block px-2 py-1 text-black">
          {user.email}
        </span>
      </td>

      {/* Calories */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg text-black">
        <span className="inline-block px-2 py-1 text-black">
          {user.phone_number}
        </span>
      </td>
      
      {/* Protein */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block  px-2 py-1 text-black">
          {user.age}
        </span>
      </td>
      
      {/* Carbs */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block px-2 py-1 text-black">
          {user.gender}
        </span>
      </td>
      
      {/* Fat */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block px-2 py-1 text-black">
          {user.height}
        </span>
      </td>

      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block px-2 py-1 text-black">
          {user.weight}
        </span>
      </td>

      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        <span className="inline-block px-2 py-1 text-black">
          {user.goal}
        </span>
      </td>

    </tr>
  );
}