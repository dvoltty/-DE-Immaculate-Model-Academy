-- Starter schema for a Supabase-backed DE' Immaculate Model Academy LMS.
-- Review with a qualified developer before production. Apply migrations in a staging project first.
create extension if not exists pgcrypto;

create type public.app_role as enum ('student','tutor','admin');
create type public.approval_status as enum ('pending','approved','suspended','rejected');
create type public.exam_type as enum ('JAMB','WAEC','NECO','Post-UTME');
create type public.test_status as enum ('draft','pending_review','published','archived');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  username text unique,
  phone text,
  role public.app_role not null default 'student',
  approval public.approval_status not null default 'pending',
  student_category text check (student_category in ('Science','Art','Commercial','General')),
  exam_focus public.exam_type,
  subjects text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.courses (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  exam public.exam_type not null,
  subject text not null,
  description text,
  tutor_id uuid references public.profiles(id),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.question_sets (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  exam public.exam_type not null,
  subject text not null,
  exam_year int check (exam_year between 2000 and 2100),
  source_label text,
  licence_note text,
  status public.test_status not null default 'draft',
  duration_minutes int not null default 60 check (duration_minutes between 1 and 300),
  created_by uuid not null references public.profiles(id),
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  question_set_id uuid not null references public.question_sets(id) on delete cascade,
  position int not null,
  prompt text not null,
  options jsonb not null check (jsonb_typeof(options) = 'array' and jsonb_array_length(options) = 4),
  correct_option smallint not null check (correct_option between 0 and 3),
  explanation text,
  topic text,
  unique(question_set_id, position)
);

create table public.exam_attempts (
  id uuid primary key default gen_random_uuid(),
  question_set_id uuid not null references public.question_sets(id),
  student_id uuid not null references public.profiles(id),
  answers jsonb not null default '{}',
  score int,
  total int,
  started_at timestamptz not null default now(),
  submitted_at timestamptz,
  check (score is null or score >= 0),
  check (total is null or total > 0)
);

create table public.class_sessions (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  course_id uuid references public.courses(id),
  tutor_id uuid not null references public.profiles(id),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  meeting_provider text,
  meeting_room_ref text,
  status text not null default 'scheduled',
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table public.class_enrolments (
  session_id uuid references public.class_sessions(id) on delete cascade,
  student_id uuid references public.profiles(id) on delete cascade,
  joined_at timestamptz,
  primary key(session_id, student_id)
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id),
  recipient_id uuid references public.profiles(id),
  session_id uuid references public.class_sessions(id) on delete cascade,
  body text,
  attachment_path text,
  created_at timestamptz not null default now(),
  check (body is not null or attachment_path is not null)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles(id),
  plan_code text not null,
  amount_kobo bigint not null check (amount_kobo >= 0),
  currency text not null default 'NGN',
  provider_reference text unique,
  status text not null default 'pending',
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

-- Helper functions: do not allow users to self-assign privileged roles.
create or replace function public.current_role()
returns public.app_role language sql stable security definer set search_path = public
as $$ select role from public.profiles where id = auth.uid() $$;

create or replace function public.is_approved()
returns boolean language sql stable security definer set search_path = public
as $$ select coalesce((select approval = 'approved' from public.profiles where id = auth.uid()), false) $$;

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.question_sets enable row level security;
alter table public.questions enable row level security;
alter table public.exam_attempts enable row level security;
alter table public.class_sessions enable row level security;
alter table public.class_enrolments enable row level security;
alter table public.messages enable row level security;
alter table public.notifications enable row level security;
alter table public.subscriptions enable row level security;

-- Profiles: users can read their own profile; admin can manage all. Admin role assignment
-- should be performed only by a trusted server/admin workflow, never a public signup field.
create policy "profile self read" on public.profiles for select to authenticated using (id = auth.uid() or public.current_role() = 'admin');
create policy "profile self update" on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid() and role = public.current_role());
create policy "admin manages profiles" on public.profiles for all to authenticated using (public.current_role() = 'admin') with check (public.current_role() = 'admin');

create policy "approved users read active courses" on public.courses for select to authenticated using (public.is_approved() and is_active);
create policy "admin manages courses" on public.courses for all to authenticated using (public.current_role() = 'admin') with check (public.current_role() = 'admin');
create policy "tutor manages own courses" on public.courses for all to authenticated using (public.current_role() = 'tutor' and tutor_id = auth.uid()) with check (public.current_role() = 'tutor' and tutor_id = auth.uid());

create policy "published sets visible to approved users" on public.question_sets for select to authenticated using (public.is_approved() and status = 'published');
create policy "tutors read own sets" on public.question_sets for select to authenticated using (created_by = auth.uid());
create policy "tutors create own drafts" on public.question_sets for insert to authenticated with check (public.current_role() = 'tutor' and created_by = auth.uid() and status in ('draft','pending_review'));
create policy "tutors update own drafts" on public.question_sets for update to authenticated using (public.current_role() = 'tutor' and created_by = auth.uid() and status in ('draft','pending_review')) with check (created_by = auth.uid() and status in ('draft','pending_review'));
create policy "admin manages question sets" on public.question_sets for all to authenticated using (public.current_role() = 'admin') with check (public.current_role() = 'admin');

create policy "questions visible for published or own set" on public.questions for select to authenticated using (
  exists(select 1 from public.question_sets s where s.id = question_set_id and (s.status = 'published' and public.is_approved() or s.created_by = auth.uid() or public.current_role() = 'admin'))
);
create policy "tutors manage questions in own drafts" on public.questions for all to authenticated using (
  public.current_role() = 'tutor' and exists(select 1 from public.question_sets s where s.id = question_set_id and s.created_by = auth.uid() and s.status in ('draft','pending_review'))
) with check (
  public.current_role() = 'tutor' and exists(select 1 from public.question_sets s where s.id = question_set_id and s.created_by = auth.uid() and s.status in ('draft','pending_review'))
);
create policy "admin manages questions" on public.questions for all to authenticated using (public.current_role() = 'admin') with check (public.current_role() = 'admin');

create policy "student reads own attempts" on public.exam_attempts for select to authenticated using (student_id = auth.uid() or public.current_role() = 'admin');
create policy "student submits own attempts" on public.exam_attempts for insert to authenticated with check (student_id = auth.uid() and public.current_role() = 'student' and public.is_approved());
create policy "student updates own unsubmitted attempt" on public.exam_attempts for update to authenticated using (student_id = auth.uid() and submitted_at is null) with check (student_id = auth.uid());

create policy "approved users read class sessions" on public.class_sessions for select to authenticated using (public.is_approved());
create policy "tutors manage own sessions" on public.class_sessions for all to authenticated using (tutor_id = auth.uid() and public.current_role() = 'tutor') with check (tutor_id = auth.uid() and public.current_role() = 'tutor');
create policy "admin manages sessions" on public.class_sessions for all to authenticated using (public.current_role() = 'admin') with check (public.current_role() = 'admin');
create policy "enrolled students read own enrolments" on public.class_enrolments for select to authenticated using (student_id = auth.uid() or public.current_role() = 'admin');

create policy "participants read messages" on public.messages for select to authenticated using (sender_id = auth.uid() or recipient_id = auth.uid() or public.current_role() = 'admin');
create policy "send own messages" on public.messages for insert to authenticated with check (sender_id = auth.uid() and public.is_approved());
create policy "read own notifications" on public.notifications for select to authenticated using (recipient_id = auth.uid() or public.current_role() = 'admin');
create policy "mark own notifications read" on public.notifications for update to authenticated using (recipient_id = auth.uid()) with check (recipient_id = auth.uid());
create policy "read own subscriptions" on public.subscriptions for select to authenticated using (student_id = auth.uid() or public.current_role() = 'admin');

-- Production hardening checklist:
-- * Add a secure signup trigger that creates a student profile with role='student', approval='pending'.
-- * Do not permit users to update role/approval columns themselves; split editable profile fields
--   from privileged columns or use a tightly scoped trigger/RPC.
-- * Add tutor/course/class membership checks to messages and storage bucket policies.
-- * Keep service-role credentials, payment secrets, AI keys and video tokens server-side only.
-- * Test every policy with student, tutor, pending, suspended and admin test accounts.
