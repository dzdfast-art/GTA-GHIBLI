extends SceneTree

const SAVE_MANAGER_SCRIPT = preload("res://scripts/systems/game_save_manager.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const NEEDS_SCRIPT = preload("res://scripts/systems/player_needs.gd")
const TEST_SAVE_PATH := "user://gta_ghibli_save_manager_regression.json"
const TEST_RELATIONSHIP_PATH := "user://npc_relationships/save_manager_test_migration.json"
const TEST_RELATIONSHIP_NEWER_PATH := "user://npc_relationships/save_manager_newer.json"
const TEST_UNRELATED_PATH := "user://gta_ghibli_save_manager_unrelated.txt"
const TEST_ESCAPE_PATH := "user://save_manager_escape.json"
const LEGACY_WALLET_PATH := "user://player_wallet.json"
const LEGACY_NEEDS_PATH := "user://player_needs.json"
const ORIGINAL_RELATIONSHIP := "{\"persistence_id\":\"save_manager_test_migration\",\"trust\":17.0,\"familiarity\":42.0}"

var _preserved_files: Dictionary = {}
var _preserved_existed: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_preserve_file(LEGACY_WALLET_PATH)
	_preserve_file(LEGACY_NEEDS_PATH)
	_preserve_file(TEST_RELATIONSHIP_PATH)
	_preserve_file(TEST_RELATIONSHIP_NEWER_PATH)
	_remove_test_files()
	if not _write_text(LEGACY_WALLET_PATH, JSON.stringify({
		"schema_version": 2,
		"balance": 123,
		"reward_transactions": ["legacy_delivery_001"]
	})):
		_fail("Could not create the legacy wallet migration fixture.")
		return
	if not _write_text(LEGACY_NEEDS_PATH, JSON.stringify({
		"schema_version": 1,
		"hunger": 61.0,
		"thirst": 52.0,
		"energy": 74.0
	})):
		_fail("Could not create the legacy player-needs migration fixture.")
		return
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

	var wallet := WALLET_SCRIPT.new()
	wallet.name = "PlayerWallet"
	player.add_child(wallet)
	var needs := NEEDS_SCRIPT.new()
	needs.name = "PlayerNeeds"
	player.add_child(needs)

	var manager := SAVE_MANAGER_SCRIPT.new()
	manager.name = "GameSaveManagerTest"
	manager.set("save_path_override", TEST_SAVE_PATH)
	scene.add_child(manager)
	await process_frame
	await process_frame

	if not FileAccess.file_exists(TEST_SAVE_PATH):
		_fail("Existing legacy subsystem files must migrate into a unified save on first launch.")
		return
	var migrated_file := FileAccess.open(TEST_SAVE_PATH, FileAccess.READ)
	if migrated_file == null:
		_fail("The migrated unified save must be readable.")
		return
	var migrated = JSON.parse_string(migrated_file.get_as_text())
	migrated_file.close()
	if not migrated is Dictionary:
		_fail("The legacy migration must produce a valid JSON record.")
		return
	var migrated_components: Dictionary = migrated.get("components", {})
	var migrated_wallet: Dictionary = migrated_components.get("PlayerWallet", {})
	var migrated_needs: Dictionary = migrated_components.get("PlayerNeeds", {})
	if int(migrated_wallet.get("balance", -1)) != 123:
		_fail("First-launch migration must retain the legacy wallet balance.")
		return
	if int(migrated_needs.get("hunger", -1)) != 61 or int(migrated_needs.get("thirst", -1)) != 52:
		_fail("First-launch migration must retain legacy hunger and thirst values.")
		return
	if not migrated_wallet.get("reward_transactions", []).has("legacy_delivery_001"):
		_fail("First-launch migration must retain the legacy reward transaction ledger.")
		return

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

	# Save a newer unified snapshot while leaving the legacy files stale.
	# Loading must apply the canonical snapshot after reloading compatibility files.
	wallet.set("balance", 275)
	needs.set("hunger", 82.0)
	needs.set("thirst", 73.0)
	needs.set("energy", 64.0)
	if not manager.call("save_game"):
		_fail("The unified save manager must save a valid local game state.")
		return
	wallet.set("balance", 5)
	needs.set("hunger", 1.0)
	needs.set("thirst", 2.0)
	needs.set("energy", 3.0)
	if not manager.call("load_game"):
		_fail("The unified save manager must load a valid saved game.")
		return
	if int(wallet.call("get_balance")) != 275:
		_fail("The unified wallet snapshot must override a stale legacy wallet file.")
		return
	if int(needs.get("hunger")) != 82 or int(needs.get("thirst")) != 73 or int(needs.get("energy")) != 64:
		_fail("The unified needs snapshot must override stale legacy needs files.")
		return

	if not wallet.call("add_money_once", "post_snapshot_reward", 50):
		_fail("The wallet must accept a new transaction after the unified snapshot.")
		return
	if not manager.call("load_game"):
		_fail("The unified save manager must reload after a newer wallet transaction.")
		return
	if int(wallet.call("get_balance")) != 325 or not wallet.call("has_reward_transaction", "post_snapshot_reward"):
		_fail("Restore must preserve a newer legacy wallet balance and transaction ledger.")
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
	legacy_files[TEST_RELATIONSHIP_NEWER_PATH] = "must_not_overwrite_newer_relationship"
	legacy_files["user://npc_relationships/../../save_manager_escape.json"] = "must_not_escape_user_directory"
	if not _write_text(TEST_SAVE_PATH, JSON.stringify(parsed, "\t")):
		_fail("Could not write the controlled restore-path regression fixture.")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_RELATIONSHIP_PATH))
	if not _write_text(TEST_UNRELATED_PATH, "keep-existing-user-file"):
		_fail("Could not create the unrelated user-file sentinel.")
		return
	if not _write_text(TEST_RELATIONSHIP_NEWER_PATH, "keep-existing-newer-relationship"):
		_fail("Could not create the newer allowlisted NPC relationship sentinel.")
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
	if _read_text(TEST_RELATIONSHIP_NEWER_PATH) != "keep-existing-newer-relationship":
		_fail("A newer existing allowlisted NPC file must not be overwritten by an older embedded copy.")
		return
	if FileAccess.file_exists(TEST_ESCAPE_PATH):
		_fail("A traversal entry must not write outside the NPC relationship directory.")
		return

	_remove_test_files()
	manager.queue_free()
	scene.queue_free()
	await process_frame
	_restore_preserved_files()
	print("PASS: first-launch migration, authoritative needs, newer wallet transaction recovery, player transform, NPC restore precedence and traversal protection.")
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
		TEST_RELATIONSHIP_NEWER_PATH,
		TEST_UNRELATED_PATH,
		TEST_ESCAPE_PATH
	]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _preserve_file(path: String) -> void:
	_preserved_existed[path] = FileAccess.file_exists(path)
	if bool(_preserved_existed[path]):
		_preserved_files[path] = _read_text(path)


func _restore_preserved_files() -> void:
	for path_value in _preserved_existed.keys():
		var path := str(path_value)
		if bool(_preserved_existed[path]):
			_write_text(path, str(_preserved_files.get(path, "")))
		elif FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	_remove_test_files()
	_restore_preserved_files()
	quit(1)
