'use client';

import { AuthProvider } from '../context/auth_context';
import { UserProvider } from '../context/user_context';

// ครอบทั้งแอปด้วย Context Providers เพื่อให้ทุกหน้าเข้าถึง Auth และ User data ได้
export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <AuthProvider>
      <UserProvider>
        {children}
      </UserProvider>
    </AuthProvider>
  );
}