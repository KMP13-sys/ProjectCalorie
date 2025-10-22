'use client';

import { UserProvider } from './context/user_context';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <UserProvider>
      {children}
    </UserProvider>
  );
}