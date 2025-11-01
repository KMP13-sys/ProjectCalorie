// components/admin/DeleteUserModal.tsx
'use client';

import { useState } from 'react';
import { adminService } from '@/app/services/adminService';

type User = {
  user_id: number;
  username: string;
  email: string;
  phone_number?: string;
  age?: number;
  gender?: 'male' | 'female';
  height?: number;
  weight?: number;
  goal?: 'lose weight' | 'maintain weight' | 'gain weight';
};

type DeleteUserModalProps = {
  user: User;
  onClose: () => void;
  onDelete: () => void; // callback หลังลบสำเร็จ
};

export default function DeleteUserModal({ user, onClose, onDelete }: DeleteUserModalProps) {
  const [deleting, setDeleting] = useState(false);

  const handleDelete = async () => {
    if (!confirm(`คุณแน่ใจว่าต้องการลบผู้ใช้ ${user.username} ?`)) return;

    try {
      setDeleting(true);
      await adminService.deleteUser(user.user_id.toString());
      alert('ลบผู้ใช้สำเร็จ!');
      onDelete();
    } catch (error) {
      console.error(error);
      alert('เกิดข้อผิดพลาดในการลบผู้ใช้!');
    } finally {
      setDeleting(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
      <div className="bg-white border-4 border-black shadow-lg max-w-md w-full p-6">
        <h2 className="text-xl font-bold mb-4">ลบผู้ใช้</h2>
        <p>คุณแน่ใจว่าต้องการลบผู้ใช้ <strong>{user.username}</strong> หรือไม่?</p>
        <div className="mt-6 flex justify-end gap-4">
          <button
            className="bg-gray-300 px-4 py-2 border border-black"
            onClick={onClose}
            disabled={deleting}
          >
            ยกเลิก
          </button>
          <button
            className="bg-red-500 text-white px-4 py-2 border border-black"
            onClick={handleDelete}
            disabled={deleting}
          >
            {deleting ? 'กำลังลบ...' : 'ลบ'}
          </button>
        </div>
      </div>
    </div>
  );
}
