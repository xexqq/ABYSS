extends Node3D
## UnderwaterParticles — взвесь в воде (GPUParticles3D), следует за игроком.
## Эмит из объёма вокруг камеры, медленный дрейф вверх, билборд-спрайты.
## Количество масштабируется профилем качества.

var _particles: GPUParticles3D
var _player: Node3D


func setup(player: Node3D) -> void:
	_player = player
	global_position = player.global_position if player != null else Vector3.ZERO
	_build()


func _process(_delta: float) -> void:
	if _player != null and is_instance_valid(_player):
		global_position = _player.global_position


func _build() -> void:
	_particles = GPUParticles3D.new()
	_particles.name = "SuspendedMatter"
	var amount := 300
	if SettingsManager:
		var q := String(SettingsManager.get_profile().get("quality", "MEDIUM"))
		amount = {"LOW": 120, "MEDIUM": 300, "HIGH": 520}.get(q, 300)
	_particles.amount = amount
	_particles.lifetime = 14.0
	_particles.preprocess = 14.0
	_particles.visibility_aabb = AABB(Vector3(-40, -30, -40), Vector3(80, 60, 80))

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(34.0, 24.0, 34.0)
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = 12.0
	mat.initial_velocity_min = 0.05
	mat.initial_velocity_max = 0.22
	mat.gravity = Vector3(0.0, 0.01, 0.0)
	mat.scale_min = 0.4
	mat.scale_max = 1.6

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.035, 0.035)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	m.albedo_color = Color(0.85, 0.92, 0.95, 0.10)
	m.vertex_color_use_as_albedo = true
	mesh.material = m

	_particles.process_material = mat
	_particles.draw_pass_1 = mesh
	add_child(_particles)
