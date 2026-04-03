1) GitHub Pages
- Загрузи в репозиторий эти файлы:
  - index.html
  - supabase_setup.sql
  - fart-with-reverb.mp3
  - Звук сигнализации из-за ограбления.mp3
- В GitHub: Settings -> Pages -> Deploy from a branch -> main -> /(root)

2) Supabase
- Создай новый project
- Открой SQL Editor
- Создай новый query
- Вставь туда весь файл supabase_setup.sql
- Нажми Run

3) Где взять данные для подключения
- В Supabase открой Project Settings / API
- Скопируй:
  - Project URL
  - anon public key

4) Первый запуск сайта
- Открой сайт на GitHub Pages
- Появится окно "Подключение Supabase"
- Вставь туда:
  - Project URL
  - anon public key
- Нажми "сохранить и проверить"

5) Дальше игра работает уже через Supabase:
- общий пароль: "я скибиди" или "яскибиди"
- потом игрок вводит ник и личный пароль
- лидерборд и профили будут общими для всех

Важно:
- Это простая браузерная версия без отдельного сервера.
- Для простоты браузер работает через anon public key.
- service_role key в браузер вставлять нельзя.
