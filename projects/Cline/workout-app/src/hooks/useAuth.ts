"use client";

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabaseClient';

const useAuth = () => {
  const [userId, setUserId] = useState<string | null>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUserId(user?.id || null);
    });

    supabase.auth.onAuthStateChange((event, session) => {
      setUserId(session?.user?.id || null);
    });
  }, []);

  return { userId };
};

export default useAuth;
