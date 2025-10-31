'use client';

import { useState, useEffect } from 'react';
import { authAPI } from '@/app/services/auth_service';
import UserTable from '@/app/AboutUser/UserTable'; // import UserTable ให้ถูก path

export default function AboutUserPage() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchUser() {
      try {
        const currentUser = await authAPI.fetchCurrentUser();
        setUser(currentUser);
      } catch (error) {
        console.error('Failed to fetch user:', error);
      } finally {
        setLoading(false);
      }
    }
    fetchUser();
  }, []);

  const handleUpdate = () => {
    // สมมติว่าเราอัปเดต user ใหม่
    setLoading(true);
    authAPI.fetchCurrentUser().then((updatedUser) => {
      setUser(updatedUser);
      setLoading(false);
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-100 to-green-200 flex items-center justify-center">
      <div className="container mx-auto p-6 bg-white border-4 border-green-400 rounded-2xl shadow-xl">
        <UserTable 
          users={user ? [user] : []} 
          loading={loading} 
          onUpdate={handleUpdate} 
        />
      </div>
    </div>
  );
}
