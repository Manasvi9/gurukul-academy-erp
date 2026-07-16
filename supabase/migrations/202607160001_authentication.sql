create extension if not exists pgcrypto;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type public.app_role as enum (
      'system_admin',
      'director',
      'principal',
      'teacher',
      'parent',
      'student'
    );
  end if;
end $$;

create table if not exists public.staff_auth_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.app_role not null check (
    role in ('system_admin', 'director', 'principal', 'teacher')
  ),
  display_name text not null check (length(trim(display_name)) > 0),
  must_change_password boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.custom_auth_identities (
  id uuid primary key default gen_random_uuid(),
  role public.app_role not null check (role in ('parent', 'student')),
  identifier text not null,
  password_hash text not null,
  display_name text not null check (length(trim(display_name)) > 0),
  must_change_password boolean not null default true,
  is_active boolean not null default true,
  failed_attempts integer not null default 0,
  locked_until timestamptz,
  last_login_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint custom_auth_identifier_unique unique (role, identifier)
);

create table if not exists public.custom_auth_sessions (
  id uuid primary key default gen_random_uuid(),
  custom_auth_identity_id uuid not null references public.custom_auth_identities(id) on delete cascade,
  refresh_token_hash text not null unique,
  expires_at timestamptz not null,
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists staff_auth_profiles_updated_at on public.staff_auth_profiles;
create trigger staff_auth_profiles_updated_at
before update on public.staff_auth_profiles
for each row execute function public.set_updated_at();

drop trigger if exists custom_auth_identities_updated_at on public.custom_auth_identities;
create trigger custom_auth_identities_updated_at
before update on public.custom_auth_identities
for each row execute function public.set_updated_at();

alter table public.staff_auth_profiles enable row level security;
alter table public.custom_auth_identities enable row level security;
alter table public.custom_auth_sessions enable row level security;

drop policy if exists "staff can read own profile" on public.staff_auth_profiles;
create policy "staff can read own profile"
on public.staff_auth_profiles
for select
to authenticated
using (id = auth.uid() and is_active);

drop policy if exists "staff can clear own first login flag" on public.staff_auth_profiles;
create policy "staff can clear own first login flag"
on public.staff_auth_profiles
for update
to authenticated
using (id = auth.uid() and is_active)
with check (id = auth.uid() and is_active and must_change_password = false);

drop policy if exists "custom identities are service role only" on public.custom_auth_identities;
create policy "custom identities are service role only"
on public.custom_auth_identities
for all
using (false)
with check (false);

drop policy if exists "custom sessions are service role only" on public.custom_auth_sessions;
create policy "custom sessions are service role only"
on public.custom_auth_sessions
for all
using (false)
with check (false);
