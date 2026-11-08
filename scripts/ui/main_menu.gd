extends Control
## MainMenu — функциональное главное меню: Погрузиться / Настройки / Выход.
## Настройки дублируют панель паузы (SettingsManager — источник истины).

var _panel: VBoxContainer
var _settings_root: Control


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.004, 0.008, 0.02, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_panel = VBoxContainer.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.alignment = BoxContainer.ALIGNMENT_CENTER
	_panel.add_theme_constant_override("separation", 26)
	add_child(_panel)

	var title := Label.new()
	title.text = "ABYSS\nPHOBIA EXPERIENCE"
	title.text = "ABYSS — PHOBIA EXPERIENCE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.75, 0.9, 0.95, 0.9))
	_panel.add_child(title)

	_add_button("ПОГРУЗИТЬСЯ", _on_dive)
	_add_button("Настройки", _on_settings)
	_add_button("Выход", _on_quit)


func _add_button(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(360, 64)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.add_theme_font_size_override("font_size", 30)
	b.pressed.connect(cb)
	_panel.add_child(b)
	return b


func _on_dive() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit() -> void:
	get_tree().quit()


func _on_settings() -> void:
	if _settings_root != null:
		return
	_settings_root = _build_settings()
	add_child(_settings_root)


func _build_settings() -> Control:
	var root := ColorRect.new()
	root.color = Color(0.0, 0.0, 0.02, 0.92)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 18)
	root.add_child(vb)

	var h := Label.new()
	h.text = "НАСТРОЙКИ"
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h.add_theme_font_size_override("font_size", 44)
	vb.add_child(h)

	_quality_row(vb, "Качество", ["LOW", "MEDIUM", "HIGH"])
	_quality_row(vb, "FPS", ["30", "60", "120"])
	_slider_row(vb, "Общая громкость", SettingsManager.master_volume, func(v: float) -> void:
		SettingsManager.master_volume = v
		SettingsManager.apply_all())
	_slider_row(vb, "Чувствительность", SettingsManager.camera_sensitivity, func(v: float) -> void:
		SettingsManager.camera_sensitivity = clampf(v, 0.2, 2.0))
	var back := Button.new()
	back.text = "НАЗАД"
	back.custom_minimum_size = Vector2(300, 60)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.add_theme_font_size_override("font_size", 28)
	back.pressed.connect(func() -> void:
		SettingsManager.save()
		root.queue_free()
		_settings_root = null)
	vb.add_child(back)
	return root


func _quality_row(vb: VBoxContainer, label: String, options: Array) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", 26)
	row.add_child(l)
	for o in options:
		var ob := Button.new()
		ob.text = str(o)
		ob.add_theme_font_size_override("font_size", 22)
		ob.pressed.connect(func() -> void:
			if label == "Качество":
				SettingsManager.set_quality(str(o))
			else:
				SettingsManager.target_fps = int(o)
				SettingsManager.apply_all()
				SettingsManager.save())
		row.add_child(ob)
	vb.add_child(row)


func _slider_row(vb: VBoxContainer, label: String, value: float, cb: Callable) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", 26)
	row.add_child(l)
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 2.0 if label == "Чувствительность" else 1.0
	s.step = 0.05
	s.value = value
	s.custom_minimum_size = Vector2(320, 40)
	s.value_changed.connect(cb)
	row.add_child(s)
	vb.add_child(row)
