"use client";

import { redirect } from 'next/navigation'
import { logout } from '@/app/login/actions'
import useAuth from '@/hooks/useAuth'

export default function PrivatePage() {
  const { userId } = useAuth();

  if (!userId) {
    redirect('/login');
  }

  return (
    <div>
      <p>Hello {userId}</p>
      <form action={logout}>
        <button type="submit">Logout</button>
      </form>
    </div>
  )
}
