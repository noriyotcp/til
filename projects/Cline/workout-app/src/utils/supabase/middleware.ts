import { type NextRequest, NextResponse } from 'next/server'
import { createClient } from './server'

export async function updateSession(request: NextRequest) {
  const response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })
  const supabase = createClient({ req: request, res: response })
  try {
    await supabase.auth.getSession()
  } catch (error) {
    console.error('Error refreshing session:', error)
  }
  return response
}
