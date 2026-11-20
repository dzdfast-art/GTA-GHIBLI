extends SceneTree

const SAVE_MANAGER_SCRIPT = preload("res://scripts/systems/game_save_manager.gd")
const TEST_SAVE_PATH := "user://gta_ghibli_save_manager_regression.json"
const TEST_RELATIONSHIP_PATH := "user://npc_relationships/save_manager_test_migration.json"
const TEST_UNRELATED_PATH := "user://gta_ghibli_save_manager_unrelated.txt"
const TEST_ESCAPE_PATH := "user://save_manager_escape.json"
const ORIGINAL_RELATIONSHIP := "{\"persistence_id\":\"save_manager_test_migration\",\"trust\":17.0,\"familiarity\":42.0}"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_remove_test_files()
	if not _write_text(TEST_RELATIONSHIP_PATH, ORIGINAL_RELATIONSHIP):
		_fail("Could not create an isolated legacy NPC relationship fixture.")
		return

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

	if not manager.call("_is_allowed_legacy_restore_path", "user://player_wallet.json"):
		_fail("A documented legacy save path must remain eligible for migration.")
		return
	if not manager.call("_is_allowed_legacy_restore_path", TEST_RELATIONSHIP_PATH):
		_fail("A safe flat NPC relationship JSON path must remain eligible for migration.")
		return
	if not manager.call("_is_allowed_legacy_restore_path", "user://npc_relationships/npc_12.json"):
		_fail("Safe NPC IDs with digits must remain eligible for migration.")
		return
	if manager.call("_is_allowed_legacy_restore_path", TEST_UNRELATED_PATH):
		_fail("An unrelated user file must not be accepted as a legacy save.")
		return
	if manager.call("_is_allowed_legacy_restore_path", "user://npc_relationships/../../save_manager_escape.json"):
		_fail("A traversal path must not be accepted as a legacy save.")
		return

	if not manager.call("save_game"):
		_fail("The unified save manager must save a valid local game state.")
		return
	if not FileAccess.file_exists(TEST_SAVE_PATH):
		_fail("The save manager must create its versioned save file.")
		return

	var save_file := FileAccess.open(TEST_SAVE_PATH, FileAccess.READ)
	if save_file == null:
		_fail("The unified save file must remain readable.")
		return
	var parsed = JSON.parse_string(save_file.get_as_text())
	save_file.close()
	if not parsed is Dictionary or int(parsed.get("schema_version", 0)) != 1:
		_fail("The unified save must contain the supported schema version.")
		return
	if not parsed.has("legacy_files") or not parsed.has("missions") or not parsed.has("vehicles"):
		_fail("The unified save must include legacy records, mission snapshots and vehicle snapshots.")
		return

	var legacy_files = parsed.get("legacy_files", {})
	if not legacy_files is Dictionary or not legacy_files.has(TEST_RELATIONSHIP_PATH):
		_fail("The unified save must capture an existing NPC relationship JSON file.")
		return
	legacy_files[TEST_UNRELATED_PATH] = "must_not_overwrite_unrelated_user_file"
	legacy_files["user://npc_relationships/../../save_manager_escape.json"] = "must_not_escape_user_directory"
	if not _write_text(TEST_SAVE_PATH, JSON.stringify(parsed, "\t")):
		_fail("Could not write the controlled restore-path regression fixture.")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_RELATIONSHIP_PATH))
	if not _write_text(TEST_UNRELATED_PATH, "keep-existing-user-file"):
		_fail("Could not create the unrelated user-file sentinel.")
		return
	if FileAccess.file_exists(TEST_ESCAPE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_ESCAPE_PATH))

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
	if not FileAccess.file_exists(TEST_RELATIONSHIP_PATH):
		_fail("An allowlisted legacy NPC relationship file must be restored.")
		return
	if _read_text(TEST_RELATIONSHIP_PATH) != ORIGINAL_RELATIONSHIP:
		_fail("The restored legacy NPC relationship content must match the saved record.")
		return
	if _read_text(TEST_UNRELATED_PATH) != "keep-existing-user-file":
		_fail("An unrelated user file must not be overwritten by save restoration.")
		return
	if FileAccess.file_exists(TEST_ESCAPE_PATH):
		_fail("A traversal entry must not write outside the NPC relationship directory.")
		return

	_remove_test_files()
	print("PASS: unified save, player transform restore, legacy NPC migration, allowlisted paths and traversal protection.")
	manager.queue_free()
	scene.queue_free()
	quit(0)


func _write_text(path: String, content: String) -> bool:
	var absolute_directory := ProjectSettings.globalize_path(path.get_base_dir())
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(content)
	file.flush()
	var write_error := file.get_error()
	file.close()
	return write_error == OK


func _read_text(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var content := file.get_as_text()
	file.close()
	return content


func _remove_test_files() -> void:
	for path in [
		TEST_SAVE_PATH,
		TEST_SAVE_PATH + ".tmp",
		TEST_SAVE_PATH + ".bak",
		TEST_RELATIONSHIP_PATH,
		TEST_UNRELATED_PATH,
		TEST_ESCAPE_PATH
	]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	_remove_test_files()
	quit(1)
