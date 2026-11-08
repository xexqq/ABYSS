extends Node
## AudioManager (autoload) — фоновая подводная атмосфера с зависимостью от глубины.
## Все звуки проходят через шину Master (громкость управляет SettingsManager).

const AMBIENT_PATH := "res://assets/audio/ambient_underwater_loop.ogg"
const DEEP_PATH := "res://assets/audio/ambient_deep_rumble_loop.ogg"
const BUBBLES_PATH := "res://assets/audio/bubbles_loop.ogg"

var _ambient: AudioStreamPlayer   # светлый прибрежный гул (слышен у поверхности)
var _deep: AudioStreamPlayer      # низкочастотный мрачный слой (слышен глубоко)
var _started := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ambient = _make_player(AMBIENT_PATH, -4.0)
	_deep = _make_player(DEEP_PATH, -80.0)
	if SettingsManager:
		SettingsManager.settings_changed.connect(_apply_volumes)


func start_ambient() -> void:
	if _started:
		return
	_started = true
	_ambient.play()
	_deep.play()


## f: 0.0 — поверхность, 1.0 — максимальная глубина (Twilight).
func set_depth_factor(f: float) -> void:
	f = clampf(f, 0.0, 1.0)
	_ambient.volume_db = lerpf(-4.0, -16.0, f)
	_deep.volume_db = lerpf(-42.0, -7.0, f)
	_apply_volumes()


func _apply_volumes() -> void:
	if not SettingsManager:
		return
	var base := linear_to_db(clampf(1.0, 0.0001, 1.0))
	# ambient_volume масштабирует только атмосферный слой по отношению к master.
	var amb_db := linear_to_db(clampf(SettingsManager.ambient_volume, 0.0001, 1.0)) + base
	_ambient.stream_paused = false
	# Относительная громкость через volume_db уже учтена в set_depth_factor;
	# ambient_volume добавляем как сдвиг.
	_ambient.volume_db += amb_db
	_deep.volume_db += amb_db


func _make_player(path: String, vol_db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.name = path.get_file().get_basename()
	var s := load(path)
	if s == null:
		push_warning("AudioManager: missing stream " + path)
		return p
	if s is AudioStreamOggVorbis:
		s.loop = true
	elif s is AudioStreamWAV:
		s.loop_mode = AudioStreamWAV.LOOP_FORWARD
	p.stream = s
	p.volume_db = vol_db
	p.bus = "Master"
	add_child(p)
	return p
