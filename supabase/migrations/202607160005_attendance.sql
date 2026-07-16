do $$
begin
  if not exists (select 1 from pg_type where typname = 'attendance_status') then
    create type public.attendance_status as enum ('present', 'absent', 'late', 'leave');
  end if;
end $$;

create table if not exists public.attendance_sessions (
  id uuid primary key default gen_random_uuid(),
  academic_year_id uuid not null references public.academic_years(id),
  class_id uuid not null references public.school_classes(id),
  section_id uuid not null references public.class_sections(id),
  attendance_date date not null,
  period_number integer not null default 1 check (period_number > 0),
  marked_by uuid not null references auth.users(id),
  is_admin_override boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (academic_year_id, class_id, section_id, attendance_date, period_number)
);

create table if not exists public.student_attendance_records (
  id uuid primary key default gen_random_uuid(),
  attendance_session_id uuid not null references public.attendance_sessions(id) on delete cascade,
  student_id uuid not null references public.students(id),
  status public.attendance_status not null,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (attendance_session_id, student_id)
);

create index if not exists attendance_sessions_lookup_idx
on public.attendance_sessions (academic_year_id, class_id, section_id, attendance_date);

create index if not exists student_attendance_records_student_idx
on public.student_attendance_records (student_id);

drop trigger if exists attendance_sessions_updated_at on public.attendance_sessions;
create trigger attendance_sessions_updated_at
before update on public.attendance_sessions
for each row execute function public.set_updated_at();

drop trigger if exists student_attendance_records_updated_at on public.student_attendance_records;
create trigger student_attendance_records_updated_at
before update on public.student_attendance_records
for each row execute function public.set_updated_at();

alter table public.attendance_sessions enable row level security;
alter table public.student_attendance_records enable row level security;

create or replace function public.can_mark_attendance(
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
  select
    public.is_student_admin()
    or exists (
      select 1
      from public.teacher_class_assignments tca
      join public.staff_auth_profiles sap on sap.id = tca.teacher_id
      where tca.teacher_id = auth.uid()
        and sap.role = 'teacher'
        and sap.is_active
        and tca.is_active
        and tca.academic_year_id = target_academic_year_id
        and tca.class_id = target_class_id
        and tca.section_id = target_section_id
    )
$$;

create policy "permitted users read attendance sessions"
on public.attendance_sessions for select to authenticated
using (
  public.can_mark_attendance(academic_year_id, class_id, section_id)
  or exists (
    select 1
    from public.student_attendance_records sar
    where sar.attendance_session_id = attendance_sessions.id
      and public.can_view_student(sar.student_id)
  )
);

create policy "teachers and admins create attendance sessions"
on public.attendance_sessions for insert to authenticated
with check (public.can_mark_attendance(academic_year_id, class_id, section_id));

create policy "admins can update attendance sessions"
on public.attendance_sessions for update to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "permitted users read attendance records"
on public.student_attendance_records for select to authenticated
using (public.can_view_student(student_id));

create policy "teachers and admins write attendance records"
on public.student_attendance_records for all to authenticated
using (
  exists (
    select 1 from public.attendance_sessions ats
    where ats.id = attendance_session_id
      and public.can_mark_attendance(ats.academic_year_id, ats.class_id, ats.section_id)
  )
)
with check (
  exists (
    select 1 from public.attendance_sessions ats
    where ats.id = attendance_session_id
      and public.can_mark_attendance(ats.academic_year_id, ats.class_id, ats.section_id)
  )
);

create or replace view public.class_attendance_daily
with (security_invoker = true) as
select
  ats.id as attendance_session_id,
  ats.academic_year_id,
  ats.class_id,
  sc.name as class_name,
  ats.section_id,
  cs.name as section_name,
  ats.attendance_date,
  ats.period_number,
  count(sar.id)::integer as total_marked,
  count(*) filter (where sar.status = 'present')::integer as present_count,
  count(*) filter (where sar.status = 'absent')::integer as absent_count,
  count(*) filter (where sar.status = 'late')::integer as late_count,
  count(*) filter (where sar.status = 'leave')::integer as leave_count
from public.attendance_sessions ats
join public.school_classes sc on sc.id = ats.class_id
join public.class_sections cs on cs.id = ats.section_id
left join public.student_attendance_records sar on sar.attendance_session_id = ats.id
group by ats.id, sc.name, cs.name;

create or replace view public.student_attendance_history
with (security_invoker = true) as
select
  sar.student_id,
  s.student_name,
  s.sr_number,
  ats.attendance_date,
  ats.period_number,
  sar.status,
  sar.note,
  ats.academic_year_id,
  ats.class_id,
  ats.section_id
from public.student_attendance_records sar
join public.students s on s.id = sar.student_id
join public.attendance_sessions ats on ats.id = sar.attendance_session_id;

create or replace function public.save_daily_attendance(
  target_academic_year_id uuid,
  target_class_id uuid,
  target_section_id uuid,
  target_date date,
  records jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  session_id uuid;
  item jsonb;
begin
  if not public.can_mark_attendance(
    target_academic_year_id,
    target_class_id,
    target_section_id
  ) then
    raise exception 'Not allowed to mark attendance for this class.';
  end if;

  insert into public.attendance_sessions (
    academic_year_id, class_id, section_id, attendance_date, period_number,
    marked_by, is_admin_override
  )
  values (
    target_academic_year_id, target_class_id, target_section_id, target_date, 1,
    auth.uid(), public.is_student_admin()
  )
  on conflict (academic_year_id, class_id, section_id, attendance_date, period_number)
  do update set marked_by = auth.uid(),
                is_admin_override = public.is_student_admin()
  returning id into session_id;

  for item in select * from jsonb_array_elements(records)
  loop
    insert into public.student_attendance_records (
      attendance_session_id, student_id, status, note
    )
    values (
      session_id,
      (item->>'student_id')::uuid,
      (item->>'status')::public.attendance_status,
      nullif(item->>'note', '')
    )
    on conflict (attendance_session_id, student_id)
    do update set status = excluded.status,
                  note = excluded.note;
  end loop;

  return session_id;
end;
$$;
