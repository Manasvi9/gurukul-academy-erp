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
  recent_notifications jsonb;
  total_students integer := 0;
  total_teachers integer := 0;
  total_parents integer := 0;
  total_classes integer := 0;
  total_sections integer := 0;
  attendance_percentage numeric := 0;
  fee_today numeric := 0;
  fee_month numeric := 0;
  upcoming_exams integer := 0;
  pending_certificates integer := 0;
  assigned_classes integer := 0;
  marked_classes integer := 0;
  pending_homework integer := 0;
  notice_count integer := 0;
begin
  app_role := public.current_app_role();
  if app_role is null then
    raise exception 'Authenticated staff profile not found.';
  end if;

  select coalesce(jsonb_agg(notification), '[]'::jsonb)
  into recent_notifications
  from (
    select jsonb_build_object(
      'id', n.id,
      'title', n.title,
      'message', n.description,
      'created_at', n.created_at
    ) as notification
    from public.notifications n
    where not n.is_archived
      and n.published_on <= current_date
      and (n.expires_on is null or n.expires_on >= current_date)
    order by n.published_on desc, n.created_at desc
    limit 5
  ) recent;

  select jsonb_array_length(recent_notifications) into notice_count;

  if app_role in ('system_admin', 'director', 'principal') then
    select count(*)::integer into total_students
    from public.students
    where not is_archived;

    select count(*)::integer into total_teachers
    from public.staff_auth_profiles
    where role = 'teacher' and is_active;

    select count(*)::integer into total_parents
    from public.custom_auth_identities
    where role = 'parent' and is_active;

    select count(*)::integer into total_classes
    from public.school_classes
    where is_active;

    select count(*)::integer into total_sections
    from public.class_sections
    where is_active;

    select coalesce(
      round(
        100.0 * count(*) filter (where sar.status in ('present', 'late'))
        / nullif(count(*), 0),
        1
      ),
      0
    ) into attendance_percentage
    from public.student_attendance_records sar
    join public.attendance_sessions ats on ats.id = sar.attendance_session_id
    where ats.attendance_date = current_date;

    select coalesce(sum(amount), 0) into fee_today
    from public.student_fee_payments
    where status = 'posted' and payment_date = current_date;

    select coalesce(sum(amount), 0) into fee_month
    from public.student_fee_payments
    where status = 'posted'
      and date_trunc('month', payment_date) = date_trunc('month', current_date);

    select count(*)::integer into upcoming_exams
    from public.exams
    where not is_archived
      and status = 'published'
      and start_date >= current_date;
  end if;

  if app_role = 'teacher' then
    select count(*)::integer into assigned_classes
    from public.teacher_class_assignments
    where teacher_id = auth.uid() and is_active;

    select count(*)::integer into marked_classes
    from public.attendance_sessions ats
    where ats.attendance_date = current_date
      and ats.marked_by = auth.uid();

    select count(*)::integer into pending_homework
    from public.homework
    where teacher_id = auth.uid()
      and not is_deleted
      and due_date >= current_date;

    select count(*)::integer into upcoming_exams
    from public.exams e
    where not e.is_archived
      and e.status = 'published'
      and e.start_date >= current_date
      and exists (
        select 1
        from public.teacher_class_assignments tca
        where tca.teacher_id = auth.uid()
          and tca.is_active
          and tca.academic_year_id = e.academic_year_id
          and tca.class_id = e.class_id
          and tca.section_id = e.section_id
      );
  end if;

  if app_role = 'principal' then
    select count(*)::integer into pending_certificates
    from public.certificates
    where status = 'draft';
  end if;

  if app_role in ('system_admin', 'director') then
    cards := jsonb_build_array(
      public.dashboard_metric('total_students', 'Total Students', total_students::text, 'groups', '/students'),
      public.dashboard_metric('total_teachers', 'Total Teachers', total_teachers::text, 'school', '/teachers'),
      public.dashboard_metric('total_parents', 'Total Parents', total_parents::text, 'groups', null),
      public.dashboard_metric('total_classes', 'Total Classes', total_classes::text, 'school', '/academic-structure/classes'),
      public.dashboard_metric('total_sections', 'Total Sections', total_sections::text, 'school', '/academic-structure/sections'),
      public.dashboard_metric('attendance_today', 'Attendance Today', attendance_percentage::text || '%', 'fact_check', null),
      public.dashboard_metric('fee_collection', 'Fee Collection Summary', 'Today ₹' || fee_today::text || '\nMonth ₹' || fee_month::text, 'payments', '/fees'),
      public.dashboard_metric('upcoming_exams', 'Upcoming Exams', upcoming_exams::text, 'event', '/exams')
    );
  elsif app_role = 'principal' then
    cards := jsonb_build_array(
      public.dashboard_metric('student_strength', 'Student Strength', total_students::text, 'groups', '/students'),
      public.dashboard_metric('teacher_strength', 'Teacher Strength', total_teachers::text, 'school', '/teachers'),
      public.dashboard_metric('attendance_today', 'Today''s Attendance', attendance_percentage::text || '%', 'fact_check', null),
      public.dashboard_metric('fee_overview', 'Fee Overview', 'Today ₹' || fee_today::text || '\nMonth ₹' || fee_month::text, 'payments', '/fees'),
      public.dashboard_metric('upcoming_exams', 'Upcoming Exams', upcoming_exams::text, 'event', '/exams'),
      public.dashboard_metric('pending_certificates', 'Pending Certificates', pending_certificates::text, 'pending_actions', '/certificates')
    );
  elsif app_role = 'teacher' then
    cards := jsonb_build_array(
      public.dashboard_metric('assigned_classes', 'Assigned Classes', assigned_classes::text, 'school', null),
      public.dashboard_metric('attendance_status', 'Today''s Attendance', marked_classes::text || ' of ' || assigned_classes::text || ' marked', 'fact_check', null),
      public.dashboard_metric('pending_homework', 'Pending Homework', pending_homework::text, 'assignment', '/homework'),
      public.dashboard_metric('upcoming_exams', 'Upcoming Exams', upcoming_exams::text, 'event', '/exams'),
      public.dashboard_metric('recent_notices', 'Recent Notices', notice_count::text, 'notifications', null)
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
    'notifications', recent_notifications
  );
end;
$$;
