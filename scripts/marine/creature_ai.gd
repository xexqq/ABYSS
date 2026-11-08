extends Node3D
## CreatureAI — одиночное крупное существо (манта, кит, акула).
## Круиз по случайным вейпоинтам в домашнем объёме, лёгкий крен в поворотах,
## реакции: страх (уход), любопытство (сближение + круг вокруг игрока),
## возврат к блужданию. Steering 5 Гц + интерполяция каждый кадр.

const TICK := 0.2

# kind: "flee" | "curious" | "calm"
var speed := 2.5
var wander_radius := 60.0
var fear_radius := 14.0
var kind := "calm"
var min_y := -40.0    # глубже не ныряет (зона обитания)
var max_y := -8.0     # не поднимается выше
var floor_margin := 4.0

var _home := Vector3.ZERO
var _target := Vector3.ZERO
var _player: Node3D
var _timer := 0.0
var _repoint_timer := 0.0
var _curious_until := 0.0
var _flee_until := 0.0


func setup(home: Vector3, player: Node3D, cfg: Dictionary) -> void:
	_home = home
	_target = home
	_player = player
	speed = float(cfg.get("speed", 2.5))
	wander_radius = float(cfg.get("wander_radius", 60.0))
	fear_radius = float(cfg.get("fear_radius", 14.0))
	kind = str(cfg.get("kind", "calm"))
	min_y = float(cfg.get("min_y", -40.0))
	max_y = float(cfg.get("max_y", -8.0))
	global_position = home
	_pick_waypoint()
	_play_swim()


func _pick_waypoint() -> void:
	var t := home_random()
	# выход за пределы объёма сближения с игроком недопустим — потом кламп
	_target = t


func home_random() -> Vector3:
	return _home + Vector3(randf_range(-1, 1), randf_range(-0.4, 0.4), randf_range(-1, 1)).normalized() * randf_range(wander_radius * 0.45, wander_radius)


func _physics_process(delta: float) -> void:
	_timer += delta
	if _timer >= TICK:
		_timer = 0.0
		_steer(TICK)
	var w := 1.0 - exp(-2.6 * delta)
	global_position = global_position.lerp(_target, w)
	var dir := _target - global_position
	if dir.length_squared() > 0.02:
		var nb := Basis.looking_at(dir.normalized(), Vector3.UP)
		global_basis = global_basis.slerp(nb, 1.0 - exp(-5.0 * delta))


func _steer(delta: float) -> void:
	if _player != null:
		var d := global_position.distance_to(_player.global_position)
		# страх: уход прочь
		if kind != "calm" and d < fear_radius and _flee_until <= 0.0 and _curious_until <= 0.0:
			_flee_until = 5.0
			var away := global_position - _player.global_position
			away.y *= 0.4
			_target = _home + away.normalized() * wander_radius
		if _flee_until > 0.0:
			_flee_until -= delta
			return  # цель уже назначена (убегание работает по интерполяции)
		# любопытство: сближение, потом круг на дистанции 12 м
		if kind == "curious" and _curious_until <= 0.0:
			if d > 30.0 and d < 60.0 and randf() < 0.02:
				_curious_until = 16.0
		if _curious_until > 0.0:
			_curious_until -= delta
			if d > 14.0:
				_target = global_position.lerp(_player.global_position, 0.35)
			else:
				var t := Time.get_ticks_msec() * 0.0006
				_target = _player.global_position + Vector3(cos(t) * 12.0, sin(t * 0.7) * 3.0, sin(t) * 12.0)
			_target.y = clampf(_target.y, min_y, max_y)
			return
	# блуждание: периодическая смена вейпоинта
	_repoint_timer -= delta
	if _repoint_timer <= 0.0:
		_repoint_timer = randf_range(6.0, 14.0)
		_target = home_random()
		if global_position.distance_to(_home) > wander_radius * 1.4:
			_target = _home + (global_position - _home).normalized() * wander_radius * 0.5
	# держим зону обитания и дно
	_target.y = clampf(_target.y, min_y, max_y)
	var ocean := _find_ocean()
	if ocean != null:
		var floor_y := float(ocean.call("terrain_height", _target.x, _target.z)) + floor_margin
		if _target.y < floor_y:
			_target.y = floor_y


func _find_ocean() -> Node:
	var n: Node = self
	while n != null and n.name != "World":
		n = n.get_parent()
	if n == null:
		return null
	return n.get_node_or_null("OceanEnvironment")


func _play_swim() -> void:
	var ap := _find_anim_player(self)
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
		ap.get_animation(chosen).loop_mode = Animation.LOOP_LINEAR
		ap.play(chosen)


func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for c in node.get_children():
		var r := _find_anim_player(c)
		if r != null:
			return r
	return null
