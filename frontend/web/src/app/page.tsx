'use client'

import { useState, useEffect } from 'react'
import LogIn from './LogIn'
import Register from './Register'
import Image from 'next/image'


export default function Home() {
  const [currentPage, setCurrentPage] = useState<'open' | 'login' | 'register'>('open')

  useEffect(() => {
    // แสดงหน้า Open 2 วินาที แล้วเปลี่ยนเป็นหน้า Login
    const timer = setTimeout(() => {
      setCurrentPage('login')
    }, 2000)

    return () => clearTimeout(timer)
  }, [])

// แสดงหน้า Register
if (currentPage === 'register') {
  return <Register />
}

  // แสดงหน้า Login
  if (currentPage === 'login') {
    return <LogIn onNavigateToRegister={() => setCurrentPage('register')} />
  }

  // แสดงหน้า Open (Splash Screen)
  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-green-400 via-emerald-500 to-teal-600">
      <div className="flex flex-col items-center justify-center gap-8 p-8 text-center">
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

        <h1 className="text-5xl md:text-6xl font-bold text-white drop-shadow-lg tracking-wider">
          CAL-DEFICITS
        </h1>

        <p className="text-white/80 text-lg animate-pulse">
          กำลังโหลด...
        </p>

        <div className="w-16 h-16 border-4 border-white/30 border-t-white rounded-full animate-spin"></div>

      </div>
    </div>
  )
}