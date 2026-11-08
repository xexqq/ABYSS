extends Node3D
## Game — корневой оркестратор сцены «The Beginning» (модуль талассофобии).
## Собирает мир и системы, соединяет сигналы ввода/глубины/рендера.
## Системы — независимые ноды; модуль игры знает только их публичные API.

const PLAYER_SPAWN := Vector3(0.0, -7.0, 70.0)
const PLAYER_SPAWN_YAW_DEG := 180.0  # взгляд из спавна к центру рифа
const MENU_SCENE := "res://scenes/main.tscn"
# Явные preload (не class_name): устойчиво к порядку парсинга на первой импортции CI.
const SCENE_OCEAN := preload("res://scripts/systems/ocean_environment.gd")
const SCENE_UNDERWATER := preload("res://scripts/systems/underwater_rendering.gd")
const SCENE_DEPTH := preload("res://scripts/systems/depth_manager.gd")
const SCENE_PARTICLES := preload("res://scripts/systems/underwater_particles.gd")
const SCENE_BREATH := preload("res://scripts/systems/breath_system.gd")
const SCENE_MARINE := preload("res://scripts/marine/marine_life_manager.gd")

var _player: CharacterBody3D
var _camera: Camera3D
var _controls: CanvasLayer
var _ui: CanvasLayer
var _rendering: Node
var _dbg: Label


func _ready() -> void:
	_build_debug_overlay()
	_dbg_log("boot")

	# --- Мир ---
	var world := Node3D.new()
	world.name = "World"
	add_child(world)
	var ocean: Node = SCENE_OCEAN.new()
	ocean.name = "OceanEnvironment"
	world.add_child(ocean)
	ocean.call("build", world)
	_dbg_log("world ok")

	# --- Системы ---
	var systems := Node.new()
	systems.name = "Systems"
	add_child(systems)

	_rendering = SCENE_UNDERWATER.new()
	_rendering.name = "UnderwaterRendering"
	systems.add_child(_rendering)

	var depth: Node = SCENE_DEPTH.new()
	depth.name = "DepthManager"
	systems.add_child(depth)

	# --- Игрок ---
	_player = CharacterBody3D.new()
	_player.name = "Player"
	_player.set_script(load("res://scripts/core/player_controller.gd"))
	add_child(_player)
	_player.global_position = PLAYER_SPAWN
	_camera = Camera3D.new()
	_camera.name = "Camera"
	_camera.set_script(load("res://scripts/core/camera_controller.gd"))
	_player.add_child(_camera)
	_camera.make_current()
	_player.call("attach_camera", _camera)
	_camera.call("setup", _player, 0.15, deg_to_rad(PLAYER_SPAWN_YAW_DEG))
	_dbg_log("player ok")

	depth.set("player", _player)
	if _rendering.has_method("setup"):
		_rendering.call("setup", ocean.environment_res, ocean.sun)
	_dbg_log("render ok")

	# --- Ввод и HUD: добавляем СРАЗУ, чтобы ввод/HUD жили независимо
	# от поздних систем (морская жизнь/частицы/дыхание).
	_controls = CanvasLayer.new()
	_controls.name = "TouchControls"
	_controls.set_script(load("res://scripts/input/touch_controls.gd"))
	add_child(_controls)
	_ui = CanvasLayer.new()
	_ui.name = "UIManager"
	_ui.set_script(load("res://scripts/systems/ui_manager.gd"))
	add_child(_ui)
	_dbg_log("ui ok")

	# --- Соединения: ввод → игрок/камера/пауза ---
	_controls.connect("move_changed", _on_move_changed)
	_controls.connect("ascend_changed", _on_ascend_changed)
	_controls.connect("descend_changed", _on_descend_changed)
	_controls.connect("look_moved", _on_look_moved)
	_controls.connect("pause_pressed", _on_pause_pressed)
	# --- Соединения: пауза-меню ---
	_ui.connect("resume_requested", _on_resume_requested)
	_ui.connect("return_to_menu_requested", _on_return_to_menu_requested)
	# --- Соединения: глубина → HUD/рендер/звук ---
	depth.connect("depth_changed", _on_depth_changed)
	AudioManager.start_ambient()
	_ui.call("set_depth", maxf(0.0, -PLAYER_SPAWN.y))
	_rendering.call("set_depth", maxf(0.0, -PLAYER_SPAWN.y))
	_dbg_log("wiring ok")

	# --- Морская жизнь (Этап 4) — некритична для играбельности ---
	_spawn_deferred(systems, ocean, _player)
	# начальный статус HUD
	_ui.call("set_depth", maxf(0.0, -PLAYER_SPAWN.y))


func _spawn_deferred(systems: Node, ocean: Node, player: Node3D) -> void:
	# некритичные модули: отказ одного не должен ломать ввод/HUD.
	var marine: Node = SCENE_MARINE.new()
	marine.name = "MarineLifeManager"
	systems.add_child(marine)
	marine.call("setup", ocean, player)
	_dbg_log("marine ok")

	var particles: Node3D = SCENE_PARTICLES.new()
	particles.name = "UnderwaterParticles"
	systems.add_child(particles)
	particles.call("setup", player)
	_dbg_log("particles ok")

	var breath: Node = SCENE_BREATH.new()
	breath.name = "BreathSystem"
	systems.add_child(breath)
	breath.call("setup", player)
	_dbg_log("breath ok")


func _build_debug_overlay() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 99
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(layer)
	_dbg = Label.new()
	_dbg.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_dbg.offset_left = 24.0
	_dbg.offset_top = 24.0
	_dbg.offset_right = 720.0
	_dbg.offset_bottom = 200.0
	_dbg.add_theme_font_size_override("font_size", 30)
	_dbg.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 0.85))
	layer.add_child(_dbg)
	var t := Timer.new()
	t.wait_time = 1.0
	t.autostart = true
	t.timeout.connect(_dbg_update)
	layer.add_child(t)


func _dbg_log(msg: String) -> void:
	if _dbg != null:
		_dbg.text = msg


func _dbg_update() -> void:
	if _dbg == null:
		return
	var pos := Vector3.ZERO
	if _player != null and is_instance_valid(_player):
		pos = _player.global_position
	_dbg.text = "%s | fps %d\ny=%.1f v=%.1f" % [
		_dbg.text.split("\n")[0],
		Engine.get_frames_per_second(),
		pos.y,
		(_player.velocity.length() if _player is CharacterBody3D else 0.0),
	]


func _on_move_changed(v: Vector2) -> void:
	_player.set("move_input", v)


func _on_ascend_changed(pressed: bool) -> void:
	_player.set("lift_input", 1.0 if pressed else 0.0)


func _on_descend_changed(pressed: bool) -> void:
	_player.set("lift_input", -1.0 if pressed else 0.0)


func _on_look_moved(px: Vector2) -> void:
	_camera.call("add_look", px)


func _on_pause_pressed() -> void:
	_set_paused(not get_tree().paused)


func _on_resume_requested() -> void:
	_set_paused(false)


func _on_return_to_menu_requested() -> void:
	_set_paused(false)
	get_tree().change_scene_to_file(MENU_SCENE)


func _on_depth_changed(d: float) -> void:
	_ui.call("set_depth", d)
	_rendering.call("set_depth", d)
	AudioManager.set_depth_factor(clampf(d / 150.0, 0.0, 1.0))


func _set_paused(p: bool) -> void:
	get_tree().paused = p
	_ui.call("set_paused", p)
