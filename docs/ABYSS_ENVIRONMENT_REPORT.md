# ABYSS_ENVIRONMENT_REPORT.md
Дата: 08.11.2026. Окружение: OpenCode Mobile → Linux userspace (aarch64), Ubuntu 24.04.5 PRoot дистро.

## 1. Система
| Параметр | Значение |
|---|---|
| Architecture | aarch64 (ARM64), 8 ядер |
| Ядро | 6.6.118-android15-8 (pocof7_USER, Android 15) |
| OS | Ubuntu 24.04.5 LTS (noble), PRoot-Distro |
| RAM | 10 GiB visible (POCO F7 ~12 GB физически; 7.1 used, 3.7–3.9 available), swap 11 GiB |
| Диск / | 479G total, 126G свободно |
| Сеть | GitHub: OK (200), Godot CDN: OK, ambientCG API: OK, Poly Haven API: OK |
| Пользователь GitHub | xexqq (11 публичных репо, репозитория ABYSS нет) |

## 2. Инструменты — было до старта
| Инструмент | Статус | Версия | ARM64+PRoot совместимость |
|---|---|---|---|
| Git | ✓ | 2.43.0 | OK |
| FFmpeg | ✓ | 6.1.1-3ubuntu5 | OK |
| Python 3 | ✓ | 3.12.3 | OK |
| pip | ✗ → ✓ | 26.2.2 (установлен apt python3-pip) | OK |
| Node.js | ✓ | 18.19.1 | OK |
| curl | ✓ | 8.5.0 aarch64 | OK |
| zip/unzip | ✓ | Info-ZIP | OK |
| Godot Engine | ✗ → частично | 4.7.2-stable arm64 (установлен в /root/opt/godot) | КРАШ: см. ниже |
| Blender | ✗ | — | Официальные сборки только x86_64 — НЕ устанавливать (по правилу md) |
| OpenJDK (Java 17) | ✗ | — | Специально не установлен: сборка APK переехала на CI (п.12 md) |
| Android SDK / Build Tools / cmdline-tools / platform-tools | ✗ | — | Специально не установлен: NOT требуется локально (сборка = GH Actions) |
| NDK/CMake | ✗ | — | Не требуется для APK-экспорта без gradle build |

## 3. Проблемы совместимости (проверено, не догмы)
### 3.1 Godot редактор не запускается в PRoot — КРАШ
- Установлены официальные ARM64 билды 4.7.2-stable и 4.6.3-stable.
- Симптом: `godot --version` OK, но любой запуск фазы редактора (--import, --editor) Immediately падает: `double free or corruption` (glibc heap, поток-воркер, обнаружено через gdb backtrace). Одинаково на 4.6.3 и 4.7.2; не зависит от проекта (пустой проект тоже падает); не связано с root-warning, locale, ICU, audio.
- Вывод: официальные Godot-бинарники не совместимы с данным PRoot/ядром на этапе редакторного пулов памяти.
- Решение по md (п.1 «предложи альтернативу»): вся редакторская работа на CI (GitHub Actions x64) — там Godot 4.7.2 официальная сборка Linux x86_64 работает штатно. Локально: файлы проекта редактируются напрямую (GDScript/сцены — текстовые). Локальный headless запуск игр не используем.
- (Альтернатива на будущее: сборка Godot из исходников под aarch64 в дистре — ~40–60 мин на 8 ядрах; предложу отдельно, если локальная валидация станет нужна.)

### 3.2 Sketchfab / Smithsonian API заблокированы из сети этого устройства (403/Cloudflare)
- Решение: каталог Sketchfab-моделей составлен, но каждая модель должна быть проверена браузером (лицензия-бейдж на странице) или через следующую сессию. В plan — только уже верифицированные одной из двух связок или те, что позволяют прямые ссылки.

### 3.3 Freesound: полные WAV только для залогиненных
- Каталог CC0-звуков составлен; скачивание через браузер (логин бесплатный) — потом file в repo.

### 3.4 Kenney сайт с bot-блоком (403)
- Mодульный cave kit взят с официального зеркала на OpenGameArt (та же CC0 лицензия, прямая ссылка). Зеркало перед использованием проверено.

### 3.5 GitHub: создание нового репозитория через MCP API заблокировано
- Ошибка: «Due to U.S. trade controls law restrictions, we are unable to provide this access to this API» ( górничие на выдачу requests за content for new repos via API с текущей сетевой точки).
- Но: существующие репо читаются/пишутся (MCP) — create file/push работает с уже существующим репо.
- Решение: создать пустой приватный репозиторий `ABYSS` вручную (github.com/new → name: ABYSS, Private, БЕЗ README) — 1 минута; далее всё уже готово: файлы и workflow лежат в /root/ABYSS и защёлняются через MCP сразу после создания репо.

## 4. Что удалось установить
1. Godot 4.7.2-stable (ARM64): установлен в /root/opt/godot, линк /root/bin/godot — CLI (-version/--help) работает; редакторные фазы — нет (см 3.1).
2. pip 26.2.2 (python3-pip) для будущих скриптов обработки ресурсов.
3. 39 Godot Skills (прошлая задача) — доступны OpenCode на новой сессии.

## 5. Что не удалось установить и почему
| Что | Почему | Альтернатива |
|---|---|---|
| Godot редактор (локально в PRoot) | heap corruption в редакторной фазе (тёплая проблема окружения) | CI Godot (x64) — импорт+экспорт+испытания в Actions |
| Blender | Официально нет aarch64 Linux билдов | Модели брать сразу в GLB/FBX (Godot 4.x FBX импортируется нативно через ufbx); конвертации в CI (x64) при необходимости |
| OpenJDK + Android SDK локально | По п.12 md: локальную сборку APK НЕ использовать | GitHub Actions (готовый workflow) |
| Sketchfab/Smithsonian системные API | 403 из этой сети | Ручная проверка страниц в браузере / следующая сессия |

## 6. Как выполняется Android-сборка
- Весь конвейер: `.github/workflows/android-build.yml` (см. ABYSS_GITHUB_BUILD_REPORT.md).
- Runner: ubuntu-latest x64; Java 17 Temurin; SDK platform-34 + build-tools 34.0.0; Godot 4.7.2 ubuntu x64 + выгруженные export templates 4.7.2; headless import → экспорт `ABYSS Android` (ARM64-v8a, APK) с debug-keystore, который генерируется на runner'е и НЕ коммитится; проверки непустого APK; artifact ABYSS-Android-debug-APK.

## 7. Итоговая готовность среды
- Кель: структура проекта создана (см. ниже), проект.godot (Godot 4.7, Mobile renderer, landscape lock, com.xex.abyss), export_presets.cfg (пресет «ABYSS Android», только ARM64), workflow CI готов.
- Ресурсы первой необходимости — загружены (см. ABYSS_STORAGE_REPORT.md).
- Блокер для сборки: ручное создание пустого репозитория ABYSS на GitHub (ограничение GitHub API, 1 минута для пользователя).
