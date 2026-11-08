extends Node
## DepthManager — отслеживает глубину игрока относительно уровня воды (y = 0)
## и эмитит обновление не чаще чем раз в 0.1 с, чтобы не дёргать UI и рендер каждый кадр.

signal depth_changed(depth_m: float)

const UPDATE_INTERVAL := 0.1
const MIN_DELTA := 0.25

## Игровые ориентиры зон (м), из ТЗ. Arch: Twilight/функциональные зоны готовятся на будущее.
const ZONE_SURFACE := 20.0
const ZONE_REEF := 80.0
const ZONE_OPEN := 300.0
const ZONE_TWILIGHT := 1000.0

var player: Node3D
var current_depth := 0.0
var _accum := 0.0


func _physics_process(delta: float) -> void:
	if player == null:
		return
	_accum += delta
	if _accum < UPDATE_INTERVAL:
		return
	_accum = 0.0
	var d := maxf(0.0, -player.global_position.y)
	if absf(d - current_depth) >= MIN_DELTA:
		current_depth = d
		depth_changed.emit(d)


static func zone_name(depth: float) -> String:
	if depth < ZONE_SURFACE:
		return "Surface"
	elif depth < ZONE_REEF:
		return "Reef"
	elif depth < ZONE_OPEN:
		return "Open Ocean"
	elif depth < ZONE_TWILIGHT:
		return "Twilight"
	return "Abyss"
