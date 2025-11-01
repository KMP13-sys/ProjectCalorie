'use client'
import React, { useEffect } from 'react'
import Image from 'next/image'

interface OpenProps {
  onComplete?: () => void
}

export default function Open({ onComplete }: OpenProps) {
  // เปลี่ยนหน้าอัตโนมัติหลังจาก 2 วินาที
  useEffect(() => {
    const timer = setTimeout(() => {
      if (onComplete) {
        onComplete()
      }
    }, 2000)

    return () => clearTimeout(timer)
  }, [onComplete])

  const handleSkip = () => {
    if (onComplete) {
      onComplete()
    }
  }

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-[#6fa85e] via-[#8bc273] to-[#a8d48f] relative overflow-hidden">
      {/* พื้นหลังลาย Pixel Grid */}
      <div
        className="absolute inset-0 opacity-10"
        style={{
          backgroundImage: `
            linear-gradient(0deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent),
            linear-gradient(90deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent)
          `,
          backgroundSize: '50px 50px'
        }}
      ></div>

      {/* เมฆลอยแบบ Pixel Art */}
      <div className="absolute top-10 left-10 w-24 h-16 opacity-20">
        <div className="grid grid-cols-6 gap-1">
          {[...Array(24)].map((_, i) => (
            <div 
              key={i} 
              className={`w-3 h-3 ${[0, 1, 5, 6, 7, 11, 12, 13, 14, 15, 16, 17].includes(i) ? 'bg-white' : 'bg-transparent'}`}
              style={{ imageRendering: 'pixelated' }}
            ></div>
          ))}
        </div>
      </div>

      <div className="absolute top-32 right-20 w-24 h-16 opacity-20">
        <div className="grid grid-cols-6 gap-1">
          {[...Array(24)].map((_, i) => (
            <div 
              key={i} 
              className={`w-3 h-3 ${[0, 1, 5, 6, 7, 11, 12, 13, 14, 15, 16, 17].includes(i) ? 'bg-white' : 'bg-transparent'}`}
              style={{ imageRendering: 'pixelated' }}
            ></div>
          ))}
        </div>
      </div>

      {/* กล่องเนื้อหาหลัก */}
      <div className="relative z-10">
        <div
          className="bg-white border-8 border-black p-12 relative"
          style={{
            boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
            imageRendering: 'pixelated'
          }}
        >
          {/* Pixel มุมกล่องตกแต่ง */}
          <div className="absolute top-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
          <div className="absolute top-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>
          <div className="absolute bottom-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
          <div className="absolute bottom-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>

          <div className="flex flex-col items-center justify-center gap-6 text-center">
            {/* โลโก้พร้อมกรอบ Pixel */}
            <div className="relative">
              <div 
                className="bg-gradient-to-br from-[#a8d48f] to-[#8bc273] border-6 border-black p-4"
                style={{ boxShadow: '6px 6px 0px rgba(0,0,0,0.2)' }}
              >
                <Image 
                  src="/pic/logo.png" 
                  alt="Salad Bowl"
                  width={128}
                  height={128}
                  className="object-contain"
                  style={{ imageRendering: 'pixelated' }}
                  priority
                />
              </div>
              {/* ประกายดาว Pixel */}
              <div className="absolute -top-2 -right-2 w-4 h-4 bg-yellow-300 animate-ping"></div>
              <div className="absolute -bottom-2 -left-2 w-4 h-4 bg-yellow-300 animate-ping" style={{ animationDelay: '0.5s' }}></div>
            </div>

            {/* ชื่อแอป */}
            <div className="relative">
              <h1 
                className="text-5xl md:text-6xl font-bold text-gray-800 tracking-wider mb-2"
                style={{ 
                  fontFamily: 'TA8bit',
                  textShadow: '4px 4px 0px rgba(111, 168, 94, 0.5)'
                }}
              >
                CAL-DEFICITS
              </h1>
              <div className="flex justify-center gap-1">
                <div className="w-2 h-2 bg-[#6fa85e]"></div>
                <div className="w-2 h-2 bg-[#8bc273]"></div>
                <div className="w-2 h-2 bg-[#a8d48f]"></div>
                <div className="w-2 h-2 bg-[#8bc273]"></div>
                <div className="w-2 h-2 bg-[#6fa85e]"></div>
              </div>
            </div>

            {/* ข้อความโหลด */}
            <div className="bg-black border-4 border-[#6fa85e] px-6 py-2">
              <p
                className="text-white text-lg font-bold animate-pulse"
                style={{ fontFamily: 'TA8bit' }}
              >
                &gt; LOADING...
              </p>
            </div>

            {/* แถบแสดงความคืบหน้า */}
            <div className="w-64">
              <div className="bg-black border-4 border-gray-800 p-2">
                <div className="bg-gray-900 h-8 relative overflow-hidden">
                  <div
                    className="absolute top-0 left-0 h-full bg-gradient-to-r from-[#6fa85e] to-[#a8d48f]"
                    style={{
                      animation: 'pixelLoading 2s ease-in-out',
                      width: '100%'
                    }}
                  >
                    <div className="absolute top-0 left-0 w-full h-2 bg-white opacity-40"></div>
                    <div className="absolute bottom-0 left-0 w-full h-2 bg-black opacity-20"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* ดาวลอย Pixel */}
        <div className="absolute -top-8 left-1/4 w-4 h-4 bg-yellow-300 animate-bounce"></div>
        <div className="absolute -bottom-8 right-1/4 w-4 h-4 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.3s' }}></div>
      </div>

      <style jsx>{`
        @keyframes pixelLoading {
          0% { 
            width: 0%; 
          }
          100% { 
            width: 100%; 
          }
        }
      `}</style>
    </div>
  )
}