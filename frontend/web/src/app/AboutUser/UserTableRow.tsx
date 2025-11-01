// components/admin/UserTableRow.tsx
'use client';

import { User } from '@/app/services/adminService';

type UserTableRowProps = {
  user: User;
  onEdit: () => void;
  isEven?: boolean;
};

export default function UserTableRow({ user, onEdit, isEven = false }: UserTableRowProps) {
  return (
    <tr className={`border-2 sm:border-3 border-black transition-colors hover:bg-green-100 ${isEven ? 'bg-green-50' : 'bg-white'}`}>
      
      {/* Edit Button */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center">
        <button
          onClick={onEdit}
          className="w-10 h-10 sm:w-12 sm:h-12 md:w-14 md:h-14 border-2 sm:border-3 border-black bg-white hover:bg-green-200 active:translate-y-1 transition-all shadow-[3px_3px_0px_0px_rgba(0,0,0,1)] flex items-center justify-center mx-auto group"
          aria-label={`แก้ไข ${user.username}`}
        >
          <span className="text-xl sm:text-2xl md:text-3xl group-hover:scale-110 transition-transform">                  
            <img
              src="/pic/trash.png"
              alt="Logo"
              className="w-15 h-15 object-contain"
              style={{ imageRendering: 'pixelated' }}
            />
          </span>
        </button>
      </td>

      {/* Username */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 font-medium text-sm sm:text-base md:text-lg ">
        {user.username}
      </td>

      {/* Email */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        {user.email}
      </td>

      {/* Phone Number */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        {user.phone_number}
      </td>

      {/* Age */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        {user.age}
      </td>

      {/* Gender */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        {user.gender}
      </td>

      {/* Goal */}
      <td className="border-2 sm:border-3 border-black p-2 sm:p-3 md:p-4 text-center font-bold text-sm sm:text-base md:text-lg">
        {user.goal}
      </td>

    </tr>
  );
}
