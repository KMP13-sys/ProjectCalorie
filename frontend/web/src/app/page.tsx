'use client'

import { useState, useEffect } from 'react'
import Open from './open/open'
import Login from './login/page'
import Register from './register/page'

export default function Home() {
  const [currentPage, setCurrentPage] = useState<'open' | 'login' | 'register'>('open')

  // ลบ useEffect ออก - ให้ Open component จัดการเอง

  // แสดงหน้า Register
  if (currentPage === 'register') {
    return <Register onNavigateToLogin={() => setCurrentPage('login')} />
  }

  // แสดงหน้า Login
  if (currentPage === 'login') {
    return <Login onNavigateToRegister={() => setCurrentPage('register')} />
  }

  // แสดงหน้า Open (Splash Screen) พร้อม callback
  return <Open onComplete={() => setCurrentPage('login')} />
}