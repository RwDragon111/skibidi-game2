-- Полная настройка / обновление базы для версии с модератором.
alter table if exists public.profiles drop constraint if exists profiles_password_hash_key;

do $$ begin
  create table if not exists public.profiles (
    nickname text primary key,
    password_hash text not null,
    avatar_data text not null default '',
    created_at timestamptz not null default now()
  );
exception when others then null;
end $$;

alter table public.profiles add column if not exists account_code text;
alter table public.profiles add column if not exists is_moderator boolean not null default false;

do $$ begin
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
exception when others then null;
end $$;

create index if not exists attempts_mode_success_idx on public.attempts (target, success, time_seconds, camera_hits);
create index if not exists attempts_nickname_idx on public.attempts (nickname, created_at desc);
create unique index if not exists profiles_account_code_idx on public.profiles(account_code) where account_code is not null;

create or replace function public.generate_account_code() returns text
language plpgsql
as $$
declare
  v_code text;
begin
  loop
    v_code := lpad((floor(random()*1000000))::int::text, 6, '0');
    exit when not exists(select 1 from public.profiles where account_code = v_code);
  end loop;
  return v_code;
end;
$$;

update public.profiles
set account_code = public.generate_account_code()
where account_code is null or account_code !~ '^\d{6}$';

-- создаём или обновляем модератора
insert into public.profiles (nickname, password_hash, avatar_data, account_code, is_moderator)
values (
  'rwdragon',
  '9c9109b3ee9008f84873e7ee235d2d9fd668971e25d7a2f8daa316a0459b3b3e',
  '',
  public.generate_account_code(),
  true
)
on conflict (nickname) do update
set password_hash = excluded.password_hash,
    is_moderator = true,
    account_code = coalesce(public.profiles.account_code, excluded.account_code);

alter table public.profiles enable row level security;
alter table public.attempts enable row level security;

drop policy if exists "profiles_select_all" on public.profiles;
drop policy if exists "profiles_insert_all" on public.profiles;
drop policy if exists "profiles_update_all" on public.profiles;
drop policy if exists "attempts_select_all" on public.attempts;
drop policy if exists "attempts_insert_all" on public.attempts;
drop policy if exists "attempts_delete_all" on public.attempts;

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

create policy "attempts_delete_all"
on public.attempts for delete
to anon
using (true);