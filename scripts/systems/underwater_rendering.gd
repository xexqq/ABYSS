extends Node
## UnderwaterRendering — меняет атмосферу (цвет тумана/солнца, плотность, ambient)
## по мере погружения игрока. Значения интерполируются по якорям глубины,
## плотность тумана и тени масштабируются профилем качества из SettingsManager.

## Якоря по глубине: [глубина_м, цвет_тумана, множитель_плотности, энергия_солнца]
const DEPTH_ANCHORS := [
	[0.0, Color(0.02, 0.28, 0.34), 0.45, 1.35],
	[20.0, Color(0.012, 0.19, 0.27), 0.7, 0.95],
	[80.0, Color(0.006, 0.10, 0.17), 1.1, 0.4],
	[300.0, Color(0.002, 0.045, 0.09), 1.7, 0.12],
	[1000.0, Color(0.0, 0.014, 0.04), 2.4, 0.05],
]
const BASE_FOG_DENSITY := 0.028

var _env: Environment
var _sun: DirectionalLight3D
var _last_depth := 0.0


func _ready() -> void:
	if SettingsManager:
		SettingsManager.settings_changed.connect(_on_settings_changed)


## Основная точка входа — подключается к сигналу DepthManager.depth_changed.
func set_depth(depth_m: float) -> void:
	_last_depth = depth_m
	if _env != null:
		_apply(depth_m)


func setup(env: Environment, sun: DirectionalLight3D) -> void:
	_env = env
	_sun = sun
	_apply(_last_depth)


func _on_settings_changed() -> void:
	if _env != null:
		_apply(_last_depth)


func _apply(depth_m: float) -> void:
	var profile: Dictionary = SettingsManager.get_profile() if SettingsManager else {}
	var t: Dictionary = _lerp_anchors(depth_m)
	var fog_color: Color = t["color"]
	# Туман: цвет и плотность (влияет и на дальность восприятия).
	_env.fog_light_color = fog_color
	_env.fog_density = BASE_FOG_DENSITY * float(t["dens_mult"]) * float(profile.get("fog_density_mult", 1.0))
	_env.background_color = fog_color.darkened(0.15)
	# Солнце: гаснет и синеет с глубиной; тени — по профилю качества.
	if _sun != null:
		_sun.light_energy = float(t["sun_energy"])
		_sun.light_color = Color(1.0, 1.0, 1.0).lerp(Color(0.45, 0.75, 0.9), clampf(depth_m / 300.0, 0.0, 1.0))
		_sun.shadow_enabled = bool(profile.get("shadow_enabled", true))
	# Ambient: мягкая равномерная подводная подсветка, гаснет с глубиной.
	_env.ambient_light_color = fog_color
	_env.ambient_light_energy = lerpf(1.25, 0.55, clampf(depth_m / 200.0, 0.0, 1.0))


static func _lerp_anchors(depth_m: float) -> Dictionary:
	var lo: Array = DEPTH_ANCHORS[0]
	var hi: Array = DEPTH_ANCHORS[1]
	var last_i := DEPTH_ANCHORS.size() - 1
	for i in range(1, DEPTH_ANCHORS.size()):
		lo = DEPTH_ANCHORS[i - 1]
		hi = DEPTH_ANCHORS[i]
		if depth_m < float(hi[0]):
			break
	if depth_m >= float(DEPTH_ANCHORS[last_i][0]):
		lo = DEPTH_ANCHORS[last_i - 1]
		hi = DEPTH_ANCHORS[last_i]
	var denom := maxf(float(hi[0]) - float(lo[0]), 1.0)
	var f := clampf((depth_m - float(lo[0])) / denom, 0.0, 1.0)
	return {
		"color": (lo[1] as Color).lerp(hi[1] as Color, f),
		"dens_mult": lerpf(float(lo[2]), float(hi[2]), f),
		"sun_energy": lerpf(float(lo[3]), float(hi[3]), f),
	}
