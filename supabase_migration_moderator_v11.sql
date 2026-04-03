-- Безопасное обновление базы до v11 без потери текущих данных.
-- Что делает:
-- 1) сохраняет все текущие профили и попытки
-- 2) гарантирует уникальность ника
-- 3) делает каскадное удаление попыток при удалении аккаунта
-- 4) добавляет служебные поля, если их ещё нет
-- 5) оставляет модератора rwdragon активным

alter table if exists public.profiles
  add column if not exists account_code text,
  add column if not exists is_moderator boolean not null default false,
  add column if not exists is_banned boolean not null default false,
  add column if not exists avatar_data text not null default '';

create unique index if not exists profiles_nickname_unique_idx on public.profiles (nickname);
create unique index if not exists profiles_account_code_idx on public.profiles (account_code) where account_code is not null;

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

do $$
begin
  if exists (
    select 1
    from information_schema.table_constraints
    where constraint_schema = 'public'
      and table_name = 'attempts'
      and constraint_name = 'attempts_nickname_fkey'
  ) then
    alter table public.attempts drop constraint attempts_nickname_fkey;
  end if;
exception when others then null;
end $$;

do $$
begin
  alter table public.attempts
    add constraint attempts_nickname_fkey
    foreign key (nickname) references public.profiles(nickname) on delete cascade;
exception when duplicate_object then null;
end $$;

create index if not exists attempts_mode_success_idx on public.attempts (target, success, time_seconds, camera_hits);
create index if not exists attempts_nickname_idx on public.attempts (nickname, created_at desc);

-- оставляем модератора активным
update public.profiles
set is_moderator = true,
    is_banned = false
where nickname = 'rwdragon';
