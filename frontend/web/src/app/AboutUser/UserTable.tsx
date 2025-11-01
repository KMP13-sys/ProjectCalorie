// components/admin/UserTable.tsx
'use client';

import { useState } from 'react';
import UserTableRow from './UserTableRow';
import DeleteUserModal from './DeleteUserModal';
import { User } from '@/app/services/adminService';

type UserTableProps = {
  users: User[];
  loading: boolean;
  onUpdate: () => void; // รีเฟรชตารางหลังแก้ไขหรือลบ
};

export default function UserTable({ users, loading, onUpdate }: UserTableProps) {
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [deletingUser, setDeletingUser] = useState<User | null>(null);

  return (
    <div className="w-full p-2 sm:p-4 md:p-6">
      <div className="max-w-7xl mx-auto">

        {/* Header */}
        <div className="flex flex-col sm:flex-row items-center gap-2 sm:gap-4 mb-4 sm:mb-6">
          <button 
            onClick={() => window.history.back()}
            className="w-10 h-10 sm:w-14 sm:h-14 md:w-16 md:h-16 border-2 sm:border-3 border-black bg-white hover:bg-gray-100 active:translate-y-1 transition-all shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] flex items-center justify-center group text-black"
          >
            <span className="text-xl sm:text-2xl md:text-3xl group-hover:-translate-x-1 transition-transform">◀</span>
          </button>

          <div className="flex-1 bg-gradient-to-r from-green-300 via-green-200 to-green-300 border-2 sm:border-3 border-black shadow-[6px_6px_0px_0px_rgba(0,0,0,1)] p-2 sm:p-4 md:p-5">
            <h2 className="text-lg sm:text-2xl md:text-3xl lg:text-4xl font-bold text-center tracking-wider text-black">
              Users
            </h2>
            <div className="flex justify-center gap-1 sm:gap-2 mt-1 sm:mt-2">
              <div className="w-2 h-2 sm:w-3 sm:h-3 bg-green-600 rounded-full"></div>
              <div className="w-2 h-2 sm:w-3 sm:h-3 bg-green-500 rounded-full"></div>
              <div className="w-2 h-2 sm:w-3 sm:h-3 bg-green-400 rounded-full"></div>
            </div>
          </div>
        </div>

        {/* Table */}
        <div className="bg-white border-2 sm:border-3 md:border-4 border-black shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] sm:shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] overflow-hidden rounded-md">
          <div className="overflow-x-auto">
            <table className="w-full border-collapse min-w-[600px] sm:min-w-[640px]">
              <thead>
                <tr className="bg-gradient-to-r from-green-200 via-green-300 to-green-200">
                  <th className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center w-16 sm:w-20 md:w-24">Delete</th>
                  <th className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-left">Username</th>
                  <th className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">Email</th>
                  <th className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">Phone</th>
                  <th className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">Weight</th>
                  <th className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">Age</th>
                  <th className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">Gender</th>
                  <th className="border border-black p-2 sm:p-3 md:p-4 font-bold text-sm sm:text-base md:text-lg text-center">Goal</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={8} className="text-center p-6 sm:p-8 md:p-12 bg-green-50">
                      <div className="flex flex-col items-center justify-center gap-2 sm:gap-3">
                        <div className="w-10 h-10 sm:w-12 sm:h-12 border-4 sm:border-6 border-gray-300 border-t-green-500 rounded-full animate-spin"></div>
                        <span className="text-sm sm:text-base md:text-lg font-bold text-gray-600">Loading...</span>
                      </div>
                    </td>
                  </tr>
                ) : users.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="text-center p-6 sm:p-8 md:p-12 bg-green-50">
                      <div className="flex flex-col items-center gap-2 sm:gap-3">
                        <span className="text-3xl sm:text-4xl md:text-5xl">👤</span>
                        <span className="text-sm sm:text-base md:text-lg font-bold text-gray-600">ไม่มีผู้ใช้</span>
                        <span className="text-xs sm:text-sm md:text-base text-gray-500">กรุณาเพิ่มผู้ใช้</span>
                      </div>
                    </td>
                  </tr>
                ) : (
                  users.map((user, index) => (
                    <UserTableRow
                      key={user.user_id}
                      user={user}
                      onEdit={() => setEditingUser(user)}
                      isEven={index % 2 === 0}
                    />
                  ))
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* Delete Modal */}
      {deletingUser && (
        <DeleteUserModal
          user={deletingUser}
          onClose={() => setDeletingUser(null)}
          onDelete={() => {
            setDeletingUser(null);
            onUpdate();
          }}
        />
      )}
    </div>
  );
}
