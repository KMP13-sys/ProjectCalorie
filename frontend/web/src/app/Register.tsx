'use client'

import React, { useState } from 'react'

interface FormData {
  username: string
  email: string
  phone: string
  password: string
  confirmPassword: string
  acceptTerms: boolean
}

interface RegisterProps {
  onBackToLogin?: () => void
}

export default function Register({ onBackToLogin }: RegisterProps) {
  const [formData, setFormData] = useState<FormData>({
    username: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    acceptTerms: false,
  })

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }))
  }

  const validateEmail = (email: string): boolean => {
    return /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/.test(email)
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.username) {
      alert('กรุณากรอก Username')
      return
    }

    if (!formData.email) {
      alert('กรุณากรอก Email')
      return
    }

    if (!validateEmail(formData.email)) {
      alert('รูปแบบ Email ไม่ถูกต้อง')
      return
    }

    if (!formData.phone) {
      alert('กรุณากรอกหมายเลขโทรศัพท์')
      return
    }

    if (!formData.password) {
      alert('กรุณากรอก Password')
      return
    }

    if (formData.password.length < 6) {
      alert('Password ต้องมีอย่างน้อย 6 ตัวอักษร')
      return
    }

    if (formData.password !== formData.confirmPassword) {
      alert('Password ไม่ตรงกัน')
      return
    }

    if (!formData.acceptTerms) {
      alert('กรุณายอมรับเงื่อนไขและความเป็นส่วนตัว')
      return
    }

    alert('สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ')
    if (onBackToLogin) {
      onBackToLogin()
    }
  }

  const showPrivacyPolicy = () => {
    alert('นโยบายความเป็นส่วนตัว\n\n1. การเก็บรวบรวมข้อมูล\n2. การใช้ข้อมูล\n3. การปกป้องข้อมูล\n4. การแบ่งปันข้อมูล\n5. สิทธิของผู้ใช้\n6. การติดต่อ')
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-green-400 via-emerald-500 to-teal-600 p-4">
      <div className="w-full max-w-md bg-white rounded-3xl shadow-2xl p-8 my-8">
        <div className="flex justify-center mb-4">
          <div className="w-20 h-20 bg-gradient-to-br from-green-400 to-emerald-500 rounded-full flex items-center justify-center shadow-lg">
            <span className="text-4xl">🥗</span>
          </div>
        </div>

        <h1 className="text-3xl font-bold text-center text-gray-800 mb-2 tracking-wider">
          CAL-DEFICITS
        </h1>
        <p className="text-center text-gray-500 mb-6 text-sm">
          สมัครสมาชิกเพื่อเริ่มต้นใช้งาน
        </p>

        <div className="space-y-3">
          <div>
            <input
              type="text"
              name="username"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition text-sm"
              placeholder="Username"
              value={formData.username}
              onChange={handleInputChange}
            />
          </div>

          <div>
            <input
              type="email"
              name="email"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition text-sm"
              placeholder="Email"
              value={formData.email}
              onChange={handleInputChange}
            />
          </div>

          <div>
            <input
              type="tel"
              name="phone"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition text-sm"
              placeholder="Phone No *"
              value={formData.phone}
              onChange={handleInputChange}
            />
          </div>

          <div>
            <input
              type="password"
              name="password"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition text-sm"
              placeholder="Password"
              value={formData.password}
              onChange={handleInputChange}
            />
          </div>

          <div>
            <input
              type="password"
              name="confirmPassword"
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-emerald-500 focus:border-transparent outline-none transition text-sm"
              placeholder="Confirm password"
              value={formData.confirmPassword}
              onChange={handleInputChange}
            />
          </div>

          <div className="flex items-start gap-2 pt-2">
            <input
              type="checkbox"
              name="acceptTerms"
              checked={formData.acceptTerms}
              onChange={handleInputChange}
              className="mt-1 w-4 h-4 text-emerald-600 border-gray-300 rounded focus:ring-emerald-500"
            />
            <span className="text-xs text-gray-600">
              I accept term and condition and{' '}
              <button
                type="button"
                className="text-emerald-600 hover:text-emerald-700 underline"
                onClick={showPrivacyPolicy}
              >
                privacy policy
              </button>
            </span>
          </div>

          <button
            onClick={handleSubmit}
            className="w-full bg-gradient-to-r from-green-500 to-emerald-600 text-white font-bold py-3 rounded-lg hover:from-green-600 hover:to-emerald-700 transform hover:scale-105 transition-all duration-200 shadow-lg"
          >
            สมัครสมาชิก
          </button>
        </div>

        <div className="mt-6 text-center">
          <button
            className="text-gray-600 hover:text-gray-700 font-medium text-sm hover:underline"
            onClick={onBackToLogin}
          >
            มีบัญชีอยู่แล้ว? เข้าสู่ระบบ
          </button>
        </div>
      </div>
    </div>
  )
}