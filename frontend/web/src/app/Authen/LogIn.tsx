'use client'

import React, { useState } from 'react'
import Image from 'next/image'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { authAPI } from '@/api'

type LogInProps = {
  onNavigateToRegister: () => void
}

export default function LoginPage({ onNavigateToRegister }: LogInProps) {
  const router = useRouter()
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState('')

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

    // Validation
    if (!username || !password) {
      setError('กรุณากรอก Username และ Password')
      return
    }

    setIsLoading(true)

    try {
      // เรียก API Login
      const data = await authAPI.login(username, password)

      console.log('Login successful:', data)
      
      // แสดงข้อความสำเร็จ
      alert(`ยินดีต้อนรับ ${data.user.username}!`)
      
      // Redirect ไปหน้า dashboard
      router.push('/dashboard')

    } catch (err: any) {
      console.error('Login error:', err)
      setError(err.message || 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#c8f4c8] p-4">
      <div className="w-full max-w-md bg-white p-8 pixel-border">
        {/* Logo */}
        <div className="flex justify-center mb-6">
          <div className="w-32 h-32 flex items-center justify-center">
            <Image 
              src="/pic/logo.png" 
              alt="Salad Bowl"
              width={128}
              height={128}
              className="object-contain pixel-art"
              priority
            />
          </div>
        </div>

        {/* Title */}
        <h1 
          className="text-2xl md:text-3xl font-bold text-center text-[#2d5016] mb-8 tracking-[0.2em]"
          style={{
            fontFamily: 'Pixel, sans-serif',
            textShadow: '3px 3px 0px rgba(45, 80, 22, 0.2)'
          }}
        >
          CAL-DEFICITS
        </h1>

        {/* Error Message */}
        {error && (
          <div className="mb-4 p-3 bg-red-100 border-4 border-red-500 text-red-700 text-sm">
            {error}
          </div>
        )}

        {/* Login Form */}
        <form onSubmit={handleLogin} className="space-y-6">
          {/* Username Field */}
          <div>
            <label 
              className="block text-sm font-bold text-[#2d5016] mb-2 tracking-wider"
              style={{ fontFamily: 'Pixel, sans-serif' }}
            >
              USERNAME
            </label>
            <input
              type="text"
              className="w-full px-4 py-3 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
              placeholder="Enter username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              disabled={isLoading}
              style={{ fontFamily: 'monospace' }}
            />
          </div>

          {/* Password Field */}
          <div>
            <label 
              className="block text-sm font-bold text-[#2d5016] mb-2 tracking-wider"
              style={{ fontFamily: 'Pixel, sans-serif' }}
            >
              PASSWORD
            </label>
            <input
              type="password"
              className="w-full px-4 py-3 border-4 border-[#2d5016] focus:outline-none focus:border-[#f56e6e] transition-colors bg-white disabled:opacity-50"
              placeholder="Enter password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={isLoading}
              style={{ fontFamily: 'monospace' }}
            />
          </div>

          {/* Login Button */}
          <button
            type="submit"
            disabled={isLoading}
            className="w-full bg-[#f56e6e] text-white font-bold py-4 border-4 border-[#2d5016] hover-pixel transition-all tracking-wider disabled:opacity-50 disabled:cursor-not-allowed"
            style={{ fontFamily: 'Pixel, sans-serif' }}
          >
            {isLoading ? 'LOADING...' : 'LOGIN'}
          </button>
        </form>

        {/* Links */}
        <div className="mt-6 space-y-3 text-center">
          <Link 
            href="/register"
            className="block w-full text-[#2d5016] hover:text-[#f56e6e] font-bold text-sm tracking-wider transition-colors"
            style={{ fontFamily: 'Pixel, sans-serif' }}
          >
            CREATE ACCOUNT
          </Link>
        </div>
      </div>
    </div>
  )
}