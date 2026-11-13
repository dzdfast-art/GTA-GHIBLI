extends Node3D

## Original low-poly village blockout.
## All geometry is procedural and intentionally lightweight for mobile.

const GROUND_Y := 0.03


func _ready() -> void:
	_build_square()
	_build_paths()
	_build_houses()
	_build_garden()
	_build_trees()
	_build_well()
	_build_signpost()


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
	_add_box(self, "GardenFenceWest", garden_origin + Vector3(-6.0, 0.48, 0.0),
		Vector3(0.16, 0.16, 8.0), Color(0.48, 0.33, 0.20), false)

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

	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.24
	trunk.bottom_radius = 0.38
	trunk.height = 2.8
	_add_mesh(tree, "Trunk", trunk, Vector3(0.0, 1.4, 0.0),
		Color(0.34, 0.23, 0.15))

	var crown := SphereMesh.new()
	crown.radius = 1.65
	crown.height = 3.0
	_add_mesh(tree, "Canopy", crown, Vector3(0.0, 3.2, 0.0),
		Color(0.30, 0.52, 0.29))


func _build_well() -> void:
	var well := CylinderMesh.new()
	well.top_radius = 1.05
	well.bottom_radius = 1.05
	well.height = 0.75
	_add_mesh(self, "VillageWell", well, Vector3(0.0, 0.43, 0.0),
		Color(0.53, 0.52, 0.47))


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
