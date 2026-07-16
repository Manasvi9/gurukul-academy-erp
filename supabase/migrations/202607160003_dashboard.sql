create or replace function public.table_exists(table_name text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select to_regclass('public.' || table_name) is not null
$$;

create or replace function public.count_if_table_exists(table_name text)
returns integer
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  total integer;
begin
  if not public.table_exists(table_name) then
    return 0;
  end if;

  execute format('select count(*)::integer from public.%I', table_name)
  into total;
  return coalesce(total, 0);
end;
$$;

create or replace function public.count_active_students()
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select case
    when public.table_exists('students') then (
      select count(*)::integer from public.students where is_archived = false
    )
    else 0
  end
$$;

create or replace function public.count_active_teachers()
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select count(*)::integer
  from public.staff_auth_profiles
  where role = 'teacher' and is_active
$$;

create or replace function public.dashboard_metric(
  metric_key text,
  title text,
  value text,
  icon_name text,
  route_path text default null
)
returns jsonb
language sql
immutable
as $$
  select jsonb_build_object(
    'key', metric_key,
    'title', title,
    'value', value,
    'icon_name', icon_name,
    'route_path', route_path
  )
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
      public.dashboard_metric('teachers', 'Teachers', public.count_active_teachers()::text, 'school', null),
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
