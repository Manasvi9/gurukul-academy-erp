create table public.timetable_entries (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.school_classes(id),
  section_id uuid not null references public.class_sections(id),
  subject_id uuid not null references public.subjects(id),
  teacher_id uuid not null references auth.users(id),
  day_of_week smallint not null check (day_of_week between 1 and 7),
  start_time time not null,
  end_time time not null,
  room text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (end_time > start_time)
);

create index timetable_entries_class_lookup_idx
  on public.timetable_entries (class_id, section_id, day_of_week, start_time);
create index timetable_entries_teacher_lookup_idx
  on public.timetable_entries (teacher_id, day_of_week, start_time);

create or replace function public.prevent_timetable_overlap()
returns trigger language plpgsql set search_path = public as $$
begin
  if exists (
    select 1 from public.timetable_entries entry
    where entry.id <> coalesce(new.id, gen_random_uuid())
      and entry.day_of_week = new.day_of_week
      and entry.start_time < new.end_time
      and entry.end_time > new.start_time
      and (
        (entry.class_id = new.class_id and entry.section_id = new.section_id)
        or entry.teacher_id = new.teacher_id
      )
  ) then
    raise exception 'Timetable period overlaps an existing class or teacher period.';
  end if;
  return new;
end;
$$;
create trigger timetable_entries_prevent_overlap
before insert or update on public.timetable_entries
for each row execute function public.prevent_timetable_overlap();
create trigger timetable_entries_updated_at
before update on public.timetable_entries
for each row execute function public.set_updated_at();

create or replace view public.timetable_entry_details
with (security_invoker = true) as
select entry.*, class.name as class_name, section.name as section_name,
  subject.name as subject_name, profile.display_name as teacher_name
from public.timetable_entries entry
join public.school_classes class on class.id = entry.class_id
join public.class_sections section on section.id = entry.section_id
join public.subjects subject on subject.id = entry.subject_id
join public.staff_auth_profiles profile on profile.id = entry.teacher_id;

alter table public.timetable_entries enable row level security;
create policy "staff read permitted timetable" on public.timetable_entries for select to authenticated using (
  public.is_student_admin() or exists (
    select 1 from public.teacher_class_assignments assignment
    where assignment.teacher_id = auth.uid() and assignment.is_active
      and assignment.class_id = timetable_entries.class_id
      and assignment.section_id = timetable_entries.section_id
  )
);
create policy "admins manage timetable" on public.timetable_entries for all to authenticated
using (public.is_student_admin()) with check (public.is_student_admin());

create or replace function public.timetable_teacher_options()
returns table(id uuid, display_name text)
language sql stable security definer set search_path = public as $$
  select id, display_name from public.staff_auth_profiles
  where role = 'teacher' and is_active order by display_name
$$;
