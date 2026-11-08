extends Node
## MarineLifeManager — центральная точка морской жизни (Этап 4).
## Спавнит стаи рыб (Boids) и крупных существ по зонам глубины,
## масштабирует количество по профилю качества и глушит AI за пределами
## радиуса активности. Животные привязаны к OceanEnvironment (высота дна).

const SCRIPT_SCHOOL := preload("res://scripts/marine/fish_school.gd")
const SCRIPT_CREATURE := preload("res://scripts/marine/creature_ai.gd")

const AI_ACTIVE_RADIUS := 180.0

var _ocean: Node
var _player: Node3D
var _beings: Array = []      # Node3D существа и стаи
var _cull_timer := 0.0


func setup(ocean: Node, player: Node3D) -> void:
	_ocean = ocean
	_player = player
	var mult := 1.0
	if SettingsManager:
		mult = float(SettingsManager.get_profile().get("scatter_mult", 1.0))
	_spawn_school("res://assets/models/fish/tropical_a_swim.glb",
		Vector3(25.0, -9.0, 25.0), int(8 * mult), 16.0, 2.3, 18.0)
	_spawn_school("res://assets/models/fish/tropical_b_swim.glb",
		Vector3(-45.0, -30.0, 30.0), int(8 * mult), 20.0, 2.1, 16.0)
	_spawn_school("res://assets/models/fish/tropical_c_swim.glb",
		Vector3(60.0, -55.0, -40.0), int(6 * mult), 22.0, 2.5, 18.0)
	_spawn_creature("res://assets/models/sharks/manta_ray_swim.glb",
		Vector3(0.0, -42.0, -90.0), {
			"speed": 3.2, "wander_radius": 65.0, "fear_radius": 12.0,
			"kind": "flee", "min_y": -55.0, "max_y": -10.0,
		})
	_spawn_creature("res://assets/models/whales/whale_swim.glb",
		Vector3(-40.0, -128.0, -160.0), {
			"speed": 2.0, "wander_radius": 80.0, "fear_radius": 8.0,
			"kind": "calm", "min_y": -160.0, "max_y": -90.0,
		})
	_spawn_creature("res://assets/models/sharks/shark_swim.glb",
		Vector3(100.0, -92.0, 120.0), {
			"speed": 2.6, "wander_radius": 100.0, "fear_radius": 10.0,
			"kind": "curious", "min_y": -130.0, "max_y": -60.0,
		})


func _spawn_school(scene_path: String, home: Vector3, count: int, radius: float, speed: float, fear: float) -> void:
	if count < 4:
		count = 4
	var school: Node3D = SCRIPT_SCHOOL.new()
	school.name = "School_" + scene_path.get_file().get_basename()
	add_child(school)
	school.call("setup", home, _player, scene_path.get_file(), count, radius, speed)
	school.set("fear_radius", fear)
	_beings.append(school)


func _spawn_creature(scene_path: String, home: Vector3, cfg: Dictionary) -> void:
	var ps := load(scene_path) as PackedScene
	if ps == null:
		push_warning("MarineLifeManager: нет сцены " + scene_path)
		return
	var inst: Node3D = ps.instantiate()
	inst.name = scene_path.get_file().get_basename()
	add_child(inst)
	inst.position = home
	inst.set_script(SCRIPT_CREATURE)
	inst.call("setup", home, _player, cfg)
	_beings.append(inst)


func _physics_process(delta: float) -> void:
	# Раз в секунду: дальняя биота гасится целиком (экономия CPU/скиннинга).
	_cull_timer += delta
	if _cull_timer < 1.0:
		return
	_cull_timer = 0.0
	if _player == null:
		return
	for b in _beings:
		if not is_instance_valid(b):
			continue
		var far := global_far(b)
		var want_active: bool = far < AI_ACTIVE_RADIUS
		var is_active: bool = b.process_mode != Node.PROCESS_MODE_DISABLED
		if want_active != is_active:
			b.process_mode = Node.PROCESS_MODE_INHERIT if want_active else Node.PROCESS_MODE_DISABLED
			b.visible = want_active


func global_far(b: Node3D) -> float:
	return Vector3(b.global_position - _player.global_position).length()
