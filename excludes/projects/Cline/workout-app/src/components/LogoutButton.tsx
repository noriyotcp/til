"use client";

import { useRouter } from 'next/navigation';
import { useAuth } from '@/context/AuthContext';
import { logout } from '@/app/actions';

const LogoutButton = () => {
  const router = useRouter();
  const { setUserId } = useAuth();

  async function handleLogout() {
    await logout();
    setUserId(null);
    router.refresh();
  }

  return (
    <button onClick={handleLogout}>Logout</button>
  );
}

export default LogoutButton;
