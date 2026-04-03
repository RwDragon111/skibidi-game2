-- Запусти этот SQL целиком в Supabase SQL Editor.
create table if not exists public.profiles (
  nickname text primary key,
  password_hash text not null unique,
  avatar_data text not null default '',
  created_at timestamptz not null default now()
);

create table if not exists public.attempts (
  id bigint generated always as identity primary key,
  nickname text not null references public.profiles(nickname) on delete cascade,
  target integer not null check (target in (10,20,30,67)),
  time_seconds numeric(10,1) not null default 0,
  camera_hits integer not null default 0,
  skibidi_hits integer not null default 0,
  poop_hits integer not null default 0,
  success boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists attempts_mode_success_idx on public.attempts (target, success, time_seconds, camera_hits);
create index if not exists attempts_nickname_idx on public.attempts (nickname, created_at desc);

alter table public.profiles enable row level security;
alter table public.attempts enable row level security;

drop policy if exists "profiles_select_all" on public.profiles;
drop policy if exists "profiles_insert_all" on public.profiles;
drop policy if exists "profiles_update_all" on public.profiles;
drop policy if exists "attempts_select_all" on public.attempts;
drop policy if exists "attempts_insert_all" on public.attempts;

create policy "profiles_select_all"
on public.profiles for select
to anon
using (true);

create policy "profiles_insert_all"
on public.profiles for insert
to anon
with check (true);

create policy "profiles_update_all"
on public.profiles for update
to anon
using (true)
with check (true);

create policy "attempts_select_all"
on public.attempts for select
to anon
using (true);

create policy "attempts_insert_all"
on public.attempts for insert
to anon
with check (true);
