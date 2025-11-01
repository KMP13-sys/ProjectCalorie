'use client'

import { useEffect, useState } from 'react'
import { authAPI, User } from '../services/auth_service'

export default function AboutUserPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const data = await authAPI.getAllUsers()
        setUsers(data)
      } catch (err: any) {
        setError(err.message || 'ไม่สามารถดึงข้อมูลผู้ใช้ได้')
      } finally {
        setLoading(false)
      }
    }

    fetchUsers()
  }, [])

  if (loading) return <p>Loading...</p>
  if (error) return <p>Error: {error}</p>

  return (
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">All Users</h1>
      <table className="border-collapse border border-black w-full">
        <thead>
          <tr>
            <th className="border border-black px-2 py-1">ID</th>
            <th className="border border-black px-2 py-1">Username</th>
            <th className="border border-black px-2 py-1">Email</th>
            <th className="border border-black px-2 py-1">Role</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.id}>
              <td className="border border-black px-2 py-1">{u.id}</td>
              <td className="border border-black px-2 py-1">{u.username}</td>
              <td className="border border-black px-2 py-1">{u.email}</td>
              <td className="border border-black px-2 py-1">{u.role}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
