'use client'

import { useRouter } from 'next/navigation'
import Open from './open/open'

// หน้าแรกของแอป - แสดงหน้า splash screen
export default function Home() {
  const router = useRouter()

  // เมื่อ splash screen เสร็จ ไปหน้า login
  const handleSplashComplete = () => {
    router.push('/login')
  }

  return <Open onComplete={handleSplashComplete} />
}