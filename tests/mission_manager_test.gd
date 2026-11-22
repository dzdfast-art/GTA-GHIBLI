extends SceneTree

## Headless regression test for mission JSON loading, objective order, and save persistence.

const MISSION_MANAGER_SCRIPT = preload("res://scripts/missions/mission_manager.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const SAVE_MANAGER_SCRIPT = preload("res://scripts/systems/game_save_manager.gd")
const SAVE_PATH := "user://gta_ghibli_save.json"
const UNIFIED_SAVE_PATH := "user://gta_ghibli_mission_001_unified_regression.json"


func _initialize() -> void:
	call_deferred("_run_mission_test")


func _run_mission_test() -> void:
	var absolute_save_path := ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(absolute_save_path)

	if FileAccess.file_exists(UNIFIED_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(UNIFIED_SAVE_PATH))
	if FileAccess.file_exists(UNIFIED_SAVE_PATH + ".tmp"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(UNIFIED_SAVE_PATH + ".tmp"))
	if FileAccess.file_exists(UNIFIED_SAVE_PATH + ".bak"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(UNIFIED_SAVE_PATH + ".bak"))

	var scene := Node3D.new()
	scene.name = "MissionTestScene"
	root.add_child(scene)
	current_scene = scene

	var save_manager := Node.new()
	save_manager.name = "GameSaveManager"
	save_manager.set_script(SAVE_MANAGER_SCRIPT)
	save_manager.set("save_path_override", UNIFIED_SAVE_PATH)
	scene.add_child(save_manager)
	await process_frame

	var player := Node3D.new()
	player.add_to_group("player")
	scene.add_child(player)
	var wallet: Node = WALLET_SCRIPT.new()
	wallet.name = "PlayerWallet"
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 0)
	player.add_child(wallet)

	var mira := Node.new()
	mira.add_user_signal("dialogue_spoken")
		scene.add_child(mira)

	var manager: CanvasLayer = MISSION_MANAGER_SCRIPT.new() as CanvasLayer
	manager.name = "MissionManager"
	scene.add_child(manager)

	if manager._objectives.size() != 3:
		_fail("The mission manager did not load all three objectives from mission_001.json.")
		return
	if str(manager._mission_data.get("mission_id", "")) != "meet_the_village":
		_fail("The mission manager loaded the wrong mission record.")
		return

	manager.setup(player, mira)

	player.global_position = Vector3(0.0, 0.95, -18.0)
	manager._process(0.0)
	if manager._square_reached:
		_fail("The square objective completed before the player reached the square.")
		return

	player.global_position = Vector3(0.0, 0.95, 0.0)
	manager._process(0.0)
	if not manager._square_reached:
		_fail("The square objective did not complete at the village square.")
		return
	var square_save := _read_unified_save()
	var mission_snapshot: Dictionary = square_save.get("missions", {}).get("MissionManager", {})
	if not bool(mission_snapshot.get("square_reached", false)):
		_fail("Mission 001 progress must reach the unified save immediately after the square objective.")
		return

	mira.emit_signal("dialogue_spoken")
	if not manager._mira_spoken_to:
		_fail("Speaking with Mira did not complete the dialogue objective.")
		return
	var dialogue_save := _read_unified_save()
	mission_snapshot = dialogue_save.get("missions", {}).get("MissionManager", {})
	if not bool(mission_snapshot.get("mira_spoken_to", false)):
		_fail("Mira dialogue progress must reach the unified save immediately.")
		return

	player.global_position = Vector3(0.0, 0.95, 27.0)
	manager._process(0.0)
	if not manager._garden_visited:
		_fail("The garden objective did not complete at the community garden.")
		return

	if int(wallet.call("get_balance")) != 25:
		_fail("Completing mission 001 did not credit its 25-currency reward to the wallet.")
		return
	manager.call("_claim_completion_reward_if_ready")
	if int(wallet.call("get_balance")) != 25:
		_fail("Mission 001 paid its completion reward more than once.")
		return
	var completed_save := _read_unified_save()
	mission_snapshot = completed_save.get("missions", {}).get("MissionManager", {})
	var wallet_snapshot: Dictionary = completed_save.get("components", {}).get("PlayerWallet", {})
	if not bool(mission_snapshot.get("completion_reward_claimed", false)) or int(wallet_snapshot.get("balance", -1)) != 25:
		_fail("The mission completion flag and wallet reward must be committed together in the unified save.")
		return

	if not FileAccess.file_exists(SAVE_PATH):
		_fail("Mission progress was not written to the local save file.")
		return

	var restored_manager: CanvasLayer = MISSION_MANAGER_SCRIPT.new() as CanvasLayer
	root.add_child(restored_manager)
	if not restored_manager._square_reached or not restored_manager._mira_spoken_to or not restored_manager._garden_visited:
		_fail("Mission progress was not restored from the local save file.")
		return

	print("PASS: mission JSON loads, every Mission 001 objective immediately updates the unified save, reward and completion state are committed, and progress survives manager reload.")
	quit(0)


func _read_unified_save() -> Dictionary:
	if not FileAccess.file_exists(UNIFIED_SAVE_PATH):
		return {}
	var file := FileAccess.open(UNIFIED_SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
