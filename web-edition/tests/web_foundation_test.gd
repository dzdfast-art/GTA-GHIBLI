extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("Main scene could not be loaded.")
		return

	var game := packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	var player := game.get_node_or_null("Player")
	var world := game.get_node_or_null("World")
	var missions := game.get_node_or_null("MissionManager")
	if player == null or world == null or missions == null:
		_fail("Player, World, or MissionManager is missing from the new project.")
		return

	var interactables := get_nodes_in_group("interactables")
	if interactables.size() < 3:
		_fail("Expected Claire, Mia, and Nora interactive actors.")
		return

	var vehicles := get_nodes_in_group("drivable_vehicles")
	if vehicles.size() != 1:
		_fail("Expected one functional starter sedan in the foundation milestone.")
		return

	if world.call("get_region_name_at", Vector3(-96.0, 0.0, 0.0)) != "Harbor City":
		_fail("Harbor City coordinate mapping failed.")
		return
	if world.call("get_region_name_at", Vector3(-32.0, 0.0, 0.0)) != "Sapphire Coast":
		_fail("Sapphire Coast coordinate mapping failed.")
		return
	if world.call("get_region_name_at", Vector3(32.0, 0.0, 0.0)) != "Pine Highlands":
		_fail("Pine Highlands coordinate mapping failed.")
		return
	if world.call("get_region_name_at", Vector3(96.0, 0.0, 0.0)) != "Amber Valley":
		_fail("Amber Valley coordinate mapping failed.")
		return

	missions.call("reset_progress")
	missions.call("handle_interaction", "claire")
	if int(missions.get("mission_stage")) != 1:
		_fail("Mission 001 did not advance after speaking to Claire.")
		return
	missions.call("handle_interaction", "nora")
	if int(missions.get("mission_stage")) != 2:
		_fail("Mission 001 did not complete after meeting Nora.")
		return
	if int(missions.call("get_wallet")) != 600:
		_fail("Mission 001 reward was not added exactly once.")
		return

	print("PASS: fresh Web project main scene starts.")
	print("PASS: player, four connected blockout regions, and interactive named characters exist.")
	print("PASS: one starter sedan is registered as drivable.")
	print("PASS: Mission 001 progresses and awards the expected one-time reward.")
	print("NOTE: this is a foundation regression test, not full-game acceptance.")
	game.queue_free()
	await process_frame
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
