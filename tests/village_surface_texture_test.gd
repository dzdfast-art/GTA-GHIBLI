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
	"res://assets/environment/materials/painted_metal_4k.svg"
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
		Color(0.32, 0.40, 0.55)
	]
	for color in samples:
		var material := village.call("_material", color) as StandardMaterial3D
		if material == null or material.albedo_texture == null:
			_fail("Village material did not resolve an original 4K texture.")
			return
	print("PASS: eight original 4K surface textures import and bind to village materials.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
