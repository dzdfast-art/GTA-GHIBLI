extends SceneTree

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_script := load("res://scripts/game_root.gd")
	if game_script == null:
		_fail("Game root failed to load.")
		return
	var game: Node = game_script.new()
	root.add_child(game)
	await process_frame
	await process_frame

	var player: Node3D = game.get_node_or_null("Player") as Node3D
	if player == null or not bool(player.call("has_runtime_services")):
		_fail("Player controller is not bound to player-vitals and camera-follow services.")
		return
	var camera_pivot := player.get("_camera_pivot") as Node3D
	if camera_pivot == null or camera_pivot.get_parent() != game:
		_fail("Camera pivot must be independent from the player so camera-follow smoothing is active.")
		return
	var camera_before := camera_pivot.global_position
	player.global_position += Vector3(5.0, 0.0, 0.0)
	player.call("_process", 0.10)
	var camera_after := camera_pivot.global_position
	if camera_after.x <= camera_before.x or camera_after.x >= player.global_position.x:
		_fail("Camera-follow service did not smoothly track player translation.")
		return
	player.global_position -= Vector3(5.0, 0.0, 0.0)

	var vehicles: Array[Node] = game.get_tree().get_nodes_in_group("drivable_vehicles")
	if vehicles.is_empty():
		_fail("The live world did not create a drivable vehicle.")
		return
	var vehicle: Node3D = vehicles[0] as Node3D
	if not bool(vehicle.call("has_runtime_models")):
		_fail("The live vehicle is not bound to profile, dynamics, fuel and damage models.")
		return
	var predicted_speed := float(vehicle.call("calculate_runtime_speed", 0.0, 1.0, false, 0.2))
	if predicted_speed <= 0.0:
		_fail("The configured vehicle dynamics did not produce forward acceleration.")
		return
	var fuel_before := float(vehicle.call("get_fuel_remaining"))
	vehicle.call("consume_runtime_fuel", 100.0)
	if float(vehicle.call("get_fuel_remaining")) >= fuel_before:
		_fail("The live vehicle did not consume its bound fuel model.")
		return
	var durability_before := float(vehicle.call("get_durability"))
	vehicle.call("apply_runtime_impact", 12.0)
	if float(vehicle.call("get_durability")) >= durability_before:
		_fail("The live vehicle did not apply collision damage through its damage model.")
		return

	var ticks_before := int(game.call("get_simulation_ticks"))
	var signals: RefCounted = game.call("get_runtime_system", "traffic_signal_controller") as RefCounted
	signals.call("configure", {"green_duration": 0.01, "amber_duration": 0.02, "red_duration": 0.03})
	game.call("advance_simulation", 0.02)
	if int(game.call("get_simulation_ticks")) != ticks_before + 1 or str(signals.call("get_phase")) != "amber":
		_fail("The live game loop did not advance its traffic-signal controller.")
		return

	game.call("report_crime", 1)
	var officer: Node3D = Node3D.new()
	officer.name = "TestPoliceUnit"
	officer.add_to_group("police_units")
	officer.global_position = player.global_position + Vector3(0.0, 0.0, 8.0)
	game.add_child(officer)
	game.call("advance_simulation", 0.1)
	var pursuit: RefCounted = game.call("get_runtime_system", "police_pursuit") as RefCounted
	if str(pursuit.get("state")) != "pursuing":
		_fail("Police-pursuit service did not receive the visible player position from the live simulation.")
		return
	officer.global_position = player.global_position + Vector3(0.0, 0.0, 100.0)
	game.call("advance_simulation", 0.1)
	if str(pursuit.get("state")) != "searching":
		_fail("Police pursuit did not transition to searching after losing visual contact.")
		return
	pursuit.call("configure", 0.2)
	game.call("advance_simulation", 0.25)
	if str(pursuit.get("state")) != "lost":
		_fail("Police pursuit did not transition to lost after its search timeout.")
		return
	game.call("report_crime", 1)
	if str(pursuit.get("state")) != "pursuing":
		_fail("A new crime did not restart a completed police-pursuit state.")
		return
	var wanted: RefCounted = game.call("get_runtime_system", "wanted_level") as RefCounted
	if int(wanted.call("get_level")) != int(game.call("get_runtime_system", "hud_state").get("wanted")):
		_fail("Wanted level and rendered HUD state are not synchronized.")
		return

	if not bool(game.call("save_runtime_checkpoint")):
		_fail("The runtime save manager could not persist an autosave checkpoint.")
		return
	var save_manager: RefCounted = game.call("get_runtime_system", "save_slot_manager") as RefCounted
	var loaded: Dictionary = save_manager.call("load_slot", "autosave")
	if not loaded.has("payload") or not loaded.payload.has("player_position"):
		_fail("The persisted autosave did not retain the live player checkpoint.")
		return
	var fresh_manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new() as RefCounted
	var restored: Dictionary = fresh_manager.call("load_slot", "autosave")
	if not restored.has("payload") or restored.payload.get("player_position") != player.global_position:
		_fail("A new save-slot manager instance could not reload the saved checkpoint from disk.")
		return

	var hud_report: Dictionary = game.call("get_runtime_status_report")
	if int(hud_report.get("simulation_ticks", 0)) <= 0 or not bool(hud_report.get("vehicle_bound", false)):
		_fail("Live runtime status report is incomplete.")
	print("PASS: live player vitals/camera, vehicle profile/dynamics/fuel/damage, traffic lights, police pursuit, HUD sync and persistent checkpoint.")
	game.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
