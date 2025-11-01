'use client'

import { useEffect, useState } from 'react'
import { adminService, User } from '../services/adminService'

export default function AboutUserPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        const data = await adminService.getAllUsers()
        setUsers(data)
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
    <div className="p-4">
      <h1 className="text-2xl font-bold mb-4">All Users</h1>
      <table className="border-collapse border border-black w-full">
        <thead>
          <tr>
            <th className="border border-black px-2 py-1">ID</th>
            <th className="border border-black px-2 py-1">Username</th>
            <th className="border border-black px-2 py-1">Email</th>
            <th className="border border-black px-2 py-1">Phone</th>
            <th className="border border-black px-2 py-1">Age</th>
            <th className="border border-black px-2 py-1">Gender</th>
            <th className="border border-black px-2 py-1">Goal</th>
          </tr>
        </thead>
        <tbody>
          {users.map((u) => (
            <tr key={u.user_id}>
              <td className="border border-black px-2 py-1">{u.user_id}</td>
              <td className="border border-black px-2 py-1">{u.username}</td>
              <td className="border border-black px-2 py-1">{u.email}</td>
              <td className="border border-black px-2 py-1">{u.phone_number}</td>
              <td className="border border-black px-2 py-1">{u.age}</td>
              <td className="border border-black px-2 py-1">{u.gender}</td>
              <td className="border border-black px-2 py-1">{u.goal}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
