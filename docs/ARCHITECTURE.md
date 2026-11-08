# ARCHITECTURE

## Принципы
- Ядро игры (загрузка/настройки/аудио) отделено от игровых модулей (фобий).
- Модуль талассофобии = сцена `scenes/game.tscn` + оркестратор `scripts/core/game.gd`.
- Связь ТОЛЬКО через сигналы и публичные API нод; никаких прямых обращений к чужим нодам из глубины систем.
- `class_name` не используется для межскриптовых ссылок (ранний парсинг CI) — только preload-константы.

## Дерево (сцена Game, строится в _ready)
```
Game (Node3D, game.gd)
├─ World (Node3D)
│  └─ OceanEnvironment (террейн MultiMesh-скалы, вода, солнце, wreck и т.д.)
├─ Systems
│  ├─ UnderwaterRendering (Environment+Sun по глубине)
│  └─ DepthManager (сигнал depth_changed, зоны)
├─ Player (CharacterBody3D, player_controller.gd)
│  └─ Camera (Camera3D, camera_controller.gd)
├─ TouchControls (CanvasLayer, мульти-тач input)
└─ UIManager (CanvasLayer, HUD + пауза)
```
Автозагрузки: SettingsManager, AudioManager.

## Сигналы (граф данных)
TouchControls.move/ascend/descend/look/pause → Game → Player/Camera/UI.
DepthManager.depth_changed → UIManager.set_depth, UnderwaterRendering.set_depth, AudioManager.set_depth_factor.

## Точки расширения (будущие фобии)
- Новый модуль = новая сцена + оркестратор, реиспользует SettingsManager/AudioManager/TouchControls/UnderwaterRendering.
- Качество: SettingsManager.QUALITY_PROFILES (реальные значения: тени, туман, scatter_mult, view_distance).
