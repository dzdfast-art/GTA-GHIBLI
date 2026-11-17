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
	"res://assets/environment/materials/weathered_canvas_4k.svg"
]

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
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
	var samples := [
		Color(0.88, 0.75, 0.58),
		Color(0.55, 0.25, 0.20),
		Color(0.66, 0.57, 0.43),
		Color(0.34, 0.23, 0.15),
		Color(0.30, 0.52, 0.29),
		Color(0.30, 0.22, 0.13),
		Color(0.53, 0.52, 0.47),
		Color(0.32, 0.40, 0.55),
		Color(0.72, 0.58, 0.38), Color(0.18, 0.22, 0.26),
		Color(0.22, 0.34, 0.19), Color(0.43, 0.48, 0.46),
		Color(0.40, 0.27, 0.16), Color(0.29, 0.19, 0.13),
		Color(0.62, 0.30, 0.22), Color(0.58, 0.49, 0.32)
	]
	for color in samples:
		var material := village.call("_material", color) as StandardMaterial3D
		if material == null or material.albedo_texture == null:
			_fail("Village material did not resolve an original 4K texture.")
			return
	print("PASS: sixteen original 4K surface textures import and bind to village and market materials.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
