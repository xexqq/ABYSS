# ABYSS_GITHUB_BUILD_REPORT.md
Дата: 08.11.2026

## Статус: ✅ УСПЕШНАЯ СБОРКА APK В GITHUB ACTIONS

## 1. Репозиторий — ГОТОВО
- URL: **https://github.com/xexqq/ABYSS** (public, ветка `main`).
- Создан пользователем вручную (создание репо через MCP API заблокировано — U.S. trade controls).
- Push выполнен локально через git HTTPS + PAT из opencode.json (токен не логировался, remote после push удалялся).
- Содержимое: `project.godot`, `export_presets.cfg`, `.github/workflows/android-build.yml`, `assets/`, `docs/`, `ASSET_LICENSES.md`, `README.md`, `.gitignore` — **232 файла**.

## 2. Коммиты
- `84a482f` Initial ABYSS project: Godot 4.7 scaffold, CC0 assets, Android export preset, CI workflow (232 файла).
- `70487e1` CI fix: add cmdline-tools to PATH for sdkmanager.
- `5532afe` Enable ETC2/ASTC VRAM texture compression (required for Android export).

## 3. Прогоны CI (workflow_dispatch + push)
| Run | Результат | Причина | Решение |
|-----|-----------|---------|---------|
| 42434548140 | ❌ failure | `sdkmanager: command not found` (exit 127) — cmdline-tools не в PATH на раннере | добавлен `export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"` |
| 42507949539 | ❌ failure | Godot: `ETC2/ASTC texture compression is required for Android export` — APK не создан | в `project.godot` добавлено `textures/vram_compression/import_etc2_astc=true` |
| **42508181982** | ✅ **success** | — | APK собран и загружен артефактом |

Логи: https://github.com/xexqq/ABYSS/actions/runs/42508181982
Job: `build-apk` — все шаги прошли (checkout → YAML-check → Java 17 Temurin → Android SDK → Godot 4.7.2 x64 → templates 4.7.2 → `--import` (0 SCRIPT ERROR) → keytool debug-keystore → sed-keystore в пресет → `--export-debug "ABYSS Android"` → verify → artifact).

## 4. Результат сборки
- **APK: `build/ABYSS.apk`, 277 994 073 байт (~265 МБ)** — debug, ARM64-v8a, `com.xex.abyss` (`Application/com.xex.abyss`).
- Артефакт: **`ABYSS-Android-debug-APK`** (zip ~274,99 МБ):
  https://github.com/xexqq/ABYSS/actions/runs/42508181982 → раздел Artifacts (нужен вход в GitHub).
- Внутри APK: `lib/arm64-v8a/libgodot_android.so`, AndroidManifest — проверено `unzip -l` на раннере.
- Размер большой из-за включённых в PCK CC0-моделей/текстур Poly Haven (dutch_ship 69k tris, HDRI) — это норма для first build; оптимизация позже.

## 5. Технические заметки (для будущих правок)
- Keystore: debug-keystore генерируется `keytool` в CI (`/tmp/keys/debug.keystore`, pass `android`) и подключается в `export_presets.cfg` через sed — в отсутствии релизного ключа.
- Импорт Godot в CI: `--headless --import` прошёл БЕЗ SCRIPT ERROR/Parse Error (проверка grep в workflow).
- Локальный Godot-редактор в PRoot по-прежнему крашится (double free) — вся валидация идёт в CI; локально CLI работает.
- Git: при `gc --aggressive` в PRoot повредились объекты (PRoot mmap-особенность) — рабочий коммит восстановлен пересозданием репозитория поверх рабочей папки; для локального .git лучше не запускать aggressive gc.

## 6. Что дальше
- Скачать APK из артефакта (логин в GitHub) и поставить на POCO F7 для smoke-теста.
- Оптимизация ассетов (слишком тяжёлые PCK) — отдельная задача.
- Разработка первой игровой сцены — ТОЛЬКО после твоего разрешения.

## 7. Фикс запуска на устройстве (08.11.2026, вечер)
- Симптом: «ERROR! Unable to setup the Godot engine! Aborting...» при запуске APK.
- Причина: не задана главная сцена — Godot прерывает setup на Android при отсутствии main scene (подтверждено issue godotengine/godot#86565).
- Фикс: добавлена placeholder-сцена `scenes/main.tscn` (тёмный фон + Label «ABYSS — PHOBIA EXPERIENCE / Boot scene»), в `project.godot` прописан `run/main_scene="res://scenes/main.tscn"`. Коммит `01e026e`.
- Результат: Run 42510623495 ✅ success — новый APK в артефакте `ABYSS-Android-debug-APK` (https://github.com/xexqq/ABYSS/actions/runs/42510623495).
- ВАЖНО: debug-keystore генерируется заново на каждый run → перед установкой нового APK **сначала удалить старый** (иначе Android откажет: подпись не совпадает).
