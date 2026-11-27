extends Node3D
class_name ComboVFX

@export var effect_lifetime: float = 0.22
@export var spark_lifetime: float = 0.18

const COMBO_COLORS: Array[Color] = [
	Color(0.55, 0.82, 1.0, 0.95),
	Color(0.72, 0.88, 1.0, 0.95),
	Color(0.95, 0.98, 1.0, 1.0)
]

func play_attack(combo_index: int, heavy: bool, forward: Vector3, hit_positions: Array[Vector3]) -> void:
	var direction := Vector3(forward.x, 0.0, forward.z).normalized()
	if direction.length_squared() < 0.001:
		direction = Vector3.FORWARD
	var origin := get_parent().global_position + Vector3.UP * (1.12 if not heavy else 1.0)
	_spawn_slash(origin, direction, combo_index, heavy)
	for hit_position in hit_positions:
		_spawn_impact(hit_position + Vector3.UP * 0.85, combo_index, heavy)

func _spawn_slash(origin: Vector3, direction: Vector3, combo_index: int, heavy: bool) -> void:
	var slash := MeshInstance3D.new()
	slash.mesh = _build_arc_mesh(1.35 if not heavy else 1.7, 0.78 if not heavy else 0.92)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = Color(0.9, 0.96, 1.0, 0.92) if heavy else COMBO_COLORS[clampi(combo_index - 1, 0, 2)]
	material.emission_enabled = true
	material.emission = Color(0.42, 0.72, 1.0) if not heavy else Color(0.8, 0.92, 1.0)
	material.emission_energy_multiplier = 1.8 if not heavy else 2.7
	slash.material_override = material
	get_tree().current_scene.add_child(slash)
	slash.global_position = origin + direction * 0.72
	slash.global_basis = Basis.looking_at(direction, Vector3.UP)
	slash.rotation.z = deg_to_rad([-28.0, 24.0, 72.0][clampi(combo_index - 1, 0, 2)] if not heavy else -8.0)
	_animate_mesh(slash, material, effect_lifetime, Vector3(1.0, 1.0, 1.0), Vector3(1.28, 1.12, 1.0))

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
