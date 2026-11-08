# ABYSS_GITHUB_BUILD_REPORT.md
Дата: 08.11.2026

## Статус: ОФОРМЛЕНО ЛОКАЛЬНО, ЗАБЛОКИРОВАНО НА СОЗДАНИИ РЕПОЗИТОРИЯ

## 1. Репозиторий
- Аккаунт: **xexqq** (проверено через GitHub MCP).
- Существующий репозиторий ABYSS: **НЕТ** (просмотрены все 11 репо — дублей нет).
- Создать через MCP API невозможно: GitHub возвращает ошибку `Due to U.S. trade controls law restrictions, we are unable to provide this access to this API` — блокировка на создание новых репо через API с текущей сетевой точки (при этом существующие репозитории читаются/пишутся вполне нормально).
- **Что нужно от тебя (1 минута):**
  1. открыть https://github.com/new
  2. Repository name: `ABYSS`
  3. Visibility: Private
  4. НЕ добавлять README/gitignore/license (иначе конфликт с первым push)
  5. нажать Create repository
  После этого скажи мне «репо же создан» — я запушу все файлы и запущу workflow в той же сессии.

## 2. Локальный проект (готов к push) — /root/ABYSS
```
.github/workflows/android-build.yml   # CI сборка APK
assets/ (модели GLB/GLTF+текстуры PBR 1K/HDRI/аудио OGG+WAV)
addons/  scenes/  scripts/  resources/  tests/  docs/
project.godot          # Godot 4.7, Mobile renderer, landscape, icon
export_presets.cfg     # пресет "ABYSS Android": ARM64-v8a, APK, com.xex.abyss
ASSET_LICENSES.md      # реестр лицензий
README.md  .gitignore
git-место: /root/ABYSS (локальная папка; 196 MB, .git инициализировать буду при push)
```

## 3. Workflow `.github/workflows/android-build.yml`
- Запуск: `workflow_dispatch` + `push→main`
- Runner: ubuntu-latest
- Проверки: `project.godot` существует; пресет «ABYSS Android» найден
- Java 17 (Temurin, setup-java)
- Android SDK: `platforms;android-34`, `build-tools;34.0.0`, `platform-tools`, лицензии
- Godot: официальный релиз `4.7.2-stable` linux x86_64 (`--version` проверка)
- Export Templates: `Godot_v4.7.2-stable_export_templates.tpz` → `~/.local/share/godot/export_templates/4.7.2.stable/` (соответствие версий гарантировано: template и Godot из одного релиза)
- `--headless --import` (импорт ресурсов; лог сохраняется)
- Проверка «нет критических SCRIPT ERROR / Parse Error» (по логу)
- debug-keystore: keytool генерирует `/tmp/keys/debug.keystore` НО НЕ коммитится; пресет получает keystore через sed-подстановку в CI-шаге
- `--headless --export-debug "ABYSS Android" build/ABYSS.apk`
- Верификация APK: существует, >3 MB, есть .so/AndroidManifest
- Артефакт: `ABYSS-Android-debug-APK`
- Инфо-логи при неудаче: import.log/export.log отдельным artifact

## 4. Настройки PHP Android Export Preset
| Параметр | Значение |
|---|---|
| Имя пресета | ABYSS Android |
| Формат | APK (для тестирования) |
| Архитектура | ARM64-v8a (единственная) |
| Package ID | com.xex.abyss |
| Название приложения | ABYSS — PHOBIA EXPERIENCE |
| Категория | Games |
| Ориентация | Landscape (project.godot: window/handheld/orientation=0) |
| Min Android | зависит от Godot 4.7 (по умолчанию пресета — Gradle-min); совместимо с SDK 34 розвитfmt |
| Рендер | Godot Mobile renderer (project.godot) |
| Подпись | debug (временный keystore от runner'a), Release — ЛЮДИ, секреты в GitHub Actions Secrets |
| Immersive mode | on |

## 5. Результат тестовой сборки
- НЕ запущена: репозитория ещё нет → тестовой GitHub Actions Run нет.
- Согласно п.12.7 md: поскольку проект ещё не содержит полноценной игры (нет сцен — я CHECKем проверить, будет ли сборка успешной уже после создания репо — там обработка файла проекта с одним `project.godot` обычно собираёт валидный- пустой APK; скорее всего удастся проверить SATISFY).
- Обещание: НЕ заявлять об успешном APK верифably до фактического зеленого Run.

## 6. Что требуется для Release (будущее)
- GitHub Actions Secrets: `KEYSTORE` (base64), `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`
- Workflow-release-release-вариант (exclusion выброс/release-notes/прик статически)
- Пока НЕ настраиваю (п.12.6 md: «пока не публикуй релиз автоматически»)

## 7. Источник GitHub-офиса:
- Godot release: https://github.com/godotengine/godot/releases/tag/4.7.2-stable
- Export Docs: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
