extends Node3D

# Static references ensure Godot's export pipeline includes these textures in
# Web and Android packages even though district selection is data-driven.
const SURFACE_TEXTURES := {
	"res://assets/environment/materials/hd_harbor_paving.svg": preload("res://assets/environment/materials/hd_harbor_paving.svg"),
	"res://assets/environment/materials/hd_pine_forest_floor.svg": preload("res://assets/environment/materials/hd_pine_forest_floor.svg"),
	"res://assets/environment/materials/hd_amber_orchard_soil.svg": preload("res://assets/environment/materials/hd_amber_orchard_soil.svg"),
	"res://assets/environment/materials/hd_sapphire_coastal_sand.svg": preload("res://assets/environment/materials/hd_sapphire_coastal_sand.svg"),
	"res://assets/environment/materials/hd_weathered_dock_timber.svg": preload("res://assets/environment/materials/hd_weathered_dock_timber.svg"),
	"res://assets/environment/materials/hd_terracotta_roof.svg": preload("res://assets/environment/materials/hd_terracotta_roof.svg"),
	"res://assets/environment/materials/hd_village_plaster_wall.svg": preload("res://assets/environment/materials/hd_village_plaster_wall.svg"),
	"res://assets/environment/materials/hd_district_asphalt.svg": preload("res://assets/environment/materials/hd_district_asphalt.svg"),
}

## Procedural blockout for four explorable districts linked to Willow Village.
## Geometry is original, light-weight and assembled at runtime for mobile testing.
const CIVILIAN_NPC_SCRIPT = preload("res://scripts/characters/world_npc_actor.gd")
const HARBOR_HOUSES_MESH = preload("res://assets/environment/modular/village_house_collection.obj")
const HARBOR_ROADS_MESH = preload("res://assets/environment/modular/road_street_collection.obj")
const PUBLIC_DRINKING_FOUNTAIN_SCENE = preload("res://scenes/world/public_drinking_fountain.tscn")
const SEAFOOD_MARKET_SCENE = preload("res://scenes/world/seafood_market.tscn")
const VEHICLE_SERVICE_GARAGE_SCENE = preload("res://scenes/world/vehicle_service_garage.tscn")
const COASTAL_LIGHTHOUSE_SCENE = preload("res://scenes/world/coastal_lighthouse.tscn")

var _region_ids: Array[String] = []
var _population_count := 0
var _building_count := 0
var _surface_texture_cache: Dictionary = {}

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
	if region_id == "harbor_city":
		_build_harbor_city_block(district)
	else:
		_build_district_buildings(district, wall_color, roof_color)
	_build_district_details(district, region_id, ground_color)
	_build_district_navigation(district, region_id)
	_build_civilians(district, region_id, npc_names)



func _build_harbor_city_block(district: Node3D) -> void:
	# Four-by-four original low-rise house set, scaled to the district parcel.
	var houses := MeshInstance3D.new()
	houses.name = "HarborResidentialMesh"
	houses.mesh = HARBOR_HOUSES_MESH
	houses.position = Vector3(-16.5, 0.025, -16.2)
	houses.scale = Vector3.ONE * 0.5
	district.add_child(houses)

	# Keep collision envelopes aligned with the 4x4 house footprints.
	var house_centers_x := [-14.0, -5.0, 4.0, 13.5]
	var house_centers_z := [-14.0, -5.0, 4.0, 12.8]
	for row in range(house_centers_z.size()):
		for column in range(house_centers_x.size()):
			var body := StaticBody3D.new()
			body.name = "HarborHouseCollision_%02d_%02d" % [row, column]
			body.add_to_group("radar_buildings")
			body.position = Vector3(house_centers_x[column], 0.0, house_centers_z[row])
			body.collision_layer = 1
			body.collision_mask = 1
			var shape := BoxShape3D.new()
			shape.size = Vector3(5.5, 4.2, 4.7)
			var collision := CollisionShape3D.new()
			collision.shape = shape
			collision.position.y = 2.1
			body.add_child(collision)
			district.add_child(body)
			_building_count += 1

	# This original road set supplies lanes, raised curbs, junction markings and sidewalks.
	var roads := MeshInstance3D.new()
	roads.name = "HarborStreetNetworkMesh"
	roads.mesh = HARBOR_ROADS_MESH
	roads.position = Vector3(-23.8, 0.055, -14.7)
	roads.scale = Vector3.ONE * 0.335
	district.add_child(roads)

func _build_road(center: Vector3) -> void:
	var flat_center := Vector2(center.x, center.z)
	var length := flat_center.length()
	var midpoint := Vector3(center.x * 0.5, 0.08, center.z * 0.5)
	var road := MeshInstance3D.new()
	road.name = "RoadTo_" + str(_region_ids.back())
	road.add_to_group("radar_roads")
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
		building.add_to_group("radar_buildings")
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
			_build_marsa_al_noor(district)
			_build_public_drinking_fountain(district)
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
			_build_vehicle_service_garage(district)
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
			_build_seafood_market(district)
			_build_coastal_lighthouse(district)
		_:
			pass


func _build_public_drinking_fountain(district: Node3D) -> void:
	# Original public drinking point in Harbor City's central plaza.
	var fountain := PUBLIC_DRINKING_FOUNTAIN_SCENE.instantiate()
	fountain.name = "PublicDrinkingFountain"
	fountain.position = Vector3(0.0, 0.0, -9.0)
	district.add_child(fountain)


func _build_seafood_market(district: Node3D) -> void:
	# Reuses the existing market stall and adds a functional seafood display.
	var market := SEAFOOD_MARKET_SCENE.instantiate()
	market.name = "SeafoodMarket"
	market.position = Vector3(17.0, 0.0, 14.0)
	district.add_child(market)


func _build_vehicle_service_garage(district: Node3D) -> void:
	# Original repair workshop on the Amber Valley service road.
	var garage := VEHICLE_SERVICE_GARAGE_SCENE.instantiate()
	garage.name = "VehicleServiceGarage"
	garage.position = Vector3(17.0, 0.0, -13.2)
	district.add_child(garage)


func _build_coastal_lighthouse(district: Node3D) -> void:
	# Tall Sapphire Coast landmark with a rotating dusk/night beacon.
	var lighthouse := COASTAL_LIGHTHOUSE_SCENE.instantiate()
	lighthouse.name = "CoastalLighthouse"
	lighthouse.position = Vector3(-17.0, 0.0, 0.0)
	district.add_child(lighthouse)


func _build_marsa_al_noor(district: Node3D) -> void:
	# Initial canonical landmark placement: Harbor City local (14, 0, 10).
	var landmark := StaticBody3D.new()
	landmark.name = "MarsaAlNoor"
	landmark.position = Vector3(14.0, 0.0, 10.0)
	landmark.add_to_group("world_landmarks")
	landmark.add_to_group("marsa_al_noor")
	landmark.set_meta("location_id", "marsa_al_noor")
	landmark.collision_layer = 1
	landmark.collision_mask = 1

	var base := MeshInstance3D.new()
	base.name = "BeaconBase"
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 1.05
	base_mesh.bottom_radius = 1.25
	base_mesh.height = 0.36
	base.mesh = base_mesh
	base.position.y = 0.18
	base.material_override = _material(Color(0.34, 0.37, 0.35))
	landmark.add_child(base)

	var beacon := MeshInstance3D.new()
	beacon.name = "HarborBeacon"
	var beacon_mesh := CylinderMesh.new()
	beacon_mesh.top_radius = 0.34
	beacon_mesh.bottom_radius = 0.48
	beacon_mesh.height = 2.8
	beacon.mesh = beacon_mesh
	beacon.position.y = 1.76
	beacon.material_override = _material(Color(0.78, 0.60, 0.27))
	landmark.add_child(beacon)

	var lantern := OmniLight3D.new()
	lantern.name = "BeaconLantern"
	lantern.position.y = 3.35
	lantern.light_color = Color(1.0, 0.78, 0.39)
	lantern.light_energy = 0.7
	lantern.omni_range = 8.0
	landmark.add_child(lantern)

	var sign := Label3D.new()
	sign.name = "LocationSign"
	sign.text = "مرسى النور\nMARSA AL-NOOR"
	sign.position = Vector3(0.0, 4.25, 0.0)
	sign.font_size = 30
	sign.outline_size = 7
	sign.modulate = Color(1.0, 0.90, 0.67)
	landmark.add_child(sign)

	var collision := CollisionShape3D.new()
	collision.name = "BeaconCollision"
	var shape := CylinderShape3D.new()
	shape.radius = 1.25
	shape.height = 3.2
	collision.shape = shape
	collision.position.y = 1.6
	landmark.add_child(collision)

	district.add_child(landmark)

func _build_civilians(district: Node3D, region_id: String, npc_names: Array) -> void:
	var positions := [Vector3(-8.0, 0.0, 0.0), Vector3(8.0, 0.0, 0.0)]
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
		var texture := _load_surface_texture(texture_path)
		if texture != null:
			material.albedo_texture = texture
			material.uv1_scale = Vector3(3.0, 3.0, 3.0)
	return material


func _load_surface_texture(texture_path: String) -> Texture2D:
	if _surface_texture_cache.has(texture_path):
		return _surface_texture_cache[texture_path] as Texture2D
	var texture := SURFACE_TEXTURES.get(texture_path) as Texture2D
	if texture == null:
		push_warning("Unknown district surface texture: " + texture_path)
		return null
	_surface_texture_cache[texture_path] = texture
	return texture

## Builds a small, authored low-poly walkable grid around the district's six
## building footprints. This avoids expensive run-time geometry baking on mobile.
func _build_district_navigation(district: Node3D, region_id: String) -> void:
	var region := NavigationRegion3D.new()
	region.name = "NavigationRegion3D"
	var navigation_mesh := NavigationMesh.new()
	navigation_mesh.agent_radius = 0.35
	navigation_mesh.agent_height = 1.7
	navigation_mesh.cell_size = 0.25
	navigation_mesh.cell_height = 0.2

	var vertices := PackedVector3Array()
	var cell_size := 2.5
	var minimum_x := -20.0
	var minimum_z := -16.0
	var columns := 16
	var rows := 12
	var polygon_count := 0
	var polygons: Array[PackedInt32Array] = []

	for x_index in range(columns):
		var left := minimum_x + float(x_index) * cell_size
		var right := left + cell_size
		for z_index in range(rows):
			var top := minimum_z + float(z_index) * cell_size
			var bottom := top + cell_size
			if _navigation_cell_overlaps_building(left, right, top, bottom, region_id):
				continue
			var base_index := vertices.size()
			# Counter-clockwise when viewed from above, so each polygon faces +Y.
			vertices.append(Vector3(left, 0.08, top))
			vertices.append(Vector3(left, 0.08, bottom))
			vertices.append(Vector3(right, 0.08, bottom))
			vertices.append(Vector3(right, 0.08, top))
			polygons.append(PackedInt32Array([
				base_index, base_index + 1, base_index + 2, base_index + 3
			]))
			polygon_count += 1

	navigation_mesh.set_vertices(vertices)
	for polygon in polygons:
		navigation_mesh.add_polygon(polygon)
	region.navigation_mesh = navigation_mesh
	region.add_to_group("world_navigation_regions")
	district.add_child(region)
	if polygon_count == 0:
		push_warning("No walkable navigation cells were created for " + district.name)


func _navigation_cell_overlaps_building(left: float, right: float,
		top: float, bottom: float, region_id: String) -> bool:
	if region_id == "harbor_city":
		# Keep the central fountain footprint clear for NPC path queries.
		if right > -1.5 and left < 1.5 and bottom > -10.5 and top < -7.5:
			return true
		const HOUSE_HALF_WIDTH := 2.85
		const HOUSE_HALF_DEPTH := 2.45
		for center_x in [-14.0, -5.0, 4.0, 13.5]:
			for center_z in [-14.0, -5.0, 4.0, 12.8]:
				var overlaps_x: bool = right > float(center_x) - HOUSE_HALF_WIDTH and left < float(center_x) + HOUSE_HALF_WIDTH
				var overlaps_z: bool = bottom > float(center_z) - HOUSE_HALF_DEPTH and top < float(center_z) + HOUSE_HALF_DEPTH
				if overlaps_x and overlaps_z:
					return true
		return false
	const BUILDING_HALF_WIDTH := 4.25
	const BUILDING_HALF_DEPTH := 3.85
	for center_x in [-12.0, 0.0, 12.0]:
		for center_z in [-7.0, 8.0]:
			var overlaps_x: bool = right > float(center_x) - BUILDING_HALF_WIDTH and left < float(center_x) + BUILDING_HALF_WIDTH
			var overlaps_z: bool = bottom > float(center_z) - BUILDING_HALF_DEPTH and top < float(center_z) + BUILDING_HALF_DEPTH
			if overlaps_x and overlaps_z:
				return true
	if region_id == "sapphire_coast" and right > -20.5 and left < -13.5 and bottom > -3.5 and top < 3.5:
		return true
	return false
