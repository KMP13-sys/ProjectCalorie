'use client';

import Link from 'next/link';
import { useState } from 'react';

export default function RegisterPage() {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    agreedToTerms: false
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleRegister = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Validation
    if (formData.password !== formData.confirmPassword) {
      alert('Password ไม่ตรงกัน!');
      return;
    }
    
    if (!formData.agreedToTerms) {
      alert('กรุณายอมรับข้อกำหนดและเงื่อนไข');
      return;
    }

    // เพิ่มฟังก์ชัน register ตรงนี้
    console.log('Register:', formData);
  };

  return (
    <div className="min-h-screen bg-[#DBFFC8] flex items-center justify-center p-4">
      <div className="bg-white border-3 border-black p-12 w-full max-w-md">
        {/* Logo */}
        <div className="flex flex-col items-center mb-8">
          <img 
            src="/pic/logoja.png" 
            className="w-48 h-48 object-contain mb-4"
          />
          <h1 className="text-2xl font-bold text-gray-800 tracking-wider">
            CAL-DEFICITS
          </h1>
        </div>

        {/* Register Form */}
        <form onSubmit={handleRegister} className="space-y-4">
          <input
            type="text"
            name="username"
            placeholder="Username"
            value={formData.username}
            onChange={handleChange}
            required
            className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
          />
          
          <input
            type="email"
            name="email"
            placeholder="Email"
            value={formData.email}
            onChange={handleChange}
            required
            className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
          />

          <input
            type="tel"
            name="phone"
            placeholder="Phone No *"
            value={formData.phone}
            onChange={handleChange}
            required
            className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
          />
          
          <input
            type="password"
            name="password"
            placeholder="Password"
            value={formData.password}
            onChange={handleChange}
            required
            className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
          />

          <input
            type="password"
            name="confirmPassword"
            placeholder="Confirm password"
            value={formData.confirmPassword}
            onChange={handleChange}
            required
            className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
          />

          {/* Terms and Conditions */}
          <div className="flex items-start gap-2 mt-4">
            <input
              type="checkbox"
              name="agreedToTerms"
              id="terms"
              checked={formData.agreedToTerms}
              onChange={handleChange}
              required
              className="mt-1 w-4 h-4"
            />
            <label htmlFor="terms" className="text-sm text-gray-600">
              I accept term and condition and{' '}
              <Link href="/privacy-policy" className="text-blue-600 underline">
                privacy policy
              </Link>
            </label>
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-[#8b9d6f] text-white font-semibold hover:bg-[#7a8c5e] transition-colors border-2 border-black mt-6"
          >
            REGISTER
          </button>
        </form>
      </div>
    </div>
  );
}