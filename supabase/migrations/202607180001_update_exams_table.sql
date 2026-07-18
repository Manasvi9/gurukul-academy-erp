-- Add start_date, end_date and description to exams table
alter table public.exams 
rename column exam_date to start_date;

alter table public.exams 
add column end_date date,
add column description text;

-- Update index to use start_date
drop index if exists exams_class_date_idx;
create index exams_class_date_idx on public.exams (academic_year_id, class_id, section_id, start_date) where not is_archived;
