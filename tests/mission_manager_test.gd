extends SceneTree

## Headless regression test for the first mission objective sequence.

const MISSION_MANAGER_SCRIPT = preload("res://scripts/missions/mission_manager.gd")


func _initialize() -> void:
	call_deferred("_run_mission_test")


func _run_mission_test() -> void:
	var player := Node3D.new()
	root.add_child(player)

	var mira := Node.new()
	mira.add_user_signal("dialogue_spoken")
	root.add_child(mira)

	var manager: CanvasLayer = MISSION_MANAGER_SCRIPT.new() as CanvasLayer
	root.add_child(manager)
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

	print("PASS: first mission objectives complete in the correct order.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
