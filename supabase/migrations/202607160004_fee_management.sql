do $$
begin
  if not exists (select 1 from pg_type where typname = 'fee_payment_status') then
    create type public.fee_payment_status as enum ('posted', 'void');
  end if;
end $$;

create table if not exists public.fee_heads (
  id uuid primary key default gen_random_uuid(),
  name text not null unique check (length(trim(name)) > 0),
  display_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.class_fee_head_amounts (
  id uuid primary key default gen_random_uuid(),
  academic_year_id uuid not null references public.academic_years(id),
  class_id uuid not null references public.school_classes(id),
  fee_head_id uuid not null references public.fee_heads(id),
  amount numeric(12,2) not null check (amount >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (academic_year_id, class_id, fee_head_id)
);

create table if not exists public.student_fee_scholarships (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id),
  academic_year_id uuid not null references public.academic_years(id),
  amount numeric(12,2) not null check (amount >= 0),
  reason text not null check (length(trim(reason)) > 0),
  approved_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (student_id, academic_year_id)
);

create table if not exists public.student_fee_payments (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id),
  academic_year_id uuid not null references public.academic_years(id),
  amount numeric(12,2) not null check (amount > 0),
  payment_date date not null default current_date,
  payment_mode text not null check (length(trim(payment_mode)) > 0),
  reference_number text,
  note text,
  status public.fee_payment_status not null default 'posted',
  voided_at timestamptz,
  voided_by uuid references auth.users(id),
  void_reason text,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.student_fee_completions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id),
  academic_year_id uuid not null references public.academic_years(id),
  marked_by uuid not null references auth.users(id),
  marked_at timestamptz not null default now(),
  note text,
  unique (student_id, academic_year_id)
);

create index if not exists class_fee_head_amounts_lookup_idx
on public.class_fee_head_amounts (academic_year_id, class_id, is_active);

create index if not exists student_fee_payments_lookup_idx
on public.student_fee_payments (student_id, academic_year_id, status);

create index if not exists student_fee_scholarships_lookup_idx
on public.student_fee_scholarships (student_id, academic_year_id);

drop trigger if exists fee_heads_updated_at on public.fee_heads;
create trigger fee_heads_updated_at
before update on public.fee_heads
for each row execute function public.set_updated_at();

drop trigger if exists class_fee_head_amounts_updated_at on public.class_fee_head_amounts;
create trigger class_fee_head_amounts_updated_at
before update on public.class_fee_head_amounts
for each row execute function public.set_updated_at();

drop trigger if exists student_fee_scholarships_updated_at on public.student_fee_scholarships;
create trigger student_fee_scholarships_updated_at
before update on public.student_fee_scholarships
for each row execute function public.set_updated_at();

drop trigger if exists student_fee_payments_updated_at on public.student_fee_payments;
create trigger student_fee_payments_updated_at
before update on public.student_fee_payments
for each row execute function public.set_updated_at();

alter table public.fee_heads enable row level security;
alter table public.class_fee_head_amounts enable row level security;
alter table public.student_fee_scholarships enable row level security;
alter table public.student_fee_payments enable row level security;
alter table public.student_fee_completions enable row level security;

create policy "authenticated can read active fee heads"
on public.fee_heads for select to authenticated using (is_active);

create policy "student admins manage fee heads"
on public.fee_heads for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "authenticated can read class fee head amounts"
on public.class_fee_head_amounts for select to authenticated using (is_active);

create policy "student admins manage class fee head amounts"
on public.class_fee_head_amounts for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "permitted users read scholarships"
on public.student_fee_scholarships for select to authenticated
using (public.can_view_student(student_id));

create policy "student admins manage scholarships"
on public.student_fee_scholarships for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "permitted users read payments"
on public.student_fee_payments for select to authenticated
using (public.can_view_student(student_id));

create policy "student admins manage payments"
on public.student_fee_payments for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create policy "permitted users read completions"
on public.student_fee_completions for select to authenticated
using (public.can_view_student(student_id));

create policy "student admins manage completions"
on public.student_fee_completions for all to authenticated
using (public.is_student_admin())
with check (public.is_student_admin());

create or replace view public.student_fee_ledger
with (security_invoker = true) as
select
  se.student_id,
  s.student_name,
  s.sr_number,
  se.academic_year_id,
  ay.name as academic_year,
  se.class_id,
  sc.name as class_name,
  se.section_id,
  cs.name as section_name,
  coalesce(sum(cfha.amount) filter (where cfha.is_active), 0) as class_fee,
  coalesce(se.transport_fee, 0) as transport_fee,
  coalesce(sfs.amount, se.scholarship_discount, 0) as scholarship_discount,
  coalesce(sum(sfp.amount) filter (where sfp.status = 'posted'), 0) as paid_amount,
  (
    coalesce(sum(cfha.amount) filter (where cfha.is_active), 0)
    + coalesce(se.transport_fee, 0)
    - coalesce(sfs.amount, se.scholarship_discount, 0)
    - coalesce(sum(sfp.amount) filter (where sfp.status = 'posted'), 0)
  ) as outstanding_due,
  sfc.id is not null as is_fee_complete
from public.student_enrollments se
join public.students s on s.id = se.student_id
join public.academic_years ay on ay.id = se.academic_year_id
join public.school_classes sc on sc.id = se.class_id
join public.class_sections cs on cs.id = se.section_id
left join public.class_fee_head_amounts cfha
  on cfha.academic_year_id = se.academic_year_id
 and cfha.class_id = se.class_id
left join public.student_fee_scholarships sfs
  on sfs.student_id = se.student_id
 and sfs.academic_year_id = se.academic_year_id
left join public.student_fee_payments sfp
  on sfp.student_id = se.student_id
 and sfp.academic_year_id = se.academic_year_id
left join public.student_fee_completions sfc
  on sfc.student_id = se.student_id
 and sfc.academic_year_id = se.academic_year_id
where s.is_archived = false
group by
  se.student_id, s.student_name, s.sr_number, se.academic_year_id, ay.name,
  se.class_id, sc.name, se.section_id, cs.name, se.transport_fee,
  sfs.amount, se.scholarship_discount, sfc.id;

create or replace function public.record_fee_payment(
  target_student_id uuid,
  target_academic_year_id uuid,
  amount numeric,
  payment_date date,
  payment_mode text,
  reference_number text,
  note text
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  payment_id uuid;
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can record fee payments.';
  end if;

  insert into public.student_fee_payments (
    student_id, academic_year_id, amount, payment_date, payment_mode,
    reference_number, note, created_by
  )
  values (
    target_student_id, target_academic_year_id, amount, payment_date,
    trim(payment_mode), nullif(trim(reference_number), ''), nullif(trim(note), ''),
    auth.uid()
  )
  returning id into payment_id;

  return payment_id;
end;
$$;

create or replace function public.edit_fee_payment(
  target_payment_id uuid,
  amount numeric,
  payment_date date,
  payment_mode text,
  reference_number text,
  note text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can edit fee payments.';
  end if;

  update public.student_fee_payments
  set amount = edit_fee_payment.amount,
      payment_date = edit_fee_payment.payment_date,
      payment_mode = trim(edit_fee_payment.payment_mode),
      reference_number = nullif(trim(edit_fee_payment.reference_number), ''),
      note = nullif(trim(edit_fee_payment.note), '')
  where id = target_payment_id
    and status = 'posted';
end;
$$;

create or replace function public.void_fee_payment(
  target_payment_id uuid,
  reason text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can void fee payments.';
  end if;

  update public.student_fee_payments
  set status = 'void',
      voided_at = now(),
      voided_by = auth.uid(),
      void_reason = trim(reason)
  where id = target_payment_id
    and status = 'posted';
end;
$$;

create or replace function public.mark_fee_complete(
  target_student_id uuid,
  target_academic_year_id uuid,
  note text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_student_admin() then
    raise exception 'Only admin, director, and principal can mark fees complete.';
  end if;

  insert into public.student_fee_completions (
    student_id, academic_year_id, marked_by, note
  )
  values (
    target_student_id, target_academic_year_id, auth.uid(), nullif(trim(note), '')
  )
  on conflict (student_id, academic_year_id)
  do update set marked_by = excluded.marked_by,
                marked_at = now(),
                note = excluded.note;
end;
$$;
