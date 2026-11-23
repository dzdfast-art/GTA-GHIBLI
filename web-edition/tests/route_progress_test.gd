extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var progress_script = load("res://scripts/world/route_progress.gd")
	if progress_script == null:
		_fail("Route progress evaluator could not be loaded.")
		return
	var evaluator = progress_script.new()
	var route := {
		"reachable": true,
		"path": [
			Vector3(0.0, 0.0, 0.0),
			Vector3(10.0, 0.0, 0.0),
			Vector3(10.0, 0.0, 20.0)
		]
	}
	var start_result: Dictionary = evaluator.call("evaluate", route, Vector3(2.0, 0.0, 0.0))
	if not bool(start_result.get("valid", false)) or absf(float(start_result.get("remaining_distance", -1.0)) - 28.0) > 0.01:
		_fail("Remaining road distance was not calculated from the nearest route projection.")
		return
	if float(start_result.get("cross_track_distance", INF)) > 0.01:
		_fail("A player on the road route was incorrectly marked off-route.")
		return
	var off_route_result: Dictionary = evaluator.call("evaluate", route, Vector3(5.0, 0.0, 6.0))
	if not bool(evaluator.call("is_off_route", off_route_result, 5.0)):
		_fail("Cross-track distance did not detect a player away from the route.")
		return
	var arrived_result: Dictionary = evaluator.call("evaluate", route, Vector3(10.0, 0.0, 18.0), 3.0)
	if not bool(arrived_result.get("arrived", false)) or float(arrived_result.get("remaining_distance", -1.0)) != 0.0:
		_fail("Arrival radius did not stop the remaining-distance countdown.")
		return
	var unreachable_result: Dictionary = evaluator.call("evaluate", {"reachable": false, "path": []}, Vector3.ZERO)
	if bool(unreachable_result.get("valid", true)):
		_fail("An unreachable route was incorrectly evaluated as valid.")
		return
	print("PASS: route progress, remaining distance, off-route detection and arrival radius.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
