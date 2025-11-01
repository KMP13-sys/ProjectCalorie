'use client'

import { useEffect, useState } from 'react'
import { authAPI, User } from '../services/auth_service'
import UserTable from '@/app/AboutUser/UserTable'

export default function AboutUserPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const data = await authAPI.getAllUsers()
        setUsers(Array.isArray(data) ? data : [])
      } catch (err: any) {
        console.error(err)
        setError(err.message || 'ไม่สามารถดึงข้อมูลผู้ใช้ได้')
      } finally {
        setLoading(false)
      }
    }

    fetchUsers()
  }, [])

  const handleUpdate = async () => {
    setLoading(true)
    try {
      const data = await authAPI.getAllUsers()
      setUsers(Array.isArray(data) ? data : [])
    } catch (err: any) {
      console.error(err)
      setError(err.message || 'ไม่สามารถดึงข้อมูลผู้ใช้ได้')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-100 to-green-200 flex items-start sm:items-center justify-center py-8 sm:py-12">
      <div className="w-full max-w-6xl px-4 sm:px-6 lg:px-8 bg-white border-4 border-green-400 rounded-2xl shadow-xl overflow-x-auto text-black">
        {error && <p className="text-red-500 mb-4 text-center sm:text-left">{error}</p>}
        <UserTable users={users} loading={loading} onUpdate={handleUpdate} />
      </div>
    </div>
  )
}
