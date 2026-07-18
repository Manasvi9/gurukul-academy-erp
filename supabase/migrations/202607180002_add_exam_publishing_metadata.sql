-- Migration to add publishing metadata to the exams table
alter table public.exams
  add column if not exists published_at timestamptz,
  add column if not exists published_by uuid references auth.users(id);

create index if not exists exams_published_idx on public.exams (status, published_at);
