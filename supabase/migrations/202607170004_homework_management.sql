create table if not exists public.homework (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users(id),
  academic_year_id uuid not null references public.academic_years(id),
  class_id uuid not null references public.school_classes(id),
  section_id uuid not null references public.class_sections(id),
  subject_id uuid not null references public.subjects(id),
  due_date date not null,
  description text not null check (length(trim(description)) > 0),
  is_deleted boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists homework_class_section_due_idx
  on public.homework (academic_year_id, class_id, section_id, due_date)
  where not is_deleted;
create index if not exists homework_teacher_idx
  on public.homework (teacher_id, due_date desc)
  where not is_deleted;

drop trigger if exists homework_updated_at on public.homework;
create trigger homework_updated_at before update on public.homework
for each row execute function public.set_updated_at();

alter table public.homework enable row level security;

create or replace function public.can_view_homework(
  target_academic_year_id uuid,
  target_class_id uuid,
  target_section_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.is_student_admin()
    or exists (
      select 1 from public.teacher_class_assignments tca
      where tca.teacher_id = auth.uid()
        and tca.is_active
        and tca.academic_year_id = target_academic_year_id
        and tca.class_id = target_class_id
        and tca.section_id = target_section_id
    )
    or exists (
      select 1 from public.student_enrollments se
      where se.academic_year_id = target_academic_year_id
        and se.class_id = target_class_id
        and se.section_id = target_section_id
        and public.can_view_student(se.student_id)
    )
$$;

create policy "permitted users can read homework"
on public.homework for select to authenticated
using (not is_deleted and public.can_view_homework(academic_year_id, class_id, section_id));

create policy "teachers and admins create homework"
on public.homework for insert to authenticated
with check (
  teacher_id = auth.uid()
  and public.can_mark_attendance(academic_year_id, class_id, section_id)
);

create policy "teachers and admins update homework"
on public.homework for update to authenticated
using (teacher_id = auth.uid() or public.is_student_admin())
with check (teacher_id = auth.uid() or public.is_student_admin());

create or replace view public.homework_details
with (security_invoker = true) as
select
  h.id,
  h.teacher_id,
  h.academic_year_id,
  h.class_id,
  sc.name as class_name,
  h.section_id,
  cs.name as section_name,
  h.subject_id,
  s.name as subject_name,
  h.due_date,
  h.description,
  h.created_at
from public.homework h
join public.school_classes sc on sc.id = h.class_id
join public.class_sections cs on cs.id = h.section_id
join public.subjects s on s.id = h.subject_id
where not h.is_deleted;
