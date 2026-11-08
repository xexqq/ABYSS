extends CharacterBody3D
## PlayerController — FP-пловец. Мягкая инерция, вертикальные кнопки, границы мира.
## Ввод приходит через game.gd из TouchControls (сигналы). Гравитация воды почти
## нейтральна: небольшая генеральная инерция + демпфирование.

signal moved_speed(speed: float)

@export var max_speed := 5.0            # м/с горизонталь+вперёд
@export var vertical_speed := 3.0       # м/с всплытие/погружение
@export var accel := 9.0                # отзывчивость (экспоненциальное сглаживание)
@export var drag := 2.4                 # затухание без ввода
@export var world_bound := 285.0        # радиус мягких границ

var move_input := Vector2.ZERO          # джойстик: x — стрейф, y — вперёд(+1)/назад
var lift_input := 0.0                   # +1 всплытие, -1 погружение
var _camera: Node3D


func attach_camera(cam: Node3D) -> void:
	_camera = cam


func _physics_process(delta: float) -> void:
	var target := Vector3.ZERO
	if _camera != null:
		var b := _camera.global_basis
		# Горизонтальное направление относительно поворота камеры (pitch игнорируем).
		var fwd := -b.z
		fwd.y = 0.0
		var right := b.x
		right.y = 0.0
		if fwd.length_squared() > 0.001:
			fwd = fwd.normalized()
		if right.length_squared() > 0.001:
			right = right.normalized()
		target = fwd * move_input.y + right * move_input.x
	target.y = lift_input * vertical_speed
	target *= max_speed
	# Экспоненциальное сглаживание — плавно и не зависит от FPS.
	var w := 1.0 - exp(-accel * delta)
	velocity = velocity.lerp(target, w)
	# Затухание при почти нулевом вводе (постепенное торможение).
	if move_input.length() < 0.06 and lift_input == 0.0:
		velocity *= exp(-drag * delta)
		if velocity.length() < 0.05:
			velocity = Vector3.ZERO
	move_and_slide()
	# Мягкие границы мира — мягко отталкиваем обратно.
	var pos := global_position
	var dist := Vector2(pos.x, pos.z).length()
	if dist > world_bound:
		var inward := Vector2(-pos.x, -pos.z).normalized()
		velocity.x += inward.x * (dist - world_bound) * 2.0 * delta * 60.0 * 0.01
		velocity.z += inward.y * (dist - world_bound) * 2.0 * delta * 60.0 * 0.01
	# Потолок: над поверхностью не выпрыгиваем.
	if pos.y > -1.6:
		velocity.y = minf(velocity.y, 0.0)
	moved_speed.emit(velocity.length())
