'use client'

import React, { useEffect } from 'react'
import { useRouter } from 'next/navigation'

export default function Open() {
  const router = useRouter()

  useEffect(() => {
    // Auto-navigate to login after 3 seconds
    const timer = setTimeout(() => {
      router.push('/login')
    }, 2000)

    return () => clearTimeout(timer)
  }, [router])

  const handleSkip = () => {
    router.push('/login')
  }

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-green-400 via-emerald-500 to-teal-600">
      <div className="flex flex-col items-center justify-center gap-8 p-8 text-center">
        {/* Salad Bowl Image */}
        <div className="relative w-48 h-48 animate-bounce-slow">
          <div className="absolute inset-0 bg-white rounded-full opacity-20 blur-2xl"></div>
          <div className="relative w-full h-full bg-white rounded-full flex items-center justify-center shadow-2xl">
            <div className="text-8xl">🥗</div>
          </div>
        </div>

        {/* Title */}
        <h1 className="text-5xl md:text-6xl font-bold text-white drop-shadow-lg tracking-wider">
          CAL-DEFICITS
        </h1>
        <p className="text-white/80 text-lg animate-pulse">
          กำลังโหลด...
        </p>

        {/* Loading Spinner */}
        <div className="w-16 h-16 border-4 border-white/30 border-t-white rounded-full animate-spin">
        </div>
      </div>

      <style jsx>{`
        @keyframes bounce-slow {
          0%, 100% {
            transform: translateY(0);
          }
          50% {
            transform: translateY(-20px);
          }
        }
        .animate-bounce-slow {
          animation: bounce-slow 2s ease-in-out infinite;
        }
      `}</style>
    </div>
  )
}