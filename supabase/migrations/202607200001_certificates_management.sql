-- Certificates Management Module
create table public.certificates (
  id uuid default gen_random_uuid() primary key,
  student_id uuid references public.students(id) on delete cascade not null,
  certificate_type text not null check (certificate_type in ('bonafide', 'character', 'transfer', 'study', 'custom')),
  issue_date date not null default current_date,
  certificate_number text not null unique,
  remarks text,
  status text default 'draft' check (status in ('draft', 'issued', 'revoked')),
  created_at timestamptz default now(),
  created_by uuid references auth.users(id)
);
