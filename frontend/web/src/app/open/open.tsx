'use client'
import React, { useEffect, useState } from 'react'
import Image from 'next/image'

interface OpenProps {
  onComplete?: () => void
}

export default function Open({ onComplete }: OpenProps) {
  const [isVisible, setIsVisible] = useState(true)
  const [progress, setProgress] = useState(0)

  useEffect(() => {
    // จำลองการโหลดแบบ Flutter (มี progress bar ค่อย ๆ เพิ่ม)
    let progressValue = 0
    const interval = setInterval(() => {
      progressValue += 10
      setProgress(progressValue)
      if (progressValue >= 100) {
        clearInterval(interval)
      }
    }, 200)

    // เหมือน Future.delayed(Duration(seconds: 2))
    const timer = setTimeout(() => {
      setIsVisible(false)
      setTimeout(() => {
        if (onComplete) onComplete()
      }, 500) // เผื่อเวลา fade out
    }, 2000)

    return () => {
      clearTimeout(timer)
      clearInterval(interval)
    }
  }, [onComplete])

  const handleSkip = () => {
    setIsVisible(false)
    if (onComplete) onComplete()
  }

  return (
    <div
      className={`flex items-center justify-center min-h-screen transition-opacity duration-500 ${
        isVisible ? 'opacity-100' : 'opacity-0 pointer-events-none'
      } bg-gradient-to-br from-[#6fa85e] via-[#8bc273] to-[#a8d48f] relative overflow-hidden`}
    >
      {/* พื้นหลัง Pixel Grid */}
      <div
        className="absolute inset-0 opacity-10"
        style={{
          backgroundImage: `
            linear-gradient(0deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent),
            linear-gradient(90deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent)
          `,
          backgroundSize: '50px 50px',
        }}
      ></div>

      {/* กล่องหลัก */}
      <div className="relative z-10 text-center">
        <div
          className="bg-white border-8 border-black p-12 relative"
          style={{
            boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
            imageRendering: 'pixelated',
          }}
        >
          {/* ขอบตกแต่ง */}
          <div className="absolute top-0 left-0 w-6 h-6 bg-[#6fa85e]" />
          <div className="absolute top-0 right-0 w-6 h-6 bg-[#6fa85e]" />
          <div className="absolute bottom-0 left-0 w-6 h-6 bg-[#6fa85e]" />
          <div className="absolute bottom-0 right-0 w-6 h-6 bg-[#6fa85e]" />

          {/* โลโก้ */}
          <div className="flex flex-col items-center gap-6">
            <div className="relative">
              <div
                className="bg-gradient-to-br from-[#a8d48f] to-[#8bc273] border-6 border-black p-4"
                style={{ boxShadow: '6px 6px 0px rgba(0,0,0,0.2)' }}
              >
                <Image
                  src="/pic/logo.png"
                  alt="Cal Deficits Logo"
                  width={128}
                  height={128}
                  className="object-contain"
                  style={{ imageRendering: 'pixelated' }}
                  priority
                />
              </div>
            </div>

            {/* ชื่อแอป */}
            <h1
              className="text-5xl md:text-6xl font-bold text-gray-800 tracking-wider mb-2"
              style={{
                fontFamily: 'monospace',
                textShadow: '4px 4px 0px rgba(111,168,94,0.5)',
              }}
            >
              CAL-DEFICITS
            </h1>

            {/* แถบโหลด */}
            <div className="w-64">
              <div className="bg-black border-4 border-gray-800 p-2">
                <div className="bg-gray-900 h-8 relative overflow-hidden">
                  <div
                    className="absolute top-0 left-0 h-full bg-gradient-to-r from-[#6fa85e] to-[#a8d48f] transition-all duration-200"
                    style={{ width: `${progress}%` }}
                  ></div>
                </div>
              </div>
            </div>

            <p
              className="text-white bg-black border-4 border-[#6fa85e] px-6 py-2 mt-4 font-bold"
              style={{ fontFamily: 'monospace' }}
            >
              &gt; LOADING... {progress}%
            </p>

            {/* ปุ่มข้าม */}
            <button
              onClick={handleSkip}
              className="mt-6 text-black font-mono font-bold hover:underline"
            >
              SKIP ▶
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
