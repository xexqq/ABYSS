extends Node
## SettingsManager (autoload) — пользовательские настройки, сохранение в user://settings.cfg
## и применение их к движку. Единственный источник истины для конфигурации.

signal settings_changed

const CONFIG_PATH := "user://settings.cfg"

## Профили качества: реальные значения, а не декоративные переключатели.
## fog_density_mult — множитель плотности тумана (меньше = хуже видимость лучше FPS).
## shadow_enabled — тени от направленного солнца.
## scatter_mult — множитель количества объектов мира (применяется при генерации).
## view_distance — базовая дальность видимости (м).
const QUALITY_PROFILES := {
	"LOW": {
		"fog_density_mult": 1.25, "shadow_enabled": false,
		"scatter_mult": 0.6, "view_distance": 150.0,
	},
	"MEDIUM": {
		"fog_density_mult": 1.0, "shadow_enabled": true,
		"scatter_mult": 1.0, "view_distance": 240.0,
	},
	"HIGH": {
		"fog_density_mult": 0.8, "shadow_enabled": true,
		"scatter_mult": 1.35, "view_distance": 340.0,
	},
}

var camera_sensitivity := 0.7   # множитель чувствительности свайпов (0.2...2.0)
var master_volume := 0.8        # 0...1
var ambient_volume := 0.9       # 0...1
var quality := "MEDIUM"         # LOW / MEDIUM / HIGH
var target_fps := 60            # 30 / 60 / 120


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load()
	apply_all()


func _load() -> void:
	var cf := ConfigFile.new()
	if cf.load(CONFIG_PATH) == OK:
		camera_sensitivity = clampf(cf.get_value("input", "camera_sensitivity", camera_sensitivity), 0.2, 2.0)
		master_volume = clampf(cf.get_value("audio", "master_volume", master_volume), 0.0, 1.0)
		ambient_volume = clampf(cf.get_value("audio", "ambient_volume", ambient_volume), 0.0, 1.0)
		var q := str(cf.get_value("graphics", "quality", quality))
		if QUALITY_PROFILES.has(q):
			quality = q
		var fps := int(cf.get_value("graphics", "target_fps", target_fps))
		if fps == 30 or fps == 60 or fps == 120:
			target_fps = fps


func save() -> void:
	var cf := ConfigFile.new()
	cf.set_value("input", "camera_sensitivity", camera_sensitivity)
	cf.set_value("audio", "master_volume", master_volume)
	cf.set_value("audio", "ambient_volume", ambient_volume)
	cf.set_value("graphics", "quality", quality)
	cf.set_value("graphics", "target_fps", target_fps)
	cf.save(CONFIG_PATH)


## Применяет громкость и лимит FPS к движку. Вызывать после смены значений.
func apply_all() -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(clampf(master_volume, 0.0001, 1.0)))
	AudioServer.set_bus_mute(bus, master_volume <= 0.001)
	Engine.max_fps = target_fps
	settings_changed.emit()


func get_profile() -> Dictionary:
	return QUALITY_PROFILES.get(quality, QUALITY_PROFILES["MEDIUM"])


func set_quality(value: String) -> void:
	if QUALITY_PROFILES.has(value) and value != quality:
		quality = value
		save()
		apply_all()
		settings_changed.emit()
