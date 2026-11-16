extends Node3D

## Procedural blockout for four explorable districts linked to Willow Village.
## Geometry is original, light-weight and assembled at runtime for mobile testing.
const NPC_BRAIN_SCRIPT = preload("res://scripts/systems/npc_brain.gd")

var _region_ids: Array[String] = []
var _population_count := 0
var _building_count := 0

func _ready() -> void:
	_build_region("harbor_city", "مدينة الميناء", Vector3(-82.0, 0.0, -54.0),
		Color(0.48, 0.57, 0.63), Color(0.30, 0.39, 0.48), Color(0.66, 0.72, 0.73),
		["نادر", "سلمى"])
	_build_region("pine_highlands", "مرتفعات الصنوبر", Vector3(80.0, 0.0, -52.0),
		Color(0.39, 0.52, 0.36), Color(0.28, 0.39, 0.27), Color(0.61, 0.52, 0.39),
		["رامي", "هالة"])
	_build_region("amber_valley", "وادي الكهرمان", Vector3(-82.0, 0.0, 52.0),
		Color(0.69, 0.57, 0.37), Color(0.47, 0.37, 0.24), Color(0.76, 0.68, 0.50),
		["فارس", "ليلى"])
	_build_region("sapphire_coast", "ساحل الياقوت", Vector3(82.0, 0.0, 52.0),
		Color(0.36, 0.58, 0.65), Color(0.25, 0.43, 0.52), Color(0.77, 0.69, 0.54),
		["ياسر", "مريم"])

func get_region_ids() -> Array[String]:
	return _region_ids.duplicate()

func get_population_count() -> int:
	return _population_count

func get_building_count() -> int:
	return _building_count

func _build_region(region_id: String, region_name: String, center: Vector3,
		ground_color: Color, wall_color: Color, roof_color: Color, npc_names: Array) -> void:
	_region_ids.append(region_id)
	var district := Node3D.new()
	district.name = region_id.to_pascal_case()
	district.position = center
	add_child(district)

	var pad := MeshInstance3D.new()
	pad.name = "DistrictGround"
	var pad_mesh := BoxMesh.new()
	pad_mesh.size = Vector3(42.0, 0.12, 34.0)
	pad.mesh = pad_mesh
	pad.position.y = 0.04
	var ground_texture_path := _district_ground_texture(region_id)
	pad.material_override = _material(Color.WHITE, ground_texture_path)
	district.add_child(pad)

	var title := Label3D.new()
	title.name = "DistrictName"
	title.text = region_name
	title.position = Vector3(0.0, 5.6, -15.2)
	title.font_size = 44
	title.modulate = Color(1.0, 0.94, 0.78)
	title.outline_size = 8
	district.add_child(title)

	_build_road(center)
	_build_district_buildings(district, wall_color, roof_color)
	_build_district_details(district, region_id, ground_color)
	_build_civilians(district, region_id, npc_names)

func _build_road(center: Vector3) -> void:
	var flat_center := Vector2(center.x, center.z)
	var length := flat_center.length()
	var midpoint := Vector3(center.x * 0.5, 0.08, center.z * 0.5)
	var road := MeshInstance3D.new()
	road.name = "RoadTo_" + str(_region_ids.back())
	var road_mesh := BoxMesh.new()
	road_mesh.size = Vector3(5.2, 0.12, length)
	road.mesh = road_mesh
	road.position = midpoint
	road.rotation.y = atan2(center.x, center.z)
	road.material_override = _material(Color(0.20, 0.22, 0.22))
	add_child(road)

func _build_district_buildings(district: Node3D, wall_color: Color, roof_color: Color) -> void:
	var offsets := [
		Vector3(-12.0, 0.0, -7.0),
		Vector3(0.0, 0.0, -7.0),
		Vector3(12.0, 0.0, -7.0),
		Vector3(-12.0, 0.0, 8.0),
		Vector3(0.0, 0.0, 8.0),
		Vector3(12.0, 0.0, 8.0)
	]
	for index in range(offsets.size()):
		var building := StaticBody3D.new()
		building.name = "DistrictBuilding_%02d" % (index + 1)
		building.position = offsets[index]
		building.collision_layer = 1
		building.collision_mask = 1
		district.add_child(building)

		var dimensions := Vector3(7.2, 3.8 + float(index % 2) * 0.8, 6.4)
		var body_mesh := BoxMesh.new()
		body_mesh.size = dimensions
		var visual := MeshInstance3D.new()
		visual.name = "Walls"
		visual.mesh = body_mesh
		visual.position.y = dimensions.y * 0.5
		visual.material_override = _material(wall_color)
		building.add_child(visual)

		var shape := BoxShape3D.new()
		shape.size = dimensions
		var collision := CollisionShape3D.new()
		collision.shape = shape
		collision.position.y = dimensions.y * 0.5
		building.add_child(collision)

		var roof_mesh := BoxMesh.new()
		roof_mesh.size = Vector3(dimensions.x + 0.6, 0.42, dimensions.z + 0.6)
		var roof := MeshInstance3D.new()
		roof.name = "Roof"
		roof.mesh = roof_mesh
		roof.position.y = dimensions.y + 0.2
		roof.material_override = _material(roof_color)
		building.add_child(roof)

		var door_mesh := BoxMesh.new()
		door_mesh.size = Vector3(1.0, 1.9, 0.12)
		var door := MeshInstance3D.new()
		door.name = "Door"
		door.mesh = door_mesh
		door.position = Vector3(0.0, 0.95, dimensions.z * 0.5 + 0.07)
		door.material_override = _material(Color(0.25, 0.18, 0.13))
		building.add_child(door)
		_building_count += 1

func _build_district_details(district: Node3D, region_id: String, ground_color: Color) -> void:
	match region_id:
		"harbor_city":
			for index in range(8):
				_add_box(district, "CargoContainer_%02d" % index,
					Vector3(-17.0 + float(index % 4) * 8.0, 1.0 + float(index / 4) * 2.1, 12.0),
					Vector3(6.5, 2.0, 2.7), Color(0.42 + float(index % 2) * 0.12, 0.34, 0.25))
			_add_box(district, "LoadingDock", Vector3(0.0, 0.25, 15.0),
				Vector3(30.0, 0.5, 4.0), Color(0.34, 0.36, 0.35))
		"pine_highlands":
			for index in range(10):
				var x := -18.0 + float(index % 5) * 9.0
				var z := 12.0 + float(index / 5) * 7.0
				_add_tree(district, "Pine_%02d" % index, Vector3(x, 0.0, z), 1.0 + float(index % 3) * 0.1)
		"amber_valley":
			for row in range(4):
				_add_box(district, "CropRow_%02d" % row, Vector3(-15.0 + float(row) * 10.0, 0.22, 14.0),
					Vector3(2.8, 0.4, 11.0), Color(0.34, 0.48 + float(row % 2) * 0.12, 0.24))
			_add_box(district, "WaterSilo", Vector3(16.0, 2.8, 13.0), Vector3(3.4, 5.6, 3.4), Color(0.58, 0.61, 0.63))
		"sapphire_coast":
			var water := MeshInstance3D.new()
			water.name = "CoastalWater"
			var water_mesh := BoxMesh.new()
			water_mesh.size = Vector3(30.0, 0.08, 8.0)
			water.mesh = water_mesh
			water.position = Vector3(0.0, 0.06, 14.0)
			var water_material := StandardMaterial3D.new()
			water_material.albedo_color = Color(0.12, 0.45, 0.62, 0.78)
			water_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			water_material.roughness = 0.22
			water.material_override = water_material
			district.add_child(water)
			_add_box(district, "CoastalPier", Vector3(0.0, 0.32, 8.0), Vector3(5.0, 0.64, 12.0), Color(0.42, 0.31, 0.21))
			for index in range(5):
				_add_box(district, "FishCrate_%02d" % index, Vector3(-12.0 + float(index) * 5.0, 0.5, 4.0),
					Vector3(1.4, 1.0, 1.2), Color(0.58, 0.43, 0.28))
		_:
			pass

func _build_civilians(district: Node3D, region_id: String, npc_names: Array) -> void:
	var positions := [Vector3(-5.0, 0.0, 2.0), Vector3(7.0, 0.0, 1.0)]
	for index in range(positions.size()):
		var civilian := Node3D.new()
		civilian.name = "Civilian_%s_%d" % [region_id, index + 1]
		civilian.position = positions[index]
		civilian.add_to_group("civilian_npcs")
		district.add_child(civilian)
		var body := MeshInstance3D.new()
		body.name = "Body"
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.34
		capsule.height = 1.65
		body.mesh = capsule
		body.position.y = 0.83
		body.material_override = _material(Color(0.32 + index * 0.16, 0.42, 0.58 - index * 0.08))
		civilian.add_child(body)
		var name_tag := Label3D.new()
		name_tag.text = str(npc_names[index])
		name_tag.position.y = 2.05
		name_tag.font_size = 26
		name_tag.modulate = Color(1.0, 0.93, 0.78)
		civilian.add_child(name_tag)

		var brain := Node.new()
		brain.name = "NPCBrain"
		brain.set_script(NPC_BRAIN_SCRIPT)
		brain.set("persistence_id", "%s_civilian_%d" % [region_id, index + 1])
		brain.set("schedule_enabled", true)
		brain.set("work_start_hour", 8 + index)
		brain.set("work_end_hour", 17 + index)
		brain.set("work_position", civilian.to_global(positions[index] + Vector3(1.5, 0.0, 1.0)))
		brain.set("home_position", civilian.global_position)
		civilian.add_child(brain)
		var clocks := get_tree().get_nodes_in_group("world_clock")
		if not clocks.is_empty() and is_instance_valid(clocks[0]):
			brain.call("set_world_hour", int(clocks[0].call("get_hour")))
		_population_count += 1

func _add_tree(parent: Node3D, tree_name: String, at: Vector3, scale_value: float) -> void:
	var tree := Node3D.new()
	tree.name = tree_name
	tree.position = at
	tree.scale = Vector3.ONE * scale_value
	parent.add_child(tree)
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.16
	trunk_mesh.bottom_radius = 0.26
	trunk_mesh.height = 2.4
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.2
	trunk.material_override = _material(Color(0.32, 0.22, 0.14))
	tree.add_child(trunk)
	var crown := MeshInstance3D.new()
	var crown_mesh := CylinderMesh.new()
	crown_mesh.top_radius = 0.0
	crown_mesh.bottom_radius = 1.25
	crown_mesh.height = 3.4
	crown.mesh = crown_mesh
	crown.position.y = 3.0
	crown.material_override = _material(Color(0.20, 0.39, 0.25))
	tree.add_child(crown)

func _add_box(parent: Node3D, node_name: String, at: Vector3, size: Vector3, tint: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = at
	instance.material_override = _material(tint)
	parent.add_child(instance)

func _district_ground_texture(region_id: String) -> String:
	match region_id:
		"harbor_city":
			return "res://assets/environment/materials/harbor_paving_atlas.svg"
		"pine_highlands":
			return "res://assets/environment/materials/pine_forest_floor_atlas.svg"
		"amber_valley":
			return "res://assets/environment/materials/amber_orchard_soil_atlas.svg"
		"sapphire_coast":
			return "res://assets/environment/materials/sapphire_coast_sand_atlas.svg"
	return ""

func _material(tint: Color, texture_path: String = "") -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.88
	if not texture_path.is_empty():
		var texture := load(texture_path) as Texture2D
		if texture != null:
			material.albedo_texture = texture
			material.uv1_scale = Vector3(3.0, 3.0, 3.0)
	return material
