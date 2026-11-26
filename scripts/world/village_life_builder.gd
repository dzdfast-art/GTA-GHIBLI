extends RefCounted

## Adds small, collision-aware public-space furnishings to Willow Village.
## Geometry stays modular and light enough for the Android renderer.

const PAVING_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_market_pavers.svg")
const WOOD_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_market_wood.svg")
const FOLIAGE_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_foliage_detail.svg")
const WELL_STONE_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_well_stone.svg")


static func build(village: Node3D) -> void:
	var details := Node3D.new()
	details.name = "VillageLifeDetails"
	village.add_child(details)
	_build_square_paving(details)
	_build_benches(details)
	_build_planters(details)
	_build_waste_bin(details)
	_build_village_well(details)


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
		collision.name = "BenchCollision"
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


static func _build_village_well(parent: Node3D) -> void:
	var well := Node3D.new()
	well.name = "VillageWellEnhancement"
	well.position = Vector3(4.0, 0.0, 0.0)
	parent.add_child(well)

	# Textured stone coping and water surface make the existing village well readable.
	var rim_mesh := CylinderMesh.new()
	rim_mesh.top_radius = 1.10
	rim_mesh.bottom_radius = 1.10
	rim_mesh.height = 0.19
	rim_mesh.radial_segments = 24
	_add_mesh(well, "TexturedStoneCoping", rim_mesh, Vector3(0.0, 0.86, 0.0),
		_material(Color(0.92, 0.89, 0.81), WELL_STONE_TEXTURE))
	var water_mesh := CylinderMesh.new()
	water_mesh.top_radius = 0.80
	water_mesh.bottom_radius = 0.80
	water_mesh.height = 0.025
	water_mesh.radial_segments = 24
	var water_material := StandardMaterial3D.new()
	water_material.albedo_color = Color(0.10, 0.31, 0.39)
	water_material.metallic = 0.12
	water_material.roughness = 0.22
	water_material.clearcoat_enabled = true
	water_material.clearcoat = 0.55
	_add_mesh(well, "WellWater", water_mesh, Vector3(0.0, 0.83, 0.0), water_material)

	# Varied masonry blocks make the rim visibly hand-built.
	var stone_colors: Array[Color] = [
		Color(0.82, 0.78, 0.68), Color(0.73, 0.70, 0.62),
		Color(0.88, 0.83, 0.73), Color(0.77, 0.74, 0.66)
	]
	var block_mesh := BoxMesh.new()
	block_mesh.size = Vector3(0.48, 0.22, 0.30)
	for index in range(12):
		var angle := TAU * float(index) / 12.0
		var block_position := Vector3(cos(angle) * 1.04, 0.91, sin(angle) * 1.04)
		var block_material := _material(stone_colors[index % stone_colors.size()], WELL_STONE_TEXTURE)
		var block := _add_mesh(well, "RimMasonry_%02d" % index, block_mesh,
			block_position, block_material)
		block.rotation.y = -angle

	# Collision-aware timber structure for the pulley and roof.
	var frame := StaticBody3D.new()
	frame.name = "TimberFrame"
	frame.collision_layer = 1
	frame.collision_mask = 1
	well.add_child(frame)
	var timber := _material(Color(0.43, 0.28, 0.17), WOOD_TEXTURE)
	var timber_dark := _material(Color(0.25, 0.16, 0.10), WOOD_TEXTURE)
	for side in [-1.0, 1.0]:
		var side_name := "Left" if side < 0.0 else "Right"
		var post_position := Vector3(side * 0.84, 1.66, -0.10)
		_add_box(frame, "TimberPost_%s" % side_name,
			Vector3(0.17, 1.68, 0.18), post_position, timber)
		_add_box_collision(frame, "TimberPostCollision_%s" % side_name,
			Vector3(0.20, 1.72, 0.21), post_position)
		_add_box(frame, "PostCap_%s" % side_name, Vector3(0.28, 0.10, 0.28),
			Vector3(side * 0.84, 2.52, -0.10), timber_dark)

	var crossbeam_position := Vector3(0.0, 2.47, -0.10)
	_add_box(frame, "PulleyCrossbeam", Vector3(2.15, 0.18, 0.19),
		crossbeam_position, timber_dark)
	_add_box_collision(frame, "PulleyCrossbeamCollision",
		Vector3(2.18, 0.20, 0.22), crossbeam_position)

	# Wheel, axle and spokes complete a recognizable manual water-lifting mechanism.
	var axle_mesh := CylinderMesh.new()
	axle_mesh.top_radius = 0.075
	axle_mesh.bottom_radius = 0.075
	axle_mesh.height = 1.88
	axle_mesh.radial_segments = 12
	var axle := _add_mesh(frame, "PulleyAxle", axle_mesh,
		Vector3(0.0, 2.28, -0.10), timber_dark)
	axle.rotation_degrees.z = 90.0
	var wheel_mesh := CylinderMesh.new()
	wheel_mesh.top_radius = 0.31
	wheel_mesh.bottom_radius = 0.31
	wheel_mesh.height = 0.15
	wheel_mesh.radial_segments = 20
	var wheel := _add_mesh(frame, "PulleyWheel", wheel_mesh,
		Vector3(0.0, 2.28, -0.10), _material(Color(0.49, 0.31, 0.17), WOOD_TEXTURE))
	wheel.rotation_degrees.z = 90.0
	var hub_mesh := CylinderMesh.new()
	hub_mesh.top_radius = 0.12
	hub_mesh.bottom_radius = 0.12
	hub_mesh.height = 0.19
	hub_mesh.radial_segments = 12
	var hub := _add_mesh(frame, "PulleyHub", hub_mesh,
		Vector3(0.0, 2.28, -0.10), timber_dark)
	hub.rotation_degrees.z = 90.0
	for spoke_index in range(8):
		var angle := TAU * float(spoke_index) / 8.0
		var spoke := _add_box(frame, "PulleySpoke_%02d" % spoke_index,
			Vector3(0.09, 0.52, 0.07),
			Vector3(sin(angle) * 0.23, 2.28 + cos(angle) * 0.23, -0.10),
			timber_dark)
		spoke.rotation.z = angle

	# Rope and a tapered bucket descend into the visible opening.
	var rope_mesh := CylinderMesh.new()
	rope_mesh.top_radius = 0.025
	rope_mesh.bottom_radius = 0.025
	rope_mesh.height = 1.20
	rope_mesh.radial_segments = 6
	_add_mesh(frame, "WellRope", rope_mesh,
		Vector3(0.0, 1.55, 0.16), _material(Color(0.66, 0.53, 0.34)))
	var bucket_mesh := CylinderMesh.new()
	bucket_mesh.top_radius = 0.22
	bucket_mesh.bottom_radius = 0.16
	bucket_mesh.height = 0.34
	bucket_mesh.radial_segments = 12
	_add_mesh(frame, "WaterBucket", bucket_mesh,
		Vector3(0.0, 1.03, 0.16), timber)
	var bucket_rim_mesh := CylinderMesh.new()
	bucket_rim_mesh.top_radius = 0.23
	bucket_rim_mesh.bottom_radius = 0.23
	bucket_rim_mesh.height = 0.055
	bucket_rim_mesh.radial_segments = 12
	_add_mesh(frame, "BucketMetalRim", bucket_rim_mesh,
		Vector3(0.0, 1.19, 0.16), _material(Color(0.43, 0.49, 0.49)))

	# Two roof slopes use instanced terracotta shingles to limit draw calls.
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(2.55, 0.13, 1.12)
	var tile_mesh := BoxMesh.new()
	tile_mesh.size = Vector3(0.43, 0.04, 0.28)
	var tile_material := _material(Color(0.69, 0.29, 0.18))
	for side in [-1.0, 1.0]:
		var side_name := "Left" if side < 0.0 else "Right"
		var roof_panel := MeshInstance3D.new()
		roof_panel.name = "RoofSlope_%s" % side_name
		roof_panel.mesh = roof_mesh
		roof_panel.position = Vector3(0.0, 2.94, side * 0.49)
		roof_panel.rotation_degrees.x = -24.0 * side
		roof_panel.material_override = timber_dark
		frame.add_child(roof_panel)
		var shingles := MultiMeshInstance3D.new()
		shingles.name = "TerracottaShingles"
		var instances := MultiMesh.new()
		instances.transform_format = MultiMesh.TRANSFORM_3D
		instances.mesh = tile_mesh
		instances.instance_count = 15
		for tile_index in range(instances.instance_count):
			var row := int(tile_index / 5)
			var column := tile_index % 5
			var offset := Vector3(-0.88 + float(column) * 0.44, 0.09,
				-0.34 + float(row) * 0.34)
			instances.set_instance_transform(tile_index,
				Transform3D(Basis.IDENTITY, offset))
		shingles.multimesh = instances
		shingles.material_override = tile_material
		roof_panel.add_child(shingles)
		_add_box_collision(frame, "RoofCollision_%s" % side_name,
			Vector3(2.60, 0.18, 1.18), roof_panel.position)


static func _add_box_collision(parent: Node3D, node_name: String, size: Vector3,
		position: Vector3) -> CollisionShape3D:
	var collision := CollisionShape3D.new()
	collision.name = node_name
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position = position
	parent.add_child(collision)
	return collision
