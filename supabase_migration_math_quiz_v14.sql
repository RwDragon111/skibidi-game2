-- Без потери данных: добавляем поддержку второй игры "Математический квиз".
alter table if exists public.attempts
  add column if not exists game_key text not null default 'skibidi';

alter table if exists public.attempts
  add column if not exists difficulty text;

update public.attempts
set game_key = 'skibidi'
where game_key is null or game_key = '';

create index if not exists attempts_game_mode_idx
  on public.attempts (game_key, target, success, time_seconds, camera_hits);

create index if not exists attempts_game_diff_mode_idx
  on public.attempts (game_key, difficulty, target, success, time_seconds, camera_hits);
