import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "What If Invest Marketing Screenshots",
  description: "App Store screenshot compositions for What If Invest",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
