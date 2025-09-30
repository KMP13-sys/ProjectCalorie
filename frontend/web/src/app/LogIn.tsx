'use client'

import React, { useState } from 'react'

interface LogInProps {
  onNavigateToRegister: () => void
}

export default function LogIn({ onNavigateToRegister }: LogInProps) {
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')

  const handleLogin = (e: React.MouseEvent) => {
    e.preventDefault()

    if (!username || !password) {
      alert('กรุณากรอก Username และ Password')
      return
    }

    console.log('Login:', { username, password })
    alert('เข้าสู่ระบบสำเร็จ!')
  }

  const handleForgotPassword = () => {
    alert('กรุณาติดต่อผู้ดูแลระบบเพื่อรีเซ็ตรหัสผ่าน')
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-400 via-emerald-500 to-teal-600 p-4">
      <div className="w-full max-w-md bg-white rounded-3xl shadow-2xl p-8">
        <div className="flex justify-center mb-6">
          <div className="w-24 h-24 bg-gradient-to-br from-green-400 to-emerald-500 rounded-full flex items-center justify-center shadow-lg">
            <span className="text-5xl">🥗</span>
          </div>
        </div>

        <h1 className="text-3xl font-bold text-center text-gray-800 mb-2 tracking-wider">
          CAL-DEFICITS
        </h1>
        <p className="text-center text-gray-500 mb-8">
          ติดตามแคลอรี่ เพื่อสุขภาพที่ดี
        </p>

        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Username
            </label>
            <input
              type="text"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition"
              placeholder="กรอก Username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Password
            </label>
            <input
              type="password"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition"
              placeholder="กรอก Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>

          <button
            onClick={handleLogin}
            className="w-full bg-gradient-to-r from-green-500 to-emerald-600 text-white font-bold py-3 rounded-lg hover:from-green-600 hover:to-emerald-700 transform hover:scale-105 transition-all duration-200 shadow-lg"
          >
            เข้าสู่ระบบ
          </button>
        </div>

        <div className="mt-6 space-y-2 text-center">
          <button
            className="block w-full text-emerald-600 hover:text-emerald-700 font-medium text-sm hover:underline"
            onClick={handleForgotPassword}
          >
            ลืมรหัสผ่าน?
          </button>
          <button
            className="block w-full text-gray-600 hover:text-gray-700 font-medium text-sm hover:underline"
            onClick={onNavigateToRegister}
          >
            ยังไม่มีบัญชี? สมัครสมาชิก
          </button>
        </div>
      </div>
    </div>
  )
}