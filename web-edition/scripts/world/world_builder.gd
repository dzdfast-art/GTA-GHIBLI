extends Node3D
class_name GhibliWorldBuilder

const INTERACTABLE_SCRIPT = preload("res://scripts/world/interactable.gd")
const CAR_SCRIPT = preload("res://scripts/vehicles/car_controller.gd")

const REGION_NAMES := [
	"Harbor City",
	"Sapphire Coast",
	"Pine Highlands",
	"Amber Valley"
]
const REGION_CENTERS := [-96.0, -32.0, 32.0, 96.0]

var spawn_position := Vector3(-114.0, 0.05, 0.0)


func build_world() -> void:
	for index in range(REGION_NAMES.size()):
		_create_region(index)
	_create_connected_road()
	_create_access_roads()
	_create_landmarks()
	_create_characters()
	_create_starting_vehicle()


func get_region_name_at(position: Vector3) -> String:
	var index := clampi(int(floor((position.x + 128.0) / 64.0)), 0, REGION_NAMES.size() - 1)
	return REGION_NAMES[index]


func get_points_of_interest() -> Array[Dictionary]:
	return [
		{
			"id": "marsa_al_noor",
			"name": "Marsa Al-Noor Lighthouse",
			"region": "Harbor City",
			"category": "landmark",
			"position": Vector3(-79.0, 0.0, 17.0)
		},
		{
			"id": "harbor_market",
			"name": "Harbor Market",
			"region": "Harbor City",
			"category": "shop",
			"position": Vector3(-81.0, 0.0, 21.0)
		},
		{
			"id": "nora_blake",
			"name": "Nora Blake",
			"region": "Harbor City",
			"category": "mission",
			"position": Vector3(-75.0, 0.0, 11.0)
		},
		{
			"id": "sapphire_cafe",
			"name": "Sapphire Coast Cafe",
			"region": "Sapphire Coast",
			"category": "service",
			"position": Vector3(-50.0, 0.0, -19.0)
		},
		{
			"id": "pine_cabin",
			"name": "Pine Highlands Cabin",
			"region": "Pine Highlands",
			"category": "rest",
			"position": Vector3(14.0, 0.0, -18.0)
		},
		{
			"id": "amber_farm",
			"name": "Amber Valley Farm",
			"region": "Amber Valley",
			"category": "farm",
			"position": Vector3(113.0, 0.0, -18.0)
		}
	]


func get_road_graph() -> Dictionary:
	var points: Array[Dictionary] = get_points_of_interest()
	var road_x_values: Array[float] = [-128.0, -96.0, -64.0, -32.0, 0.0, 32.0, 64.0, 96.0, 128.0]
	for point in points:
		var position: Vector3 = point["position"]
		road_x_values.append(position.x)
	road_x_values.sort()

	var unique_x_values: Array[float] = []
	for x_value in road_x_values:
		if unique_x_values.is_empty() or absf(unique_x_values[unique_x_values.size() - 1] - x_value) > 0.01:
			unique_x_values.append(x_value)

	var nodes: Array[Dictionary] = []
	var edges: Array[Dictionary] = []
	var road_node_ids: Dictionary = {}
	for x_value in unique_x_values:
		var node_id := "road_%d" % roundi(x_value)
		road_node_ids[roundi(x_value)] = node_id
		nodes.append({"id": node_id, "position": Vector3(x_value, 0.0, 0.0), "kind": "road"})

	for index in range(unique_x_values.size() - 1):
		var from_x := unique_x_values[index]
		var to_x := unique_x_values[index + 1]
		var from_id := str(road_node_ids[roundi(from_x)])
		var to_id := str(road_node_ids[roundi(to_x)])
		edges.append({
			"id": "road_segment_%02d" % index,
			"from": from_id,
			"to": to_id,
			"cost": absf(to_x - from_x)
		})

	for point in points:
		var point_id := str(point["id"])
		var point_position: Vector3 = point["position"]
		var road_node_id := str(road_node_ids[roundi(point_position.x)])
		var poi_node_id := "poi_" + point_id
		nodes.append({"id": poi_node_id, "position": point_position, "kind": "poi"})
		edges.append({
			"id": "access_" + point_id,
			"from": road_node_id,
			"to": poi_node_id,
			"cost": point_position.distance_to(Vector3(point_position.x, 0.0, 0.0))
		})

	return {"nodes": nodes, "edges": edges}


func _create_access_roads() -> void:
	var material := _make_material(Color(0.17, 0.18, 0.18))
	for point in get_points_of_interest():
		var point_position: Vector3 = point["position"]
		if absf(point_position.z) < 0.5:
			continue
		var access_road := MeshInstance3D.new()
		access_road.name = "AccessRoad_" + str(point["id"])
		var road_mesh := BoxMesh.new()
		road_mesh.size = Vector3(5.0, 0.055, absf(point_position.z))
		access_road.mesh = road_mesh
		access_road.position = Vector3(point_position.x, 0.08, point_position.z * 0.5)
		access_road.material_override = material
		add_child(access_road)


func _create_region(index: int) -> void:
	var center_x: float = REGION_CENTERS[index]
	var colors := [
		Color(0.28, 0.39, 0.40),
		Color(0.62, 0.57, 0.39),
		Color(0.25, 0.38, 0.29),
		Color(0.57, 0.43, 0.27)
	]
	var ground := StaticBody3D.new()
	ground.name = REGION_NAMES[index].replace(" ", "") + "Ground"
	ground.position = Vector3(center_x, -0.25, 0.0)
	add_child(ground)

	var ground_mesh := MeshInstance3D.new()
	var ground_box := BoxMesh.new()
	ground_box.size = Vector3(64.0, 0.5, 64.0)
	ground_mesh.mesh = ground_box
	ground_mesh.material_override = _make_material(colors[index])
	ground.add_child(ground_mesh)

	var collision := CollisionShape3D.new()
	var floor_shape := BoxShape3D.new()
	floor_shape.size = ground_box.size
	collision.shape = floor_shape
	ground.add_child(collision)

	var title := Label3D.new()
	title.text = REGION_NAMES[index]
	title.position = Vector3(center_x, 0.08, -27.0)
	title.font_size = 52
	title.outline_size = 8
	title.modulate = Color(1.0, 0.91, 0.70)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(title)

	_create_region_props(index, center_x)


func _create_connected_road() -> void:
	var road := MeshInstance3D.new()
	var road_mesh := BoxMesh.new()
	road_mesh.size = Vector3(258.0, 0.08, 11.0)
	road.mesh = road_mesh
	road.position = Vector3(0.0, 0.055, 0.0)
	road.material_override = _make_material(Color(0.12, 0.14, 0.15))
	add_child(road)

	var shoulder_material := _make_material(Color(0.48, 0.43, 0.34))
	for side in [-1.0, 1.0]:
		var shoulder := MeshInstance3D.new()
		var shoulder_mesh := BoxMesh.new()
		shoulder_mesh.size = Vector3(258.0, 0.035, 1.2)
		shoulder.mesh = shoulder_mesh
		shoulder.position = Vector3(0.0, 0.02, side * 6.0)
		shoulder.material_override = shoulder_material
		add_child(shoulder)

	var line_material := _make_material(Color(0.91, 0.82, 0.54))
	for x in range(-124, 125, 12):
		var line := MeshInstance3D.new()
		var line_mesh := BoxMesh.new()
		line_mesh.size = Vector3(5.0, 0.025, 0.12)
		line.mesh = line_mesh
		line.position = Vector3(float(x), 0.105, 0.0)
		line.material_override = line_material
		add_child(line)


func _create_region_props(index: int, center_x: float) -> void:
	match index:
		0:
			_create_building("HarborHomes", Vector3(center_x - 18.0, 0.0, -20.0), Vector3(11.0, 10.0, 11.0), Color(0.72, 0.64, 0.51))
			_create_building("HarborShop", Vector3(center_x + 15.0, 0.0, 21.0), Vector3(10.0, 7.0, 9.0), Color(0.62, 0.51, 0.40))
			_create_tree(Vector3(center_x - 24.0, 0.0, 18.0), Color(0.20, 0.38, 0.25))
			_create_tree(Vector3(center_x + 25.0, 0.0, -18.0), Color(0.20, 0.38, 0.25))
		1:
			_create_building("CoastCafe", Vector3(center_x - 18.0, 0.0, -19.0), Vector3(12.0, 6.0, 10.0), Color(0.84, 0.75, 0.58))
			_create_tree(Vector3(center_x + 22.0, 0.0, -20.0), Color(0.22, 0.40, 0.31))
			_create_tree(Vector3(center_x + 23.0, 0.0, 20.0), Color(0.22, 0.40, 0.31))
		2:
			_create_building("HighlandCabin", Vector3(center_x - 18.0, 0.0, -18.0), Vector3(10.0, 7.0, 9.0), Color(0.43, 0.32, 0.22))
			for position in [
				Vector3(center_x - 24.0, 0.0, 16.0),
				Vector3(center_x - 5.0, 0.0, 24.0),
				Vector3(center_x + 22.0, 0.0, -19.0)
			]:
				_create_tree(position, Color(0.13, 0.30, 0.19))
		3:
			_create_building("AmberFarm", Vector3(center_x + 17.0, 0.0, -18.0), Vector3(13.0, 6.5, 10.0), Color(0.61, 0.43, 0.25))
			_create_tree(Vector3(center_x - 20.0, 0.0, 21.0), Color(0.38, 0.41, 0.18))
			_create_tree(Vector3(center_x + 24.0, 0.0, 20.0), Color(0.38, 0.41, 0.18))


func _create_building(building_name: String, world_position: Vector3, size: Vector3, color: Color) -> void:
	var building := StaticBody3D.new()
	building.name = building_name
	building.position = world_position
	add_child(building)

	var mesh_instance := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position.y = size.y * 0.5
	mesh_instance.material_override = _make_material(color)
	building.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position.y = size.y * 0.5
	building.add_child(collision)


func _create_tree(world_position: Vector3, leaf_color: Color) -> void:
	var tree := Node3D.new()
	tree.position = world_position
	add_child(tree)

	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.22
	trunk_mesh.bottom_radius = 0.38
	trunk_mesh.height = 2.7
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.35
	trunk.material_override = _make_material(Color(0.28, 0.19, 0.12))
	tree.add_child(trunk)

	var leaves := MeshInstance3D.new()
	var leaf_mesh := SphereMesh.new()
	leaf_mesh.radius = 1.45
	leaf_mesh.height = 2.7
	leaf_mesh.radial_segments = 7
	leaf_mesh.rings = 5
	leaves.mesh = leaf_mesh
	leaves.position.y = 3.0
	leaves.material_override = _make_material(leaf_color)
	tree.add_child(leaves)

	var collision := StaticBody3D.new()
	collision.position.y = 1.2
	var collider := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.3
	cylinder.height = 2.4
	collider.shape = cylinder
	collision.add_child(collider)
	tree.add_child(collision)


func _create_landmarks() -> void:
	var lighthouse := StaticBody3D.new()
	lighthouse.name = "MarsaAlNoorLighthouse"
	lighthouse.position = Vector3(-79.0, 0.0, 17.0)
	add_child(lighthouse)

	var tower := MeshInstance3D.new()
	var tower_mesh := CylinderMesh.new()
	tower_mesh.top_radius = 1.0
	tower_mesh.bottom_radius = 1.7
	tower_mesh.height = 9.0
	tower.mesh = tower_mesh
	tower.position.y = 4.5
	tower.material_override = _make_material(Color(0.78, 0.72, 0.59))
	lighthouse.add_child(tower)

	var roof := MeshInstance3D.new()
	var roof_mesh := CylinderMesh.new()
	roof_mesh.top_radius = 0.0
	roof_mesh.bottom_radius = 1.45
	roof_mesh.height = 1.7
	roof.mesh = roof_mesh
	roof.position.y = 9.8
	roof.material_override = _make_material(Color(0.40, 0.20, 0.15))
	lighthouse.add_child(roof)

	var collision := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 1.5
	shape.height = 9.0
	collision.shape = shape
	collision.position.y = 4.5
	lighthouse.add_child(collision)

	var sign := Label3D.new()
	sign.text = "MARSA AL-NOOR"
	sign.position = Vector3(-79.0, 11.0, 17.0)
	sign.font_size = 44
	sign.outline_size = 7
	sign.modulate = Color(1.0, 0.86, 0.55)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(sign)


func _create_characters() -> void:
	_create_person("ClaireBennett", "Claire Bennett", "claire", Vector3(-113.0, 0.0, -4.0), Color(0.66, 0.37, 0.49))
	_create_person("MiaBennett", "Mia Bennett", "mia", Vector3(-119.0, 0.0, 5.0), Color(0.40, 0.53, 0.74))
	_create_person("NoraBlake", "Nora Blake", "nora", Vector3(-75.0, 0.0, 11.0), Color(0.75, 0.54, 0.29))


func _create_person(node_name: String, label: String, action_id: String, world_position: Vector3, clothing_color: Color) -> void:
	var actor := INTERACTABLE_SCRIPT.new() as Node3D
	actor.name = node_name
	actor.set("action_id", action_id)
	actor.set("display_name", label)
	actor.set("interaction_text", "E — Speak")
	actor.position = world_position
	add_child(actor)

	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.34
	capsule.height = 1.55
	body.mesh = capsule
	body.position.y = 0.82
	body.material_override = _make_material(clothing_color)
	actor.add_child(body)

	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.27
	sphere.height = 0.54
	head.mesh = sphere
	head.position.y = 1.78
	head.material_override = _make_material(Color(0.82, 0.64, 0.49))
	actor.add_child(head)

	var title := Label3D.new()
	title.text = label
	title.position.y = 2.35
	title.font_size = 34
	title.outline_size = 6
	title.modulate = Color(1.0, 0.96, 0.84)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	actor.add_child(title)


func _create_starting_vehicle() -> void:
	var car := CAR_SCRIPT.new() as CharacterBody3D
	car.name = "HarborSedan"
	car.position = Vector3(-104.0, 0.0, 8.0)
	add_child(car)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.92
	return material
