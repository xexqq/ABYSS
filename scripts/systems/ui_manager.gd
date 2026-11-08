extends CanvasLayer
## UIManager — HUD (глубина + зона) и меню паузы. Собирается кодом,
## адаптируется к любому разрешению через anchors.

const SCRIPT_DEPTH := preload("res://scripts/systems/depth_manager.gd")

signal resume_requested
signal return_to_menu_requested

var _depth_label: Label
var _pause_root: Control
var _is_paused := false


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_hud()
	_build_pause_menu()
	_pause_root.visible = false


func _build_hud() -> void:
	_depth_label = Label.new()
	_depth_label.name = "DepthLabel"
	_depth_label.anchor_left = 0.5
	_depth_label.anchor_right = 0.5
	_depth_label.anchor_top = 1.0
	_depth_label.anchor_bottom = 1.0
	_depth_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_depth_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_depth_label.offset_top = -96.0
	_depth_label.offset_bottom = -48.0
	_depth_label.offset_left = -240.0
	_depth_label.offset_right = 240.0
	_depth_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_depth_label.add_theme_font_size_override("font_size", 40)
	_depth_label.add_theme_color_override("font_color", Color(0.92, 0.98, 1.0, 0.95))
	_depth_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	_depth_label.add_theme_constant_override("outline_size", 10)
	add_child(_depth_label)


func _build_pause_menu() -> void:
	_pause_root = Control.new()
	_pause_root.name = "PauseMenu"
	_pause_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_root.mouse_filter = Control.MOUSE_FILTER_STOP  # гасит свайпы под меню
	add_child(_pause_root)

	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.03, 0.06, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_root.add_child(dim)

	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(560, 420)
	panel.position = Vector2(-280, -210)
	panel.add_theme_stylebox_override("panel", _panel_style())
	_pause_root.add_child(panel)

	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.offset_left = 40
	vb.offset_right = -40
	vb.offset_top = 32
	vb.offset_bottom = -32
	vb.add_theme_constant_override("separation", 18)
	panel.add_child(vb)

	var title := Label.new()
	title.text = "ПАУЗА"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 52)
	vb.add_child(title)

	vb.add_child(_menu_button("Продолжить", func(): resume_requested.emit()))
	vb.add_child(_menu_button("Громкость: %d%%" % int(SettingsManager.master_volume * 100.0), _cycle_volume))
	vb.add_child(_menu_button("Чувствительность: %d%%" % int(SettingsManager.camera_sensitivity * 100.0), _cycle_sensitivity))
	vb.add_child(_menu_button("Качество: %s (%d FPS)" % [SettingsManager.quality, SettingsManager.target_fps], _cycle_quality))
	vb.add_child(_menu_button("В главное меню", func(): return_to_menu_requested.emit()))


func _panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.02, 0.10, 0.14, 0.96)
	sb.border_color = Color(0.3, 0.7, 0.8, 0.5)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	return sb


func _menu_button(text: String, action: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 56)
	b.add_theme_font_size_override("font_size", 34)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.22, 0.28, 0.9)
	sb.set_corner_radius_all(10)
	b.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate() as StyleBoxFlat
	sbh.bg_color = Color(0.12, 0.32, 0.4, 1.0)
	b.add_theme_stylebox_override("hover", sbh)
	b.add_theme_stylebox_override("pressed", sbh)
	b.pressed.connect(action)
	return b


func _cycle_volume() -> void:
	var steps := [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
	var cur := 0
	for i in range(steps.size()):
		if absf(steps[i] - SettingsManager.master_volume) < 0.11:
			cur = i
			break
	SettingsManager.master_volume = steps[(cur + 1) % steps.size()]
	SettingsManager.save()
	SettingsManager.apply_all()
	_refresh_pause_buttons()


func _cycle_sensitivity() -> void:
	var steps := [0.3, 0.5, 0.7, 1.0, 1.4, 2.0]
	var cur := 0
	for i in range(steps.size()):
		if absf(steps[i] - SettingsManager.camera_sensitivity) < 0.06:
			cur = i
			break
	SettingsManager.camera_sensitivity = steps[(cur + 1) % steps.size()]
	SettingsManager.save()
	_refresh_pause_buttons()


func _cycle_quality() -> void:
	var order := ["LOW", "MEDIUM", "HIGH"]
	var idx := order.find(SettingsManager.quality)
	SettingsManager.set_quality(order[(idx + 1) % order.size()])
	_refresh_pause_buttons()


func _refresh_pause_buttons() -> void:
	# Кнопки-циклы обновляют подписи: пересобрать панель проще всего.
	for c in _pause_root.get_children():
		c.queue_free()
	_build_pause_menu()
	_pause_root.visible = _is_paused


func set_depth(d: float) -> void:
	_depth_label.text = "Глубина: %.0f м  ·  %s" % [d, SCRIPT_DEPTH.zone_name(d)]


func set_paused(p: bool) -> void:
	_is_paused = p
	_pause_root.visible = p