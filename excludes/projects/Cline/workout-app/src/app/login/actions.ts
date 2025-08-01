'use server'

import { createClient } from '@/utils/supabase/server'
import { redirect } from 'next/navigation'


export async function login(formData: FormData) {
  const email = String(formData.get('email'))
  const password = String(formData.get('password'))

  const supabase = await createClient()

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  console.log('Email:', email);
  console.log('Password (first 5 chars):', password.substring(0, 5));

  if (error) {
    console.error('Login error:', error);
    return redirect('/login?message=Invalid credentials')
  }

  return redirect('/')
}

export async function logout() {
  const supabase = await createClient()

  await supabase.auth.signOut()

  return redirect('/login')
}
