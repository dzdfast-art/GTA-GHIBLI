extends Node3D

## Procedural blockout for four explorable districts linked to Willow Village.
## Geometry is original, light-weight and assembled at runtime for mobile testing.
const CIVILIAN_NPC_SCRIPT = preload("res://scripts/characters/world_npc_actor.gd")

var _region_ids: Array[String] = []
var _population_count := 0
var _building_count := 0
var _detail_count := 0
var _material_cache: Dictionary = {}

const CITY_MATERIALS := "res://assets/environment/materials/"

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

func get_detail_count() -> int:
	return _detail_count

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

	_build_district_sidewalks(district)

	var title := Label3D.new()
	title.name = "DistrictName"
	title.text = region_name
	title.position = Vector3(0.0, 5.6, -15.2)
	title.font_size = 44
	title.modulate = Color(1.0, 0.94, 0.78)
	title.outline_size = 8
	district.add_child(title)

	_build_road(center)
	_build_district_buildings(district, wall_color, roof_color, region_id)
	_build_district_details(district, region_id, ground_color)
	_build_street_furniture(district, region_id)
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
	road.material_override = _material(Color(0.20, 0.22, 0.22), CITY_MATERIALS + "hd_city_asphalt_cracked.svg")
	add_child(road)

func _build_district_buildings(district: Node3D, wall_color: Color, roof_color: Color, region_id: String) -> void:
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
		visual.material_override = _material(wall_color, _district_wall_texture(region_id, index))
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
		roof.material_override = _material(roof_color, CITY_MATERIALS + "hd_ceramic_roof_tiles.svg")
		building.add_child(roof)

		var door_mesh := BoxMesh.new()
		door_mesh.size = Vector3(1.0, 1.9, 0.12)
		var door := MeshInstance3D.new()
		door.name = "Door"
		door.mesh = door_mesh
		door.position = Vector3(0.0, 0.95, dimensions.z * 0.5 + 0.07)
		door.material_override = _material(Color(0.25, 0.18, 0.13), CITY_MATERIALS + ("hd_metal_garage_shutter.svg" if index % 3 == 0 else "hd_village_plaster_wall.svg"))
		building.add_child(door)

		# Distinct facade details break up the repeated prototype boxes.
		var front_z := dimensions.z * 0.5 + 0.075
		for window_index in range(2):
			var window_x := -2.05 + float(window_index) * 4.1
			_add_building_detail(building, "FrontWindow_%02d" % window_index,
				Vector3(1.38, 1.02, 0.08), Vector3(window_x, 2.20, front_z), Color(0.10, 0.20, 0.25), CITY_MATERIALS + "hd_shopfront_glass.svg")
			_add_building_detail(building, "WindowLintel_%02d" % window_index,
				Vector3(1.50, 0.11, 0.14), Vector3(window_x, 2.78, front_z + 0.035), Color(0.86, 0.80, 0.66))
			_add_building_detail(building, "WindowSill_%02d" % window_index,
				Vector3(1.50, 0.10, 0.16), Vector3(window_x, 1.66, front_z + 0.035), Color(0.78, 0.71, 0.57))
		_add_building_detail(building, "DoorHandle", Vector3(0.08, 0.16, 0.06),
			Vector3(0.31, 1.02, front_z + 0.045), Color(0.88, 0.70, 0.32))
		_add_building_detail(building, "RoofFrontTrim", Vector3(dimensions.x + 0.18, 0.12, 0.16),
			Vector3(0.0, dimensions.y + 0.43, front_z - 0.04), roof_color.lightened(0.12))
		if index % 3 == 0:
			_add_building_detail(building, "ShopAwning", Vector3(3.2, 0.16, 1.05),
				Vector3(0.0, 2.55, front_z + 0.48), Color(0.68, 0.30 + float(index % 2) * 0.12, 0.18), CITY_MATERIALS + "hd_corrugated_iron.svg")
			for post_x in [-1.42, 1.42]:
				_add_building_detail(building, "AwningSupport", Vector3(0.10, 1.48, 0.10),
					Vector3(post_x, 1.82, front_z + 0.83), Color(0.30, 0.25, 0.18))
		elif index % 3 == 1:
			_add_building_detail(building, "BalconySlab", Vector3(3.8, 0.16, 0.82),
				Vector3(0.0, 2.20, front_z + 0.40), Color(0.48, 0.43, 0.36))
			_add_building_detail(building, "BalconyRail", Vector3(3.8, 0.12, 0.08),
				Vector3(0.0, 2.78, front_z + 0.79), Color(0.18, 0.20, 0.20))
		_building_count += 1

func _district_wall_texture(region_id: String, index: int) -> String:
	match region_id:
		"harbor_city":
			return CITY_MATERIALS + ("hd_harbor_red_brick.svg" if index % 2 == 0 else "hd_city_concrete_stains.svg")
		"pine_highlands":
			return CITY_MATERIALS + "hd_city_concrete_stains.svg"
		"amber_valley":
			return "res://assets/environment/materials/hd_village_plaster_wall.svg" if index % 2 == 0 else CITY_MATERIALS + "hd_harbor_red_brick.svg"
		"sapphire_coast":
			return CITY_MATERIALS + ("hd_corrugated_iron.svg" if index % 3 == 0 else "hd_city_concrete_stains.svg")
	return "res://assets/environment/materials/hd_village_plaster_wall.svg"

func _build_district_sidewalks(district: Node3D) -> void:
	for side in [-1.0, 1.0]:
		var sidewalk := MeshInstance3D.new()
		sidewalk.name = "TexturedSidewalk_%s" % ("North" if side < 0.0 else "South")
		var mesh := BoxMesh.new()
		mesh.size = Vector3(41.0, 0.16, 2.2)
		sidewalk.mesh = mesh
		sidewalk.position = Vector3(0.0, 0.15, side * 15.0)
		sidewalk.material_override = _material(Color(0.9, 0.9, 0.9), CITY_MATERIALS + "hd_stone_sidewalk.svg")
		district.add_child(sidewalk)

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

func _add_building_detail(parent: Node3D, node_name: String, size: Vector3, at: Vector3, tint: Color, texture_path: String = "") -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.position = at
	visual.material_override = _material(tint, texture_path)
	parent.add_child(visual)
	_detail_count += 1

func _build_street_furniture(district: Node3D, region_id: String) -> void:
	# Four low-cost street lamps and one resting point per district.
	for x in [-18.0, 18.0]:
		for z in [-12.0, 12.0]:
			_add_box(district, "StreetLampPole", Vector3(x, 2.05, z), Vector3(0.12, 4.1, 0.12), Color(0.16, 0.18, 0.18))
			_add_box(district, "StreetLampHead", Vector3(x, 4.12, z - 0.24), Vector3(0.72, 0.18, 0.38), Color(0.92, 0.78, 0.48))
			_add_box(district, "StreetLampGlow", Vector3(x, 3.94, z - 0.24), Vector3(0.42, 0.05, 0.22), Color(1.0, 0.88, 0.62))
	_add_box(district, "RestBenchSeat", Vector3(-14.0, 0.58, 0.0), Vector3(2.6, 0.14, 0.72), Color(0.38, 0.25, 0.15))
	_add_box(district, "RestBenchBack", Vector3(-14.0, 1.12, 0.30), Vector3(2.6, 0.88, 0.14), Color(0.34, 0.22, 0.13))
	_add_box(district, "DistrictNoticeBoard", Vector3(14.0, 1.45, -14.0), Vector3(2.2, 1.5, 0.16), Color(0.28, 0.22, 0.14))
	_add_box(district, "DistrictNoticeHeader", Vector3(14.0, 2.30, -13.89), Vector3(2.3, 0.16, 0.22), Color(0.78, 0.62, 0.30))
	if region_id == "harbor_city":
		_add_box(district, "HarborSafetyStripe", Vector3(0.0, 0.09, 16.0), Vector3(26.0, 0.04, 0.12), Color(0.92, 0.74, 0.28))
	elif region_id == "amber_valley":
		_add_box(district, "FarmWaterChannel", Vector3(0.0, 0.10, -14.0), Vector3(28.0, 0.12, 0.48), Color(0.20, 0.42, 0.52))
	elif region_id == "sapphire_coast":
		_add_box(district, "CoastGuardRail", Vector3(0.0, 0.62, 17.0), Vector3(28.0, 0.12, 0.14), Color(0.72, 0.76, 0.72))
	else:
		_add_box(district, "ForestTrailMarker", Vector3(0.0, 0.85, 16.0), Vector3(1.7, 1.3, 0.16), Color(0.40, 0.30, 0.18))

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
	_detail_count += 1

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
	var cache_key := tint.to_html(true) + "|" + texture_path
	if _material_cache.has(cache_key):
		return _material_cache[cache_key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.88
	if not texture_path.is_empty():
		var texture := load(texture_path) as Texture2D
		if texture != null:
			material.albedo_texture = texture
			material.uv1_scale = Vector3(3.0, 3.0, 3.0)
	_material_cache[cache_key] = material
	return material
