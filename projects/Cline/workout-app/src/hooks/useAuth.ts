"use client";

import { useState, useEffect } from 'react';
import { supabase } from '@/utils/supabase/client';
import { AuthChangeEvent, Session } from '@supabase/supabase-js';

const useAuth = () => {
  const [userId, setUserId] = useState<string | null>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUserId(user?.id || null);
    });

    supabase.auth.onAuthStateChange((event: AuthChangeEvent, session: Session | null) => {
      setUserId(session?.user?.id || null);
    });
  }, []);

  return { userId, setUserId };
};

export default useAuth;
