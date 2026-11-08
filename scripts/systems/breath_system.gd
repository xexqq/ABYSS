extends Node
## BreathSystem — дыхание игрока: пузырьковый эмиссор от носа при движении,
## периодический «выдох» (bubbles_breath.wav) и пузырьковый луп, громкость
## зависит от скорости плавания. Прикрепляется к камере игрока.

const AUDIO_LOOP := preload("res://assets/audio/bubbles_loop.ogg")
const AUDIO_BREATH := preload("res://assets/audio/bubbles_breath.wav")

var _stream_breath: AudioStream
var _stream_loop: AudioStream
var _snd_loop: AudioStreamPlayer
var _snd_breath: AudioStreamPlayer
var _particles: GPUParticles3D
var _player: Node3D
var _cam: Camera3D
var _breath_timer := 0.0
var _next_breath_in := 26.0


func setup(player: Node3D) -> void:
	_player = player
	_cam = _find_cam(player)
	_snd_loop = AudioStreamPlayer.new()
	_snd_loop.name = "BubbleLoop"
	_snd_loop.stream = _load_stream(AUDIO_LOOP)
	_snd_loop.bus = "Master"
	_snd_loop.volume_db = -18.0
	add_child(_snd_loop)

	_snd_breath = AudioStreamPlayer.new()
	_snd_breath.name = "Breath"
	_snd_breath.stream = _load_stream(AUDIO_BREATH)
	_snd_breath.bus = "Master"
	_snd_breath.volume_db = -10.0
	add_child(_snd_breath)

	_particles = GPUParticles3D.new()
	_particles.name = "BreathBubbles"
	_particles.amount = 40
	_particles.lifetime = 5.0
	_particles.visibility_aabb = AABB(-6, -4, -6, 12, 20, 12)
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 0.28
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 14.0
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.2
	mat.gravity = Vector3(0, 0.8, 0)
	mat.scale_min = 0.5
	mat.scale_max = 2.0
	var mesh := SphereMesh.new()
	mesh.radius = 0.025
	mesh.height = 0.05
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.vertex_color_use_as_albedo = true
	m.albedo_color = Color(1.0, 1.0, 1.0, 0.35)
	mesh.material = m
	_particles.process_material = mat
	_particles.draw_pass_1 = mesh
	_particles.emitting = false
	add_child(_particles)


func _physics_process(delta: float) -> void:
	if _player == null:
		return
	var speed := 0.0
	if _player is RigidBody3D:
		speed = _player.linear_velocity.length()
	elif _player is CharacterBody3D:
		speed = _player.velocity.length()
	var moving := speed > 1.2
	if _cam != null:
		var cam_pos := _cam.global_position
		var up := (-_cam.global_basis.z).normalized()
		_particles.global_position = cam_pos + up * 0.35
		_particles.emitting = moving or _snd_breath.playing
	# Пузырьковый луп: громкость по скорости.
	if moving:
		if not _snd_loop.playing:
			_snd_loop.play()
		_snd_loop.volume_db = lerpf(_snd_loop.volume_db, -12.0 + clampf(speed * 1.4, 0.0, 10.0), 0.06)
	else:
		_snd_loop.volume_db = lerpf(_snd_loop.volume_db, -36.0, 0.04)
		if _snd_loop.volume_db < -30.0:
			_snd_loop.stop()
	# Периодический выдох.
	_breath_timer += delta
	if _breath_timer > _next_breath_in:
		_breath_timer = 0.0
		_next_breath_in = randf_range(18.0, 34.0)
		if moving:
			_snd_breath.play()


func _find_cam(n: Node) -> Camera3D:
	if n is Camera3D:
		return n
	for c in n.get_children():
		var r := _find_cam(c)
		if r != null:
			return r
	return null


func _load_stream(res: AudioStream) -> AudioStream:
	return res
