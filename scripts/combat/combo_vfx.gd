extends Node3D
class_name ComboVFX

@export var effect_lifetime: float = 0.22
@export var spark_lifetime: float = 0.18

const COMBO_COLORS: Array[Color] = [
	Color(0.55, 0.82, 1.0, 0.95),
	Color(0.72, 0.88, 1.0, 0.95),
	Color(0.95, 0.98, 1.0, 1.0)
]

func play_attack(combo_index: int, heavy: bool, forward: Vector3, hit_positions: Array[Vector3], weapon_form: int = 0) -> void:
	var direction := Vector3(forward.x, 0.0, forward.z).normalized()
	if direction.length_squared() < 0.001:
		direction = Vector3.FORWARD
	var origin := get_parent().global_position + Vector3.UP * (1.12 if not heavy else 1.0)
	_spawn_slash(origin, direction, combo_index, heavy, false, weapon_form)
	if not heavy and combo_index == 3:
		_spawn_slash(origin + Vector3.UP * 0.08, direction, 2, false, true, weapon_form)
	for hit_position in hit_positions:
		var impact_position := hit_position + Vector3.UP * 0.85
		_spawn_impact(impact_position, combo_index, heavy)
		_spawn_sparks(impact_position, direction, heavy)
	if heavy and not hit_positions.is_empty():
		_spawn_shock_ring(hit_positions[0])


func play_element_burst(origin: Vector3, tint: Color, radius: float) -> void:
	var burst := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.0
	burst.mesh = sphere
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(tint.r, tint.g, tint.b, 0.28)
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 2.8
	burst.material_override = material
	get_tree().current_scene.add_child(burst)
	burst.global_position = origin + Vector3.UP * 0.85
	_animate_mesh(burst, material, 0.38, Vector3.ONE * 0.2, Vector3.ONE * radius * 2.0)
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.48
	torus.outer_radius = 0.56
	ring.mesh = torus
	var ring_material := StandardMaterial3D.new()
	ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.albedo_color = tint
	ring_material.emission_enabled = true
	ring_material.emission = tint
	ring_material.emission_energy_multiplier = 3.0
	ring.material_override = ring_material
	get_tree().current_scene.add_child(ring)
	ring.global_position = origin + Vector3.UP * 0.06
	ring.rotation.x = deg_to_rad(90.0)
	_animate_mesh(ring, ring_material, 0.42, Vector3.ONE * 0.25, Vector3.ONE * radius * 1.8)

func _spawn_slash(origin: Vector3, direction: Vector3, combo_index: int, heavy: bool, echo: bool = false, weapon_form: int = 0) -> void:
	var slash := MeshInstance3D.new()
	slash.mesh = _build_arc_mesh(1.35 if not heavy else 1.7, 0.78 if not heavy else 0.92)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var form_colors := [Color(0.72, 0.88, 1.0), Color(1.0, 0.68, 0.32), Color(0.72, 0.48, 1.0), Color(0.38, 0.92, 0.9)]
	var form_color: Color = form_colors[clampi(weapon_form, 0, 3)]
	material.albedo_color = Color(form_color.r, form_color.g, form_color.b, 0.48) if echo else (Color(form_color.r, form_color.g, form_color.b, 0.96) if heavy else Color(form_color.r, form_color.g, form_color.b, COMBO_COLORS[clampi(combo_index - 1, 0, 2)].a))
	material.emission_enabled = true
	material.emission = form_color * (1.5 if not heavy else 2.2)
	material.emission_energy_multiplier = 1.8 if not heavy else 2.7
	slash.material_override = material
	get_tree().current_scene.add_child(slash)
	slash.global_position = origin + direction * (0.72 if not echo else 0.78)
	slash.global_basis = Basis.looking_at(direction, Vector3.UP)
	slash.rotation.z = deg_to_rad([-28.0, 24.0, 72.0][clampi(combo_index - 1, 0, 2)] if not heavy else -8.0)
	_animate_mesh(slash, material, effect_lifetime * (1.0 if not echo else 0.8), Vector3(1.0, 1.0, 1.0), Vector3(1.28, 1.12, 1.0))

func _spawn_impact(position: Vector3, combo_index: int, heavy: bool) -> void:
	var burst := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.13 if not heavy else 0.22
	sphere.height = sphere.radius * 2.0
	burst.mesh = sphere
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.65, 0.86, 1.0, 0.95) if not heavy else Color(0.9, 0.96, 1.0, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.35, 0.68, 1.0) if not heavy else Color(0.7, 0.88, 1.0)
	material.emission_energy_multiplier = 2.4
	burst.material_override = material
	get_tree().current_scene.add_child(burst)
	burst.global_position = position
	_animate_mesh(burst, material, spark_lifetime, Vector3(0.35, 0.35, 0.35), Vector3(1.8, 1.8, 1.8))

func _spawn_sparks(position: Vector3, forward: Vector3, heavy: bool) -> void:
	var spark_count := 7 if heavy else 4
	for i in range(spark_count):
		var spark := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(0.035, 0.035, 0.28 if heavy else 0.18)
		spark.mesh = box
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(0.72, 0.9, 1.0, 0.95)
		material.emission_enabled = true
		material.emission = Color(0.4, 0.72, 1.0)
		material.emission_energy_multiplier = 2.0
		spark.material_override = material
		get_tree().current_scene.add_child(spark)
		spark.global_position = position
		var spread := Vector3(randf_range(-0.8, 0.8), randf_range(-0.25, 0.8), randf_range(-0.7, 0.7))
		var travel := (forward * 0.4 + spread).normalized()
		spark.look_at(spark.global_position + travel, Vector3.UP)
		_animate_mesh(spark, material, spark_lifetime, Vector3.ONE, Vector3(0.25, 0.25, 0.25))
		var move_tween := spark.create_tween()
		move_tween.tween_property(spark, "global_position", position + travel * (0.65 if heavy else 0.4), spark_lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _spawn_shock_ring(position: Vector3) -> void:
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.55
	torus.outer_radius = 0.72
	ring.mesh = torus
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.55, 0.82, 1.0, 0.8)
	material.emission_enabled = true
	material.emission = Color(0.35, 0.68, 1.0)
	material.emission_energy_multiplier = 2.6
	ring.material_override = material
	get_tree().current_scene.add_child(ring)
	ring.global_position = position + Vector3.UP * 0.08
	ring.rotation.x = deg_to_rad(90.0)
	_animate_mesh(ring, material, 0.28, Vector3(0.45, 0.45, 0.45), Vector3(2.0, 2.0, 2.0))

func _animate_mesh(mesh_instance: MeshInstance3D, material: StandardMaterial3D, lifetime: float, start_scale: Vector3, end_scale: Vector3) -> void:
	mesh_instance.scale = start_scale
	var tween := mesh_instance.create_tween()
	tween.set_parallel(true)
	tween.tween_property(mesh_instance, "scale", end_scale, lifetime).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color:a", 0.0, lifetime)
	tween.chain().tween_callback(mesh_instance.queue_free)

func _build_arc_mesh(outer_radius: float, inner_radius: float) -> ArrayMesh:
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var segments := 22
	for i in range(segments + 1):
		var angle := deg_to_rad(-78.0 + 156.0 * float(i) / float(segments))
		var outer := Vector3(cos(angle) * outer_radius, sin(angle) * outer_radius, 0.0)
		var inner := Vector3(cos(angle) * inner_radius, sin(angle) * inner_radius, -0.015)
		vertices.append(outer)
		vertices.append(inner)
		normals.append(Vector3.FORWARD)
		normals.append(Vector3.FORWARD)
	for i in range(segments):
		var base := i * 2
		indices.append_array(PackedInt32Array([base, base + 1, base + 2, base + 1, base + 3, base + 2]))
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return result
