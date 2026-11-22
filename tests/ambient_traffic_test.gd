extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := MAIN_SCENE.instantiate()
	root.add_child(game)
	for _frame in range(12):
		await process_frame

	var traffic := get_nodes_in_group("ambient_traffic_vehicles")
	if traffic.size() < 4:
		_fail("The reference neighborhood should have at least four moving ambient traffic vehicles.")
		return
	var original_positions: Array[Vector3] = []
	for vehicle in traffic:
		if not vehicle.has_method("get_speed") or float(vehicle.call("get_speed")) <= 0.0:
			_fail("Every ambient traffic vehicle must expose a positive travel speed.")
			return
		if vehicle.get_node_or_null("Body") == null or vehicle.get_node_or_null("Windows") == null:
			_fail("Every ambient traffic vehicle must have a visible original car body and windows.")
			return
		original_positions.append(vehicle.global_position)

	for _frame in range(45):
		await process_frame
	var moved_count := 0
	for index in range(traffic.size()):
		if traffic[index].global_position.distance_to(original_positions[index]) > 0.25:
			moved_count += 1
	if moved_count != traffic.size():
		_fail("All ambient traffic vehicles should move along the village streets.")
		return

	print("PASS: four ambient vehicles follow village road lanes and keep moving.")
	game.queue_free()
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
