extends SceneTree

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game_script = load("res://scripts/game_root.gd")
	if game_script == null:
		_fail("The live game root did not load.")
		return
	var game = game_script.new()
	root.add_child(game)
	await process_frame

	var player: Node = game.get_node("Player")
	var world: Node = game.get_node("World")
	var cars := get_nodes_in_group("drivable_vehicles")
	if player == null or world == null or cars.is_empty():
		_fail("The live world, player or starting vehicle is missing.")
		return
	var car: Node = cars[0]
	var vitals: RefCounted = game.call("get_runtime_system", "player_vitals")
	var camera_follow: RefCounted = game.call("get_runtime_system", "camera_follow")
	var fuel: RefCounted = game.call("get_runtime_system", "vehicle_fuel")
	var damage: RefCounted = game.call("get_runtime_system", "vehicle_damage_model")
	var dynamics: RefCounted = game.call("get_runtime_system", "vehicle_dynamics")
	var signals: RefCounted = game.call("get_runtime_system", "traffic_signal_controller")
	var slots: RefCounted = game.call("get_runtime_system", "save_slot_manager")

	if player.get("runtime_vitals") != vitals:
		_fail("Player controller is not using the registered player-vitals service.")
		return
	if player.get("runtime_camera_follow") != camera_follow:
		_fail("Player controller is not using the registered camera-follow service.")
		return
	if float(car.call("get_runtime_vehicle_status").get("fuel", -1.0)) <= 0.0:
		_fail("Starting vehicle did not receive the live fuel service.")
		return
	if car.get("_dynamics") != dynamics or car.get("_damage_model") != damage or car.get("_fuel_model") != fuel:
		_fail("Starting vehicle is not bound to dynamics, damage and fuel services.")
		return

	var stamina_before := float(vitals.get("stamina"))
	Input.action_press("move_forward")
	Input.action_press("sprint")
	for frame_index in range(12):
		await physics_frame
	Input.action_release("move_forward")
	Input.action_release("sprint")
	if float(vitals.get("stamina")) >= stamina_before:
		_fail("Player sprint did not consume the shared stamina service.")
		return

	var pivot: Node3D = player.get_node("CameraPivot")
	var camera_before := pivot.global_position
	player.global_position += Vector3(4.0, 0.0, 0.0)
	await process_frame
	for frame_index in range(3):
		await process_frame
	if pivot.global_position.distance_to(camera_before) <= 0.0:
		_fail("Camera follow did not update its actual player camera pivot.")
		return

	player.global_position = car.global_position + Vector3(0.0, 0.0, 2.0)
	player.call("_enter_vehicle", car)
	Input.action_press("move_forward")
	for frame_index in range(20):
		await physics_frame
	Input.action_release("move_forward")
	if not bool(car.call("is_driven")):
		_fail("The player could not place the starting car into its driven state.")
		return
	if float(fuel.get("fuel")) >= 60.0:
		_fail("Driving did not consume fuel from the live vehicle-fuel service.")
		return
	var durability_before := float(damage.get("durability"))
	car.call("apply_impact", 20.0)
	if float(damage.get("durability")) >= durability_before:
		_fail("Vehicle impact did not reduce durability through the live damage model.")
		return

	var phase_before := str(signals.call("get_phase"))
	game.call("_advance_runtime_services", 20.0)
	if phase_before != "green" or str(signals.call("get_phase")) != "amber":
		_fail("Traffic signal phase did not advance from the game-root simulation tick.")
		return

	var unique_slot := "integration_persistence_check"
	if not bool(slots.call("save_slot", unique_slot, {"wallet": 731, "player_position": Vector3(2, 0, 3)}, 12345)):
		_fail("Save slot manager could not persist a test slot.")
		return
	var reloaded_manager: RefCounted = load("res://scripts/world/save_slot_manager.gd").new()
	var restored: Dictionary = reloaded_manager.call("load_slot", unique_slot)
	if int(restored.get("payload", {}).get("wallet", -1)) != 731:
		_fail("A new save manager instance could not reload the persisted slot.")
		return
	reloaded_manager.call("delete_slot", unique_slot)

	if int(game.call("report_crime", 1)) != 1:
		_fail("Crime did not raise wanted level through the live game root.")
		return
	var pursuit_state := str(game.call("update_police_sighting", false, 0.5))
	if pursuit_state != "searching":
		_fail("Police pursuit did not enter its search state after losing sight.")
		return
	game.call("_advance_runtime_services", 21.0)
	if str(game.call("get_runtime_system", "police_pursuit").get("state")) != "lost":
		_fail("The game-root tick did not advance the police search timeout.")
		return
	game.call("_advance_runtime_services", 10.0)
	if int(game.call("get_runtime_system", "wanted_level").call("get_level")) != 0:
		_fail("Wanted level did not cool down after the pursuit was lost.")
		return

	game.call("_sync_runtime_hud_state")
	var hud_state: Dictionary = game.call("get_runtime_system", "hud_state").call("snapshot")
	if int(hud_state.get("wanted", -1)) != 0 or float(hud_state.get("health", -1.0)) < 0.0:
		_fail("The HUD state did not receive current vitals and wanted level.")
	print("PASS: live player stamina/camera, vehicle dynamics/fuel/damage, signal clock, persistent save slots, police search and HUD state.")
	game.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
