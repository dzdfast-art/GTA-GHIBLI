extends Node3D

## Procedural blockout for four explorable districts linked to Willow Village.
## Geometry is original, light-weight and assembled at runtime for mobile testing.
const CIVILIAN_NPC_SCRIPT = preload("res://scripts/characters/world_npc_actor.gd")

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
	if region_id == "harbor_city":
		_build_harbor_skyline(district)
	_build_district_details(district, region_id, ground_color)
	if region_id == "harbor_city":
		_build_harbor_street_furniture(district)
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
	road.material_override = _material(Color(0.20, 0.22, 0.22), "res://assets/environment/materials/hd_district_asphalt.svg")
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
		visual.material_override = _material(wall_color, "res://assets/environment/materials/hd_village_plaster_wall.svg")
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
		roof.material_override = _material(roof_color, "res://assets/environment/materials/hd_terracotta_roof.svg")
		building.add_child(roof)

		var door_mesh := BoxMesh.new()
		door_mesh.size = Vector3(1.0, 1.9, 0.12)
		var door := MeshInstance3D.new()
		door.name = "Door"
		door.mesh = door_mesh
		door.position = Vector3(0.0, 0.95, dimensions.z * 0.5 + 0.07)
		door.material_override = _material(Color(0.25, 0.18, 0.13))
		building.add_child(door)
		_add_building_windows(building, dimensions)
		_building_count += 1

func _add_building_windows(building: StaticBody3D, dimensions: Vector3) -> void:
	## Repeated facade glazing gives each district building readable architectural scale.
	var transforms: Array[Transform3D] = []
	var half_width := dimensions.x * 0.5
	var half_depth := dimensions.z * 0.5
	var row_heights := [1.25, dimensions.y - 1.05]
	for y_value in row_heights:
		var y := float(y_value)
		for column in range(4):
			var x := -half_width + 1.05 + float(column) * ((dimensions.x - 2.1) / 3.0)
			transforms.append(Transform3D(Basis(), Vector3(x, y, half_depth + 0.045)))
			transforms.append(Transform3D(Basis(), Vector3(x, y, -half_depth - 0.045)))
		for column in range(3):
			var z := -half_depth + 1.0 + float(column) * ((dimensions.z - 2.0) / 2.0)
			transforms.append(Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(half_width + 0.045, y, z)))
			transforms.append(Transform3D(Basis(Vector3.UP, -PI * 0.5), Vector3(-half_width - 0.045, y, z)))

	var window_mesh := BoxMesh.new()
	window_mesh.size = Vector3(0.72, 0.58, 0.07)
	var instances := MultiMesh.new()
	instances.transform_format = MultiMesh.TRANSFORM_3D
	instances.mesh = window_mesh
	instances.instance_count = transforms.size()
	for index in range(transforms.size()):
		instances.set_instance_transform(index, transforms[index])

	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.48, 0.72, 0.82, 1.0)
	glass.roughness = 0.24
	glass.metallic = 0.12
	glass.emission_enabled = true
	glass.emission = Color(0.10, 0.19, 0.24)
	glass.emission_energy_multiplier = 0.16
	var windows := MultiMeshInstance3D.new()
	windows.name = "FacadeWindowInstances"
	windows.multimesh = instances
	windows.material_override = glass
	building.add_child(windows)


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
	var positions := [Vector3(-5.0,0.0,2.0),Vector3(7.0,0.0,1.0)]
	var ids := {
		"harbor_city":["nader_harbor","salma_harbor"],
		"pine_highlands":["rami_pines","hala_pines"],
		"amber_valley":["fares_valley","layla_valley"],
		"sapphire_coast":["yasser_coast","maryam_coast"]
	}
	var palette := [Color(0.25,0.42,0.62),Color(0.57,0.34,0.30),Color(0.34,0.48,0.31),Color(0.56,0.43,0.62)]
	for i in range(2):
		var civilian:=Node3D.new()
		civilian.name="Civilian_%s_%d" % [region_id,i+1]
		civilian.position=positions[i]
		civilian.add_to_group("civilian_npcs")
		civilian.set_script(CIVILIAN_NPC_SCRIPT)
		civilian.set("character_id",ids[region_id][i])
		civilian.set("character_name_ar",str(npc_names[i]))
		civilian.set("outfit_color",palette[(i+_region_ids.size())%palette.size()])
		district.add_child(civilian)
		_population_count+=1

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
	var texture_path := ""
	if node_name == "LoadingDock" or node_name == "CoastalPier":
		texture_path = "res://assets/environment/materials/hd_weathered_dock_timber.svg"
	instance.material_override = _material(tint, texture_path)
	parent.add_child(instance)

func _district_ground_texture(region_id: String) -> String:
	match region_id:
		"harbor_city":
			return "res://assets/environment/materials/hd_harbor_paving.svg"
		"pine_highlands":
			return "res://assets/environment/materials/hd_pine_forest_floor.svg"
		"amber_valley":
			return "res://assets/environment/materials/hd_amber_orchard_soil.svg"
		"sapphire_coast":
			return "res://assets/environment/materials/hd_sapphire_coastal_sand.svg"
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


func _build_harbor_skyline(district: Node3D) -> void:
	var skyline := Node3D.new()
	skyline.name = "GhibliSkyline"
	skyline.position = Vector3(0.0, 0.0, -25.0)
	district.add_child(skyline)

	var tower_specs := [
		{"name": "Tower_01", "position": Vector3(-17.0, 0.0, -3.0), "size": Vector3(9.0, 19.0, 8.0), "color": Color(0.43, 0.52, 0.58)},
		{"name": "Tower_02", "position": Vector3(0.0, 0.0, -1.0), "size": Vector3(10.0, 25.0, 9.0), "color": Color(0.53, 0.58, 0.61)},
		{"name": "Tower_03", "position": Vector3(17.0, 0.0, -4.0), "size": Vector3(12.0, 31.0, 10.0), "color": Color(0.39, 0.48, 0.55)},
		{"name": "Tower_04", "position": Vector3(31.0, 0.0, -2.0), "size": Vector3(8.0, 16.0, 8.0), "color": Color(0.60, 0.57, 0.50)}
	]
	for spec in tower_specs:
		var tower := Node3D.new()
		tower.name = str(spec["name"])
		tower.position = spec["position"]
		skyline.add_child(tower)

		var dimensions: Vector3 = spec["size"]
		var facade := MeshInstance3D.new()
		facade.name = "Facade"
		var facade_mesh := BoxMesh.new()
		facade_mesh.size = dimensions
		facade.mesh = facade_mesh
		facade.position.y = dimensions.y * 0.5
		facade.material_override = _material(spec["color"], "res://assets/environment/materials/ghibli_city_glass.svg")
		tower.add_child(facade)

		var roofline := MeshInstance3D.new()
		roofline.name = "Roofline"
		var roof_mesh := BoxMesh.new()
		roof_mesh.size = Vector3(dimensions.x + 0.5, 0.45, dimensions.z + 0.5)
		roofline.mesh = roof_mesh
		roofline.position.y = dimensions.y + 0.22
		roofline.material_override = _material(Color(0.22, 0.27, 0.31))
		tower.add_child(roofline)

		var window_mesh := BoxMesh.new()
		window_mesh.size = Vector3(0.68, 0.82, 0.09)
		var windows := MultiMesh.new()
		windows.transform_format = MultiMesh.TRANSFORM_3D
		windows.mesh = window_mesh
		var columns := 8
		var rows := 12
		windows.instance_count = columns * rows
		windows.visible_instance_count = columns * rows
		for row in range(rows):
			for column in range(columns):
				var x := -dimensions.x * 0.39 + float(column) * dimensions.x * 0.78 / float(columns - 1)
				var y := 1.7 + float(row) * maxf(1.2, (dimensions.y - 3.0) / float(rows - 1))
				var transform := Transform3D(Basis.IDENTITY, Vector3(x, y, -dimensions.z * 0.505))
				windows.set_instance_transform(row * columns + column, transform)
		var window_instances := MultiMeshInstance3D.new()
		window_instances.name = "WindowInstances"
		window_instances.multimesh = windows
		var window_material := StandardMaterial3D.new()
		window_material.albedo_color = Color(0.78, 0.84, 0.78)
		window_material.metallic = 0.18
		window_material.roughness = 0.24
		window_instances.material_override = window_material
		tower.add_child(window_instances)

		var side_windows := MultiMeshInstance3D.new()
		side_windows.name = "SideWindowInstances"
		var side_multimesh := MultiMesh.new()
		side_multimesh.transform_format = MultiMesh.TRANSFORM_3D
		side_multimesh.mesh = window_mesh
		side_multimesh.instance_count = 24
		side_multimesh.visible_instance_count = 24
		for index in range(24):
			var row := index / 4
			var column := index % 4
			var z := -dimensions.z * 0.36 + float(column) * dimensions.z * 0.24
			var y := 2.0 + float(row) * maxf(1.5, (dimensions.y - 3.0) / 5.0)
			side_multimesh.set_instance_transform(index, Transform3D(Basis.IDENTITY, Vector3(dimensions.x * 0.505, y, z)))
		side_windows.multimesh = side_multimesh
		side_windows.material_override = window_material
		tower.add_child(side_windows)


func _build_harbor_street_furniture(district: Node3D) -> void:
	var street := Node3D.new()
	street.name = "HarborStreetFurniture"
	district.add_child(street)

	# Raised pedestrian sidewalks along both sides of the harbor boulevard.
	for side in [-1.0, 1.0]:
		_add_box(street, "Sidewalk_%s" % str(side), Vector3(side * 3.15, 0.16, 0.0),
			Vector3(1.25, 0.22, 25.0), Color(0.62, 0.61, 0.55))
		_add_box(street, "Curb_%s" % str(side), Vector3(side * 2.52, 0.22, 0.0),
			Vector3(0.16, 0.30, 25.0), Color(0.78, 0.75, 0.66))

	# High-contrast zebra crossing, built from reusable low-poly road markings.
	var crossing := Node3D.new()
	crossing.name = "PedestrianCrossing"
	crossing.position.z = 1.8
	street.add_child(crossing)
	for stripe_index in range(7):
		_add_box(crossing, "ZebraStripe_%02d" % stripe_index,
			Vector3(0.0, 0.155, -2.1 + float(stripe_index) * 0.68),
			Vector3(4.8, 0.025, 0.34), Color(0.91, 0.90, 0.82))

	# Warm street lamps with restrained light energy for mobile rendering.
	for lamp_index in range(4):
		var side := -1.0 if lamp_index % 2 == 0 else 1.0
		var z_position := -9.0 + float(lamp_index / 2) * 18.0
		var lamp := Node3D.new()
		lamp.name = "HarborStreetLamp_%02d" % (lamp_index + 1)
		lamp.position = Vector3(side * 3.75, 0.0, z_position)
		lamp.add_to_group("harbor_street_lamps")
		street.add_child(lamp)

		var pole := MeshInstance3D.new()
		pole.name = "Pole"
		var pole_mesh := CylinderMesh.new()
		pole_mesh.top_radius = 0.055
		pole_mesh.bottom_radius = 0.085
		pole_mesh.height = 4.2
		pole.mesh = pole_mesh
		pole.position.y = 2.1
		pole.material_override = _material(Color(0.16, 0.19, 0.21))
		lamp.add_child(pole)

		var arm := MeshInstance3D.new()
		arm.name = "LampArm"
		var arm_mesh := BoxMesh.new()
		arm_mesh.size = Vector3(0.72, 0.07, 0.08)
		arm.mesh = arm_mesh
		arm.position = Vector3(-side * 0.30, 4.12, 0.0)
		arm.material_override = _material(Color(0.16, 0.19, 0.21))
		lamp.add_child(arm)

		var head := MeshInstance3D.new()
		head.name = "LampHead"
		var head_mesh := BoxMesh.new()
		head_mesh.size = Vector3(0.38, 0.12, 0.28)
		head.mesh = head_mesh
		head.position = Vector3(-side * 0.62, 4.06, 0.0)
		var head_material := StandardMaterial3D.new()
		head_material.albedo_color = Color(1.0, 0.83, 0.56)
		head_material.emission_enabled = true
		head_material.emission = Color(1.0, 0.66, 0.32)
		head_material.emission_energy_multiplier = 0.45
		head_material.roughness = 0.42
		head.material_override = head_material
		lamp.add_child(head)

		# Use emissive lamp housing only. Four realtime OmniLights pushed the
		# Android GLES3 scene shader beyond GL_MAX_FRAGMENT_UNIFORM_VECTORS.
		# The warm emission keeps the lamp visibly lit without a local-light pass.
