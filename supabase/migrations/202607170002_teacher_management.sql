create table if not exists public.teachers (
  id uuid primary key default gen_random_uuid(),
  employee_id text not null unique check (length(trim(employee_id)) > 0),
  full_name text not null check (length(trim(full_name)) > 0),
  phone text,
  email text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists teachers_active_search_idx on public.teachers (is_archived, full_name, employee_id);
drop trigger if exists teachers_updated_at on public.teachers;
create trigger teachers_updated_at before update on public.teachers for each row execute function public.set_updated_at();
alter table public.teachers enable row level security;
create policy "permitted users can read teachers" on public.teachers for select to authenticated using (public.is_student_admin());
create policy "admins can manage teachers" on public.teachers for all to authenticated using (public.is_student_admin()) with check (public.is_student_admin());
