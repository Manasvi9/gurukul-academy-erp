-- Academic Structure extends the existing Student Management class tables.
-- Keeping school_classes and class_sections avoids duplicating the relations
-- already used by student enrolments.

alter table public.school_classes
  add column if not exists is_archived boolean not null default false,
  add column if not exists archived_at timestamptz,
  add column if not exists archived_by uuid;

alter table public.class_sections
  add column if not exists capacity integer check (capacity is null or capacity > 0),
  add column if not exists is_archived boolean not null default false,
  add column if not exists archived_at timestamptz,
  add column if not exists archived_by uuid;

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  code text,
  display_order integer not null default 0,
  is_active boolean not null default true,
  is_archived boolean not null default false,
  archived_at timestamptz,
  archived_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (name),
  unique (code)
);

create table if not exists public.class_subjects (
  class_id uuid not null references public.school_classes(id),
  subject_id uuid not null references public.subjects(id),
  created_at timestamptz not null default now(),
  primary key (class_id, subject_id)
);

create index if not exists school_classes_active_search_idx
  on public.school_classes (is_archived, name, display_order);
create index if not exists class_sections_active_class_idx
  on public.class_sections (is_archived, class_id, name, display_order);
create index if not exists subjects_active_search_idx
  on public.subjects (is_archived, name, code, display_order);
create index if not exists class_subjects_subject_idx
  on public.class_subjects (subject_id, class_id);

drop trigger if exists school_classes_updated_at on public.school_classes;
create trigger school_classes_updated_at
before update on public.school_classes
for each row execute function public.set_updated_at();

drop trigger if exists class_sections_updated_at on public.class_sections;
create trigger class_sections_updated_at
before update on public.class_sections
for each row execute function public.set_updated_at();

drop trigger if exists subjects_updated_at on public.subjects;
create trigger subjects_updated_at
before update on public.subjects
for each row execute function public.set_updated_at();

alter table public.subjects enable row level security;
alter table public.class_subjects enable row level security;

drop policy if exists "authenticated can read active classes" on public.school_classes;
create policy "permitted users can read classes"
on public.school_classes for select to authenticated
using (not is_archived and (is_active or public.is_student_admin()));
create policy "admins can manage classes"
on public.school_classes for all to authenticated
using (public.is_student_admin()) with check (public.is_student_admin());

drop policy if exists "authenticated can read active sections" on public.class_sections;
create policy "permitted users can read sections"
on public.class_sections for select to authenticated
using (not is_archived and (is_active or public.is_student_admin()));
create policy "admins can manage sections"
on public.class_sections for all to authenticated
using (public.is_student_admin()) with check (public.is_student_admin());

create policy "permitted users can read subjects"
on public.subjects for select to authenticated
using (not is_archived and (is_active or public.is_student_admin()));
create policy "admins can manage subjects"
on public.subjects for all to authenticated
using (public.is_student_admin()) with check (public.is_student_admin());

create policy "permitted users can read class subjects"
on public.class_subjects for select to authenticated
using (exists (
  select 1 from public.subjects s
  where s.id = subject_id and not s.is_archived and (s.is_active or public.is_student_admin())
));
create policy "admins can manage class subjects"
on public.class_subjects for all to authenticated
using (public.is_student_admin()) with check (public.is_student_admin());

create or replace view public.academic_sections
with (security_invoker = true) as
select
  cs.id,
  cs.class_id,
  sc.name as class_name,
  cs.name,
  cs.capacity,
  cs.is_active,
  cs.display_order
from public.class_sections cs
join public.school_classes sc on sc.id = cs.class_id
where not cs.is_archived and not sc.is_archived;

create or replace function public.save_subject(
  p_id uuid,
  p_name text,
  p_code text,
  p_display_order integer,
  p_is_active boolean,
  p_class_ids uuid[]
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  saved_id uuid;
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can manage subjects.';
  end if;

  if p_id is null then
    insert into public.subjects (name, code, display_order, is_active)
    values (trim(p_name), nullif(trim(p_code), ''), p_display_order, p_is_active)
    returning id into saved_id;
  else
    update public.subjects
    set name = trim(p_name),
        code = nullif(trim(p_code), ''),
        display_order = p_display_order,
        is_active = p_is_active
    where id = p_id and not is_archived
    returning id into saved_id;
  end if;

  if saved_id is null then
    raise exception 'Subject not found.';
  end if;

  delete from public.class_subjects where subject_id = saved_id;
  insert into public.class_subjects (class_id, subject_id)
  select class_id, saved_id from unnest(coalesce(p_class_ids, '{}')) as class_id;

  return saved_id;
end;
$$;

create or replace function public.archive_academic_class(target_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can archive classes.';
  end if;
  update public.school_classes
  set is_archived = true, is_active = false, archived_at = now(), archived_by = auth.uid()
  where id = target_id;
end;
$$;

create or replace function public.archive_academic_section(target_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can archive sections.';
  end if;
  update public.class_sections
  set is_archived = true, is_active = false, archived_at = now(), archived_by = auth.uid()
  where id = target_id;
end;
$$;

create or replace function public.archive_subject(target_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can archive subjects.';
  end if;
  update public.subjects
  set is_archived = true, is_active = false, archived_at = now(), archived_by = auth.uid()
  where id = target_id;
end;
$$;

create or replace function public.get_staff_dashboard_summary()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  app_role public.app_role;
  cards jsonb;
begin
  app_role := public.current_app_role();
  if app_role is null then
    raise exception 'Authenticated staff profile not found.';
  end if;

  if app_role in ('system_admin', 'director', 'principal') then
    cards := jsonb_build_array(
      public.dashboard_metric('students', 'Students', public.count_active_students()::text, 'groups', '/students'),
      public.dashboard_metric('teachers', 'Teachers', public.count_active_teachers()::text, 'school', '/teachers'),
      public.dashboard_metric('academic_structure', 'Academic Structure', 'Classes, Sections & Subjects', 'account_tree', '/academic-structure/classes'),
      public.dashboard_metric('fees_due', 'Fees Due', '0', 'payments', '/fees'),
      public.dashboard_metric('attendance_today', 'Today''s Attendance', '0', 'fact_check', null),
      public.dashboard_metric('homework_today', 'Today''s Homework', '0', 'assignment', null),
      public.dashboard_metric('events_today', 'Today''s Events', '0', 'event', null),
      public.dashboard_metric('pending_leave', 'Pending Leave Requests', '0', 'pending_actions', null),
      public.dashboard_metric('notifications', 'Recent Notifications', '0', 'notifications', null)
    );
  elsif app_role = 'teacher' then
    cards := jsonb_build_array(
      public.dashboard_metric('todays_classes', 'Today''s Classes', '0', 'calendar_view_day', null),
      public.dashboard_metric('take_attendance', 'Take Attendance', 'Open', 'fact_check', null),
      public.dashboard_metric('homework', 'Homework', 'Open', 'assignment', null),
      public.dashboard_metric('marks', 'Marks', 'Open', 'grading', null),
      public.dashboard_metric('notifications', 'Notifications', '0', 'notifications', null)
    );
  else
    cards := '[]'::jsonb;
  end if;

  return jsonb_build_object(
    'role', app_role,
    'title', case
      when app_role = 'system_admin' then 'Admin Dashboard'
      when app_role = 'director' then 'Director Dashboard'
      when app_role = 'principal' then 'Principal Dashboard'
      when app_role = 'teacher' then 'Teacher Dashboard'
      else 'Dashboard'
    end,
    'cards', cards,
    'notifications', '[]'::jsonb
  );
end;
$$;
