'use client'

import { useRouter } from 'next/navigation'
import Open from './open/open'

export default function Home() {
  const router = useRouter()

  // When splash screen completes, navigate to login page
  const handleSplashComplete = () => {
    router.push('/login')
  }

  return <Open onComplete={handleSplashComplete} />
}