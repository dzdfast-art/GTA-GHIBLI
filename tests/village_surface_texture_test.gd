extends SceneTree

const VILLAGE_SCRIPT = preload("res://scripts/world/willow_village.gd")
const TEXTURES := [
	"res://assets/environment/materials/village_plaster_4k.svg",
	"res://assets/environment/materials/terracotta_roof_4k.svg",
	"res://assets/environment/materials/cobblestone_path_4k.svg",
	"res://assets/environment/materials/weathered_timber_4k.svg",
	"res://assets/environment/materials/willow_foliage_4k.svg",
	"res://assets/environment/materials/garden_soil_4k.svg",
	"res://assets/environment/materials/weathered_stone_4k.svg",
	"res://assets/environment/materials/painted_metal_4k.svg",
	"res://assets/environment/materials/coastal_sand_4k.svg",
	"res://assets/environment/materials/district_asphalt_4k.svg",
	"res://assets/environment/materials/pine_forest_floor_4k.svg",
	"res://assets/environment/materials/harbor_paving_4k.svg",
	"res://assets/environment/materials/orchard_soil_4k.svg",
	"res://assets/environment/materials/dock_timber_4k.svg",
	"res://assets/environment/materials/market_brick_4k.svg",
	"res://assets/environment/materials/weathered_canvas_4k.svg",
	"res://assets/environment/materials/alley_brick_4k.svg",
	"res://assets/environment/materials/dry_grass_4k.svg",
	"res://assets/environment/materials/granite_curb_4k.svg",
	"res://assets/environment/materials/industrial_concrete_4k.svg",
	"res://assets/environment/materials/mosaic_tile_4k.svg",
	"res://assets/environment/materials/olive_grove_4k.svg",
	"res://assets/environment/materials/plaza_marble_4k.svg",
	"res://assets/environment/materials/red_sandstone_4k.svg",
	"res://assets/environment/materials/river_mud_4k.svg",
	"res://assets/environment/materials/road_markings_4k.svg",
	"res://assets/environment/materials/roof_slate_4k.svg",
	"res://assets/environment/materials/wet_stone_4k.svg",
	"res://assets/environment/materials/coastal_dune_4k.svg",
	"res://assets/environment/materials/river_pebble_4k.svg",
	"res://assets/environment/materials/market_ceramic_4k.svg",
	"res://assets/environment/materials/volcanic_rock_4k.svg"
]

const HD_TEXTURES := [
	"res://assets/environment/materials/hd/asphalt_road_512.bmp",
	"res://assets/environment/materials/hd/cobblestone_village_512.bmp",
	"res://assets/environment/materials/hd/terracotta_roof_512.bmp",
	"res://assets/environment/materials/hd/pine_forest_floor_512.bmp",
	"res://assets/environment/materials/hd/weathered_timber_512.bmp",
	"res://assets/environment/materials/hd/granite_curb_512.bmp",
	"res://assets/environment/materials/hd/mosaic_market_tile_512.bmp",
	"res://assets/environment/materials/hd/olive_grove_floor_512.bmp",
	"res://assets/environment/materials/hd/plaza_marble_512.bmp",
	"res://assets/environment/materials/hd/red_sandstone_512.bmp",
	"res://assets/environment/materials/hd/river_mud_512.bmp",
	"res://assets/environment/materials/hd/wet_stone_512.bmp",
	"res://assets/environment/materials/hd/painted_metal_512.bmp",
	"res://assets/environment/materials/hd/harbor_paving_512.bmp"
]

const HD_COLORS := [
	Color(0.18, 0.22, 0.26),
	Color(0.66, 0.57, 0.43),
	Color(0.55, 0.25, 0.20),
	Color(0.22, 0.34, 0.19),
	Color(0.34, 0.23, 0.15),
	Color(0.44, 0.46, 0.48),
	Color(0.16, 0.55, 0.58),
	Color(0.36, 0.48, 0.18),
	Color(0.78, 0.78, 0.72),
	Color(0.68, 0.32, 0.20),
	Color(0.27, 0.20, 0.14),
	Color(0.24, 0.38, 0.42),
	Color(0.32, 0.40, 0.55),
	Color(0.43, 0.48, 0.46)
]

const SAMPLE_COLORS := [
	Color(0.88, 0.75, 0.58),
	Color(0.55, 0.25, 0.20),
	Color(0.66, 0.57, 0.43),
	Color(0.34, 0.23, 0.15),
	Color(0.30, 0.52, 0.29),
	Color(0.30, 0.22, 0.13),
	Color(0.53, 0.52, 0.47),
	Color(0.32, 0.40, 0.55),
	Color(0.72, 0.58, 0.38),
	Color(0.18, 0.22, 0.26),
	Color(0.22, 0.34, 0.19),
	Color(0.43, 0.48, 0.46),
	Color(0.40, 0.27, 0.16),
	Color(0.29, 0.19, 0.13),
	Color(0.62, 0.30, 0.22),
	Color(0.58, 0.49, 0.32),
	Color(0.46, 0.19, 0.16),
	Color(0.48, 0.44, 0.22),
	Color(0.44, 0.46, 0.48),
	Color(0.30, 0.32, 0.34),
	Color(0.16, 0.55, 0.58),
	Color(0.36, 0.48, 0.18),
	Color(0.78, 0.78, 0.72),
	Color(0.68, 0.32, 0.20),
	Color(0.27, 0.20, 0.14),
	Color(0.85, 0.80, 0.45),
	Color(0.26, 0.30, 0.38),
	Color(0.24, 0.38, 0.42),
	Color(0.68, 0.53, 0.34),
	Color(0.38, 0.43, 0.44),
	Color(0.28, 0.48, 0.51),
	Color(0.25, 0.25, 0.27)
]


const DETAIL_COLORS := [
	Color(0.25, 0.25, 0.27), Color(0.68, 0.32, 0.20)
]

const DETAIL_NAMES := ["basalt", "red_sandstone"]

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	if TEXTURES.size() != 32 or SAMPLE_COLORS.size() != TEXTURES.size():
		_fail("Expected exactly 32 texture paths and matching material samples.")
		return

	for path in TEXTURES:
		if not ResourceLoader.exists(path):
			_fail("Missing original surface texture: " + path)
			return
		var texture := load(path) as Texture2D
		if texture == null or texture.get_width() < 4096 or texture.get_height() < 4096:
			_fail("Surface texture did not import at 4K: " + path)
			return

	var village := Node3D.new()
	village.set_script(VILLAGE_SCRIPT)
	root.add_child(village)

	for index in range(TEXTURES.size()):
		var material := village.call("_material", SAMPLE_COLORS[index]) as StandardMaterial3D
		if material == null or material.albedo_texture == null:
			_fail("No texture bound for material sample %d." % index)
			return
		if material.albedo_texture.resource_path != TEXTURES[index]:
			_fail("Wrong texture bound at sample %d: expected %s, got %s" % [
				index, TEXTURES[index], material.albedo_texture.resource_path
			])
			return

	for index in range(HD_TEXTURES.size()):
		var path: String = HD_TEXTURES[index]
		if not ResourceLoader.exists(path):
			_fail("Missing high-detail raster surface: " + path)
			return
		var hd_texture := load(path) as Texture2D
		if hd_texture == null or hd_texture.get_width() != 512 or hd_texture.get_height() != 512:
			_fail("High-detail surface did not import at 512x512: " + path)
			return
		var hd_material := village.call("_material", HD_COLORS[index]) as StandardMaterial3D
		if hd_material == null or hd_material.roughness_texture == null:
			_fail("No high-detail raster texture bound for sample %d." % index)
			return
		if hd_material.roughness_texture.resource_path != path:
			_fail("Wrong high-detail texture at sample %d." % index)
			return


	var extra_paths := [
		"res://assets/environment/materials/hd/basalt_fracture_roughness_1k.bmp",
		"res://assets/environment/materials/hd/river_pebble_roughness_1k.bmp",
		"res://assets/environment/materials/hd/road_aggregate_roughness_1k.bmp",
		"res://assets/environment/materials/hd/terracotta_weathering_roughness_1k.bmp"
	]
	var extra_colors := [
		Color(0.25, 0.25, 0.27), Color(0.38, 0.43, 0.44),
		Color(0.19, 0.20, 0.21), Color(0.57, 0.27, 0.17)
	]
	var extra_albedo := [
		"res://assets/environment/materials/volcanic_rock_4k.svg",
		"res://assets/environment/materials/river_pebble_4k.svg",
		"res://assets/environment/materials/district_asphalt_4k.svg",
		"res://assets/environment/materials/red_sandstone_4k.svg"
	]
	for index in range(extra_paths.size()):
		var path: String = extra_paths[index]
		if not ResourceLoader.exists(path):
			_fail("Missing 1K roughness surface: " + path)
			return
		var texture := load(path) as Texture2D
		if texture == null or texture.get_width() != 960 or texture.get_height() != 960:
			_fail("1K roughness surface did not import at 960x960: " + path)
			return
		var material := village.call("_material", extra_colors[index]) as StandardMaterial3D
		if material == null or material.roughness_texture == null:
			_fail("No 1K roughness texture bound for sample %d." % index)
			return
		if material.roughness_texture.resource_path != path:
			_fail("Wrong 1K roughness texture bound at sample %d." % index)
			return
		if material.albedo_texture == null or material.albedo_texture.resource_path != extra_albedo[index]:
			_fail("The 4K albedo surface was not preserved for sample %d." % index)
			return
	var added_plots := ["BasaltRidgeWalk", "RiverPebbleFord", "RoadAggregateLoop", "TerracottaKilnCourt"]
	for plot_name in added_plots:
		if village.get_node_or_null(plot_name) == null:
			_fail("Missing new walkable material plot: " + plot_name)
			return

	for index in range(DETAIL_NAMES.size()):
		var material := village.call("_material", DETAIL_COLORS[index]) as StandardMaterial3D
		var detail_path := "res://assets/environment/materials/hd/detail_2k/%s_detail_albedo_2k.bmp" % DETAIL_NAMES[index]
		var normal_path := "res://assets/environment/materials/hd/detail_2k/%s_normal_2k.bmp" % DETAIL_NAMES[index]
		if not ResourceLoader.exists(detail_path) or not ResourceLoader.exists(normal_path):
			_fail("Missing generated 2K material pair: " + DETAIL_NAMES[index])
			return
		var detail_texture := load(detail_path) as Texture2D
		var normal_texture := load(normal_path) as Texture2D
		if detail_texture == null or detail_texture.get_width() != 1900 or detail_texture.get_height() != 1900:
			_fail("Detail albedo did not import at 2048x2048: " + detail_path)
			return
		if normal_texture == null or normal_texture.get_width() != 1900 or normal_texture.get_height() != 1900:
			_fail("Tangent-space normal map did not import at 2048x2048: " + normal_path)
			return
		if material == null or not material.detail_enabled or material.detail_albedo == null:
			_fail("2K detail albedo was not enabled for " + DETAIL_NAMES[index])
			return
		if material.detail_albedo.resource_path != detail_path:
			_fail("Wrong 2K detail albedo bound for " + DETAIL_NAMES[index])
			return
		if not material.normal_enabled or material.normal_texture == null:
			_fail("2K normal map was not enabled for " + DETAIL_NAMES[index])
			return
		if material.normal_texture.resource_path != normal_path:
			_fail("Wrong 2K normal map bound for " + DETAIL_NAMES[index])
			return

	print("PASS: 32 original 4K albedo surfaces, 18 legacy raster maps and two original 1900px albedo/normal pairs import and bind to their intended world materials.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
