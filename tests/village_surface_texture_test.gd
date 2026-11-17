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

	print("PASS: all 32 original 4K surface textures import and bind to their matching village and district materials.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
