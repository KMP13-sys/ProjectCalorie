'use client'

import React, { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import Image from 'next/image'

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
    </div>
  )
}