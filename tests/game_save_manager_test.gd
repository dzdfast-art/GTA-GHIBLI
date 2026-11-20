extends SceneTree

const SAVE_MANAGER_SCRIPT = preload("res://scripts/systems/game_save_manager.gd")
const TEST_SAVE_PATH := "user://gta_ghibli_save_manager_regression.json"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_remove_test_files()
	var scene := Node3D.new()
	scene.name = "SaveManagerTestScene"
	root.add_child(scene)
	current_scene = scene

	var player := CharacterBody3D.new()
	player.name = "Player"
	player.add_to_group("player")
	scene.add_child(player)
	player.global_position = Vector3(12.5, 1.0, -27.0)
	player.rotation = Vector3(0.0, 0.75, 0.0)

	var manager := SAVE_MANAGER_SCRIPT.new()
	manager.name = "GameSaveManagerTest"
	manager.set("save_path_override", TEST_SAVE_PATH)
	scene.add_child(manager)
	await process_frame

	if not manager.call("save_game"):
		_fail("The unified save manager must save a valid local game state.")
		return
	if not FileAccess.file_exists(TEST_SAVE_PATH):
		_fail("The save manager must create its versioned save file.")
		return

	player.global_position = Vector3(-100.0, 0.0, 100.0)
	player.rotation = Vector3.ZERO
	if not manager.call("load_game"):
		_fail("The unified save manager must load a valid saved game.")
		return
	if player.global_position.distance_to(Vector3(12.5, 1.0, -27.0)) > 0.001:
		_fail("Player position must be restored from the unified save.")
		return
	if absf(player.rotation.y - 0.75) > 0.001:
		_fail("Player rotation must be restored from the unified save.")
		return

	var file := FileAccess.open(TEST_SAVE_PATH, FileAccess.READ)
	if file == null:
		_fail("The unified save file must remain readable.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or int(parsed.get("schema_version", 0)) != 1:
		_fail("The unified save must contain the supported schema version.")
		return
	if not parsed.has("legacy_files") or not parsed.has("missions") or not parsed.has("vehicles"):
		_fail("The unified save must include legacy records, mission snapshots and vehicle snapshots.")
		return

	_remove_test_files()
	print("PASS: versioned unified save, local persistence, player transform restore and compatibility sections.")
	manager.queue_free()
	scene.queue_free()
	quit(0)


func _remove_test_files() -> void:
	for path in [TEST_SAVE_PATH, TEST_SAVE_PATH + ".tmp", TEST_SAVE_PATH + ".bak"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	_remove_test_files()
	quit(1)
