# ABYSS_DOWNLOAD_PLAN.md
Дата: 08.11.2026. Правило: A — скачиваем теперь; B/C — только с твоего подтверждения.

## Категория A — Обязательно (без этого разработка не начнут)
| # | Ресурс | Источник | Формат | Лицензия | Размер арх.|.Size распак.| Анимации | Полигоны | Текс | Godot | Мобил. | Конверт.? |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| A1 | Quaternius LowPoly Fish Pack (7 глб) | trebeljahr/quaternius-showcase mirror → /root/ABYSS assets/models/{fish,sharks,whales} | GLB | CC0 | н/д (GLB в git) | 520 KB | ✅ swim | 0.5–1.5k tris | vertex-blend | 4.x | YES | нет |
| A2 | Kenney Modular Cave Kit 1.0 | kenney.nl → зеркало OGA direct zip | GLB | CC0 | 6.7 MB | 6.5 MB | нет | 0.6–3k tris/блок | 1 карта/блок | 4.x | YES | нет |
| A3 | dutch_ship_medium GLTF 2K | polyhaven.com/a/dutch_ship_medium | GLTF+bin+jpg | CC0 | (по сетям) | 27 MB | нет | 69k tris | 2K PBR | 4.x | hero → оптимизировать | нет/LOD позже |
| A4 | rock_face_01 + rock_face_02 GLTF 2K | polyhaven.com | GLTF+bin+jpg | CC0 | — | 17.5 MB | нет | 20k/29k | 2K PBR | 4.x | YES (модульные) | нет |
| A5 | modular_industrial_pipes_01 GLTF 2K | polyhaven.com | GLTF+bin+jpg | CC0 | — | 20 MB | нет | 12k | 2K PBR | 4.x | YES (модульные) | нет |
| A6 | Ocean Trio.fbx | opengameart (CC0) | FBX | CC0 | 3.8 MB | 4 MB | нет | низк | 1 tex | 4.7 нативно FBX | YES | нет |
| A7 | ambientCG 1K-JPG ×12 (Ground054/060/101, Rock035/041/059, Rust008, Metal041B, Planks038, CorrugatedSteel008A, Moss001, WoodSiding002) | ambientcg.com (direct zip API) | JPG PBR zip | CC0 | 81 MB | ~90 MB | — | — | 1K | 4.x | YES | нет |
| A8 | Poly Haven textures 1K ×12 (sand_01, coral_gravel, coral_ground_02, coast_sand_rocks_02, rocky_terrain_03, rusty_metal_02, weathered_planks, mossy_brick, brown_mud_02, shell_floor_01, rock_face_03, cliff_side) | polyhaven API direct | JPG PBR | CC0 | — | ~31 MB | — | — | 1K | 4.x | YES | нет |
| A9 | Poly Haven HDRI 1K ×3 (tucker_wreck, fish_hoek_beach, secluded_beach) | polyhaven API direct | HDR | CC0 | ~3 MB | 4.5 MB | — | — | — | 4.x | только как skybox/tint | нет |
| A10 | OGA аудио: deep_rumble.ogg, underwater_engine.ogg, bubbles.ogg, bubbles-loop1.wav | opengameart direct | OGG/WAV | CC0 | ~1.9 MB | 2 MB | — | — | — | 4.x | YES | loops — loop=true в Godot |

**Статус категории A: ВСЁ СКАЧАНО (загружено в /root/ABYSS/assets). 185 MB (реально).**

## Категория B — Желательно (первая полноценная версия; загрузить после твоего «окей»)
| # | Ресурс | Источник | Лицензия | Ожид. объём | Примечание |
|---|---|---|---|---|---|
| B1 | Freesound CC0 звуки (7 категорий: whale/close, dolphins, deep creature, drone, cave, metal creak, sonar) | freesound.org — прямые ссылки в ASSET_LICENSES.md | CC0 | ~30–80 MB (WAV→OGG усечение) | нужен через браузер с логином; конвертация в OGG |
| B2 | Innerscene 3D Parts (clow/t turtle/manta/dolphin/octopus whale humpback GLB) | innerscene.com direct API | CC0 | ~5 MB | КАЧЕСТВО не проверено (AI-процедурная геометрия, 16–18 KB GLB) — нужна ручная проверка в Godot / URI |
| B3 | Поли Pizza CC BY 3.0 (jellyfish ×2, squid/giant squid, anglerfish, sea-turtle variants) | poly.pizza | CC BY 3.0 (атрибуция!) | ~5–15 MB | проверить каждую страницу; прямые GLB из CDN |
| B4 | Polyy.AI 3D Fish Pack (25 GLB с LOD 2.2–7.7k) | polyyai.itch.io/3d-fish-pack | CC0 | ~20–40 MB | AI-generated (CC0-разрешение проверено) |
| B5 | Kenney Modular Space Kit + Factory Kit | kenney.nl (или зеркало OGA) | CC0 | ~30–80 MB | руины станции/завода |
| B6 | Poly Haven dutch_ship_large_01 (hero wreck) | polyhaven | CC0 | ~40 MB (2k) | после decimation hero |
| B7 | Quaternius Sea Monster Scene + Tentacles | poly.pizza (CDN GLB) | CC0 | ~3–8 MB | основа «неизвестного существа» |
| B8 | Godot Android ICONS/заглушки + UI HUD наборы | kenney UI packs | CC0 | ~10 MB | mobile theme |

## Категория C — Позже
| # | Ресурс | Источник | Лицензия | Примечание |
|---|---|---|---|---|
| C1 | Sketchfab CC0/CC BY low-poly aquarium-наборы (coral, anemone, sponges, kelp) | sketchfab (фильтры в каталоге ниже) | CC0/CC BY | проверять каждую модель; главное — реалистичные кораллы в CC0 почти отсутствуют — предупреждаю честно |
| C2 | Smithsonian 3D CT-сканы (mollusk/coral) | 3d.si.edu | CC0/Open Access | 5–50M tris — нужен heavy decimation; морфология-референс только |
| C3 | Coastral cliff → после decimation (coastal_cliff_01 865k tris) | polyhaven | CC0 | источник массива рифа |
| C4 | Полная стая биолюминесценции-скада: любой простой барreleye/viperfish — НЕТ в свободном доступе под имя | — | — | честный вывод: собирается из anglerfish.preview (Quaternius/PollYY) + emissive shader |
| C5 | Epic ambient doom наборы | freesound CC0 | CC0 | «страшные» слои |

## Правило загрузки (напминить)
1. Ты выбираешь категории B/C и говоришь «окей B1, B4...
2. Я качаю ТОЛЬКО выбранные; проверяю лицензию; конвертирую если нужно (OGG/WAV; FBX нативно).
3. Записываю в ASSET_LICENSES.md.
4. Общий контроль: df -h (126 GB free — запас гигантский).

## Приоритеты для первой играбельной версии ABYSS (минимальный mesh-набор)
1. Стая рыб + swim (A1 ✅)
2. Дно/скалы (A3 ship + A4 rocks + A7/A8 textures ✅)
3. Модульный релиф + пещеры (A2 ✅ + A4)
4. Обломки/трубы (A3 ✅ + A5 ✅)
5. Звуки: ambient (A10 ✅) + биологич. (B1 — только с логина)
6. Fish FBX вариант (A6 ✅)
7. Дельф/кит/манта/акула GLB swim (A1 ✅)
