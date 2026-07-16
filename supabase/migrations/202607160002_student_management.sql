create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

create table if not exists public.academic_years (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (length(trim(name)) > 0),
  starts_on date not null,
  ends_on date not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint academic_year_dates_valid check (starts_on < ends_on)
);

create table if not exists public.school_classes (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (length(trim(name)) > 0),
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.class_sections (
  id uuid primary key default gen_random_uuid(),
  class_id uuid not null references public.school_classes(id),
  name text not null check (length(trim(name)) > 0),
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (class_id, name)
);

create table if not exists public.transport_villages (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (length(trim(name)) > 0),
  transport_fee numeric(12,2) not null check (transport_fee >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.class_fee_structures (
  id uuid primary key default gen_random_uuid(),
  academic_year_id uuid not null references public.academic_years(id),
  class_id uuid not null references public.school_classes(id),
  tuition_fee numeric(12,2) not null check (tuition_fee >= 0),
  admission_fee numeric(12,2) not null check (admission_fee >= 0),
  exam_fee numeric(12,2) not null check (exam_fee >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (academic_year_id, class_id)
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  sr_number text not null unique check (length(trim(sr_number)) > 0),
  admission_date date not null,
  student_name text not null check (length(trim(student_name)) > 0),
  gender text not null check (gender in ('male', 'female', 'other')),
  date_of_birth date not null,
  father_name text not null check (length(trim(father_name)) > 0),
  mother_name text not null check (length(trim(mother_name)) > 0),
  parent_mobile_number text not null check (parent_mobile_number ~ '^[6-9][0-9]{9}$'),
  is_archived boolean not null default false,
  archived_at timestamptz,
  archived_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.student_enrollments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id),
  academic_year_id uuid not null references public.academic_years(id),
  class_id uuid not null references public.school_classes(id),
  section_id uuid not null references public.class_sections(id),
  roll_number integer,
  scholarship_discount numeric(12,2) not null default 0 check (scholarship_discount >= 0),
  uses_transport boolean not null default false,
  village_id uuid references public.transport_villages(id),
  transport_fee numeric(12,2) not null default 0 check (transport_fee >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (student_id, academic_year_id),
  unique (academic_year_id, class_id, section_id, roll_number),
  constraint transport_village_required check (
    (uses_transport = false and village_id is null and transport_fee = 0)
    or (uses_transport = true and village_id is not null)
  )
);

create table if not exists public.teacher_class_assignments (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid not null references auth.users(id),
  academic_year_id uuid not null references public.academic_years(id),
  class_id uuid not null references public.school_classes(id),
  section_id uuid not null references public.class_sections(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (teacher_id, academic_year_id, class_id, section_id)
);

create table if not exists public.student_guardians (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id),
  parent_identity_id uuid references public.custom_auth_identities(id),
  relation text not null default 'parent',
  is_primary boolean not null default true,
  created_at timestamptz not null default now(),
  unique (student_id, parent_identity_id)
);

create table if not exists public.student_user_links (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id),
  student_identity_id uuid references public.custom_auth_identities(id),
  created_at timestamptz not null default now(),
  unique (student_id, student_identity_id)
);

create table if not exists public.student_recently_viewed (
  user_id uuid not null,
  student_id uuid not null references public.students(id),
  viewed_at timestamptz not null default now(),
  primary key (user_id, student_id)
);

create index if not exists students_search_trgm_idx on public.students using gin (
  (student_name || ' ' || sr_number || ' ' || father_name || ' ' || mother_name || ' ' || parent_mobile_number) gin_trgm_ops
);

create or replace function public.current_app_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select role from public.staff_auth_profiles where id = auth.uid() and is_active
$$;

create or replace function public.is_student_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(public.current_app_role() in ('system_admin', 'director', 'principal'), false)
$$;

create or replace function public.can_view_student(target_student_id uuid)
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
      from public.staff_auth_profiles sap
      join public.teacher_class_assignments tca on tca.teacher_id = sap.id
      join public.student_enrollments se
        on se.academic_year_id = tca.academic_year_id
       and se.class_id = tca.class_id
       and se.section_id = tca.section_id
      where sap.id = auth.uid()
        and sap.role = 'teacher'
        and sap.is_active
        and tca.is_active
        and se.student_id = target_student_id
    )
$$;

alter table public.academic_years enable row level security;
alter table public.school_classes enable row level security;
alter table public.class_sections enable row level security;
alter table public.transport_villages enable row level security;
alter table public.class_fee_structures enable row level security;
alter table public.students enable row level security;
alter table public.student_enrollments enable row level security;
alter table public.teacher_class_assignments enable row level security;
alter table public.student_guardians enable row level security;
alter table public.student_user_links enable row level security;
alter table public.student_recently_viewed enable row level security;

create policy "authenticated can read active academic years"
on public.academic_years for select to authenticated using (is_active);

create policy "authenticated can read active classes"
on public.school_classes for select to authenticated using (is_active);

create policy "authenticated can read active sections"
on public.class_sections for select to authenticated using (is_active);

create policy "authenticated can read active transport villages"
on public.transport_villages for select to authenticated using (is_active);

create policy "authenticated can read active fee structures"
on public.class_fee_structures for select to authenticated using (is_active);

create policy "permitted users can read students"
on public.students for select to authenticated
using (not is_archived and public.can_view_student(id));

create policy "student admins can insert students"
on public.students for insert to authenticated
with check (public.is_student_admin());

create policy "student admins can update students"
on public.students for update to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "permitted users can read enrollments"
on public.student_enrollments for select to authenticated
using (public.can_view_student(student_id));

create policy "student admins can write enrollments"
on public.student_enrollments for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "teachers can read own assignments"
on public.teacher_class_assignments for select to authenticated
using (teacher_id = auth.uid() or public.is_student_admin());

create policy "student admins can manage teacher assignments"
on public.teacher_class_assignments for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "permitted users can read guardians"
on public.student_guardians for select to authenticated
using (public.can_view_student(student_id));

create policy "student admins can manage guardians"
on public.student_guardians for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "permitted users can read student links"
on public.student_user_links for select to authenticated
using (public.can_view_student(student_id));

create policy "student admins can manage student links"
on public.student_user_links for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "users manage own recently viewed"
on public.student_recently_viewed for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create or replace view public.student_list_details
with (security_invoker = true) as
select
  s.id,
  s.sr_number,
  s.student_name,
  s.father_name,
  s.mother_name,
  s.parent_mobile_number,
  s.is_archived,
  se.academic_year_id,
  se.class_id,
  se.section_id,
  se.roll_number,
  sc.name as class_name,
  cs.name as section_name,
  greatest(
    coalesce(cfs.tuition_fee, 0) + coalesce(cfs.admission_fee, 0) + coalesce(cfs.exam_fee, 0)
    - coalesce(se.scholarship_discount, 0),
    0
  ) as fee_due,
  null::numeric as attendance_percentage
from public.students s
join public.student_enrollments se on se.student_id = s.id
join public.school_classes sc on sc.id = se.class_id
join public.class_sections cs on cs.id = se.section_id
left join public.class_fee_structures cfs
  on cfs.academic_year_id = se.academic_year_id
 and cfs.class_id = se.class_id
 and cfs.is_active;

create or replace view public.student_profile_details
with (security_invoker = true) as
select
  s.id,
  s.sr_number,
  s.admission_date,
  s.student_name,
  s.gender,
  s.date_of_birth,
  s.father_name,
  s.mother_name,
  s.parent_mobile_number,
  s.is_archived,
  se.academic_year_id,
  ay.name as academic_year,
  se.class_id,
  sc.name as class_name,
  se.section_id,
  cs.name as section_name,
  se.roll_number,
  se.scholarship_discount,
  se.uses_transport,
  se.village_id,
  tv.name as village_name,
  se.transport_fee,
  greatest(
    coalesce(cfs.tuition_fee, 0) + coalesce(cfs.admission_fee, 0) + coalesce(cfs.exam_fee, 0)
    - coalesce(se.scholarship_discount, 0),
    0
  ) as fee_due,
  null::numeric as attendance_percentage
from public.students s
join public.student_enrollments se on se.student_id = s.id
join public.academic_years ay on ay.id = se.academic_year_id
join public.school_classes sc on sc.id = se.class_id
join public.class_sections cs on cs.id = se.section_id
left join public.transport_villages tv on tv.id = se.village_id
left join public.class_fee_structures cfs
  on cfs.academic_year_id = se.academic_year_id
 and cfs.class_id = se.class_id
 and cfs.is_active;

create or replace view public.student_recently_viewed_details
with (security_invoker = true) as
select
  srv.user_id,
  srv.viewed_at,
  sld.*
from public.student_recently_viewed srv
join public.student_list_details sld on sld.id = srv.student_id
where srv.user_id = auth.uid();

create or replace function public.search_students(search_query text)
returns setof public.student_list_details
language sql
stable
security definer
set search_path = public
as $$
  select sld.*
  from public.student_list_details sld
  where not sld.is_archived
    and public.can_view_student(sld.id)
    and (
      search_query is null
      or length(trim(search_query)) = 0
      or (
        sld.student_name || ' ' || sld.sr_number || ' ' || sld.father_name || ' ' ||
        sld.mother_name || ' ' || sld.parent_mobile_number
      ) ilike '%' || trim(search_query) || '%'
    )
  order by sld.student_name
  limit 50
$$;

create or replace function public.mark_student_recently_viewed(target_student_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.can_view_student(target_student_id) then
    raise exception 'Not allowed to view this student.';
  end if;

  insert into public.student_recently_viewed (user_id, student_id, viewed_at)
  values (auth.uid(), target_student_id, now())
  on conflict (user_id, student_id)
  do update set viewed_at = excluded.viewed_at;
end;
$$;

create or replace function public.resolve_transport_fee(uses_transport boolean, village_id uuid)
returns numeric
language sql
stable
security definer
set search_path = public
as $$
  select case
    when uses_transport = false then 0
    else (
      select transport_fee
      from public.transport_villages
      where id = village_id and is_active
    )
  end
$$;

create or replace function public.create_student(
  sr_number text,
  admission_date date,
  student_name text,
  gender text,
  date_of_birth date,
  father_name text,
  mother_name text,
  parent_mobile_number text,
  academic_year_id uuid,
  class_id uuid,
  section_id uuid,
  scholarship_discount numeric,
  uses_transport boolean,
  village_id uuid
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  new_student_id uuid;
  calculated_transport_fee numeric;
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can create students.';
  end if;

  calculated_transport_fee := public.resolve_transport_fee(uses_transport, village_id);
  if uses_transport and calculated_transport_fee is null then
    raise exception 'Invalid transport village.';
  end if;

  insert into public.students (
    sr_number, admission_date, student_name, gender, date_of_birth,
    father_name, mother_name, parent_mobile_number
  )
  values (
    trim(sr_number), admission_date, trim(student_name), gender, date_of_birth,
    trim(father_name), trim(mother_name), trim(parent_mobile_number)
  )
  returning id into new_student_id;

  insert into public.student_enrollments (
    student_id, academic_year_id, class_id, section_id, scholarship_discount,
    uses_transport, village_id, transport_fee
  )
  values (
    new_student_id, academic_year_id, class_id, section_id, scholarship_discount,
    uses_transport, case when uses_transport then village_id else null end,
    calculated_transport_fee
  );

  return new_student_id;
end;
$$;

create or replace function public.update_student(
  target_student_id uuid,
  p_sr_number text,
  p_admission_date date,
  p_student_name text,
  p_gender text,
  p_date_of_birth date,
  p_father_name text,
  p_mother_name text,
  p_parent_mobile_number text,
  p_academic_year_id uuid,
  p_class_id uuid,
  p_section_id uuid,
  p_scholarship_discount numeric,
  p_uses_transport boolean,
  p_village_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  calculated_transport_fee numeric;
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can update students.';
  end if;

  calculated_transport_fee := public.resolve_transport_fee(
    p_uses_transport,
    p_village_id
  );
  if p_uses_transport and calculated_transport_fee is null then
    raise exception 'Invalid transport village.';
  end if;

  update public.students
  set
    sr_number = trim(p_sr_number),
    admission_date = p_admission_date,
    student_name = trim(p_student_name),
    gender = p_gender,
    date_of_birth = p_date_of_birth,
    father_name = trim(p_father_name),
    mother_name = trim(p_mother_name),
    parent_mobile_number = trim(p_parent_mobile_number)
  where id = target_student_id;

  insert into public.student_enrollments (
    student_id, academic_year_id, class_id, section_id, scholarship_discount,
    uses_transport, village_id, transport_fee
  )
  values (
    target_student_id, p_academic_year_id, p_class_id, p_section_id,
    p_scholarship_discount, p_uses_transport,
    case when p_uses_transport then p_village_id else null end,
    calculated_transport_fee
  )
  on conflict (student_id, academic_year_id)
  do update set
    class_id = excluded.class_id,
    section_id = excluded.section_id,
    scholarship_discount = excluded.scholarship_discount,
    uses_transport = excluded.uses_transport,
    village_id = excluded.village_id,
    transport_fee = excluded.transport_fee;
end;
$$;

create or replace function public.archive_student(target_student_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can archive students.';
  end if;

  update public.students
  set is_archived = true,
      archived_at = now(),
      archived_by = auth.uid()
  where id = target_student_id;
end;
$$;
