create table public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  theme text not null default 'system',
  notifications_enabled boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.user_settings enable row level security;

create policy "users manage own settings" on public.user_settings for all to authenticated
using (auth.uid() = user_id) with check (auth.uid() = user_id);
