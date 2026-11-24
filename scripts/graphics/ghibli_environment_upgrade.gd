extends Node3D

## First in-engine art-direction pass for GTA GHIBLI.
## Uses original, low-cost procedural meshes so the Android prototype stays lightweight.

func _ready() -> void:
	_build_harbor_city()
	_build_village_blossoms()
	_build_reference_street()


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
		var tower_at: Vector3 = data["at"]
		var tower_size: Vector3 = data["size"]
		var tower_color: Color = data["color"]
		_add_tower(skyline, str(data["name"]), tower_at, tower_size, tower_color)

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
	line_mesh.size = Vector3(1.45, 0.025, 0.12)
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


func _build_reference_street() -> void:
	var game_root := get_parent() as Node3D
	if game_root == null:
		return
	var street := Node3D.new()
	street.name = "ReferenceStreetComposition"
	game_root.add_child(street)
	_build_reference_road(street)
	_build_reference_skyline(street)
	_build_suspension_bridge(street)
	_build_reference_hill(street)
	_build_reference_billboard(street)
	_build_reference_shop(street)
	_build_reference_traffic(street)
	_build_reference_aircraft(street)
	_build_reference_trees(street)


func _build_reference_road(parent: Node3D) -> void:
	var asphalt := BoxMesh.new()
	asphalt.size = Vector3(18.0, 0.14, 88.0)
	_add_mesh(parent, "OpeningBoulevard", asphalt, Vector3(0.0, 0.08, 42.0),
		_make_material(Color(0.13, 0.15, 0.16), 0.97))
	var sidewalk := BoxMesh.new()
	sidewalk.size = Vector3(2.0, 0.25, 88.0)
	for side in [-1.0, 1.0]:
		_add_mesh(parent, "BoulevardPavement", sidewalk,
			Vector3(side * 10.0, 0.17, 42.0),
			_make_material(Color(0.62, 0.63, 0.58), 0.95))
	var lane_line := BoxMesh.new()
	lane_line.size = Vector3(0.14, 0.025, 2.1)
	for index in range(22):
		_add_mesh(parent, "BoulevardLaneDash_%02d" % index, lane_line,
			Vector3(0.0, 0.17, 4.0 + float(index) * 3.7),
			_make_material(Color(1.0, 0.78, 0.23), 0.78))
	var curb := BoxMesh.new()
	curb.size = Vector3(0.25, 0.34, 88.0)
	for side in [-1.0, 1.0]:
		_add_mesh(parent, "BoulevardCurb", curb, Vector3(side * 9.05, 0.24, 42.0),
			_make_material(Color(0.76, 0.72, 0.62), 0.96))


func _build_reference_skyline(parent: Node3D) -> void:
	var skyline := Node3D.new()
	skyline.name = "OpeningSkyline"
	skyline.position = Vector3(0.0, 0.0, 0.0)
	parent.add_child(skyline)
	var towers := [
		{"name": "OpeningTower_Left", "at": Vector3( -25.0, 0.0, 82.0), "size": Vector3(8.0, 23.0, 8.0), "color": Color(0.29, 0.43, 0.54)},
		{"name": "OpeningTower_TallLeft", "at": Vector3(-13.0, 0.0, 87.0), "size": Vector3(8.5, 33.0, 8.0), "color": Color(0.25, 0.39, 0.52)},
		{"name": "OpeningTower_Center", "at": Vector3(0.0, 0.0, 84.0), "size": Vector3(10.0, 43.0, 9.0), "color": Color(0.20, 0.34, 0.46)},
		{"name": "OpeningTower_Right", "at": Vector3(13.0, 0.0, 88.0), "size": Vector3(8.2, 29.0, 8.0), "color": Color(0.34, 0.47, 0.56)},
		{"name": "OpeningTower_FarRight", "at": Vector3(25.0, 0.0, 82.0), "size": Vector3(9.0, 20.0, 8.0), "color": Color(0.31, 0.43, 0.50)}
	]
	for tower in towers:
		var tower_at: Vector3 = tower["at"]
		var tower_size: Vector3 = tower["size"]
		var tower_color: Color = tower["color"]
		_add_tower(skyline, str(tower["name"]), tower_at, tower_size, tower_color)
	_add_mesh(skyline, "SkylineRooftopWaterTank", CylinderMesh.new(),
		Vector3(-13.0, 35.0, 87.8), _make_material(Color(0.45, 0.52, 0.55), 0.62))
	var city_name := Label3D.new()
	city_name.name = "HarborCityWelcome"
	city_name.text = "HARBOR CITY  •  مدينة الميناء"
	city_name.position = Vector3(0.0, 7.0, 72.0)
	city_name.font_size = 46
	city_name.pixel_size = 0.004
	city_name.modulate = Color(1.0, 0.86, 0.59)
	city_name.outline_size = 7
	skyline.add_child(city_name)


func _build_suspension_bridge(parent: Node3D) -> void:
	var bridge := Node3D.new()
	bridge.name = "RedSuspensionBridge"
	bridge.position = Vector3(23.0, 0.0, 47.0)
	parent.add_child(bridge)
	var deck := BoxMesh.new()
	deck.size = Vector3(31.0, 0.50, 3.2)
	_add_mesh(bridge, "BridgeDeck", deck, Vector3(0.0, 5.0, 0.0),
		_make_material(Color(0.55, 0.21, 0.18), 0.78))
	for side in [-1.0, 1.0]:
		var rail := BoxMesh.new()
		rail.size = Vector3(31.0, 0.75, 0.20)
		_add_mesh(bridge, "BridgeGuardRail", rail,
			Vector3(0.0, 5.62, side * 1.46),
			_make_material(Color(0.67, 0.29, 0.22), 0.72))
	for tower_x in [-13.0, 13.0]:
		var pier := BoxMesh.new()
		pier.size = Vector3(1.15, 17.0, 1.30)
		_add_mesh(bridge, "BridgePylon", pier,
			Vector3(tower_x, 13.5, 0.0),
			_make_material(Color(0.66, 0.25, 0.20), 0.72))
		var crossbeam := BoxMesh.new()
		crossbeam.size = Vector3(2.0, 0.65, 2.0)
		_add_mesh(bridge, "BridgePylonCap", crossbeam,
			Vector3(tower_x, 21.7, 0.0),
			_make_material(Color(0.75, 0.32, 0.25), 0.72))
	for side in [-1.0, 1.0]:
		var cable_z := side * 1.05
		var previous := Vector3(-15.0, 21.5, cable_z)
		for index in range(1, 25):
			var t := float(index) / 24.0
			var x := lerpf(-15.0, 15.0, t)
			var y := 21.5 - 5.0 * sin(t * PI)
			var next := Vector3(x, y, cable_z)
			_add_bar_between(bridge, "SuspensionMainCable", previous, next, 0.075,
				Color(0.85, 0.64, 0.45))
			previous = next
		for index in range(13):
			var t := float(index + 1) / 14.0
			var x := lerpf(-12.0, 12.0, t)
			var y := 21.5 - 5.0 * sin((x + 15.0) / 30.0 * PI)
			_add_bar_between(bridge, "SuspensionVerticalCable",
				Vector3(x, y, cable_z), Vector3(x, 5.45, cable_z), 0.035,
				Color(0.87, 0.70, 0.52))


func _build_reference_hill(parent: Node3D) -> void:
	var hill := Node3D.new()
	hill.name = "GreenGhibliHill"
	hill.position = Vector3(-38.0, 0.0, 91.0)
	parent.add_child(hill)
	var hill_color := _make_material(Color(0.29, 0.48, 0.29), 1.0)
	for index in range(4):
		var mound := SphereMesh.new()
		mound.radius = 12.0 - float(index % 2) * 1.5
		mound.height = mound.radius * 1.65
		var offset := Vector3(float(index) * 8.0 - 9.0, 6.0 + float(index % 2) * 2.0, float(index % 2) * 4.0)
		var scaled := _add_mesh(hill, "HillMound_%02d" % index, mound, offset, hill_color)
		scaled.scale = Vector3(1.45, 0.72, 0.80)
	var title := Label3D.new()
	title.name = "HillTitle"
	title.text = "GHIBLI"
	title.position = Vector3(0.0, 15.0, -8.7)
	title.font_size = 86
	title.pixel_size = 0.008
	title.modulate = Color(0.88, 0.87, 0.67)
	title.outline_size = 8
	hill.add_child(title)


func _build_reference_billboard(parent: Node3D) -> void:
	var billboard := Node3D.new()
	billboard.name = "GhibliStoryBillboard"
	billboard.position = Vector3(-21.0, 0.0, 24.0)
	parent.add_child(billboard)
	for side in [-1.0, 1.0]:
		var support := BoxMesh.new()
		support.size = Vector3(0.36, 9.0, 0.42)
		_add_mesh(billboard, "BillboardSupport", support,
			Vector3(side * 6.4, 4.5, 0.0),
			_make_material(Color(0.16, 0.20, 0.22), 0.78))
	var board := BoxMesh.new()
	board.size = Vector3(13.5, 7.2, 0.55)
	_add_mesh(billboard, "BillboardBoard", board, Vector3(0.0, 10.0, 0.0),
		_make_material(Color(0.075, 0.21, 0.32), 0.52, 0.22))
	var screen := BoxMesh.new()
	screen.size = Vector3(12.9, 6.6, 0.07)
	_add_mesh(billboard, "BillboardScreen", screen, Vector3(0.0, 10.0, -0.31),
		_make_material(Color(0.24, 0.53, 0.72), 0.42))
	var sky_patch := SphereMesh.new()
	sky_patch.radius = 2.4
	sky_patch.height = 2.2
	var sky_visual := _add_mesh(billboard, "BillboardCloudArt", sky_patch,
		Vector3(-3.9, 11.7, -0.42), _make_material(Color(0.75, 0.84, 0.88), 0.96))
	sky_visual.scale = Vector3(1.5, 0.55, 0.10)
	var mascot_hair := SphereMesh.new()
	mascot_hair.radius = 1.15
	mascot_hair.height = 2.0
	var hair_visual := _add_mesh(billboard, "MascotHair", mascot_hair,
		Vector3(2.8, 11.1, -0.48), _make_material(Color(0.18, 0.10, 0.08), 0.95))
	hair_visual.scale = Vector3(1.25, 1.08, 0.35)
	var mascot_face := SphereMesh.new()
	mascot_face.radius = 0.76
	mascot_face.height = 1.4
	var face_visual := _add_mesh(billboard, "MascotFace", mascot_face,
		Vector3(2.8, 10.8, -0.58), _make_material(Color(0.91, 0.68, 0.51), 0.94))
	face_visual.scale = Vector3(0.86, 1.0, 0.26)
	var mascot_body := BoxMesh.new()
	mascot_body.size = Vector3(1.7, 2.1, 0.32)
	_add_mesh(billboard, "MascotCoat", mascot_body, Vector3(2.8, 8.7, -0.50),
		_make_material(Color(0.31, 0.36, 0.55), 0.91))
	for side in [-1.0, 1.0]:
		var bow := SphereMesh.new()
		bow.radius = 0.48
		bow.height = 0.6
		var bow_part := _add_mesh(billboard, "MascotBow", bow,
			Vector3(2.8 + side * 0.72, 12.0, -0.62),
			_make_material(Color(0.84, 0.08, 0.13), 0.7))
		bow_part.scale = Vector3(1.2, 0.7, 0.35)
	var caption := Label3D.new()
	caption.name = "BillboardTitle"
	caption.text = "GHIBLI  •  STORIES TO EXPLORE"
	caption.position = Vector3(-2.9, 8.0, -0.43)
	caption.font_size = 28
	caption.pixel_size = 0.0035
	caption.modulate = Color(1.0, 0.94, 0.75)
	caption.outline_size = 5
	billboard.add_child(caption)


func _build_reference_shop(parent: Node3D) -> void:
	var shop := Node3D.new()
	shop.name = "Harbor24HourShop"
	shop.position = Vector3(-15.0, 0.0, 15.0)
	parent.add_child(shop)
	var body := BoxMesh.new()
	body.size = Vector3(8.5, 4.0, 4.2)
	_add_mesh(shop, "ShopBody", body, Vector3(0.0, 2.0, 0.0),
		_make_material(Color(0.69, 0.51, 0.34), 0.92))
	var window := BoxMesh.new()
	window.size = Vector3(6.7, 1.8, 0.10)
	_add_mesh(shop, "ShopFrontGlass", window, Vector3(0.0, 2.0, -2.15),
		_make_material(Color(0.14, 0.39, 0.52, 0.86), 0.22, 0.18))
	var awning := BoxMesh.new()
	awning.size = Vector3(9.0, 0.34, 1.3)
	_add_mesh(shop, "ShopAwning", awning, Vector3(0.0, 3.25, -2.35),
		_make_material(Color(0.83, 0.22, 0.28), 0.74))
	var sign := BoxMesh.new()
	sign.size = Vector3(4.0, 1.05, 0.18)
	_add_mesh(shop, "ShopOpenSign", sign, Vector3(0.0, 4.65, -2.18),
		_make_material(Color(0.045, 0.12, 0.13), 0.42))
	var open_label := Label3D.new()
	open_label.name = "ShopOpenText"
	open_label.text = "24/7  OPEN"
	open_label.position = Vector3(0.0, 4.62, -2.30)
	open_label.font_size = 48
	open_label.pixel_size = 0.004
	open_label.modulate = Color(0.42, 1.0, 0.48)
	open_label.outline_size = 7
	shop.add_child(open_label)
	var store_title := Label3D.new()
	store_title.name = "StoreTitle"
	store_title.text = "MARKET  •  بقالة"
	store_title.position = Vector3(0.0, 3.72, -2.24)
	store_title.font_size = 28
	store_title.pixel_size = 0.003
	store_title.modulate = Color(1.0, 0.92, 0.76)
	store_title.outline_size = 5
	shop.add_child(store_title)


func _build_reference_traffic(parent: Node3D) -> void:
	_add_static_sedan(parent, "ParkedBlackSedan", Vector3(-5.8, 0.0, 26.0),
		Color(0.045, 0.055, 0.065))
	_add_static_motorcycle(parent, "ParkedStreetMotorcycle", Vector3(-13.8, 0.0, 24.0))


func _add_static_sedan(parent: Node3D, vehicle_name: String, at: Vector3,
		body_color: Color) -> void:
	var vehicle := Node3D.new()
	vehicle.name = vehicle_name
	vehicle.position = at
	vehicle.rotation.y = PI
	parent.add_child(vehicle)
	_add_box(vehicle, "SedanLowerBody", Vector3(2.0, 0.72, 4.25),
		Vector3(0.0, 0.82, 0.0), body_color)
	_add_box(vehicle, "SedanHood", Vector3(1.82, 0.13, 1.12),
		Vector3(0.0, 1.25, -1.40), body_color)
	_add_box(vehicle, "SedanCabin", Vector3(1.65, 0.92, 2.0),
		Vector3(0.0, 1.55, 0.18), _make_material(Color(0.12, 0.23, 0.30), 0.28, 0.3))
	_add_box(vehicle, "SedanFrontGlass", Vector3(1.46, 0.48, 0.08),
		Vector3(0.0, 1.70, -0.80), _make_material(Color(0.30, 0.58, 0.66), 0.22, 0.2))
	_add_box(vehicle, "SedanRearGlass", Vector3(1.42, 0.43, 0.08),
		Vector3(0.0, 1.68, 1.15), _make_material(Color(0.22, 0.45, 0.55), 0.23, 0.2))
	for side in [-1.0, 1.0]:
		for axle in [-1.30, 1.30]:
			var wheel := CylinderMesh.new()
			wheel.top_radius = 0.43
			wheel.bottom_radius = 0.43
			wheel.height = 0.27
			wheel.radial_segments = 16
			var wheel_node := _add_mesh(vehicle, "SedanWheel", wheel,
				Vector3(side * 0.99, 0.43, axle), _make_material(Color(0.045, 0.05, 0.055), 0.98))
			wheel_node.rotation.z = PI * 0.5
			var rim := CylinderMesh.new()
			rim.top_radius = 0.22
			rim.bottom_radius = 0.22
			rim.height = 0.29
			rim.radial_segments = 12
			var rim_node := _add_mesh(vehicle, "SedanRim", rim,
				Vector3(side * 1.0, 0.43, axle), _make_material(Color(0.54, 0.59, 0.62), 0.3, 0.72))
			rim_node.rotation.z = PI * 0.5
	_add_box(vehicle, "SedanFrontBumper", Vector3(2.0, 0.18, 0.16),
		Vector3(0.0, 0.50, -2.12), _make_material(Color(0.20, 0.22, 0.23), 0.68))


func _add_static_motorcycle(parent: Node3D, vehicle_name: String, at: Vector3) -> void:
	var bike := Node3D.new()
	bike.name = vehicle_name
	bike.position = at
	bike.rotation.y = PI * 0.92
	parent.add_child(bike)
	var frame := CylinderMesh.new()
	frame.top_radius = 0.12
	frame.bottom_radius = 0.16
	frame.height = 1.55
	var frame_node := _add_mesh(bike, "MotorcycleFrame", frame,
		Vector3(0.0, 0.92, 0.0), _make_material(Color(0.76, 0.10, 0.07), 0.56, 0.22))
	frame_node.rotation.z = PI * 0.5
	for z in [-0.83, 0.83]:
		var wheel := TorusMesh.new()
		wheel.inner_radius = 0.35
		wheel.outer_radius = 0.44
		var wheel_node := _add_mesh(bike, "MotorcycleWheel", wheel,
			Vector3(0.0, 0.48, z), _make_material(Color(0.04, 0.045, 0.05), 0.96))
		wheel_node.rotation.x = PI * 0.5
	var tank := SphereMesh.new()
	tank.radius = 0.42
	tank.height = 0.52
	var tank_node := _add_mesh(bike, "MotorcycleFuelTank", tank,
		Vector3(0.0, 1.18, -0.10), _make_material(Color(0.12, 0.25, 0.52), 0.48, 0.22))
	tank_node.scale = Vector3(0.9, 0.7, 1.4)
	var seat := BoxMesh.new()
	seat.size = Vector3(0.42, 0.14, 0.82)
	_add_mesh(bike, "MotorcycleSeat", seat, Vector3(0.0, 1.42, 0.54),
		_make_material(Color(0.055, 0.06, 0.065), 0.94))


func _build_reference_aircraft(parent: Node3D) -> void:
	var airplane := Node3D.new()
	airplane.name = "DistantAirplane"
	airplane.position = Vector3(18.0, 34.0, 66.0)
	airplane.rotation.y = deg_to_rad(-18.0)
	parent.add_child(airplane)
	_add_mesh(airplane, "AirplaneFuselage", CapsuleMesh.new(),
		Vector3.ZERO, _make_material(Color(0.78, 0.82, 0.84), 0.65))
	var wing := BoxMesh.new()
	wing.size = Vector3(9.0, 0.18, 1.15)
	_add_mesh(airplane, "AirplaneWing", wing, Vector3(0.0, 0.05, 0.0),
		_make_material(Color(0.82, 0.84, 0.85), 0.62))
	var tail := BoxMesh.new()
	tail.size = Vector3(3.0, 0.16, 0.7)
	_add_mesh(airplane, "AirplaneTail", tail, Vector3(0.0, 0.65, 2.25),
		_make_material(Color(0.82, 0.84, 0.85), 0.62))
	var helicopter := Node3D.new()
	helicopter.name = "DistantHelicopter"
	helicopter.position = Vector3(-25.0, 27.0, 53.0)
	helicopter.rotation.y = deg_to_rad(22.0)
	parent.add_child(helicopter)
	var cabin := SphereMesh.new()
	cabin.radius = 1.0
	cabin.height = 1.3
	var cabin_node := _add_mesh(helicopter, "HelicopterCabin", cabin,
		Vector3.ZERO, _make_material(Color(0.23, 0.39, 0.48), 0.26, 0.22))
	cabin_node.scale = Vector3(1.35, 0.85, 1.2)
	var tail_boom := BoxMesh.new()
	tail_boom.size = Vector3(0.22, 0.22, 3.5)
	_add_mesh(helicopter, "HelicopterTail", tail_boom,
		Vector3(0.0, 0.0, 2.0), _make_material(Color(0.32, 0.40, 0.44), 0.7))
	var rotor := BoxMesh.new()
	rotor.size = Vector3(7.0, 0.08, 0.22)
	_add_mesh(helicopter, "HelicopterMainRotor", rotor,
		Vector3(0.0, 1.10, 0.0), _make_material(Color(0.12, 0.15, 0.17), 0.62))


func _build_reference_trees(parent: Node3D) -> void:
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var at := Vector3(side * 12.5, 0.0, 6.0 + float(index) * 10.0)
		_add_palm(parent, "BoulevardPalm_%02d" % index, at, 0.72 + float(index % 3) * 0.12)


func _add_bar_between(parent: Node3D, node_name: String, start: Vector3,
		finish: Vector3, thickness: float, tint: Color) -> void:
	var direction := finish - start
	var length := direction.length()
	if length <= 0.001:
		return
	var mesh := CylinderMesh.new()
	mesh.top_radius = thickness
	mesh.bottom_radius = thickness
	mesh.height = length
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.position = (start + finish) * 0.5
	node.quaternion = Quaternion(Vector3.UP, direction.normalized())
	node.material_override = _make_material(tint, 0.76)
	parent.add_child(node)
