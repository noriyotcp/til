'use server'

import { createClient } from '@/utils/supabase/server'
import { redirect } from 'next/navigation'

export async function signup(formData: FormData) {
  const email = String(formData.get('email'))
  const password = String(formData.get('password'))
  const firstName = String(formData.get('firstName'))
  const lastName = String(formData.get('lastName'))

  const supabase = await createClient()

  const { error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        first_name: firstName,
        last_name: lastName,
      },
      emailRedirectTo: `${process.env.NEXT_PUBLIC_SITE_URL}/auth/confirm`,
    },
  })

  if (error) {
    return redirect('/error')
  }

  return redirect('/login?message=Check email to continue sign in process')
}
