# ABYSS_ASSET_CATALOG.md
Дата: 08.11.2026. Реалистичный подводный хоррор, Godot 4.x, Android / Snapdragon 8s Gen 4 / Mobile renderer.
Лицензии — только те, что проверены конкректным файлом. Полный реестр: ASSET_LICENSES.md.
Загруженное отмечено ✅ (см. правила загрузки в ABYSS_DOWNLOAD_PLAN.md).

---

## 1. МОРСКИЕ СУЩЕСТВА

### Загружено (категория A)
| Существо | Модель | Лицензия | Полигоны/анимации | Путь |
|---|---|---|---|---|
| Маленькие тропические рыбы (стая) | Quaternius Fish1/2/3 (`Armature|Swim`) | CC0 | ~0.5–1.5k tris, swim ✅ | assets/models/fish/tropical_[abc]_swim.glb |
| Дельфин | Quaternius Dolphin | CC0 | swim ✅ | models/whales/dolphin_swim.glb |
| Кит | Quaternius Whale | CC0 | swim ✅ | models/whales/whale_swim.glb |
| Манта | Quaternius Manta_ray | CC0 | swim ✅ | models/sharks/manta_ray_swim.glb |
| Рифовая/большая акула | Quaternius Shark | CC0 | swim ✅ | models/sharks/shark_swim.glb |
| Образец FX набора | Ocean Trio.fbx (fish/octopus/jelly) | CC0 | FBX нативный импорт | models/fish/Ocean Trio.fbx |
| Исходники для доработки (вне git) | shark.blend, whale_0.blend (rigged+swim, 288 tris), Shark.7z | CC0 | Blender-only | assets/_downloads |

### Кандидаты, проверенные на реальных страницах (категория B — нужен твой okэй)
| Существо | Модель | Источник | Лицензия | Полигоны | Анимации | Примечание |
|---|---|---|---|---|---|---|
| Клоун | Quaternius Clownfish / Zebra Clown Fish | poly.pizza/m/769fHo3eEB, /m/6jO6q4uCdh | CC0 | ~1–2k | swim | стайные |
| Хирурги | Yellow Tang / Blue Tang (Quaternius) | poly.pizza/m/CrDlkPLon0, /m/TQaMo8GTJl | CC0 | ~1–2k | swim | точные аналоги вида |
| «Ангелы» | Moorish Idol (Quaternius) + Angelfish (Polyy.AI) | poly.pizza/m/M0UX3rVvNX; polyyai.itch.io | CC0 | 1–7.7k | swim/стат. | настоящий морской ангел в CC0 отсутствует (честно) |
| Черепаха | Loggerhead (Innerscene GLB) | innerscene.com/api/library/loggerhead-sea-turtle-0f7b7b89/download | CC0 | n/a | нет | ⚠ AI-процедурная геометрия — проверить качество |
| Медузы | Poly by Google Jellyfish ×2 | poly.pizza/m/dA5osnS0Rzj, /m/5PxIqPamrag | CC BY 3.0 | низк | нет (шейдер пульсации) | требует атрибуции |
| Осьминог | Innerscene Common Octopus / Poly Google Octopus | innerscene / poly.pizza/m/9-b6-yqrwEe | CC0 / CC BY 3.0 | низк | нет | |
| Кальмары | Giant Squid (S.Paul.Michael) + Squid ×2 | poly.pizza/m/09Uxw60zbm_, /m/aOY1Ae28E9k, /m/7zWPX7vtBXO | CC BY 3.0 | низк | нет | giant — атмосферные встречи ✨ |
| Удильщик | Quaternius Anglerfish / Poly Google / Polyy.AI | poly.pizza/m/MRjSlwCjHM, /m/85n5_RiSeSf | CC0 | 1–7.7k | swim (Quat.) | эмиссив-упрощения добавить |
| Морские драконы/бар胃肠али | N/A — в свободных лицензиях нет | — | — | — | — | решение: emissive-шейдер на anglerfish/blobfish (CC0) |
| Левиафан | Quaternius Sea Monster Scene + Tentacles ×2 | poly.pizza/m/wSlNdvboIS, /m/BR1vpIvPZvA | CC0 | сцена | частично | собирается процедурно |
| Кашалот | Sperm Whale (Poly by Google) | poly.pizza/m/e8rjQPyT1xL | CC BY 3.0 | низк | нет | |
| Горбатый кит | Innerscene Humpback Whale (GLB 4.8MB) | files.innerscene.com/... | CC0 | n/a | нет | ⚠ проверить визуально |
| Гигантский кальмар (мутант) | +Shader-эмиссия и scale | — | — | — | — | комбинация |

### Честно НЕ СУЩЕСТВУЕТ бесплатно
- Морские ангелы (Pomacanthus/императорский) в CC0.
- Биолюминесцентные виды (dragonfish/viperfish/barreleye/lanternfish) — собираются шейдером от anglerfish/blobfish.
- Черепаха/осьминог/ кальмар с АНИМАЦИЯМИ в CC0 — отсутствуют; анимировать программно (bezier-кривые, шейдер).

---

## 2. ОКРУЖЕНИЕ

### Загружено (A)
| Объект | Модель | Лицензия | Полигоны | Путь |
|---|---|---|---|---|
| Затонувший корабль (hero) | dutch_ship_medium GLTF 2K | CC0 | 69k (hull/rigging/sails) | assets/models/wrecks |
| Скальные стены | rock_face_01 (20k), rock_face_02 (29k) | CC0 | модульные секции | models/rocks/rockface01|02 |
| Трубы металл | modular_industrial_pipes_01 (12k) | CC0 | МОДУЛЬНЫЕ секции | models/environment/pipes |
| Пещеры модульные | Kenney Modular Cave Kit (46 GLB: corridors, rooms, gates, stairs, template-walls) | CC0 | 0.6–3k/блок | models/caves |

### Кандидаты (B)
| Объект | Модель | Источник | Лицензия | Полигоны | Прим. |
|---|---|---|---|---|---|
| Гигантский корабль | dutch_ship_large_01 (110k) | polyhaven.com/a/dutch_ship_large_01 | CC0 | 110k | после децимации hero |
| Корабль Large-02 / pinnace (rigged 183k) | polyhaven | CC0 | 96k/183k | hero wreck варианты |
| Cliff-массив | coastal_cliff_01 | polyhaven | CC0 | 865k ! | только после decimation |
| Валуны | rock_09 (23k), rock_07, boulder_01 (123k), Namaqualand Boulders | polyhaven | CC0 | 23–124k | scatter |
| Вулкан/базальт | Moon Rock 02–07 (6–18k) | polyhaven | CC0 | да | чёрная порода + тёмный tint |
| Бочки/ящики | barrel_01 (2.6k!), wooden_barrels_01, wooden_crate_01/02 | polyhaven | CC0 | 2–33k | scatter трюмы |
| Ракушка | lambis_shell (12k) | polyhaven | CC0 | | единственная PH-деталь с тегом coral |
| Растения | fern_02 (6k) как kelp-заготовка (tint+vertex-sway) | polyhaven | CC0 | | |
| Гроты-руины | Kenney Modular Dungeon Kit | kenney.nl/зеркало OGA | CC0 | | |
| Станция/завод | Kenney Modular Space Kit, Factory Kit | kenney.nl | CC0 | | sci-fi-регесистрально |
| Корабль low-poly | Kenney Pirate Kit / Quaternius Ships Pack | kenney/quaternius | CC0 | | стильные альтернативы |

### Реалистичные кораллы/анемоны/губки (пробел)
- Честно: полных CC0-реалистичных кораллов в Poly Haven/ambientCG/Kenney/OGA НЕТ.
- Решение: (1) Sketchfab-фильтры cc0/cc-by «coral pack» — проверять каждую вручную; (2) Smithsonian-CT-сканы (5–50M tris — need decimation); (3) процедурные кораллы в Godot (voices: shader/geometry).
- Только коралл-черепь доступно: coral_gravel, coral_ground_02 (текстуры, уже загружены).

---

## 3. ТЕКСТУРЫ PBR (загружено в assets/textures — все 1K, CC0)

### Poly Haven (polarить: Diffuse+Normal(gl)+ARM+Displacement)
sand_01 ✅, coral_gravel ✅, coral_ground_02 ✅, coast_sand_rocks_02 ✅, rocky_terrain_03 ✅, rusty_metal_02 ✅, weathered_planks ✅, mossy_brick ✅, brown_mud_02 ✅, shell_floor_01 ✅, rock_face_03 ✅, cliff_side ✅

### ambientCG (12 материалов ✅, 1K-JPG zip, полный PBR)
Ground054 (песок), Ground060, Ground101 (светл), Rock035 (чёрный/пещерный), Rock041, Rock059 (мох.камень → обрастания), Rust008 (ржавчина), Metal041B, Planks038 (дерево+), CorrugatedSteel008A, Moss001 (биоплёнка), WoodSiding002

### HDRI (загружено, CC0, 1K)
tucker_wreck ✅, fish_hoek_beach ✅, secluded_beach ✅
⚠ Настоящие underwater-HDRI в CC0 НЕ существуют (проверено полным списком тегов). Осветление — через консистентный fog-шейдер + DirectionalLight; HDRI-1K может пригодиться как skybox-пак выше воды.

## 4. ШЕЙДЕРЫ — что делаем сами (платные запрещены)
| Эффект | Реализуемость Godot 4.x Mobile | Метод (без кода) |
|---|---|---|
| Подводный туман/видимость | ДА | Environment fog_depth + density + height; volumetric fog только Forward+ (не для мобилы) |
| Цвет воды с глубиной | ДА | градиент по view-depth, синий shift |
| Солнечные лучи | ЧАСТИЧНО | конусные billboard-меши + additive (volumetric fog недоступен на mobile) |
| Каустика | ДА | 2 scroll-слоя текстуры в light() поверх дна |
| Частицы/планктон | ДА | GPUParticles3D + additive quads; CPUParticles3D фолбэк |
| Биолюминесценция | ДА | emission + glow (bloom) в Environment |
| Пузырьки | ДА | GPUParticles3D, 100–300 частиц |
| Мутная вода/взвесь | ДА | densité fog выше + noise-план + screen-space tint |
| Blend-режимы (soft-add и т.п.) | ЧАСТИЧНО | ручное смешивание во fragment |

## 5. АУДИО

### Загружено (A, CC0, OGA)
| Категория | Файл | Источник |
|---|---|---|
| Глубинный гул (loop) | ambient_deep_rumble_loop.ogg | OGA underwater-or-space-engine-rumble |
| Подводный пейзаж (loop) | ambient_underwater_loop.ogg | OGA (тот же) |
| Пузырьки-лОоп | bubbles_loop.ogg | OGA skippy-fish collection |
| Пузырьки-exhale | bubbles_breath.wav | OGA bubble-sound-effects |

### Freesound CC0 кандидаты (B — качаются вручную через браузер с логином)
| Категория | Автор — назв. | Ссылка |
|---|---|---|
| Глубинный гул | Fission9 — Underwater Ambience | freesound.org/people/Fission9/sounds/504641/ |
| Мелководье/рифф | Kinoton — Underwater Ambience | freesound.org/people/Kinoton/sounds/393819/ |
| Гидрофон-рифф | GirlWithSoundRecorder — Below the Sea | freesound.org/people/GirlWithSoundRecorder/sounds/773947/ |
| Пузыри-дайвер | timsc | freesound.org/people/timsc/sounds/274491/ |
| Плавание | tbsounddesigns — POOL SWIMMING | freesound.org/people/tbsounddesigns/sounds/530158/ |
| Китовый вой (далёкий) | KEVOY — Diving with whales | freesound.org/people/KEVOY/sounds/82325/ |
| Дельфины (гидрофон) | felix.blume | freesound.org/people/felix.blume/sounds/161691/ |
| Глуб. существо | carroll27 — Deep sea creature noise | freesound.org/people/carroll27/sounds/151852/ |
| Странный вой | McDrok — whale-sound-from-door-creaking | freesound.org/people/McDrok_the_RhythmDoc/sounds/673463/ |
| Ужасный дрон | Soparnik — Doomed Drone | freesound.org/people/Soparnik/sounds/786902/ |
| Пульс-дрон | gerainsan — Horror Pulsating Loop | freesound.org/people/gerainsan/sounds/457046/ |
| Пещера | Andy_Gardner — Sea Cave | freesound.org/people/Andy_Gardner/sounds/196713/ |
| Пещера-луп OGG | Nox_Sound — Atmosphere Cave Loop | freesound.org/people/Nox_Sound/sounds/553080/ |
| Металл затонув | Ubehag — sinking submarine | freesound.org/people/Ubehag/sounds/232021/ |
| Металл-клаттер | craigsmith (SSE) | freesound.org/people/craigsmith/sounds/675196/ |
| СОНАР (появление) | Breviceps — Submarine Sonar | freesound.org/people/Breviceps/sounds/493162/ |
| Рёв неталифана | rifthead — Nemean Roar | freesound.org/people/rifthead/sounds/240311/ |
| UI-клик | el_boss — UI Button Click | freesound.org/people/el_boss/sounds/677861/ |
| UI app/bell | GabFitzgerald — Approval | freesound.org/people/GabFitzgerald/sounds/625174/ |

Pixabay: библиотека открыта по Pixabay License (спроса в игре разрешено без атрибуции), но страницы из этой сети не открылись — перед ссылкой проверяй в браузере; реп毛泽ение в звонку депо — запрещено.

## 6. АНИМАЦИИ И ПОВЕДЕНИЕ (п.6 md)
- Установлено: GLB со swim-анимацией (Quaternius): рыбки ×3, дельфин, кит, манта, акула ✅.
- Без анимаций (нужен programm): turtle, octopus, squid, jelly (пульсация), coral, plants (sway).
- План UI: единая система поведения на GDScript (mobility states: idle_patrol → investigate → flee/approach), стая (flocking) и спаун по биому/глубине — БЕЗ отдельных AI per creature. Библиотеку (Beehave/LimboAI) выбираем отдельно — у нас уже есть Skills: beehave и limboai. Нужен РОВНО ОДИН аддон. Рекомендация: **Beehave** (легковесный, GDScript-native, без нативных GDExtension — просто совместим с Mobile/PRoot, Apache 2.0; github.com/bitwes/GodotBehaviorTree). LimboAI — мощнее, но тянет GDExtension-биндинги → лишний бинарный файл в Android-APK. Вывод: Beehave —首选, ставим ТОЛЬКО ПОДТВЕРЖДЁННОЙ ВЕРСИИ под 4.7 (проверить releases). НЕ устанавливаю теперь (правило md: без обоснования — не устанавливать).
