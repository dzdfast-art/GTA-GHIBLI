extends Node3D

## Original low-poly village blockout.
## All geometry is procedural and intentionally lightweight for mobile.

const GROUND_Y := 0.03
const FOLIAGE_VISUAL_BUILDER = preload("res://scripts/world/foliage_visual_builder.gd")


func _ready() -> void:
	_build_mira()
	_build_reference_mission_marker()
	_build_square()
	_build_paths()
	_build_reference_street()
	_build_houses()
	_build_house_portal()
	_build_garden()
	_build_trees()
	_build_well()
	_build_signpost()
	_build_interactive_objects()
	_build_consumable_shop()
	_build_flora_details()


func _build_mira() -> void:
	var mira_script = preload("res://scripts/characters/mira_npc.gd")
	var mira := Node3D.new()
	mira.name = "MiraCaretaker"
	mira.position = Vector3(0.0, 0.0, -4.0)
	mira.set_script(mira_script)
	add_child(mira)


func _build_square() -> void:
	_add_box(self, "VillageSquare", Vector3(0.0, 0.025, 0.0),
		Vector3(12.0, 0.08, 12.0), Color(0.70, 0.62, 0.47), false)
	_add_box(self, "SquareCenterStone", Vector3(0.0, 0.075, 0.0),
		Vector3(2.4, 0.04, 2.4), Color(0.78, 0.72, 0.60), false)


func _build_paths() -> void:
	_add_box(self, "NorthPath", Vector3(0.0, 0.025, -15.0),
		Vector3(3.2, 0.06, 18.0), Color(0.66, 0.57, 0.43), false)
	_add_box(self, "SouthPath", Vector3(0.0, 0.025, 15.0),
		Vector3(3.2, 0.06, 18.0), Color(0.66, 0.57, 0.43), false)
	_add_box(self, "EastPath", Vector3(15.0, 0.025, 0.0),
		Vector3(18.0, 0.06, 3.2), Color(0.66, 0.57, 0.43), false)
	_add_box(self, "WestPath", Vector3(-15.0, 0.025, 0.0),
		Vector3(18.0, 0.06, 3.2), Color(0.66, 0.57, 0.43), false)


func _build_houses() -> void:
	_add_house("BakerHouse", Vector3(-11.0, 0.0, -10.0),
		Color(0.88, 0.75, 0.58), Color(0.55, 0.25, 0.20))
	_add_house("BlueHouse", Vector3(11.0, 0.0, -10.0),
		Color(0.70, 0.78, 0.77), Color(0.32, 0.40, 0.55))
	_add_house("CaretakerHouse", Vector3(-11.0, 0.0, 11.0),
		Color(0.82, 0.76, 0.61), Color(0.48, 0.35, 0.22))
	_add_house("Workshop", Vector3(11.0, 0.0, 11.0),
		Color(0.77, 0.68, 0.55), Color(0.43, 0.29, 0.20))


func _add_house(house_name: String, origin: Vector3,
		wall_color: Color, roof_color: Color) -> void:
	var house := StaticBody3D.new()
	house.name = house_name
	house.position = origin
	house.collision_layer = 1
	house.collision_mask = 1
	add_child(house)

	var walls := BoxMesh.new()
	walls.size = Vector3(5.0, 3.0, 4.5)
	_add_mesh(house, "Walls", walls, Vector3(0.0, 1.5, 0.0), wall_color)

	var wall_shape := BoxShape3D.new()
	wall_shape.size = walls.size
	_add_collision(house, wall_shape, Vector3(0.0, 1.5, 0.0))

	var roof := BoxMesh.new()
	roof.size = Vector3(5.8, 0.65, 5.2)
	_add_mesh(house, "Roof", roof, Vector3(0.0, 3.25, 0.0), roof_color)

	var door := BoxMesh.new()
	door.size = Vector3(0.95, 1.9, 0.10)
	_add_mesh(house, "FrontDoor", door, Vector3(0.0, 0.95, 2.30),
		Color(0.30, 0.20, 0.13))

	var window_mesh := BoxMesh.new()
	window_mesh.size = Vector3(0.85, 0.75, 0.12)
	_add_mesh(house, "LeftWindow", window_mesh, Vector3(-1.55, 1.9, 2.31),
		Color(0.40, 0.68, 0.75))
	_add_mesh(house, "RightWindow", window_mesh, Vector3(1.55, 1.9, 2.31),
		Color(0.40, 0.68, 0.75))

	# Architectural trim: foundations, roof fascia, window frames and door hardware.
	_add_mesh(house, "StoneFoundation", BoxMesh.new(), Vector3(0.0, 0.18, 0.0),
		Color(0.43, 0.40, 0.34))
	var foundation_node := house.get_node("StoneFoundation") as MeshInstance3D
	(foundation_node.mesh as BoxMesh).size = Vector3(5.18, 0.36, 4.68)
	_add_mesh(house, "RoofFrontFascia", BoxMesh.new(), Vector3(0.0, 2.94, 2.58),
		Color(0.34, 0.25, 0.19))
	var fascia_node := house.get_node("RoofFrontFascia") as MeshInstance3D
	(fascia_node.mesh as BoxMesh).size = Vector3(5.92, 0.16, 0.16)
	_add_mesh(house, "DoorFrame", BoxMesh.new(), Vector3(0.0, 0.98, 2.37),
		Color(0.66, 0.53, 0.37))
	var door_frame := house.get_node("DoorFrame") as MeshInstance3D
	(door_frame.mesh as BoxMesh).size = Vector3(1.18, 2.08, 0.12)
	_add_mesh(house, "DoorHandle", SphereMesh.new(), Vector3(0.31, 0.95, 2.40),
		Color(0.88, 0.68, 0.28))
	for window_x in [-1.55, 1.55]:
		var frame := BoxMesh.new()
		frame.size = Vector3(1.02, 0.91, 0.10)
		_add_mesh(house, "WindowFrame_%s" % str(window_x), frame,
			Vector3(window_x, 1.9, 2.39), Color(0.34, 0.25, 0.18))
		var crossbar := BoxMesh.new()
		crossbar.size = Vector3(0.06, 0.76, 0.06)
		_add_mesh(house, "WindowMullion_%s" % str(window_x), crossbar,
			Vector3(window_x, 1.9, 2.46), Color(0.78, 0.69, 0.52))
		var sill := BoxMesh.new()
		sill.size = Vector3(1.12, 0.10, 0.20)
		_add_mesh(house, "WindowSill_%s" % str(window_x), sill,
			Vector3(window_x, 1.40, 2.42), Color(0.79, 0.73, 0.62))
		var shutter := BoxMesh.new()
		shutter.size = Vector3(0.16, 0.86, 0.12)
		for shutter_side in [-1.0, 1.0]:
			_add_mesh(house, "WindowShutter_%s_%s" % [str(window_x), str(shutter_side)],
				shutter, Vector3(window_x + shutter_side * 0.59, 1.9, 2.42),
				roof_color.darkened(0.10))

	# A small porch, steps, chimney and drainpipe break up the flat box-house silhouette.
	var porch_roof := BoxMesh.new()
	porch_roof.size = Vector3(2.25, 0.14, 1.05)
	_add_mesh(house, "PorchCanopy", porch_roof, Vector3(0.0, 2.43, 2.78),
		roof_color.darkened(0.12))
	var porch_column := CylinderMesh.new()
	porch_column.top_radius = 0.065
	porch_column.bottom_radius = 0.085
	porch_column.height = 2.25
	for column_x in [-0.96, 0.96]:
		_add_mesh(house, "PorchColumn_%s" % str(column_x), porch_column,
			Vector3(column_x, 1.16, 3.16), Color(0.83, 0.77, 0.65))
	var upper_step := BoxMesh.new()
	upper_step.size = Vector3(1.55, 0.16, 0.48)
	_add_mesh(house, "FrontStepUpper", upper_step, Vector3(0.0, 0.11, 2.73),
		Color(0.59, 0.56, 0.49))
	var lower_step := BoxMesh.new()
	lower_step.size = Vector3(1.82, 0.12, 0.58)
	_add_mesh(house, "FrontStepLower", lower_step, Vector3(0.0, 0.06, 3.08),
		Color(0.67, 0.63, 0.55))
	var chimney := BoxMesh.new()
	chimney.size = Vector3(0.55, 1.25, 0.58)
	_add_mesh(house, "Chimney", chimney, Vector3(1.62, 3.92, -1.20),
		roof_color.darkened(0.24))
	var chimney_cap := BoxMesh.new()
	chimney_cap.size = Vector3(0.72, 0.12, 0.72)
	_add_mesh(house, "ChimneyCap", chimney_cap, Vector3(1.62, 4.60, -1.20),
		Color(0.35, 0.28, 0.23))
	var drainpipe := CylinderMesh.new()
	drainpipe.top_radius = 0.045
	drainpipe.bottom_radius = 0.045
	drainpipe.height = 2.75
	_add_mesh(house, "RainDownpipe", drainpipe, Vector3(-2.39, 1.43, 2.12),
		Color(0.34, 0.38, 0.38))


func _build_house_portal() -> void:
	var portal_script = preload("res://scripts/world/house_interior_portal.gd")
	var portal := Node3D.new()
	portal.name = "CaretakerHousePortal"
	portal.position = Vector3(-11.0, 0.0, 13.35)
	portal.set_script(portal_script)
	portal.set("room_title_ar", "منزل الحارسة")
	add_child(portal)


func _build_garden() -> void:
	var garden_origin := Vector3(0.0, 0.0, 27.0)
	_add_box(self, "CommunityGarden", garden_origin + Vector3(0.0, 0.04, 0.0),
		Vector3(13.0, 0.08, 9.0), Color(0.38, 0.55, 0.31), false)

	for x in [-6.0, 6.0]:
		for z in [-4.0, 4.0]:
			_add_box(self, "GardenFencePost", garden_origin + Vector3(x, 0.55, z),
				Vector3(0.22, 1.1, 0.22), Color(0.40, 0.27, 0.16), false)
	_add_box(self, "GardenFenceNorth", garden_origin + Vector3(0.0, 0.48, -4.0),
		Vector3(12.0, 0.16, 0.16), Color(0.48, 0.33, 0.20), false)
	_add_box(self, "GardenFenceSouth", garden_origin + Vector3(0.0, 0.48, 4.0),
		Vector3(12.0, 0.16, 0.16), Color(0.48, 0.33, 0.20), false)
	_add_box(self, "GardenFenceEast", garden_origin + Vector3(6.0, 0.48, 0.0),
		Vector3(0.16, 0.16, 8.0), Color(0.48, 0.33, 0.20), false)
	_add_box(self, "GardenFenceWestNorth", garden_origin + Vector3(-6.0, 0.48, -2.875),
		Vector3(0.16, 0.16, 2.25), Color(0.48, 0.33, 0.20), false)
	_add_box(self, "GardenFenceWestSouth", garden_origin + Vector3(-6.0, 0.48, 2.875),
		Vector3(0.16, 0.16, 2.25), Color(0.48, 0.33, 0.20), false)

	for x in [-3.5, 0.0, 3.5]:
		_add_box(self, "GardenBed", garden_origin + Vector3(x, 0.18, 0.0),
			Vector3(1.8, 0.25, 4.5), Color(0.30, 0.22, 0.13), false)
		_add_box(self, "GardenLeaves", garden_origin + Vector3(x, 0.42, 0.0),
			Vector3(1.45, 0.22, 3.8), Color(0.35, 0.62, 0.30), false)


func _build_trees() -> void:
	var positions := [
		Vector3(-23.0, 0.0, -18.0), Vector3(23.0, 0.0, -18.0),
		Vector3(-24.0, 0.0, 5.0), Vector3(24.0, 0.0, 5.0),
		Vector3(-19.0, 0.0, 29.0), Vector3(19.0, 0.0, 29.0),
		Vector3(-4.0, 0.0, 35.0), Vector3(5.0, 0.0, 36.0)
	]
	for index in range(positions.size()):
		_add_tree("WillowTree_%02d" % index, positions[index],
			1.0 + float(index % 3) * 0.12)


func _add_tree(tree_name: String, origin: Vector3, scale_factor: float) -> void:
	var tree := Node3D.new()
	tree.name = tree_name
	tree.position = origin
	tree.scale = Vector3.ONE * scale_factor
	add_child(tree)
	var variant := int(absf(origin.x * 3.0 + origin.z)) % 9
	FOLIAGE_VISUAL_BUILDER.build_tree_geometry(tree, variant)


func _build_well() -> void:
	var well := CylinderMesh.new()
	well.top_radius = 1.05
	well.bottom_radius = 1.05
	well.height = 0.75
	_add_mesh(self, "VillageWell", well, Vector3(4.0, 0.43, 0.0),
		Color(0.53, 0.52, 0.47))


func _build_interactive_objects() -> void:
	var door_script = preload("res://scripts/systems/interactable_door.gd")
	var garden_gate := Node3D.new()
	garden_gate.name = "GardenGate"
	garden_gate.position = Vector3(-6.0, 0.08, 25.25)
	garden_gate.set_script(door_script)
	garden_gate.set("panel_size", Vector3(0.14, 1.15, 3.5))
	add_child(garden_gate)

	var prop_script = preload("res://scripts/systems/carryable_prop.gd")
	var carryable := RigidBody3D.new()
	carryable.name = "CarryableGardenBasket"
	carryable.position = Vector3(3.0, 0.45, 27.0)
	carryable.set_script(prop_script)
	carryable.set("display_name_ar", "سلة الحديقة")
	add_child(carryable)


func _build_flora_details() -> void:
	var flower_colors := [
		Color(0.95, 0.67, 0.42),
		Color(0.88, 0.76, 0.82),
		Color(0.93, 0.84, 0.48)
	]
	var flower_positions := [
		Vector3(-5.2, 0.0, -7.0), Vector3(5.4, 0.0, -7.8),
		Vector3(-5.0, 0.0, 8.0), Vector3(5.0, 0.0, 8.5),
		Vector3(-17.0, 0.0, -13.0), Vector3(17.0, 0.0, -13.0),
		Vector3(-15.0, 0.0, 23.0), Vector3(15.0, 0.0, 23.0)
	]
	for index in range(flower_positions.size()):
		var flower := Node3D.new()
		flower.name = "Wildflower_%02d" % index
		flower.position = flower_positions[index]
		add_child(flower)
		var stem := CylinderMesh.new()
		stem.top_radius = 0.025
		stem.bottom_radius = 0.035
		stem.height = 0.42
		_add_mesh(flower, "Stem", stem, Vector3(0.0, 0.21, 0.0),
			Color(0.25, 0.43, 0.22))
		var bloom := SphereMesh.new()
		bloom.radius = 0.16
		bloom.height = 0.18
		_add_mesh(flower, "Bloom", bloom, Vector3(0.0, 0.45, 0.0),
			flower_colors[index % flower_colors.size()])

	for index in range(6):
		var stone := SphereMesh.new()
		stone.radius = 0.34
		stone.height = 0.22
		_add_mesh(self, "PathStone_%02d" % index, stone,
			Vector3(-2.5 + float(index) * 0.9, 0.12, -13.0),
			Color(0.55, 0.55, 0.48))


func _build_signpost() -> void:
	var post := CylinderMesh.new()
	post.top_radius = 0.10
	post.bottom_radius = 0.14
	post.height = 2.0
	_add_mesh(self, "VillageSignPost", post, Vector3(0.0, 1.0, -22.0),
		Color(0.35, 0.24, 0.15))

	var sign := BoxMesh.new()
	sign.size = Vector3(2.8, 0.75, 0.18)
	_add_mesh(self, "VillageSign", sign, Vector3(0.0, 1.85, -22.0),
		Color(0.62, 0.43, 0.24))

	var label := Label3D.new()
	label.name = "VillageName"
	label.text = "WILLOW VILLAGE"
	label.position = Vector3(0.0, 1.85, -21.85)
	label.font_size = 32
	label.modulate = Color(1.0, 0.93, 0.75)
	add_child(label)


func _add_box(parent: Node3D, node_name: String, position: Vector3,
		size: Vector3, color: Color, with_collision: bool) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	parent.add_child(instance)

	if with_collision:
		var body := StaticBody3D.new()
		body.name = node_name + "Body"
		body.position = position
		var shape := BoxShape3D.new()
		shape.size = size
		_add_collision(body, shape, Vector3.ZERO)
		parent.add_child(body)


func _add_mesh(parent: Node3D, node_name: String, mesh: Mesh,
		position: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	parent.add_child(instance)


func _add_collision(parent: Node3D, shape: Shape3D, position: Vector3) -> void:
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = position
	parent.add_child(collision)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material


func _build_consumable_shop() -> void:
	var shop_script = preload("res://scripts/world/consumable_shop.gd")
	var shop := Node3D.new()
	shop.name = "VillageGrocery"
	shop.position = Vector3(-11.0, 0.0, -5.2)
	shop.set_script(shop_script)
	add_child(shop)


func _build_reference_street() -> void:
	# A paved residential street and raised sidewalks frame the initial spawn,
	# matching the road/sidewalk composition in the supplied mobile reference.
	var road_mesh := BoxMesh.new()
	road_mesh.size = Vector3(10.4, 0.06, 58.0)
	var road := MeshInstance3D.new()
	road.name = "ReferenceResidentialRoad"
	road.mesh = road_mesh
	road.position = Vector3(0.0, 0.025, -15.0)
	var asphalt := _material(Color(0.92, 0.94, 0.95))
	var asphalt_texture := load("res://assets/environment/materials/hd_district_asphalt.svg") as Texture2D
	if asphalt_texture != null:
		asphalt.albedo_texture = asphalt_texture
		asphalt.uv1_scale = Vector3(4.0, 4.0, 4.0)
	road.material_override = asphalt
	add_child(road)

	for side in [-1.0, 1.0]:
		var sidewalk_mesh := BoxMesh.new()
		sidewalk_mesh.size = Vector3(3.0, 0.08, 58.0)
		var sidewalk := MeshInstance3D.new()
		sidewalk.name = "ResidentialSidewalk_%s" % ("West" if side < 0.0 else "East")
		sidewalk.mesh = sidewalk_mesh
		sidewalk.position = Vector3(side * 6.9, 0.045, -15.0)
		var pavement := _material(Color(0.83, 0.84, 0.80))
		var pavement_texture := load("res://assets/environment/materials/harbor_paving_atlas.svg") as Texture2D
		if pavement_texture != null:
			pavement.albedo_texture = pavement_texture
			pavement.uv1_scale = Vector3(3.0, 3.0, 3.0)
		sidewalk.material_override = pavement
		add_child(sidewalk)

		var curb_mesh := BoxMesh.new()
		curb_mesh.size = Vector3(0.22, 0.17, 58.0)
		var curb := MeshInstance3D.new()
		curb.name = "ResidentialCurb_%s" % ("West" if side < 0.0 else "East")
		curb.mesh = curb_mesh
		curb.position = Vector3(side * 5.22, 0.12, -15.0)
		curb.material_override = _material(Color(0.55, 0.57, 0.55))
		add_child(curb)

	# Broken center line, lane edge guidance and a pedestrian crossing.
	for index in range(9):
		var dash := BoxMesh.new()
		dash.size = Vector3(0.13, 0.012, 2.4)
		_add_mesh(self, "RoadCenterDash_%02d" % index, dash,
			Vector3(0.0, 0.064, -41.0 + float(index) * 6.2),
			Color(0.91, 0.89, 0.77))
	for x_index in range(9):
		var stripe := BoxMesh.new()
		stripe.size = Vector3(0.58, 0.014, 2.8)
		_add_mesh(self, "PedestrianCrossing_%02d" % x_index, stripe,
			Vector3(-4.0 + float(x_index) * 1.0, 0.068, -5.5),
			Color(0.92, 0.91, 0.83))

	# Expansion joints and storm drains add scale cues to the sidewalk and curb.
	var sidewalk_joint := BoxMesh.new()
	sidewalk_joint.size = Vector3(2.88, 0.012, 0.035)
	var drain_cover := BoxMesh.new()
	drain_cover.size = Vector3(0.52, 0.018, 0.72)
	for side in [-1.0, 1.0]:
		for joint_index in range(14):
			_add_mesh(self, "SidewalkJoint_%s_%02d" % [str(side), joint_index],
				sidewalk_joint, Vector3(side * 6.9, 0.091,
					-42.0 + float(joint_index) * 4.1), Color(0.59, 0.60, 0.57))
		for drain_index in range(3):
			var drain_z := -36.0 + float(drain_index) * 18.0
			_add_mesh(self, "StormDrain_%s_%d" % [str(side), drain_index],
				drain_cover, Vector3(side * 5.04, 0.091, drain_z),
				Color(0.19, 0.22, 0.22))
			for grate_index in range(5):
				var grate_bar := BoxMesh.new()
				grate_bar.size = Vector3(0.42, 0.022, 0.035)
				_add_mesh(self, "StormDrainBar_%s_%d_%d" % [str(side), drain_index, grate_index],
					grate_bar, Vector3(side * 5.04, 0.105,
						drain_z - 0.27 + float(grate_index) * 0.135),
					Color(0.48, 0.52, 0.52))

	# Trees and street lamps give the first camera view a recognizable sidewalk edge.
	for index in range(3):
		var z_position := -34.0 + float(index) * 17.0
		for side in [-1.0, 1.0]:
			var tree_name := "ResidentialTree_%02d_%s" % [index, "W" if side < 0.0 else "E"]
			_add_tree(tree_name, Vector3(side * 8.9, 0.0, z_position),
				0.88 + float(index % 2) * 0.06)

	for index in range(3):
		var z_position := -30.0 + float(index) * 18.0
		for side in [-1.0, 1.0]:
			var lamp := Node3D.new()
			lamp.name = "ResidentialStreetLamp_%02d_%s" % [index, "W" if side < 0.0 else "E"]
			lamp.position = Vector3(side * 8.0, 0.0, z_position)
			add_child(lamp)
			var pole := CylinderMesh.new()
			pole.top_radius = 0.055
			pole.bottom_radius = 0.085
			pole.height = 4.2
			_add_mesh(lamp, "Pole", pole, Vector3(0.0, 2.1, 0.0),
				Color(0.18, 0.20, 0.19))
			var arm := BoxMesh.new()
			arm.size = Vector3(0.8, 0.08, 0.08)
			_add_mesh(lamp, "Arm", arm, Vector3(-side * 0.32, 4.12, 0.0),
				Color(0.18, 0.20, 0.19))
			var fixture := SphereMesh.new()
			fixture.radius = 0.16
			fixture.height = 0.22
			_add_mesh(lamp, "LampFixture", fixture,
				Vector3(-side * 0.65, 4.02, 0.0), Color(0.96, 0.83, 0.55))


func _build_reference_mission_marker() -> void:
	var marker_script = preload("res://scripts/world/reference_mission_marker.gd")
	var marker := Node3D.new()
	marker.name = "ReferenceMissionMarker"
	marker.position = Vector3(5.6, 0.04, -8.0)
	marker.set_script(marker_script)
	add_child(marker)
