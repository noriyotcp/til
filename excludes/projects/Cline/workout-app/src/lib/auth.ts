import { supabase } from '@/utils/supabase/client';

export async function signUp(email: string, password: string) {
  const { data, error } = await supabase.auth.signUp({
    email: email,
    password: password,
  });

  if (error) {
    console.error('Error signing up:', error);
    return null;
  }

  return data.user;
}
