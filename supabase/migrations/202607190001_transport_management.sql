-- Transport Management Module
create table public.vehicles (
  id uuid default gen_random_uuid() primary key,
  vehicle_number text not null,
  vehicle_type text check (vehicle_type in ('bus', 'van')),
  driver_name text not null,
  driver_phone text not null,
  capacity int not null,
  status text default 'active' check (status in ('active', 'inactive')),
  created_at timestamptz default now()
);

create table public.transport_routes (
  id uuid default gen_random_uuid() primary key,
  route_name text not null,
  created_at timestamptz default now()
);

create table public.route_stops (
  id uuid default gen_random_uuid() primary key,
  route_id uuid references public.transport_routes(id) on delete cascade,
  stop_name text not null,
  pickup_time time not null,
  drop_time time not null,
  stop_order int not null
);

create table public.student_transport_assignments (
  id uuid default gen_random_uuid() primary key,
  student_id uuid references public.students(id) on delete cascade,
  route_id uuid references public.transport_routes(id) on delete cascade,
  unique(student_id)
);
