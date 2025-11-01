import type { Metadata } from "next";
import "./globals.css";
import { Providers } from "./providers";

// ข้อมูล metadata ของแอปพลิเคชัน
export const metadata: Metadata = {
  title: "CAL-DEFICITS",
  description: "Calorie tracking application with pixel art style",
};

// Root Layout - ครอบทั้งแอปพลิเคชันด้วย Providers (Auth & User Context)
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  );
}