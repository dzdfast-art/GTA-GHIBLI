extends RefCounted

## Adds small, collision-aware public-space furnishings to Willow Village.
## Geometry stays modular and light enough for the Android renderer.

const PAVING_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_market_pavers.svg")
const WOOD_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_market_wood.svg")
const FOLIAGE_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_foliage_detail.svg")


static func build(village: Node3D) -> void:
	var details := Node3D.new()
	details.name = "VillageLifeDetails"
	village.add_child(details)
	_build_square_paving(details)
	_build_benches(details)
	_build_planters(details)
	_build_waste_bin(details)


static func _build_square_paving(parent: Node3D) -> void:
	var paving := MeshInstance3D.new()
	paving.name = "VillageSquarePaving"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(6.8, 0.018, 6.8)
	paving.mesh = mesh
	paving.position = Vector3(0.0, 0.078, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.92, 0.90, 0.84)
	material.albedo_texture = PAVING_TEXTURE
	material.uv1_scale = Vector3(2.8, 1.0, 2.8)
	material.roughness = 0.98
	paving.material_override = material
	parent.add_child(paving)


static func _build_benches(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-3.85, 0.0, 2.85),
		Vector3(3.85, 0.0, -2.85)
	]
	for index in range(positions.size()):
		var bench := StaticBody3D.new()
		bench.name = "VillageBench_%02d" % index
		bench.position = positions[index]
		bench.collision_layer = 1
		bench.collision_mask = 1
		parent.add_child(bench)
		var collision := CollisionShape3D.new()
		var collision_shape := BoxShape3D.new()
		collision_shape.size = Vector3(1.92, 1.08, 0.82)
		collision.shape = collision_shape
		collision.position = Vector3(0.0, 0.53, 0.0)
		bench.add_child(collision)
		var wood := _material(Color(0.70, 0.50, 0.31), WOOD_TEXTURE)
		var dark_wood := _material(Color(0.34, 0.23, 0.15), WOOD_TEXTURE)
		for plank_index in range(5):
			_add_box(bench, "SeatPlank_%02d" % plank_index,
				Vector3(1.76, 0.075, 0.14),
				Vector3(0.0, 0.56, -0.30 + float(plank_index) * 0.15), wood)
		for back_index in range(3):
			_add_box(bench, "BackPlank_%02d" % back_index,
				Vector3(1.76, 0.12, 0.085),
				Vector3(0.0, 0.77 + float(back_index) * 0.17, -0.36), wood)
		for side in [-1.0, 1.0]:
			_add_box(bench, "BenchLeg_%s" % str(side),
				Vector3(0.13, 0.52, 0.14), Vector3(side * 0.72, 0.27, 0.0), dark_wood)
			_add_box(bench, "BackSupport_%s" % str(side),
				Vector3(0.11, 0.88, 0.12), Vector3(side * 0.72, 0.72, -0.34), dark_wood)


static func _build_planters(parent: Node3D) -> void:
	var positions: Array[Vector3] = [
		Vector3(-4.65, 0.0, -4.55),
		Vector3(4.65, 0.0, 4.55)
	]
	for index in range(positions.size()):
		var planter := StaticBody3D.new()
		planter.name = "PlazaPlanter_%02d" % index
		planter.position = positions[index]
		planter.collision_layer = 1
		planter.collision_mask = 1
		parent.add_child(planter)
		var collision := CollisionShape3D.new()
		var collision_shape := BoxShape3D.new()
		collision_shape.size = Vector3(1.34, 0.62, 0.80)
		collision.shape = collision_shape
		collision.position.y = 0.31
		planter.add_child(collision)
		var stone := _material(Color(0.54, 0.53, 0.48))
		var soil := _material(Color(0.25, 0.18, 0.12))
		_add_box(planter, "StonePlanter", Vector3(1.34, 0.48, 0.80),
			Vector3(0.0, 0.24, 0.0), stone)
		_add_box(planter, "PlanterSoil", Vector3(1.12, 0.06, 0.58),
			Vector3(0.0, 0.50, 0.0), soil)
		for shrub_index in range(3):
			var shrub_mesh := SphereMesh.new()
			shrub_mesh.radius = 0.31
			shrub_mesh.height = 0.48
			shrub_mesh.radial_segments = 9
			shrub_mesh.rings = 6
			var shrub_material := StandardMaterial3D.new()
			shrub_material.albedo_color = Color(0.68, 0.85, 0.48)
			shrub_material.albedo_texture = FOLIAGE_TEXTURE
			shrub_material.uv1_scale = Vector3(1.2, 1.2, 1.2)
			shrub_material.roughness = 1.0
			var shrub := MeshInstance3D.new()
			shrub.name = "Shrub_%02d" % shrub_index
			shrub.mesh = shrub_mesh
			shrub.position = Vector3(-0.34 + float(shrub_index) * 0.34, 0.70, 0.0)
			shrub.material_override = shrub_material
			planter.add_child(shrub)


static func _build_waste_bin(parent: Node3D) -> void:
	var bin := StaticBody3D.new()
	bin.name = "VillageWasteBin_00"
	bin.position = Vector3(-5.0, 0.0, 1.55)
	bin.collision_layer = 1
	bin.collision_mask = 1
	parent.add_child(bin)
	var collision := CollisionShape3D.new()
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = 0.31
	cylinder_shape.height = 0.90
	collision.shape = cylinder_shape
	collision.position.y = 0.45
	bin.add_child(collision)
	var body_mesh := CylinderMesh.new()
	body_mesh.top_radius = 0.30
	body_mesh.bottom_radius = 0.34
	body_mesh.height = 0.84
	body_mesh.radial_segments = 12
	_add_mesh(bin, "BinBody", body_mesh, Vector3(0.0, 0.42, 0.0),
		_material(Color(0.30, 0.37, 0.37)))
	var lid_mesh := CylinderMesh.new()
	lid_mesh.top_radius = 0.34
	lid_mesh.bottom_radius = 0.34
	lid_mesh.height = 0.075
	lid_mesh.radial_segments = 12
	_add_mesh(bin, "BinLid", lid_mesh, Vector3(0.0, 0.86, 0.0),
		_material(Color(0.17, 0.23, 0.24)))
	_add_box(bin, "BinSlot", Vector3(0.30, 0.065, 0.045),
		Vector3(0.0, 0.67, 0.305), _material(Color(0.07, 0.09, 0.09)))


static func _add_box(parent: Node3D, node_name: String, size: Vector3,
		position: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _add_mesh(parent, node_name, mesh, position, material)


static func _add_mesh(parent: Node3D, node_name: String, mesh: Mesh,
		position: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	parent.add_child(instance)
	return instance


static func _material(color: Color, texture: Texture2D = null) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if texture != null:
		material.albedo_texture = texture
		material.uv1_scale = Vector3(1.4, 1.4, 1.4)
	material.roughness = 0.96
	return material
