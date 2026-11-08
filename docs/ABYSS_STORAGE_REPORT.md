# ABYSS_STORAGE_REPORT.md
Дата: 08.11.2026

## Диск и память
| Метрика | Значение |
|---|---|
| Диск всего | 479 GB |
| Диск занято (до скачиваний) | 353 GB |
| Диск свободно | 126 GB |
| RAM устройства | 12 GB (Telegram-PRoot видит ~10 GiB, доступно ~3.9 GiB) |

## Загружено в /root/ABYSS/assets (реально, проверено du)
| Категория | Объём | Содержимое |
|---|---|---|
| Модели Quaternius (7 GLB swim) | 0.5 MB | тропические рыбы ×3, дельфин, кит, манта, акула |
| Модульные пещеры Kenney (46 GLB) | ~6.5 MB (распаковано) | коридоры/комнаты/шлюзы |
| Poly Haven dutch_ship_medium (GLTF 2K + PBR) | ~27 MB | затонувший корабль (hull/rigging/sails) |
| Poly Haven rock_face_01/02 (GLTF 2K + PBR) | ~17.5 MB | скальные стены (модульные секции) |
| Poly Haven modular_industrial_pipes_01 (GLTF 2K) | ~20 MB | модульные трубы |
| Ocean Trio.fbx | 4 MB | образец рыбы на FBX (импорт уфа Godot 4.7 нативный) |
| Текстуры Poly Haven 1K (12 сетов PBR = 50 карт) | ~31 MB | песок/коралл/скалы/ржавчина/дерево/кирпич/грязь |
| Текстуры ambientCG 1K JPG (12 материалов) | ~81 MB | полные PBR наборы (color/nor/rough/AO/disp) |
| HDRI Poly Haven 1K (3 файла) | ~4.5 MB | wreck, beach, ocean light |
| Аудио OGA (4 файла) | ~2 MB | rumble loop, underwater loop, bubbles ogg+wav |
| Blender-исходники (вне git, assets/_downloads) | ~2 MB | shark, whale (риБы для конверсии будущим) |
| В проекте итого (du /root/ABYSS) | ≈196 MB | включая .git и служебные |

## Инструменты разработки (на телефоне)
| Инструмент | Размер на диске |
|---|---|
| Godot 4.7.2 arm64 редактор | 132 MB (сжатый 74 MB в zip остался) |
| pip + кэш apt (python3-pip) | ~15 MB |
| Итого инструменты | ≈150 MB |

## Различия с GitHub CI (бежевые только в облако)
- Export Templates 4.7.2 (.tpz) на CI: ~950 MB (artifact-папка runner'а ephemeral, не хранится локально).
- Android SDK components (platform-34, build-tools 34.0.0, platform-tools): ~1.5 GB на runner.

## Ожидаемый объём проекта (прогноз, для планирования запаса)
| Статья | Оценка |
|---|---|
| Текущая библиотека A | ~120 MB (уже загружена) |
| Текущий .git | ~14 MB |
| Категория B (остаток существ, звуки Freesound WAV, Innerscene, WebGL-прыг src) | 100–300 MB |
| Категория C (крупные hero-модели, decimated, скины, биоружие) | 0.5–2 GB (по согласованности) |
| .godot/ кэш импорта (локально, gitignored) | 0.3–1 GB |
| Апk сборки | 30–80 MB / артефакт |
| Итого прогноз с запасом на разработку | ~2–4 GB |

## Рекомендуемый запас
- Держать **свободными ≥ 20 GB** (тек. 126 GB — запас огромный).
- Контроль: каждые пару недель запустить `du -sh /root/ABYSS` и проверить `df -h /`.
