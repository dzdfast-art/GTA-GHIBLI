extends Node3D

## First in-engine art-direction pass for GTA GHIBLI.
## Uses original, low-cost procedural meshes so the Android prototype stays lightweight.

func _ready() -> void:
	_build_harbor_city()
	_build_village_blossoms()


func _build_harbor_city() -> void:
	var regions := get_parent().get_node_or_null("OpenWorldRegions") as Node3D
	if regions == null:
		push_warning("Ghibli visual pass: OpenWorldRegions was not found.")
		return
	var harbor := regions.get_node_or_null("HarborCity") as Node3D
	if harbor == null:
		push_warning("Ghibli visual pass: HarborCity was not found.")
		return

	var skyline := Node3D.new()
	skyline.name = "GhibliSkyline"
	harbor.add_child(skyline)

	var tower_data := [
		{"name": "Tower_01", "at": Vector3(-15.0, 0.0, -17.0), "size": Vector3(6.2, 16.0, 5.4), "color": Color(0.24, 0.38, 0.48)},
		{"name": "Tower_02", "at": Vector3(-7.6, 0.0, -19.2), "size": Vector3(6.3, 23.0, 5.0), "color": Color(0.29, 0.43, 0.52)},
		{"name": "Tower_03", "at": Vector3(0.0, 0.0, -17.8), "size": Vector3(7.2, 29.0, 5.8), "color": Color(0.20, 0.34, 0.46)},
		{"name": "Tower_04", "at": Vector3(8.0, 0.0, -18.7), "size": Vector3(6.0, 20.0, 5.2), "color": Color(0.34, 0.45, 0.50)},
		{"name": "Tower_05", "at": Vector3(15.2, 0.0, -16.2), "size": Vector3(5.8, 14.0, 5.0), "color": Color(0.30, 0.40, 0.50)}
	]

	for data in tower_data:
		_add_tower(
			skyline,
			str(data["name"]),
			data["at"] as Vector3,
			data["size"] as Vector3,
			data["color"] as Color
		)

	_add_city_sign(skyline)
	_build_city_road(harbor)
	_add_palm(harbor, "Palm_West_01", Vector3(-18.0, 0.0, 13.0), 1.0)
	_add_palm(harbor, "Palm_West_02", Vector3(-11.0, 0.0, 14.0), 0.88)
	_add_palm(harbor, "Palm_East_01", Vector3(11.0, 0.0, 14.0), 0.92)
	_add_palm(harbor, "Palm_East_02", Vector3(18.0, 0.0, 12.0), 1.05)
	_add_street_lamp(harbor, "HarborLamp_Left", Vector3(-7.0, 0.0, 15.6))
	_add_street_lamp(harbor, "HarborLamp_Right", Vector3(7.0, 0.0, 15.6))


func _add_tower(parent: Node3D, tower_name: String, at: Vector3,
		dimensions: Vector3, wall_color: Color) -> void:
	var tower := StaticBody3D.new()
	tower.name = tower_name
	tower.position = at
	tower.collision_layer = 1
	tower.collision_mask = 1
	parent.add_child(tower)

	var walls := BoxMesh.new()
	walls.size = dimensions
	_add_mesh(tower, "Facade", walls, Vector3(0.0, dimensions.y * 0.5, 0.0),
		_make_material(wall_color, 0.48, 0.18))

	var collision_shape := BoxShape3D.new()
	collision_shape.size = dimensions
	var collision := CollisionShape3D.new()
	collision.name = "BuildingCollision"
	collision.shape = collision_shape
	collision.position.y = dimensions.y * 0.5
	tower.add_child(collision)

	var roof := BoxMesh.new()
	roof.size = Vector3(dimensions.x + 0.38, 0.34, dimensions.z + 0.38)
	_add_mesh(tower, "RoofRim", roof,
		Vector3(0.0, dimensions.y + 0.17, 0.0),
		_make_material(Color(0.13, 0.22, 0.30), 0.62))

	var trim := BoxMesh.new()
	trim.size = Vector3(0.12, dimensions.y, dimensions.z + 0.12)
	for side in [-1.0, 1.0]:
		_add_mesh(tower, "FacadeEdge_%s" % str(side), trim,
			Vector3(side * (dimensions.x * 0.5 - 0.08), dimensions.y * 0.5, 0.0),
			_make_material(Color(0.52, 0.64, 0.68), 0.42))

	_add_window_instances(tower, dimensions)
	_add_roof_details(tower, dimensions)


func _add_window_instances(parent: Node3D, dimensions: Vector3) -> void:
	var half_width := dimensions.x * 0.5
	var half_depth := dimensions.z * 0.5
	var transforms: Array[Transform3D] = []
	var tints: Array[Color] = []
	var floors := maxi(2, int(dimensions.y / 1.12))

	for row in range(floors):
		var y := 1.45 + float(row) * 1.08
		if y > dimensions.y - 0.75:
			break
		for column in range(5):
			var x := -half_width + 0.72 + float(column) * ((dimensions.x - 1.44) / 4.0)
			var warm := (row + column) % 5 == 0
			var tint := Color(1.0, 0.78, 0.46, 1.0) if warm else Color(0.54, 0.82, 0.94, 1.0)
			transforms.append(Transform3D(Basis(), Vector3(x, y, half_depth + 0.045)))
			tints.append(tint)
			transforms.append(Transform3D(Basis(), Vector3(x, y, -half_depth - 0.045)))
			tints.append(tint)

		for column in range(4):
			var z := -half_depth + 0.72 + float(column) * ((dimensions.z - 1.44) / 3.0)
			var side_tint := Color(1.0, 0.78, 0.46, 1.0) if (row + column) % 6 == 0 else Color(0.48, 0.76, 0.90, 1.0)
			transforms.append(Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(half_width + 0.045, y, z)))
			tints.append(side_tint)
			transforms.append(Transform3D(Basis(Vector3.UP, -PI * 0.5), Vector3(-half_width - 0.045, y, z)))
			tints.append(side_tint)

	var window_mesh := BoxMesh.new()
	window_mesh.size = Vector3(0.48, 0.68, 0.055)
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = true
	multi.mesh = window_mesh
	multi.instance_count = transforms.size()
	for index in range(transforms.size()):
		multi.set_instance_transform(index, transforms[index])
		multi.set_instance_color(index, tints[index])

	var windows := MultiMeshInstance3D.new()
	windows.name = "WindowInstances"
	windows.multimesh = multi
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color.WHITE
	glass.vertex_color_use_as_albedo = true
	glass.roughness = 0.28
	glass.metallic = 0.18
	glass.emission_enabled = true
	glass.emission = Color(0.16, 0.30, 0.38)
	glass.emission_energy_multiplier = 0.22
	windows.material_override = glass
	parent.add_child(windows)


func _add_roof_details(parent: Node3D, dimensions: Vector3) -> void:
	var mast := CylinderMesh.new()
	mast.top_radius = 0.025
	mast.bottom_radius = 0.055
	mast.height = 2.4
	_add_mesh(parent, "RooftopAntenna", mast,
		Vector3(0.0, dimensions.y + 1.35, 0.0),
		_make_material(Color(0.23, 0.28, 0.31), 0.7))

	var beacon := SphereMesh.new()
	beacon.radius = 0.11
	beacon.height = 0.22
	var beacon_material := _make_material(Color(1.0, 0.36, 0.19), 0.35)
	beacon_material.emission_enabled = true
	beacon_material.emission = Color(1.0, 0.12, 0.04)
	beacon_material.emission_energy_multiplier = 0.7
	_add_mesh(parent, "RoofBeacon", beacon,
		Vector3(0.0, dimensions.y + 2.55, 0.0), beacon_material)


func _add_city_sign(parent: Node3D) -> void:
	var sign_post := BoxMesh.new()
	sign_post.size = Vector3(0.18, 3.0, 0.18)
	for x in [-8.0, 8.0]:
		_add_mesh(parent, "CitySignSupport", sign_post,
			Vector3(x, 7.5, -23.0), _make_material(Color(0.17, 0.22, 0.25), 0.8))

	var board := BoxMesh.new()
	board.size = Vector3(16.5, 2.0, 0.32)
	_add_mesh(parent, "CitySignBoard", board,
		Vector3(0.0, 9.0, -23.0), _make_material(Color(0.12, 0.28, 0.36), 0.48))

	var title := Label3D.new()
	title.name = "CitySignTitle"
	title.text = "HARBOR CITY  •  مدينة الميناء"
	title.position = Vector3(0.0, 9.0, -22.80)
	title.font_size = 52
	title.pixel_size = 0.004
	title.modulate = Color(1.0, 0.88, 0.61)
	title.outline_size = 8
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(title)


func _build_city_road(parent: Node3D) -> void:
	var asphalt := BoxMesh.new()
	asphalt.size = Vector3(42.0, 0.12, 6.4)
	_add_mesh(parent, "HarborBoulevard", asphalt,
		Vector3(0.0, 0.13, 18.3), _make_material(Color(0.12, 0.15, 0.17), 0.94))

	var sidewalk := BoxMesh.new()
	sidewalk.size = Vector3(42.0, 0.24, 1.25)
	for side in [-1.0, 1.0]:
		_add_mesh(parent, "BoulevardSidewalk", sidewalk,
			Vector3(0.0, 0.16, 18.3 + side * 3.82),
			_make_material(Color(0.61, 0.62, 0.58), 0.96))

	var line_mesh := BoxMesh.new()
	line_mesh.size = Vector3(0.12, 0.025, 1.45)
	for index in range(12):
		_add_mesh(parent, "RoadDash_%02d" % index, line_mesh,
			Vector3(-19.0 + float(index) * 3.45, 0.205, 18.3),
			_make_material(Color(1.0, 0.78, 0.26), 0.78))


func _add_palm(parent: Node3D, tree_name: String, at: Vector3,
		scale_factor: float) -> void:
	var palm := Node3D.new()
	palm.name = tree_name
	palm.position = at
	palm.scale = Vector3.ONE * scale_factor
	parent.add_child(palm)

	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.16
	trunk.bottom_radius = 0.31
	trunk.height = 6.2
	_add_mesh(palm, "PalmTrunk", trunk, Vector3(0.0, 3.1, 0.0),
		_make_material(Color(0.46, 0.30, 0.17), 0.96))

	for ring in range(5):
		var band := CylinderMesh.new()
		band.top_radius = 0.19
		band.bottom_radius = 0.20
		band.height = 0.10
		_add_mesh(palm, "TrunkRing_%d" % ring, band,
			Vector3(0.0, 0.8 + float(ring) * 1.0, 0.0),
			_make_material(Color(0.30, 0.21, 0.14), 0.98))

	var leaf_colors := [
		Color(0.18, 0.43, 0.25),
		Color(0.24, 0.54, 0.29),
		Color(0.31, 0.61, 0.34)
	]
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		var leaf_mesh := CapsuleMesh.new()
		leaf_mesh.radius = 0.12
		leaf_mesh.height = 2.9
		var leaf := MeshInstance3D.new()
		leaf.name = "PalmFrond_%02d" % index
		leaf.mesh = leaf_mesh
		leaf.position = Vector3(cos(angle) * 0.75, 6.12, sin(angle) * 0.75)
		leaf.rotation.y = angle
		leaf.rotation.z = -0.88
		leaf.material_override = _make_material(leaf_colors[index % leaf_colors.size()], 0.96)
		palm.add_child(leaf)


func _add_street_lamp(parent: Node3D, lamp_name: String, at: Vector3) -> void:
	var lamp := Node3D.new()
	lamp.name = lamp_name
	lamp.position = at
	parent.add_child(lamp)

	var pole := CylinderMesh.new()
	pole.top_radius = 0.055
	pole.bottom_radius = 0.085
	pole.height = 4.8
	_add_mesh(lamp, "Pole", pole, Vector3(0.0, 2.4, 0.0),
		_make_material(Color(0.19, 0.23, 0.25), 0.78))

	var arm := BoxMesh.new()
	arm.size = Vector3(1.1, 0.08, 0.08)
	_add_mesh(lamp, "LampArm", arm, Vector3(0.48, 4.65, 0.0),
		_make_material(Color(0.19, 0.23, 0.25), 0.78))

	var light_mesh := BoxMesh.new()
	light_mesh.size = Vector3(0.48, 0.14, 0.30)
	var light_material := _make_material(Color(1.0, 0.83, 0.52), 0.38)
	light_material.emission_enabled = true
	light_material.emission = Color(1.0, 0.65, 0.28)
	light_material.emission_energy_multiplier = 0.5
	_add_mesh(lamp, "LampHousing", light_mesh,
		Vector3(0.88, 4.56, 0.0), light_material)


func _build_village_blossoms() -> void:
	var village := get_parent().get_node_or_null("WillowVillage") as Node3D
	if village == null:
		return
	var grove := Node3D.new()
	grove.name = "GhibliCherryBlossoms"
	village.add_child(grove)

	_add_cherry_tree(grove, "BlossomTree_01", Vector3(-18.0, 0.0, -5.0), 1.0)
	_add_cherry_tree(grove, "BlossomTree_02", Vector3(18.0, 0.0, 8.0), 0.88)
	_add_cherry_tree(grove, "BlossomTree_03", Vector3(-19.0, 0.0, 25.0), 1.08)


func _add_cherry_tree(parent: Node3D, tree_name: String, at: Vector3,
		scale_factor: float) -> void:
	var tree := Node3D.new()
	tree.name = tree_name
	tree.position = at
	tree.scale = Vector3.ONE * scale_factor
	parent.add_child(tree)

	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.13
	trunk.bottom_radius = 0.23
	trunk.height = 3.5
	_add_mesh(tree, "Trunk", trunk, Vector3(0.0, 1.75, 0.0),
		_make_material(Color(0.35, 0.22, 0.16), 0.98))

	var blossom_colors := [
		Color(0.92, 0.54, 0.66),
		Color(1.0, 0.70, 0.76),
		Color(0.84, 0.43, 0.58),
		Color(0.98, 0.78, 0.78)
	]
	var offsets := [
		Vector3(0.0, 3.65, 0.0),
		Vector3(-0.78, 3.35, 0.12),
		Vector3(0.78, 3.42, 0.08),
		Vector3(0.0, 3.25, -0.82),
		Vector3(0.0, 3.30, 0.82)
	]
	for index in range(offsets.size()):
		var crown := SphereMesh.new()
		crown.radius = 1.02 if index == 0 else 0.82
		crown.height = crown.radius * 1.7
		_add_mesh(tree, "BlossomCanopy_%02d" % index, crown,
			offsets[index], _make_material(blossom_colors[index % blossom_colors.size()], 0.96))


func _add_mesh(parent: Node3D, node_name: String, mesh: Mesh,
		at: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = at
	instance.material_override = material
	parent.add_child(instance)
	return instance


func _make_material(color: Color, roughness: float = 0.86,
		metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material
