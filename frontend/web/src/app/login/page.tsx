'use client';

import Link from 'next/link';
import { useState } from 'react';

export default function LoginPage() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    // เพิ่มฟังก์ชัน login ตรงนี้
    console.log('Login:', { username, password });
  };

  return (
    <div className="min-h-screen bg-[#d4f4c4] flex items-center justify-center p-4">
      <div className="bg-white border-3 border-black p-12 w-full max-w-md">
        {/* Logo */}
        <div className="flex flex-col items-center mb-8">
          <img 
            src="/pic/logoja.png" 
            className="w-48 h-48 object-contain mb-4"
          />
          <p className="text-[24px] font-bold text-gray-800 tracking-wider">
            CAL-DEFICITS
          </p>
        </div>

        {/* Login Form */}
        <form onSubmit={handleLogin} className="space-y-4">
          <input
            type="text"
            placeholder="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
          />
          
          <input
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
          />

          <button
            type="submit"
            className="w-full py-3 bg-[#8b9d6f] text-white font-semibold hover:bg-[#7a8c5e] transition-colors border-2 border-black"
          >
            Log in
          </button>
        </form>

        {/* Links */}
        <div className="mt-6 flex justify-between text-sm text-gray-600">
          <Link href="/forgot-password" className="hover:underline">
            Forgot Password ?
          </Link>
          <Link href="/register" className="hover:underline">
            I Don't have account
          </Link>
        </div>
      </div>
    </div>
  );
}