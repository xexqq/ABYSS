extends CanvasLayer
## TouchControls v2 — виджет-ориентированный тач.
## - Кнопки ▲▼/Пауза = настоящие Button (тема, гарантированный рендер и ввод).
## - Джойстик = зона в нижней 55% левой половины экрана; визуал — круг на Control.draw.
## - Обзор камеры = свайпы во всём остальном пространстве через ScreenTouch/ScreenDrag.
## Кнопки поглощают свои касания, обзорные касания кнопок игнорируются.

signal move_changed(dir: Vector2)
signal ascend_changed(pressed: bool)
signal descend_changed(pressed: bool)
signal pause_pressed
signal look_moved(delta_px: Vector2)

const JOY_RADIUS_RATIO := 0.11
const LOOK_DEADZONE := 1.5

enum Role { NONE, JOY, LOOK, BTN }

var _joy_finger := -1
var _joy_center := Vector2.ZERO
var _joy_vector := Vector2.ZERO
var _roles := {}
var _root: Control
var _joy_zone: Control          # визуальная подсказка джойстика
var _btn_asc: Button
var _btn_desc: Button
var _btn_pause: Button
var _joy_radius := 80.0
var _diag: Label                # ВРЕМЕННО: показывает последние input-события
var _diag_lines: PackedStringArray = []


func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.name = "TouchRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_build_joy_zone()
	_build_look_guard()
	_build_buttons()
	var vs := _root.get_viewport_rect().size
	_joy_radius = minf(vs.x, vs.y) * JOY_RADIUS_RATIO
	_joy_update_visual()
	_build_diag()


func _build_diag() -> void:
	_diag = Label.new()
	_diag.name = "TouchDiag"
	_diag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_diag.anchor_top = 0.0
	_diag.anchor_bottom = 0.0
	_diag.offset_left = 24.0
	_diag.offset_top = 224.0
	_diag.offset_right = 900.0
	_diag.offset_bottom = 400.0
	_diag.add_theme_font_size_override("font_size", 24)
	_diag.add_theme_color_override("font_color", Color(0.5, 1.0, 0.6, 0.9))
	_root.add_child(_diag)


## ВРЕМЕННАЯ диагностика: всё, что движок получает от тач-устройства.
func _input(event: InputEvent) -> void:
	if _diag == null:
		return
	if event is InputEventScreenTouch:
		_diag_lines.append("T%d %s @%s" % [event.index, "↓" if event.pressed else "↑", event.position])
	elif event is InputEventScreenDrag:
		_diag_lines.append("D%d rel=%s" % [event.index, event.relative])
	elif event is InputEventMouseButton:
		_diag_lines.append("M%d %s" % [event.button_index, "↓" if event.pressed else "↑"])
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_diag_lines.append("MM rel=%s" % [event.relative])
	if _diag_lines.size() > 4:
		_diag_lines = _diag_lines.slice(_diag_lines.size() - 4)
	_diag.text = "\n".join(_diag_lines)


# --- зоны (рисуются первыми, кнопки поверх) -------------------------------

func _build_joy_zone() -> void:
	_joy_zone = Control.new()
	_joy_zone.name = "JoyZone"
	_joy_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# нижняя-левая область: x 0..45%, y 45..100%
	_joy_zone.anchor_left = 0.0
	_joy_zone.anchor_right = 0.45
	_joy_zone.anchor_top = 0.45
	_joy_zone.anchor_bottom = 1.0
	_joy_zone.draw.connect(_paint_joy)
	_root.add_child(_joy_zone)


func _build_look_guard() -> void:
	# Кнопки справа: касания на них не должны крутить камеру.
	# Реализуется в _start: если палец попал в прямоугольник кнопки — Role.BTN.
	pass


func _build_buttons() -> void:
	var vs := _root.get_viewport_rect().size
	var unit := minf(vs.x, vs.y)
	var side := unit * 0.145

	_btn_asc = _make_button("ВВЕРХ", Vector2(vs.x - side * 0.9, vs.y * 0.46), side)
	_btn_desc = _make_button("ВНИЗ", Vector2(vs.x - side * 0.9, _btn_asc.position.y + side * 1.35), side)
	_btn_pause = _make_button("II", Vector2(vs.x - side * 1.5, 28.0), side * 0.55, true)

	_btn_asc.button_down.connect(func() -> void: ascend_changed.emit(true))
	_btn_asc.button_up.connect(func() -> void: ascend_changed.emit(false))
	_btn_desc.button_down.connect(func() -> void: descend_changed.emit(true))
	_btn_desc.button_up.connect(func() -> void: descend_changed.emit(false))
	_btn_pause.pressed.connect(func() -> void: pause_pressed.emit())


func _make_button(text: String, pos: Vector2, side: float, square: bool = false) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.custom_minimum_size = Vector2(side, side * 0.75 if square else side)
	b.add_theme_font_size_override("font_size", int(side * 0.30) if not square else int(side * 0.38))
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.20, 0.26, 0.55)
	sb.set_corner_radius_all(int(side * 0.22))
	sb.set_border_width_all(3)
	sb.border_color = Color(0.75, 0.95, 1.0, 0.7)
	b.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate() as StyleBoxFlat
	sbh.bg_color = Color(0.10, 0.34, 0.44, 0.85)
	b.add_theme_stylebox_override("hover", sbh)
	b.add_theme_stylebox_override("pressed", sbh)
	b.add_theme_color_override("font_color", Color(0.95, 1.0, 1.0, 0.95))
	b.focus_mode = Control.FOCUS_NONE
	b.action_mode = Button.ACTION_MODE_BUTTON_PRESS   # реагировать на нажатие, не на отпускание
	_root.add_child(b)
	return b


# --- SONAR: джойстик рисуем на Control.draw --------------------------------

func _current_radius() -> float:
	var vs := Vector2.ONE * 640.0
	if _root != null and is_instance_valid(_root):
		vs = _root.get_viewport_rect().size
	return clampf(minf(vs.x, vs.y) * JOY_RADIUS_RATIO, 60.0, 220.0)


func _paint_joy() -> void:
	var t := _joy_zone as Control
	var size := t.size
	var rad := _current_radius()
	var center := Vector2(size.x * 0.55, size.y - rad - 40.0)
	# статичная подсказка
	t.draw_circle(center, rad, Color(0.75, 0.95, 1.0, 0.10))
	t.draw_arc(center, rad, 0, TAU, 48, Color(0.75, 0.95, 1.0, 0.55), 3.0, false)
	t.draw_circle(center, rad * 0.45, Color(0.75, 0.95, 1.0, 0.22))
	if _joy_finger != -1:
		var knob := center + _joy_vector * rad
		t.draw_circle(knob, rad * 0.42, Color(1.0, 1.0, 1.0, 0.5))


func _joy_update_visual() -> void:
	if _joy_zone != null:
		_joy_zone.queue_redraw()


# --- ввод -------------------------------------------------------------------

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


func _btn_rects() -> Array:
	var out := []
	var pad := maxf(10.0, _current_radius() * 0.22)
	for b in [_btn_asc, _btn_desc, _btn_pause]:
		if b != null and is_instance_valid(b):
			out.append(b.get_global_rect().grow(pad))
	return out


func _in_any_btn(pos: Vector2) -> bool:
	for r in _btn_rects():
		if (r as Rect2).has_point(pos):
			return true
	return false


func _start(idx: int, pos: Vector2) -> void:
	var vs := _root.get_viewport_rect().size
	if _in_any_btn(pos):
		_roles[idx] = Role.BTN
		return
	var in_joy_zone := pos.x < vs.x * 0.45 and pos.y > vs.y * 0.45
	if in_joy_zone and _joy_finger == -1:
		_joy_finger = idx
		_roles[idx] = Role.JOY
		_joy_center = pos
		_joy_update_visual()
		return
	_roles[idx] = Role.LOOK
	_trace("start idx=%d role=%d pos=%s roles=%s" % [idx, _roles[idx], pos, str(_roles.keys())])


func _trace(msg: String) -> void:
	print("TC: ", msg)


func _drag(idx: int, pos: Vector2, rel: Vector2) -> void:
	var role: int = _roles.get(idx, Role.NONE)
	match role:
		Role.JOY:
			# Экранная ось Y растёт вниз — для контроллера «вверх пальцем» = вперёд (+1).
			var v := pos - _joy_center
			var rad := _current_radius()
			if v.length() > rad:
				v = v / v.length() * rad
			_joy_vector = Vector2(v.x / maxf(rad, 1.0), -v.y / maxf(rad, 1.0))
			move_changed.emit(_joy_vector)
			_joy_update_visual()
		Role.LOOK:
			look_moved.emit(rel)


func _end(idx: int) -> void:
	var role: int = _roles.get(idx, Role.NONE)
	match role:
		Role.JOY:
			_joy_finger = -1
			_joy_vector = Vector2.ZERO
			move_changed.emit(Vector2.ZERO)
			_joy_update_visual()
	_roles.erase(idx)
	_trace("end idx=%d roles=%s" % [idx, str(_roles.keys())])
