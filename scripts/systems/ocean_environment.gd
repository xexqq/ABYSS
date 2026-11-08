extends Node
## OceanEnvironment — процедурная локация «The Beginning».
## Создаёт в рантайме: рельефное дно (sand triplanar), поверхность воды (шейдер),
## солнце + WorldEnvironment, скальные массивы (MultiMesh), пещерный кит (Kenney
## Modular Cave Kit), подводные трубы, обломок корабля. Все меши берём из assets/.

const WATER_Y := 0.0
const WORLD_HALF := 300.0      # радиус мира (м); за r>400 — бездна, скрытая туманом
const GRID_N := 128            # сетка дна: 128×128 ячеек (16,5k вершин)

const SAND_DIFF := "res://assets/textures/sand_01/sand_01_diff_1k.jpg"
const SAND_NORM := "res://assets/textures/sand_01/sand_01_nor_gl_1k.jpg"
const CORAL_DIFF := "res://assets/textures/coral_gravel/coral_gravel_diff_1k.jpg"
const CORAL_NORM := "res://assets/textures/coral_gravel/coral_gravel_nor_gl_1k.jpg"
const ROCK_01 := "res://assets/models/rocks/rockface01/rock_face_01_2k.gltf"
const ROCK_02 := "res://assets/models/rocks/rockface02/rock_face_02_2k.gltf"
const CAVES := [
	"res://assets/models/caves/room-large.glb",
	"res://assets/models/caves/room-small.glb",
	"res://assets/models/caves/room-wide.glb",
	"res://assets/models/caves/corridor.glb",
]
const PIPES := "res://assets/models/environment/pipes/modular_industrial_pipes_01_2k.gltf"
const WRECK := "res://assets/models/wrecks/dutch_ship_medium_2k.gltf"

var environment_res: Environment
var sun: DirectionalLight3D
var water_material: ShaderMaterial
var _rng: RandomNumberGenerator


func build(world_root: Node3D) -> void:
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	_build_terrain(world_root)
	_build_water(world_root)
	_build_light_and_env(world_root)
	_scatter_rocks(world_root)
	_place_set_pieces(world_root)


## Высота дна в точке — публичный API для спавна объектов и будущего AI.
func terrain_height(x: float, z: float) -> float:
	var r := sqrt(x * x + z * z)
	var base: float
	if r < 60.0:
		base = -4.0 - r * 0.2           # приподнятое рифовое плато: -4 → -16
	elif r < 190.0:
		var t := clampf((r - 60.0) / 130.0, 0.0, 1.0)
		base = lerpf(-16.0, -95.0, t * t * (3.0 - 2.0 * t))  # склон к открытому океану
	else:
		var t2 := clampf((r - 190.0) / 170.0, 0.0, 1.0)
		base = lerpf(-95.0, -260.0, t2) # бездна
	var amp := lerpf(6.0, 20.0, clampf(r / 200.0, 0.0, 1.0))
	return base + _noise().get_noise_2d(x * 0.011, z * 0.011) * amp


static var _noise_cache: FastNoiseLite


static func _noise() -> FastNoiseLite:
	if _noise_cache == null:
		var n := FastNoiseLite.new()
		n.seed = 1911
		n.noise_type = FastNoiseLite.TYPE_SIMPLEX
		n.fractal_octaves = 3
		n.fractal_gain = 0.5
		_noise_cache = n
	return _noise_cache


# ---------------------------------------------------------------- terrain ---

func _build_terrain(root: Node3D) -> void:
	var n := GRID_N
	var count := n + 1
	var step := (WORLD_HALF * 2.0) / n
	var half := WORLD_HALF
	# высоты и UV
	var verts := PackedVector3Array(); verts.resize(count * count)
	var norm := PackedVector3Array(); norm.resize(count * count)
	var tang := PackedFloat32Array(); tang.resize(count * count * 4)
	var uvs := PackedVector2Array(); uvs.resize(count * count)
	for j in range(count):
		for i in range(count):
			var x := -half + i * step
			var z := -half + j * step
			var y := terrain_height(x, z)
			verts[j * count + i] = Vector3(x, y, z)
			uvs[j * count + i] = Vector2(i / float(n), j / float(n))
	# нормали (finite difference) + касательные
	var e := step
	for j in range(count):
		for i in range(count):
			var x := verts[j * count + i].x
			var z := verts[j * count + i].z
			var nx := terrain_height(x - e, z) - terrain_height(x + e, z)
			var nz := terrain_height(x, z - e) - terrain_height(x, z + e)
			var nv := Vector3(nx, 2.0 * e, nz).normalized()
			norm[j * count + i] = nv
			var tv := (Vector3(1.0, 0.0, 0.0) - nv * nv.x)
			if tv.length() < 0.05:
				tv = Vector3(0.0, 0.0, 1.0)
			tv = tv.normalized()
			var o := (j * count + i) * 4
			tang[o] = tv.x; tang[o + 1] = tv.y; tang[o + 2] = tv.z; tang[o + 3] = 1.0
	# индексы (обход CCW, нормаль вверх)
	var idx := PackedInt32Array(); idx.resize(n * n * 6)
	var w := 0
	for j in range(n):
		for i in range(n):
			var a := j * count + i
			var b := j * count + i + 1
			var c := (j + 1) * count + i + 1
			var d := (j + 1) * count + i
			idx[w] = a; idx[w + 1] = d; idx[w + 2] = b
			idx[w + 3] = b; idx[w + 4] = d; idx[w + 5] = c
			w += 6
	var arrays := []; arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_NORMAL] = norm
	arrays[Mesh.ARRAY_TANGENT] = tang
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = idx
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	mesh.surface_set_material(0, _terrain_material(false))
	var mi := MeshInstance3D.new()
	mi.name = "Terrain"
	mi.mesh = mesh
	root.add_child(mi)


func _terrain_material(coral: bool) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load(CORAL_DIFF if coral else SAND_DIFF)
	mat.normal_enabled = true
	mat.normal_texture = load(CORAL_NORM if coral else SAND_NORM)
	mat.normal_scale = 0.7
	mat.roughness = 0.95
	mat.uv1_triplanar = true
	mat.uv1_world_triplanar = true
	mat.uv1_scale = Vector3(0.07, 0.07, 0.07)
	return mat


# ------------------------------------------------------------------ water ---

func _build_water(root: Node3D) -> void:
	var pm := PlaneMesh.new()
	pm.size = Vector2(1200.0, 1200.0)
	pm.subdivide_width = 80
	pm.subdivide_depth = 80
	var mat := ShaderMaterial.new()
	var sh := load("res://assets/shaders/water_surface.gdshader") as Shader
	mat.shader = sh
	water_material = mat
	var mi := MeshInstance3D.new()
	mi.name = "WaterSurface"
	mi.mesh = pm
	mi.material_override = mat
	mi.position = Vector3(0.0, WATER_Y, 0.0)
	root.add_child(mi)


# ------------------------------------------------------------- light + env ---

func _build_light_and_env(root: Node3D) -> void:
	sun = DirectionalLight3D.new()
	sun.name = "Sun"
	sun.basis = Basis.from_euler(Vector3(deg_to_rad(-64.0), deg_to_rad(25.0), 0.0))
	sun.light_energy = 1.3
	sun.light_color = Color(1.0, 0.98, 0.92)
	sun.shadow_enabled = true
	root.add_child(sun)

	environment_res = Environment.new()
	environment_res.background_mode = Environment.BG_COLOR
	environment_res.background_color = Color(0.012, 0.18, 0.25)
	environment_res.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_res.ambient_light_color = Color(0.02, 0.25, 0.32)
	environment_res.ambient_light_energy = 1.2
	environment_res.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment_res.fog_enabled = true
	environment_res.fog_light_color = Color(0.02, 0.25, 0.33)
	environment_res.fog_density = 0.028
	var we := WorldEnvironment.new()
	we.name = "WorldEnvironment"
	we.environment = environment_res
	root.add_child(we)


# ---------------------------------------------------------------- scatter ---

func _mesh_from_scene(path: String) -> Mesh:
	var ps := load(path) as PackedScene
	if ps == null:
		push_warning("OceanEnvironment: не загрузилась сцена " + path)
		return null
	var inst := ps.instantiate()
	var mesh := _find_mesh(inst)
	if mesh != null:
		mesh = mesh.duplicate()
	inst.free()
	return mesh


func _find_mesh(node: Node) -> Mesh:
	if node is MeshInstance3D and (node as MeshInstance3D).mesh != null:
		return (node as MeshInstance3D).mesh
	for c in node.get_children():
		var m := _find_mesh(c)
		if m != null:
			return m
	return null


func _scatter(parent: Node3D, mesh: Mesh, count: int, r_min: float, r_max: float,
		s_min: float, s_max: float, sink: float) -> void:
	if mesh == null or count <= 0:
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = count
	for i in range(count):
		var r := _rng.randf_range(r_min, r_max)
		var a := _rng.randf() * TAU
		var x := cos(a) * r
		var z := sin(a) * r
		var y := terrain_height(x, z) - _rng.randf_range(0.2, sink)
		var basis := Basis.from_euler(Vector3(
			_rng.randf_range(-0.22, 0.22), _rng.randf() * TAU, _rng.randf_range(-0.22, 0.22)))
		var s := _rng.randf_range(s_min, s_max)
		mm.set_instance_transform(i, Transform3D(basis.scaled(Vector3(s, s, s)), Vector3(x, y, z)))
	var mmi := MultiMeshInstance3D.new()
	mmi.name = "RockScatter"
	mmi.multimesh = mm
	mmi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mmi)


func _scatter_rocks(root: Node3D) -> void:
	var mult := _scatter_mult()
	# Прибрежные скалы-утёсы на рифе и склоне.
	_scatter(root, _mesh_from_scene(ROCK_01), int(16 * mult), 30.0, 150.0, 1.2, 3.0, 2.5)
	# Глубокие массивы у бездны.
	_scatter(root, _mesh_from_scene(ROCK_02), int(12 * mult), 130.0, 280.0, 1.6, 4.2, 3.0)


func _scatter_mult() -> float:
	if SettingsManager:
		return float(SettingsManager.get_profile().get("scatter_mult", 1.0))
	return 1.0


# ------------------------------------------------------------- set pieces ---

func _place_set_pieces(root: Node3D) -> void:
	# Пещеры на плато (риск застрять — отделяемые позже; на этапе 1 декор).
	var s := 2.0
	var spots := [
		[Vector2(42.0, 30.0), 0.6, "res://assets/models/caves/room-large.glb"],
		[Vector2(-50.0, 44.0), 2.4, "res://assets/models/caves/room-small.glb"],
		[Vector2(18.0, -60.0), 4.1, "res://assets/models/caves/room-wide.glb"],
		[Vector2(-30.0, -52.0), 1.4, "res://assets/models/caves/corridor.glb"],
	]
	for sp in spots:
		var p: Vector2 = sp[0]
		_place_scene(root, sp[2], Vector3(p.x, terrain_height(p.x, p.y) + 0.6 * s - 1.0, p.y), Vector3(0.0, float(sp[1]), 0.0), s)
	# Подводные трубы — индустриальный контраст на склоне рифа.
	var pipe_scale := 1.1
	_place_scene(root, PIPES, Vector3(88.0, terrain_height(88.0, -36.0) + 0.8, -36.0), Vector3(0.0, 0.9, 0.0), pipe_scale)
	_place_scene(root, PIPES, Vector3(56.0, terrain_height(56.0, -78.0) + 0.8, -78.0), Vector3(0.0, 2.4, 0.0), pipe_scale)
	# Обломок корабля на склоне у границы Open Ocean.
	var wr_pos := Vector3(150.0, 0.0, 140.0)
	wr_pos.y = terrain_height(150.0, 140.0) + 2.0
	_place_scene(root, WRECK, wr_pos, Vector3(0.32, 2.15, 0.0), 1.0)


func _place_scene(parent: Node3D, path: String, pos: Vector3, rot: Vector3, s: float) -> void:
	var ps := load(path) as PackedScene
	if ps == null:
		push_warning("OceanEnvironment: не загрузилась сцена " + path)
		return
	var inst := ps.instantiate()
	inst.position = pos
	inst.basis = Basis.from_euler(rot)
	inst.scale = Vector3(s, s, s)
	parent.add_child(inst)
