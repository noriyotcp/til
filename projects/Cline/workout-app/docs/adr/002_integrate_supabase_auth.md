# 002: Integrate Supabase Auth

## Status

Proposed

## Context

We need to implement authentication in our Next.js application.

## Decision

We will use Supabase Auth for server-side authentication.

## Consequences

*   We will need to install the `@supabase/supabase-js` and `@supabase/ssr` packages.
*   We will need to set up environment variables for the Supabase URL and anon key.
*   We will need to create server-side and client-side Supabase clients.
*   We will need to integrate middleware to refresh expired Auth tokens.
*   We will need to create a login page with signup and login functionality.
*   We will need to create an email confirmation route to handle user verification.
*   We will need to create a private page to demonstrate accessing user information.
