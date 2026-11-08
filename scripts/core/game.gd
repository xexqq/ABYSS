extends Node3D
## Game — корневой оркестратор сцены «The Beginning» (модуль талассофобии).
## Собирает мир и системы, соединяет сигналы ввода/глубины/рендера.
## Системы — независимые ноды; модуль игры знает только их публичные API.

const PLAYER_SPAWN := Vector3(0.0, -7.0, 70.0)
const PLAYER_SPAWN_YAW_DEG := 180.0  # взгляд из спавна к центру рифа
const MENU_SCENE := "res://scenes/main.tscn"

var _player: CharacterBody3D
var _camera: Camera3D
var _controls: CanvasLayer
var _ui: CanvasLayer
var _rendering: Node


func _ready() -> void:
	# --- Мир ---
	var world := Node3D.new()
	world.name = "World"
	add_child(world)
	var ocean := OceanEnvironment.new()
	ocean.name = "OceanEnvironment"
	world.add_child(ocean)
	ocean.build(world)

	# --- Системы ---
	var systems := Node.new()
	systems.name = "Systems"
	add_child(systems)

	_rendering = load("res://scripts/systems/underwater_rendering.gd").new()
	_rendering.name = "UnderwaterRendering"
	systems.add_child(_rendering)

	var depth: Node = load("res://scripts/systems/depth_manager.gd").new()
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

	depth.set("player", _player)
	_rendering.call("setup", ocean.environment_res, ocean.sun)

	# --- Ввод и HUD ---
	_controls = CanvasLayer.new()
	_controls.name = "TouchControls"
	_controls.set_script(load("res://scripts/input/touch_controls.gd"))
	add_child(_controls)

	_ui = CanvasLayer.new()
	_ui.name = "UIManager"
	_ui.set_script(load("res://scripts/systems/ui_manager.gd"))
	add_child(_ui)

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
