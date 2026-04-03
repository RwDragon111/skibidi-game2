-- Миграция без потери текущих данных: добавляет бан/разбан и улучшения для модератора.
-- Обновление текущей базы для версии с модератором.
alter table if exists public.profiles drop constraint if exists profiles_password_hash_key;
alter table public.profiles add column if not exists account_code text;
alter table public.profiles add column if not exists is_moderator boolean not null default false;
alter table public.profiles add column if not exists is_banned boolean not null default false;
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

insert into public.profiles (nickname, password_hash, avatar_data, account_code, is_moderator, is_banned)
values (
  'rwdragon',
  '9c9109b3ee9008f84873e7ee235d2d9fd668971e25d7a2f8daa316a0459b3b3e',
  '',
  public.generate_account_code(),
  true,
  false
)
on conflict (nickname) do update
set password_hash = excluded.password_hash,
    is_moderator = true,
    is_banned = false,
    account_code = coalesce(public.profiles.account_code, excluded.account_code);

drop policy if exists "attempts_delete_all" on public.attempts;
create policy "attempts_delete_all"
on public.attempts for delete
to anon
using (true);