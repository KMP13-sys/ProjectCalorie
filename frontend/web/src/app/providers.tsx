'use client';

import { AuthProvider } from './context/auth_context'; // ✅ เพิ่ม AuthProvider
import { UserProvider } from './context/user_context';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <AuthProvider>
      <UserProvider>
        {children}
      </UserProvider>
    </AuthProvider>
  );
}