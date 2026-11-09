extends Node
## HeadlessCheck — автоматический E2E-прогон игровых цепочек в headless:
## инстанцирует реальную сцену game.tscn, шлёт настоящие InputEventScreenTouch
## и проверяет: движение джойстика, осмотр камерой, кнопки ↑↓, паузу,
## изменения настроек графики и восстановление управления после них.
## Печатает "RUNTIME_CHECK: OK" или список проваленных проверок; exit code =fails.

var fails: PackedStringArray = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().size = Vector2i(1280, 720)
	_run_check()


func _run_check() -> void:
	var ps := load("res://scenes/game.tscn") as PackedScene
	if ps == null:
		_fail("load", "game.tscn не загрузился")
		_finish()
		return
	add_child(ps.instantiate())
	await _wait_frames(60)

	var game: Node = get_child(get_child_count() - 1)
	var player: CharacterBody3D = game.get_node_or_null("Player")
	var camera: Camera3D = game.get_node_or_null("Player/Camera")
	var controls := game.get_node_or_null("TouchControls")
	var ui := game.get_node_or_null("UIManager")
	if player == null or camera == null or controls == null or ui == null:
		_fail("scene", "отсутствуют Player/Camera/TouchControls/UIManager")
		_finish()
		return
	print("RUNTIME_CHECK: scene ok, viewport=", get_viewport().size)

	var vs: Vector2 = get_viewport().size

	# --- 1. Джойстик: вперёд ---
	var v_before := player.velocity.length()
	_touch(0, vs * Vector2(0.22, 0.72), true)
	_touch_drag(0, vs * Vector2(0.22, 0.45), Vector2(0, -260))  # свайп вверх-вперёд
	await _wait_frames(40)
	var fwd_speed := player.velocity.length()
	print("RUNTIME_CHECK: velocities before=%.2f fwd=%.2f" % [v_before, fwd_speed])
	_assert(fwd_speed > 0.8, "joystick forward", "скорость %.2f" % fwd_speed)
	_touch(0, Vector2.ZERO, false)
	await _wait_frames(30)

	# --- 2. Джойстик: назад/вниз-стрелка ---
	_touch(0, vs * Vector2(0.22, 0.72), true)
	_touch_drag(0, vs * Vector2(0.25, 0.88), Vector2(0, 200))
	await _wait_frames(30)
	print("RUNTIME_CHECK: back velocity=", player.velocity.length())
	_touch(0, Vector2.ZERO, false)
	await _wait_frames(10)

	# --- 3. Камера: свайп справа ---
	var yaw_before: float = camera.global_basis.get_euler().y
	_touch(1, vs * Vector2(0.75, 0.35), true)
	_touch_drag(1, vs * Vector2(0.95, 0.35), Vector2(240, 0))
	_touch_drag(1, vs * Vector2(1.05, 0.35), Vector2(240, 0))
	_touch(1, Vector2.ZERO, false)
	await _wait_frames(30)
	var yaw_after: float = camera.global_basis.get_euler().y
	print("RUNTIME_CHECK: yaw %.3f -> %.3f" % [yaw_before, yaw_after])
	_assert(absf(wrapf(yaw_after - yaw_before, -PI, PI)) > 0.03, "camera swipe", "dyaw %.4f" % (yaw_after - yaw_before))

	# --- 4. Кнопки подъёма/погружения: читаем скорость ВО ВРЕМЯ удержания ---
	var asc := controls._btn_asc as Button
	var desc := controls._btn_desc as Button
	if asc != null and desc != null:
		var c_asc := _global_center(asc)
		_touch(2, c_asc, true)
		await _wait_frames(28)
		var up_vel := player.velocity.y
		print("RUNTIME_CHECK: ascend vy=", up_vel)
		_assert(absf(up_vel) > 0.1, "ascend", "vy %.2f" % up_vel)
		_touch(2, c_asc, false)
		await _wait_frames(10)

		var c_desc := _global_center(desc)
		_touch(2, c_desc, true)
		await _wait_frames(28)
		var dn_vel := player.velocity.y
		print("RUNTIME_CHECK: descend vy=", dn_vel)
		_assert(dn_vel < -0.05, "descend", "vy %.2f" % dn_vel)
		_touch(2, c_desc, false)
		await _wait_frames(10)
	else:
		_fail("buttons", "кнопки ВВЕРХ/ВНИЗ не найдены")

	# --- 5. Пауза через кнопку II ---
	var pause_btn := controls._btn_pause as Button
	if pause_btn != null:
		var c_pause := _global_center(pause_btn)
		_touch(3, c_pause, true)
		await _wait_frames(10)
		_touch(3, c_pause, false)
		await _wait_frames(8)
		_assert(get_tree().paused, "pause open", "paused=%s" % get_tree().paused)

		# --- 6. Настройки: качество + FPS при открытой паузе ---
		SettingsManager.set_quality("LOW")
		await _wait_frames(10)
		SettingsManager.set_quality("MEDIUM")
		await _wait_frames(10)
		SettingsManager.save()
		print("RUNTIME_CHECK: quality changed, paused=", get_tree().paused)

		# --- 7. «Продолжить» — реальным тапом по кнопке ---
		var resume := _find_button_by_text(ui, "Продолжить")
		if resume != null:
			var c_res := _global_center(resume)
			_touch(3, c_res, true)
			await _wait_frames(10)
			_touch(3, c_res, false)
			await _wait_frames(10)
			_assert(not get_tree().paused, "pause resume", "paused=%s" % get_tree().paused)
		else:
			_assert(false, "resume button", "кнопка Продолжить не найдена")

		# --- 8. Управление живо после изменений настроек ---
		_touch(0, vs * Vector2(0.22, 0.72), true)
		_touch_drag(0, vs * Vector2(0.22, 0.45), Vector2(0, -260))
		await _wait_frames(40)
		var after_speed := player.velocity.length()
		print("RUNTIME_CHECK: velocity after settings=%.2f" % after_speed)
		_assert(after_speed > 0.8, "movement after settings", "скорость %.2f" % after_speed)
		_touch(0, Vector2.ZERO, false)

		# --- 9. HUD жив ---
		var label: Label = _find_label(ui)
		_assert(label != null and label.is_visible_in_tree(), "hud depth label", "нет/скрыт")
		# --- 10. Отпускания не оставляют активных пальцев ---
		_assert(controls._roles.is_empty(), "roles cleared", "остались %s" % str(controls._roles.keys()))
	else:
		_fail("pause button", "II не найден")

	_finish()


# --- helpers -----------------------------------------------------------

func _touch(idx: int, pos: Vector2, pressed: bool) -> void:
	var e := InputEventScreenTouch.new()
	e.index = idx
	e.position = pos
	e.pressed = pressed
	Input.parse_input_event(e)


func _touch_drag(idx: int, to: Vector2, rel: Vector2) -> void:
	var e := InputEventScreenDrag.new()
	e.index = idx
	e.position = to
	e.relative = rel
	Input.parse_input_event(e)


func _tap_button(b: Button, idx: int, hold: int) -> void:
	var c := _global_center(b)
	_touch(idx, c, true)
	await _wait_frames(hold)
	_touch(idx, c, false)
	await _wait_frames(6)


func _global_center(c: Control) -> Vector2:
	return c.get_global_rect().get_center()


func _find_button_by_text(root: Node, text: String) -> Button:
	if root is Button and (root as Button).text == text:
		return root
	for ch in root.get_children():
		var f := _find_button_by_text(ch, text)
		if f != null:
			return f
	return null


func _find_label(root: Node) -> Label:
	if root is Label and (root as Label).text.contains("Глубина"):
		return root
	for ch in root.get_children():
		var f := _find_label(ch)
		if f != null:
			return f
	return null


func _assert(cond: bool, name_: String, detail: String) -> void:
	if cond:
		print("RUNTIME_CHECK: %s PASS" % name_)
	else:
		_fail(name_, detail)


func _fail(name_: String, detail: String) -> void:
	fails.append("%s: %s" % [name_, detail])
	print("RUNTIME_CHECK: %s FAIL — %s" % [name_, detail])


func _wait_frames(n: int) -> void:
	for i in range(n):
		await get_tree().process_frame


func _finish() -> void:
	if fails.is_empty():
		print("RUNTIME_CHECK: OK")
		get_tree().quit(0)
	else:
		print("RUNTIME_CHECK: FAIL (%d): %s" % [fails.size(), ", ".join(fails)])
		get_tree().quit(1)
