extends SceneTree

## Validates canonical location metadata against the actual Harbor City scene.
const REGIONS_SCRIPT = preload("res://scripts/world/open_world_regions.gd")
const CANONICAL_WORLD_PATH := "res://data/world/canonical_world.json"


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	if not FileAccess.file_exists(CANONICAL_WORLD_PATH):
		_fail("Canonical world location data is missing.")
		return
	var file := FileAccess.open(CANONICAL_WORLD_PATH, FileAccess.READ)
	if file == null:
		_fail("Canonical world location data could not be opened.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_fail("Canonical world location data is not a JSON object.")
		return
	var locations: Array = parsed.get("locations", [])
	var marsa: Dictionary = {}
	for item in locations:
		if item is Dictionary and str(item.get("id", "")) == "marsa_al_noor":
			marsa = item
			break
	if marsa.is_empty():
		_fail("Marsa Al-Noor is missing from canonical world locations.")
		return
	if str(marsa.get("region_id", "")) != "harbor_city":
		_fail("Marsa Al-Noor is not assigned to Harbor City.")
		return

	# Build only Harbor City here. The separate open-world regression test covers
	# all four districts and their surface textures, avoiding duplicate heavy SVG rasterization.
	var world := REGIONS_SCRIPT.new() as Node3D
	root.add_child(world)
	await process_frame
	world.call("_build_region", "harbor_city", "مدينة الميناء",
		Vector3(-82.0, 0.0, -54.0),
		Color(0.48, 0.57, 0.63), Color(0.30, 0.39, 0.48), Color(0.66, 0.72, 0.73),
		["نادر", "سلمى"])
	var harbor := world.get_node_or_null("HarborCity") as Node3D
	if harbor != null:
		world.call("_build_marsa_al_noor", harbor)
	var landmark := harbor.get_node_or_null("MarsaAlNoor") as StaticBody3D if harbor != null else null
	if landmark == null:
		_fail("Harbor City did not instantiate the Marsa Al-Noor landmark.")
		return
	if not landmark.is_in_group("world_landmarks") or not landmark.is_in_group("marsa_al_noor"):
		_fail("Marsa Al-Noor is not registered as a world landmark.")
		return
	var local_data: Dictionary = marsa.get("district_local_position", {})
	var world_data: Dictionary = marsa.get("world_position", {})
	var expected_local := Vector3(
		float(local_data.get("x", 0.0)),
		float(local_data.get("y", 0.0)),
		float(local_data.get("z", 0.0))
	)
	var expected_world := Vector3(
		float(world_data.get("x", 0.0)),
		float(world_data.get("y", 0.0)),
		float(world_data.get("z", 0.0))
	)
	if not landmark.position.is_equal_approx(expected_local):
		_fail("Marsa Al-Noor scene placement differs from its canonical local coordinates.")
		return
	if not (harbor.position + landmark.position).is_equal_approx(expected_world):
		_fail("Marsa Al-Noor world coordinates differ from the canonical world map.")
		return
	if landmark.get_node_or_null("BeaconLantern") == null or landmark.get_node_or_null("LocationSign") == null:
		_fail("Marsa Al-Noor landmark visuals are incomplete.")
		return
	world.queue_free()
	await process_frame
	print("PASS: Marsa Al-Noor canonical data, Harbor City scene, landmark groups, and world-map coordinates match.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
