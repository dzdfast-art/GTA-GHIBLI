extends SceneTree

## Headless regression test for mission JSON loading, objective order, and save persistence.

const MISSION_MANAGER_SCRIPT = preload("res://scripts/missions/mission_manager.gd")
const SAVE_PATH := "user://gta_ghibli_save.json"


func _initialize() -> void:
	call_deferred("_run_mission_test")


func _run_mission_test() -> void:
	var absolute_save_path := ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(absolute_save_path)

	var player := Node3D.new()
	root.add_child(player)

	var mira := Node.new()
	mira.add_user_signal("dialogue_spoken")
	root.add_child(mira)

	var manager: CanvasLayer = MISSION_MANAGER_SCRIPT.new() as CanvasLayer
	root.add_child(manager)

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

	mira.emit_signal("dialogue_spoken")
	if not manager._mira_spoken_to:
		_fail("Speaking with Mira did not complete the dialogue objective.")
		return

	player.global_position = Vector3(0.0, 0.95, 27.0)
	manager._process(0.0)
	if not manager._garden_visited:
		_fail("The garden objective did not complete at the community garden.")
		return

	if not FileAccess.file_exists(SAVE_PATH):
		_fail("Mission progress was not written to the local save file.")
		return

	var restored_manager: CanvasLayer = MISSION_MANAGER_SCRIPT.new() as CanvasLayer
	root.add_child(restored_manager)
	if not restored_manager._square_reached or not restored_manager._mira_spoken_to or not restored_manager._garden_visited:
		_fail("Mission progress was not restored from the local save file.")
		return

	print("PASS: mission JSON loads, objectives complete in order, and progress survives manager reload.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
