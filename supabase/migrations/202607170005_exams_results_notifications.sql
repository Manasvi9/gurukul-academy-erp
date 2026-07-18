do $$ begin
  create type public.exam_type as enum ('unit_test', 'half_yearly', 'yearly', 'pre_board');
exception when duplicate_object then null; end $$;
do $$ begin
  create type public.exam_status as enum ('draft', 'published', 'archived');
exception when duplicate_object then null; end $$;
do $$ begin
  create type public.notification_type as enum ('general', 'holiday', 'fee_reminder', 'homework', 'exam', 'emergency');
exception when duplicate_object then null; end $$;
do $$ begin
  create type public.notification_audience as enum ('all', 'teachers', 'parents', 'students', 'class', 'section');
exception when duplicate_object then null; end $$;

create table public.exams (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  type public.exam_type not null,
  academic_year_id uuid not null references public.academic_years(id),
  class_id uuid not null references public.school_classes(id),
  section_id uuid not null references public.class_sections(id),
  exam_date date not null,
  status public.exam_status not null default 'draft',
  is_archived boolean not null default false,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table public.exam_subjects (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  subject_id uuid not null references public.subjects(id),
  maximum_marks numeric(8,2) not null check (maximum_marks > 0),
  passing_marks numeric(8,2) not null check (passing_marks >= 0 and passing_marks <= maximum_marks),
  unique (exam_id, subject_id)
);
create table public.exam_marks (
  id uuid primary key default gen_random_uuid(),
  exam_subject_id uuid not null references public.exam_subjects(id) on delete cascade,
  student_id uuid not null references public.students(id),
  marks numeric(8,2) check (marks >= 0),
  is_final boolean not null default false,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now(),
  unique (exam_subject_id, student_id)
);
create table public.report_card_remarks (
  id uuid primary key default gen_random_uuid(),
  exam_id uuid not null references public.exams(id) on delete cascade,
  student_id uuid not null references public.students(id),
  remarks text,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now(),
  unique (exam_id, student_id)
);
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null check (length(trim(title)) > 0),
  description text not null check (length(trim(description)) > 0),
  type public.notification_type not null default 'general',
  audience public.notification_audience not null default 'all',
  class_id uuid references public.school_classes(id),
  section_id uuid references public.class_sections(id),
  published_on date not null default current_date,
  expires_on date,
  is_archived boolean not null default false,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint notification_target_valid check (
    (audience = 'class' and class_id is not null and section_id is null)
    or (audience = 'section' and class_id is not null and section_id is not null)
    or (audience not in ('class', 'section') and class_id is null and section_id is null)
  ),
  constraint notification_dates_valid check (expires_on is null or expires_on >= published_on)
);
create index exams_class_date_idx on public.exams (academic_year_id, class_id, section_id, exam_date) where not is_archived;
create index exam_marks_student_idx on public.exam_marks (student_id, exam_subject_id);
create index notifications_active_idx on public.notifications (audience, published_on, expires_on) where not is_archived;
create trigger exams_updated_at before update on public.exams for each row execute function public.set_updated_at();
create trigger exam_marks_updated_at before update on public.exam_marks for each row execute function public.set_updated_at();
create trigger report_card_remarks_updated_at before update on public.report_card_remarks for each row execute function public.set_updated_at();
create trigger notifications_updated_at before update on public.notifications for each row execute function public.set_updated_at();

alter table public.exams enable row level security;
alter table public.exam_subjects enable row level security;
alter table public.exam_marks enable row level security;
alter table public.report_card_remarks enable row level security;
alter table public.notifications enable row level security;
create policy "staff can read exams" on public.exams for select to authenticated using (public.is_student_admin() or public.can_mark_attendance(academic_year_id, class_id, section_id));
create policy "admins manage exams" on public.exams for all to authenticated using (public.is_student_admin()) with check (public.is_student_admin());
create policy "staff read exam subjects" on public.exam_subjects for select to authenticated using (exists (select 1 from public.exams e where e.id = exam_id and (public.is_student_admin() or public.can_mark_attendance(e.academic_year_id, e.class_id, e.section_id))));
create policy "admins manage exam subjects" on public.exam_subjects for all to authenticated using (public.is_student_admin()) with check (public.is_student_admin());
create policy "staff read marks" on public.exam_marks for select to authenticated using (public.can_view_student(student_id));
create policy "teachers write marks" on public.exam_marks for all to authenticated using (exists (select 1 from public.exam_subjects es join public.exams e on e.id = es.exam_id where es.id = exam_subject_id and public.can_mark_attendance(e.academic_year_id, e.class_id, e.section_id))) with check (exists (select 1 from public.exam_subjects es join public.exams e on e.id = es.exam_id where es.id = exam_subject_id and public.can_mark_attendance(e.academic_year_id, e.class_id, e.section_id)));
create policy "staff read report remarks" on public.report_card_remarks for select to authenticated using (public.can_view_student(student_id));
create policy "teachers write report remarks" on public.report_card_remarks for all to authenticated using (public.is_student_admin()) with check (public.is_student_admin());
create policy "applicable users read notifications" on public.notifications for select to authenticated using (not is_archived and (expires_on is null or expires_on >= current_date));
create policy "admins manage notifications" on public.notifications for all to authenticated using (public.is_student_admin()) with check (public.is_student_admin());
