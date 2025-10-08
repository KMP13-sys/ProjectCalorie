'use client'

import React, { useState } from 'react'
import Image from 'next/image'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { authAPI } from '@/api'

export default function RegisterPage() {
  const router = useRouter()
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    phone_number: '',
    password: '',
    confirmPassword: '',
    age: '',
    gender: '',
    height: '',
    weight: '',
    goal: ''
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    // Validation
    if (!formData.username || !formData.email || !formData.password) {
      setError('กรุณากรอกข้อมูลให้ครบถ้วน')
      return
    }

    if (formData.password !== formData.confirmPassword) {
      setError('รหัสผ่านไม่ตรงกัน')
      return
    }

    if (formData.password.length < 6) {
      setError('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร')
      return
    }

    setIsLoading(true)

    try {
      // เรียก API Register
      const data = await authAPI.register({
        username: formData.username,
        email: formData.email,
        phone_number: formData.phone_number,
        password: formData.password,
        age: parseInt(formData.age) || 0,
        gender: formData.gender,
        height: parseFloat(formData.height) || 0,
        weight: parseFloat(formData.weight) || 0,
        goal: formData.goal
      })

      console.log('Register successful:', data)
      
      // แสดงข้อความสำเร็จ
      alert('สมัครสมาชิกสำเร็จ!')
      
      // Redirect ไปหน้า login
      router.push('/login')

    } catch (err: any) {
      console.error('Register error:', err)
      setError(err.message || 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#c8f4c8] p-4">
      <div className="w-full max-w-2xl bg-white p-8 pixel-border my-8">
        {/* Logo */}
        <div className="flex justify-center mb-4">
          <div className="w-24 h-24 flex items-center justify-center">
            <Image 
              src="/pic/logo.png" 
              alt="Salad Bowl"
              width={96}
              height={96}
              className="object-contain pixel-art"
              priority
            />
          </div>
        </div>

        {/* Title */}
        <h1 
          className="text-xl md:text-2xl font-bold text-center text-[#2d5016] mb-6 tracking-[0.2em]"
          style={{
            fontFamily: 'Pixel, sans-serif',
            textShadow: '3px 3px 0px rgba(45, 80, 22, 0.2)'
          }}
        >
          CREATE ACCOUNT
        </h1>

        {/* Error Message */}
        {error && (
          <div className="mb-4 p-3 bg-red-100 border-4 border-red-500 text-red-700 text-sm">
            {error}
          </div>
        )}

        {/* Register Form */}
        <form onSubmit={handleRegister} className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Username */}
            <div>
              <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
                USERNAME *
              </label>
              <input
                type="text"
                name="username"
                className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
                value={formData.username}
                onChange={handleChange}
                disabled={isLoading}
                required
                style={{ fontFamily: 'monospace' }}
              />
            </div>

            {/* Email */}
            <div>
              <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
                EMAIL *
              </label>
              <input
                type="email"
                name="email"
                className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
                value={formData.email}
                onChange={handleChange}
                disabled={isLoading}
                required
                style={{ fontFamily: 'monospace' }}
              />
            </div>

            {/* Phone Number */}
            <div>
              <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
                PHONE
              </label>
              <input
                type="tel"
                name="phone_number"
                className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
                value={formData.phone_number}
                onChange={handleChange}
                disabled={isLoading}
                style={{ fontFamily: 'monospace' }}
              />
            </div>

            {/* Age */}
            <div>
              <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
                AGE
              </label>
              <input
                type="number"
                name="age"
                className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
                value={formData.age}
                onChange={handleChange}
                disabled={isLoading}
                style={{ fontFamily: 'monospace' }}
              />
            </div>

            {/* Gender */}
            <div>
              <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
                GENDER
              </label>
              <select
                name="gender"
                className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
                value={formData.gender}
                onChange={handleChange}
                disabled={isLoading}
                style={{ fontFamily: 'monospace' }}
              >
                <option value="">Select</option>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
              </select>
            </div>

            {/* Height */}
            <div>
              <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
                HEIGHT (cm)
              </label>
              <input
                type="number"
                name="height"
                className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
                value={formData.height}
                onChange={handleChange}
                disabled={isLoading}
                style={{ fontFamily: 'monospace' }}
              />
            </div>

            {/* Weight */}
            <div>
              <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
                WEIGHT (kg)
              </label>
              <input
                type="number"
                name="weight"
                className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
                value={formData.weight}
                onChange={handleChange}
                disabled={isLoading}
                style={{ fontFamily: 'monospace' }}
              />
            </div>

            {/* Goal */}
            <div>
              <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
                GOAL
              </label>
              <select
                name="goal"
                className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
                value={formData.goal}
                onChange={handleChange}
                disabled={isLoading}
                style={{ fontFamily: 'monospace' }}
              >
                <option value="">Select</option>
                <option value="lose_weight">Lose Weight</option>
                <option value="maintain">Maintain</option>
                <option value="gain_weight">Gain Weight</option>
              </select>
            </div>
          </div>

          {/* Password */}
          <div>
            <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
              PASSWORD *
            </label>
            <input
              type="password"
              name="password"
              className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
              value={formData.password}
              onChange={handleChange}
              disabled={isLoading}
              required
              style={{ fontFamily: 'monospace' }}
            />
          </div>

          {/* Confirm Password */}
          <div>
            <label className="block text-xs font-bold text-[#2d5016] mb-1" style={{ fontFamily: 'Pixel, sans-serif' }}>
              CONFIRM PASSWORD *
            </label>
            <input
              type="password"
              name="confirmPassword"
              className="w-full px-3 py-2 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
              value={formData.confirmPassword}
              onChange={handleChange}
              disabled={isLoading}
              required
              style={{ fontFamily: 'monospace' }}
            />
          </div>

          {/* Register Button */}
          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-[#f56e6e] text-white font-bold py-3 border-4 border-[#2d5016] hover-pixel transition-all tracking-wider disabled:opacity-50 disabled:cursor-not-allowed mt-6"
            style={{ fontFamily: 'Pixel, sans-serif' }}
          >
            {isLoading ? 'LOADING...' : 'REGISTER'}
          </button>
        </form>

        {/* Link to Login */}
        <div className="mt-4 text-center">
          <Link 
            href="/login"
            className="text-[#2d5016] hover:text-[#f56e6e] font-bold text-sm tracking-wider transition-colors"
            style={{ fontFamily: 'Pixel, sans-serif' }}
          >
            ALREADY HAVE ACCOUNT? LOGIN
          </Link>
        </div>
      </div>
    </div>
  )
}