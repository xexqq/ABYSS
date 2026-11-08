extends Node3D
## FishMember — рыба в стае: упрощённые Boids (сцепление/разделение/блуждание).
## Steering обновляется на тике 10 Гц, трансформ интерполируется каждый кадр.
## Дальше view-радиуса AI замирает (оптимизация, прячется из контура).

const TICK := 0.1

var _school: Node3D          # школа (центр)
var _siblings: Array         # другие члены стаи (Node3D)
var _speed_base := 1.0
var _target := Vector3.ZERO
var _phase := 0.0            # персональная фаза блуждания
var _accel := 6.0
var _timer := 0.0
var _radius := 22.0
var _min_y_off := -12.0
var _max_y_off := 8.0


func setup(school: Node3D, siblings: Array, radius: float, speed: float) -> void:
	_school = school
	_siblings = siblings
	_radius = radius
	_speed_base = speed * randf_range(0.85, 1.15)
	_phase = randf() * TAU
	_target = global_position + Vector3(randf_range(-4, 4), randf_range(-2, 2), randf_range(-4, 4)).rotated(Vector3.UP, randf() * TAU)


func _physics_process(delta: float) -> void:
	if _school == null:
		return
	_timer += delta
	var steering_here := _timer >= TICK
	if steering_here:
		_timer = 0.0
		_steer(TICK)
	# lerp каждый кадр по последнему таргету (плавно)
	var w := 1.0 - exp(-_accel * delta)
	global_position = global_position.lerp(_target, w)
	# ориентация по движению
	var dir := _target - global_position
	if dir.length_squared() > 0.001:
		var new_basis := Basis.looking_at(dir.normalized(), Vector3.UP)
		var wrap := 1.0 - exp(-8.0 * delta)
		global_basis = global_basis.slerp(new_basis, wrap)


func _steer(delta: float) -> void:
	var center := _school.global_position
	# сцепление к центру стаи
	var desired := Vector3.ZERO
	var to_center := center + Vector3(
		sin(_phase + Time.get_ticks_msec() * 0.0009) * _radius * 0.5,
		sin(_phase * 1.7 + Time.get_ticks_msec() * 0.0005) * _radius * 0.22,
		cos(_phase + Time.get_ticks_msec() * 0.0011) * _radius * 0.5,
	)
	# «Личная» точка орбиты вокруг центра — стая не собирается в комок.
	to_center += Vector3(sin(_phase * 3.1) * 2.0, 0.0, cos(_phase * 2.3) * 2.0)
	desired += (to_center - global_position) * 0.5
	# разделение от ближайших соседей
	if _siblings.size() > 1:
		for s in _siblings:
			if s == self or not is_instance_valid(s):
				continue
			var d := global_position.distance_to(s.global_position)
			if d < 2.4 and d > 0.001:
				desired += (global_position - s.global_position) / d * (2.4 - d) * 0.8
	if desired.length_squared() > 0.0001:
		desired = desired.normalized() * _speed_base
	var next := _target + desired * delta
	var r := next.distance_to(center)
	if r > _radius:
		next = center + (next - center) / r * _radius
	# не выше коралла и не в дно: означает подобие зоны стаи
	var oy := clampf(next.y - center.y, _min_y_off, _max_y_off)
	next = Vector3(next.x, center.y + oy, next.z)
	next.y = maxf(next.y, _terrain_floor(next))
	next.y = minf(next.y, -1.5)
	_target = next


func _terrain_floor(p: Vector3) -> float:
	# Нада дно вокруг стаи — быстрый поиск по миру-обертывают ветке.
	var n := _school
	while n != null and n.name != "World":
		n = n.get_parent()
	if n == null:
		return -9999.0
	var ocean := n.get_node_or_null("OceanEnvironment")
	if ocean != null:
		return float(ocean.call("terrain_height", p.x, p.z)) + 1.2
	return -9999.0
