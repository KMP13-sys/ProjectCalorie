// components/admin/EditUserModal.tsx
'use client';

import React, { useState, useEffect } from 'react';
import { User } from '../services/userModel'; 
import { adminAPI } from '../services/adminService';

interface EditUserModalProps {
  user: User | null;
  onClose: () => void;
  onSave: () => void;
}

// ----------------
// Helper Component: Input Field
// ----------------
interface InputFieldProps {
    label: string;
    name: keyof User;
    value: string | number | undefined;
    onChange: (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => void;
    type?: 'text' | 'number' | 'email';
    required?: boolean;
    options?: string[];
}

const InputField: React.FC<InputFieldProps> = ({ label, name, value, onChange, type = 'text', required = false, options }) => {
    const inputId = `edit-user-${String(name)}`;
    const inputBaseStyle = "w-full p-2 sm:p-3 border-2 border-black bg-white focus:outline-none focus:ring-2 focus:ring-green-500 transition-all text-sm sm:text-base text-black";

    return (
        <div className="mb-4">
            <label htmlFor={inputId} className="block text-sm sm:text-base font-bold text-black mb-1">
                {label} {required && <span className="text-red-500">*</span>}
            </label>
            {options ? (
                <select
                    id={inputId}
                    name={String(name)}
                    value={value || ''}
                    onChange={onChange}
                    required={required}
                    className={`${inputBaseStyle} rounded-none shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]`}
                >
                    {options.map(option => (
                        <option key={option} value={option}>{option}</option>
                    ))}
                </select>
            ) : (
                <input
                    id={inputId}
                    type={type}
                    name={String(name)}
                    value={value ?? ''}
                    onChange={onChange}
                    required={required}
                    className={`${inputBaseStyle} rounded-none shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]`}
                />
            )}
        </div>
    );
};

// ----------------
// Main Component: EditUserModal
// ----------------
const EditUserModal: React.FC<EditUserModalProps> = ({ user, onClose, onSave }) => {
  const [formData, setFormData] = useState<Partial<User>>({
    username: '',
    email: '',
    phone_number: '',
    age: undefined,
    gender: 'male', 
    height: undefined,
    weight: undefined,
    goal: 'maintain weight',
  });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    if (!user) return;

    const genderOptions: User['gender'][] = ['male', 'female'];
    const goalOptions: User['goal'][] = ['lose weight', 'maintain weight', 'gain weight'];

    const mappedGender = user.gender && genderOptions.includes(user.gender) ? user.gender : 'male';
    const mappedGoal = user.goal && goalOptions.includes(user.goal) ? user.goal : 'maintain weight';

    setFormData({
      username: user.username || '',
      email: user.email || '',
      phone_number: user.phone_number || '',
      age: user.age ?? undefined,
      gender: mappedGender,
      height: user.height ?? undefined,
      weight: user.weight ?? undefined,
      goal: mappedGoal,
    });

    setError(null);
    setSuccess(null);
  }, [user]);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    let finalValue: string | number | undefined = value;

    if (type === 'number') {
      const num = parseFloat(value);
      finalValue = isNaN(num) ? undefined : num;
    }

    setFormData(prev => ({ ...prev, [name]: finalValue }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!user) return;

    setLoading(true);
    setError(null);
    setSuccess(null);

    const payload = {
      username: formData.username!,
      email: formData.email!,
      phone_number: formData.phone_number,
      age: formData.age,
      gender: formData.gender,
      height: formData.height,
      weight: formData.weight,
      goal: formData.goal,
    };

    try {
      await adminAPI.updateUser(user.user_id, payload);

      setSuccess('บันทึกข้อมูลเรียบร้อยแล้ว');
      setTimeout(() => {
        onSave();   // รีโหลดตารางหรือข้อมูลหลังแก้ไข
        onClose();  // ปิด modal
      }, 1500);

    } catch (err: any) {
      console.error('Update Error:', err);
      setError(err.message || 'เกิดข้อผิดพลาดในการบันทึกข้อมูล');
    } finally {
      setLoading(false);
    }
  };

  if (!user) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-70 backdrop-blur-sm p-4 sm:p-8">
      <div className="relative bg-white border-4 border-black shadow-[8px_8px_0px_0px_rgba(0,0,0,1)] w-full max-w-lg mx-auto p-6 sm:p-8 md:p-10 max-h-[90vh] overflow-y-auto">
        <button
          onClick={onClose}
          className="absolute top-[-15px] right-[-15px] w-8 h-8 sm:w-10 sm:h-10 border-3 border-black bg-red-500 hover:bg-red-600 active:translate-y-1 transition-all shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] text-white text-xl sm:text-2xl font-bold flex items-center justify-center"
          aria-label="ปิด"
        >
          X
        </button>

        <h3 className="text-xl sm:text-2xl font-bold text-center mb-6 text-black border-b-2 border-black pb-2">
          แก้ไขข้อมูลผู้ใช้: {user.username} (ID: {user.user_id})
        </h3>

        <form onSubmit={handleSubmit}>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <InputField label="Username" name="username" value={formData.username} onChange={handleChange} required />
            <InputField label="Email" name="email" value={formData.email} onChange={handleChange} type="email" required />
            <InputField label="เบอร์โทรศัพท์" name="phone_number" value={formData.phone_number} onChange={handleChange} />
            <InputField label="อายุ" name="age" value={formData.age} onChange={handleChange} type="number" />
            <InputField label="เพศ" name="gender" value={formData.gender} onChange={handleChange} options={['male','female']} />
            <InputField label="ส่วนสูง (ซม.)" name="height" value={formData.height} onChange={handleChange} type="number" />
            <InputField label="น้ำหนัก (กก.)" name="weight" value={formData.weight} onChange={handleChange} type="number" />
            <InputField label="เป้าหมาย" name="goal" value={formData.goal} onChange={handleChange} options={['lose weight','maintain weight','gain weight']} />
          </div>

          {error && <p className="text-red-500 font-bold mt-4 text-center border-2 border-red-500 p-2 bg-red-50">{error}</p>}
          {success && <p className="text-green-600 font-bold mt-4 text-center border-2 border-green-600 p-2 bg-green-50">{success}</p>}

          <div className="flex justify-end gap-3 mt-8 flex-wrap">
            <button type="button" onClick={onClose} disabled={loading} className="px-4 py-2 sm:px-6 sm:py-3 border-3 border-black bg-gray-300 hover:bg-gray-400 active:translate-y-1 transition-all shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] text-black font-bold text-sm sm:text-base">
              ยกเลิก
            </button>
            <button type="submit" disabled={loading || !!success} className="px-4 py-2 sm:px-6 sm:py-3 border-3 border-black bg-green-500 hover:bg-green-600 active:translate-y-1 transition-all shadow-[4px_4px_0px_0px_rgba(0,0,0,1)] text-black font-bold text-sm sm:text-base disabled:bg-gray-400 disabled:shadow-none">
              {loading ? 'กำลังบันทึก...' : 'บันทึกการแก้ไข'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default EditUserModal;
