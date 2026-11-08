extends Node3D
## FishSchool — центр стаи: блуждание по случайным точкам вокруг дома,
## паника от игрока (уход в противоположную сторону с ускорением).
## Члены стаи — дети, обновляются своим скриптом (10 Гц steering).

const FISH_SCENE_BASE := "res://assets/models/fish/%s"

## Конфиг: путь модели без префикса, количество, радиус стаи, скорость (м/с).
var fish_scene_path := "tropical_a_swim.glb"
var fish_count := 8
var school_radius := 20.0
var swim_speed := 2.2
var fear_radius := 16.0
var wander_radius := 55.0

var _target := Vector3.ZERO
var _home := Vector3.ZERO
var _panic_until := 0.0
var _player: Node3D
var _wander_ray_phase := 0.0


func setup(home: Vector3, player: Node3D, scene_path: String, count: int, radius: float, speed: float) -> void:
	_home = home
	_target = home
	_player = player
	fish_scene_path = scene_path
	fish_count = count
	school_radius = radius
	swim_speed = speed
	global_position = home
	_spawn_members()


func _spawn_members() -> void:
	var ps := load(FISH_SCENE_BASE % fish_scene_path) as PackedScene
	if ps == null:
		push_warning("FishSchool: нет сцены " + fish_scene_path)
		return
	var siblings: Array = []
	for i in range(fish_count):
		var inst := ps.instantiate()
		add_child(inst)
		inst.position = home_offset()
		siblings.append(inst)
	for i in range(siblings.size()):
		var inst := siblings[i]
		inst.set_script(load("res://scripts/marine/fish_member.gd"))
		inst.call("setup", self, siblings, school_radius, swim_speed)
		_play_swim(inst)


func home_offset() -> Vector3:
	return Vector3(randf_range(-school_radius, school_radius) * 0.6, randf_range(-6, 6), randf_range(-school_radius, school_radius) * 0.6).rotated(Vector3.UP, randf() * TAU)


func _physics_process(delta: float) -> void:
	_wander_ray_phase += delta
	# Паника от близкого игрока.
	if _player != null:
		var d := global_position.distance_to(_player.global_position)
		if d < fear_radius and _panic_deadline_passed():
			_panic_until = 6.0
			var away := (global_position - _player.global_position)
			away.y *= 0.3
			if away.length() < 0.5:
				away = Vector3.UP
			away = away.normalized()
			_target = _home + away * wander_radius
			_target.y = clampf(_target.y, -110.0, -2.5)
	var speed := swim_speed * (3.2 if _panic_until > 0.0 else 1.0)
	if _panic_until > 0.0:
		_panic_until -= delta
	# Медленное дрейфовое блуждание вокруг дома.
	if _wander_ray_phase > 9.0 and _panic_until <= 0.0:
		_wander_ray_phase = 0.0
		_target = _home + Vector3(randf_range(-1, 1), randf_range(-0.35, 0.35), randf_range(-1, 1)).normalized() * randf_range(wander_radius * 0.5, wander_radius)
		_target.y = clampf(_target.y, -110.0, -2.5)
	var w := 1.0 - exp(-0.5 * delta)
	global_position = global_position.lerp(_target, w)


func _panic_deadline_passed() -> bool:
	return _panic_until <= 0.0


func _play_swim(node: Node) -> void:
	var ap := _find_anim_player(node)
	if ap == null:
		return
	var chosen := ""
	for name_ in ap.get_animation_list():
		if String(name_).to_lower().contains("swim"):
			chosen = name_
			break
	if chosen == "" and ap.get_animation_list().size() > 0:
		chosen = ap.get_animation_list()[0]
	if chosen != "":
		var anim := ap.get_animation(chosen)
		anim.loop_mode = Animation.LOOP_LINEAR
		ap.play(chosen)


func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for c in node.get_children():
		var r := _find_anim_player(c)
		if r != null:
			return r
	return null
