# Authentication

## Staff Users

Admin, Director, Principal, and Teacher accounts use Supabase Auth with email and password.

Staff role and first-login state are stored in `public.staff_auth_profiles`. The client reads only the authenticated user's profile through RLS.

## Parent And Student Users

Parents and students do not use generated email identities.

Parents log in with mobile number and password. Students log in with SR number and password. These flows are handled by Supabase Edge Functions backed by `public.custom_auth_identities` and `public.custom_auth_sessions`.

Passwords are stored only as bcrypt hashes. Refresh tokens are stored only as SHA-256 hashes.

## First Login

`must_change_password` is enforced after login. The Flutter client routes the user to the change-password screen, and the backend updates the flag after password change.

## Security Boundary

Flutter is an untrusted client. It never decides permissions, never stores plain passwords, and never hashes passwords for persistence. Sensitive authentication decisions belong to Supabase Auth, PostgreSQL policies, and Edge Functions.
