extends Camera3D
## CameraController — FP-камера: сглаженный yaw/pitch от свайпов, лёгкое
## подводное покачивание от скорости. Чувствительность берётся из SettingsManager.

const PITCH_LIMIT := deg_to_rad(84.0)

var _target_yaw := 0.0
var _target_pitch := 0.0
var _smooth_yaw := 0.0
var _smooth_pitch := 0.0
var _look_accum := Vector2.ZERO
var _player: Node3D
var _base_height := 0.0
var _time := 0.0


func setup(player: Node3D, eye_height: float, initial_yaw: float) -> void:
	_player = player
	_base_height = eye_height
	_target_yaw = initial_yaw
	_smooth_yaw = initial_yaw
	fov = 72.0
	near = 0.08
	far = 450.0
	_apply_rotation()
	_update_position()


## Накопленный свайп (пиксели) от TouchControls. Небольшая аккумуляция затем
## единым применением даёт плавность даже при дёрганых тач-событиях.
func add_look(delta_px: Vector2) -> void:
	_look_accum += delta_px


func _process(delta: float) -> void:
	_time += delta
	if _look_accum.length_squared() > 0.000001:
		var sens := 0.0022
		if SettingsManager:
			sens *= SettingsManager.camera_sensitivity
		_target_yaw -= _look_accum.x * sens
		_target_pitch = clampf(_target_pitch - _look_accum.y * sens, -PITCH_LIMIT, PITCH_LIMIT)
		_look_accum = Vector2.ZERO
	# Сглаживание поворота (быстрое, но мягкое).
	var w := 1.0 - exp(-26.0 * delta)
	_smooth_yaw = lerp_angle(_smooth_yaw, _target_yaw, w)
	_smooth_pitch = lerp(_smooth_pitch, _target_pitch, w)
	_apply_rotation()
	_update_position()


func _apply_rotation() -> void:
	global_basis = Basis(Vector3.UP, _smooth_yaw) * Basis(Vector3.RIGHT, _smooth_pitch)


func _update_position() -> void:
	if _player == null:
		return
	# Лёгкое покачивание корпуса пловца: амплитуда растёт со скоростью.
	var speed := 0.0
	if _player is CharacterBody3D:
		speed = (_player as CharacterBody3D).velocity.length()
	var amp := clampf(speed / 6.0, 0.0, 1.0) * 0.045
	var bob := sin(_time * 2.6) * amp
	var sway := sin(_time * 1.9 + 1.3) * amp * 0.35
	global_position = _player.global_position + Vector3(0.0, _base_height + bob, 0.0)
	global_basis = global_basis.rotated(global_basis.z, sway * 0.5)
