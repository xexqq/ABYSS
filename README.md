# ABYSS — PHOBIA EXPERIENCE

Реалистичная 3D-игра на Godot 4.x (GDScript) для Android. Первая фаза — симуляция талассофобии (страх глубины и открытой воды); в дальнейшем — другие фобии отдельными модулями.

Целевое устройство: POCO F7 (Snapdragon 8s Gen 4, 12 GB RAM), ARM64-v8a, рендерер Godot **Mobile**.

## Структура

- `addons/` — Godot-плагины (поведение животных: Beehave **или** LimboAI — выбран один)
- `assets/models/` — GLB (fish, sharks, whales, deep_sea, corals, plants, rocks, caves, wrecks, environment)
- `assets/textures/|materials/|shaders/|animations/|audio/|particles/|effects/|ui/`
- `scenes/`, `scripts/`, `resources/`, `tests/`, `docs/`
- `build/` — артефакты APK (gitignored)

## Сборка APK

APK собирается **только через GitHub Actions** (на телефоне сборка не выполняется):

`Actions → ABYSS Android Build → Run workflow`

- Пакет: `com.xex.abyss`
- Ориентация: Landscape
- Подпись: debug-keystore (генерируется на runner'е во временной папке, не коммитится)
- Артефакт: `ABYSS-Android-debug-APK`

## Лицензии

Все сторонние ресурсы — CC0 / CC BY / CC BY-SA с проверенной лицензией конкретного файла. Реестр: `ASSET_LICENSES.md` (заполняется при каждом скачивании).


## Как играть (тип 1)
- Левая зона — динамический джойстик движения.
- Правая зона — свайп для обзора.
- ▲/▼ — всплытие/погружение, ‖ — пауза.
- Глубина отображается внизу; зоны: Surface → Reef → Open Ocean → Twilight.
