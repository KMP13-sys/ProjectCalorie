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
    <tr className={`border border-black transition-colors hover:bg-green-100 ${isEven ? 'bg-green-50' : 'bg-white'}`}>
      
      {/* Edit Button */}
      <td className="border border-black p-2 sm:p-3 md:p-4 flex items-center justify-center">
        <button
          onClick={onEdit}
          className="w-8 h-8 sm:w-10 sm:h-10 md:w-12 md:h-12 flex items-center justify-center mx-auto group transition-transform active:translate-y-1"
          aria-label={`แก้ไข ${user.username}`}
        >
          <img
            src="/pic/trash.png"
            alt="Logo"
            className="w-full h-full object-contain"
            style={{ imageRendering: 'pixelated' }}
          />
        </button>
      </td>

      {/* Username */}
      <td className="border border-black p-2 sm:p-3 md:p-4 font-medium text-sm sm:text-base md:text-lg text-center md:text-left">
        {user.username}
      </td>

      {/* Email */}
      <td className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center break-words">
        {user.email}
      </td>

      {/* Phone Number */}
      <td className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">
        {user.phone_number ?? '-'}
      </td>

            {/* Age */}
      <td className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">
        {user.weight ?? '-'}
      </td>

      {/* Age */}
      <td className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">
        {user.age ?? '-'}
      </td>

      {/* Gender */}
      <td className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center capitalize">
        {user.gender ?? '-'}
      </td>

      {/* Goal */}
      <td className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center capitalize">
        {user.goal ?? '-'}
      </td>

    </tr>
  );
}
