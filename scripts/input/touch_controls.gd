extends CanvasLayer
## TouchControls — адаптивный тач-инпут, всё рисуется и обрабатывается кодом
## (никаких зависимостей от текстур, работает на любом разрешении).
## Принцип мульти-тача: каждый палец (по index) получает роль при первом касании:
##   - нижняя-левая зона → джойстик движения;
##   - круги кнопок (▲ / ▼ / пауза) → их действие;
##   - остальная часть экрана → вращение камеры (свайпы).
## Кнопки не вращают камеру — их касания не попадают в look-обработку.

signal move_changed(dir: Vector2)      # джойстик, y=+1 вперёд
signal ascend_changed(pressed: bool)
signal descend_changed(pressed: bool)
signal pause_pressed
signal look_moved(delta_px: Vector2)

const JOY_RADIUS_RATIO := 0.11         # радиус джойстика от min(w,h)
const BTN_RADIUS_RATIO := 0.052
const LOOK_DEADZONE := 1.5             # px, шум пальца

enum Role { NONE, JOY, ASC, DESC, PAUSE, LOOK }

var _joy_finger := -1
var _joy_center := Vector2.ZERO
var _joy_vector := Vector2.ZERO
var _roles := {}                       # index -> Role
var _btn_radius := 50.0
var _asc_center := Vector2.ZERO
var _desc_center := Vector2.ZERO
var _pause_center := Vector2.ZERO
var _layer_node: Control


func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS
	_layer_node = Control.new()
	_layer_node.name = "TouchArea"
	_layer_node.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layer_node.draw.connect(_paint)
	add_child(_layer_node)
	_layout()


func _layout() -> void:
	var vs := _viewport_size()
	var unit := minf(vs.x, vs.y)
	_btn_radius = unit * BTN_RADIUS_RATIO
	_asc_center = Vector2(vs.x - _btn_radius * 1.9, vs.y * 0.52)
	_desc_center = Vector2(vs.x - _btn_radius * 1.9, _asc_center.y + _btn_radius * 2.6)
	_pause_center = Vector2(vs.x - 84.0, 84.0)
	_layer_node.update()


func _viewport_size() -> Vector2:
	return _layer_node.get_viewport_rect().size


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _layer_node != null:
		_layout()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		if e.pressed:
			_start(e.index, e.position)
		else:
			_end(e.index)
	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		_drag(d.index, d.position, d.relative)


func _start(idx: int, pos: Vector2) -> void:
	var vs := _viewport_size()
	if _in_circle(pos, _asc_center, _btn_radius * 1.3):
		_roles[idx] = Role.ASC
		ascend_changed.emit(true)
		_layer_node.update()
		return
	if _in_circle(pos, _desc_center, _btn_radius * 1.3):
		_roles[idx] = Role.DESC
		descend_changed.emit(true)
		_layer_node.update()
		return
	if _d(pos, _pause_center) < 96.0:
		_roles[idx] = Role.PAUSE
		pause_pressed.emit()
		return
	if pos.x < vs.x * 0.45 and _joy_finger == -1:
		_joy_finger = idx
		_roles[idx] = Role.JOY
		_joy_center = pos
		_layer_node.update()
		return
	_roles[idx] = Role.LOOK


func _drag(idx: int, pos: Vector2, rel: Vector2) -> void:
	var role: int = _roles.get(idx, Role.NONE)
	match role:
		Role.JOY:
			var v := (pos - _joy_center)
			var rad := minf(_viewport_size().x, _viewport_size().y) * JOY_RADIUS_RATIO
			if v.length() > rad:
				v = v / v.length() * rad
			_joy_vector = v / rad
			move_changed.emit(_joy_vector)
			_layer_node.update()
		Role.LOOK:
			# Камера сама примет дельту (game.gd соединяет сигнал с CameraController).
			look_moved.emit(rel)


func _end(idx: int) -> void:
	var role: int = _roles.get(idx, Role.NONE)
	match role:
		Role.JOY:
			_joy_finger = -1
			_joy_vector = Vector2.ZERO
			move_changed.emit(Vector2.ZERO)
			_layer_node.update()
		Role.ASC:
			ascend_changed.emit(false)
			_layer_node.update()
		Role.DESC:
			descend_changed.emit(false)
			_layer_node.update()
	_roles.erase(idx)


func _d(a: Vector2, b: Vector2) -> float:
	return a.distance_to(b)


func _in_circle(p: Vector2, c: Vector2, r: float) -> bool:
	return _d(p, c) <= r


func _active(role: int) -> bool:
	return _roles.values().has(role)


func _paint() -> void:
	var t := _layer_node as Control
	# Пауза (иконка ||)
	t.draw_circle(_pause_center, 44.0, Color(1, 1, 1, 0.12))
	t.draw_arc(_pause_center, 44.0, 0, TAU, 48, Color(1, 1, 1, 0.5), 2.0, false)
	t.draw_line(_pause_center + Vector2(-9, -12), _pause_center + Vector2(-9, 12), Color(1, 1, 1, 0.9), 5.0)
	t.draw_line(_pause_center + Vector2(9, -12), _pause_center + Vector2(9, 12), Color(1, 1, 1, 0.9), 5.0)
	# Джойстик
	var rad := minf(_viewport_size().x, _viewport_size().y) * JOY_RADIUS_RATIO
	if _joy_finger == -1:
		# подсказка в покое (слабый контур слева-снизу)
		var hint := Vector2(rad + 46.0, _viewport_size().y - rad - 46.0)
		t.draw_arc(hint, rad * 0.85, 0, TAU, 40, Color(1, 1, 1, 0.16), 2.0, false)
	else:
		t.draw_circle(_joy_center, rad, Color(1, 1, 1, 0.08))
		t.draw_arc(_joy_center, rad, 0, TAU, 48, Color(1, 1, 1, 0.45), 2.0, false)
		var knob := _joy_center + _joy_vector * rad
		t.draw_circle(knob, rad * 0.38, Color(1, 1, 1, 0.35))
	# Кнопки ▲/▼
	_paint_arrow_button(t, _asc_center, true)
	_paint_arrow_button(t, _desc_center, false)


func _paint_arrow_button(t: Control, c: Vector2, up: bool) -> void:
	var pressed := _active(Role.ASC if up else Role.DESC)
	var col := Color(1, 1, 1, 0.55) if pressed else Color(1, 1, 1, 0.30)
	t.draw_circle(c, _btn_radius, Color(1, 1, 1, 0.10 if not pressed else 0.26))
	t.draw_arc(c, _btn_radius, 0, TAU, 48, col, 2.5, false)
	var dir := -1.0 if up else 1.0
	var tip := c + Vector2(0, dir * _btn_radius * 0.5)
	t.draw_line(c + Vector2(-r3(), dir * _btn_radius * 0.08), tip, Color(1, 1, 1, 0.85), 5.0)
	t.draw_line(c + Vector2(r3(), dir * _btn_radius * 0.08), tip, Color(1, 1, 1, 0.85), 5.0)


func _r3() -> float:
	return _btn_radius * 0.4
