extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var script = load("res://scripts/vehicles/vehicle_route_follower.gd")
	if script == null:
		_fail("Vehicle route follower did not load.")
		return
	var follower = script.new()
	if not follower.call("configure", {"arrival_radius": 3.0, "off_route_threshold": 6.0, "target_lookahead": 5.0}):
		_fail("Valid route follower settings were rejected.")
		return
	var route := {"reachable": true, "path": [Vector3.ZERO, Vector3(10.0, 0.0, 0.0), Vector3(10.0, 0.0, 20.0)]}
	var following: Dictionary = follower.call("evaluate_vehicle", route, Vector3(2.0, 0.0, 0.0))
	if str(following.get("status", "")) != "following" or bool(following.get("reroute_required", true)):
		_fail("Vehicle on the route was not classified as following.")
		return
	if following.get("target_position", Vector3.ZERO) == Vector3.ZERO:
		_fail("Vehicle route follower did not provide a forward target.")
		return
	var departed: Dictionary = follower.call("evaluate_vehicle", route, Vector3(3.0, 0.0, 9.0))
	if str(departed.get("status", "")) != "off_route" or not bool(departed.get("reroute_required", false)):
		_fail("Vehicle departure from route did not request a reroute.")
		return
	var arrived: Dictionary = follower.call("evaluate_vehicle", route, Vector3(10.0, 0.0, 19.0))
	if str(arrived.get("status", "")) != "arrived" or bool(arrived.get("reroute_required", true)):
		_fail("Vehicle arrival was not recognized.")
		return
	var invalid: Dictionary = follower.call("evaluate_vehicle", {"reachable": false, "path": []}, Vector3.ZERO)
	if bool(invalid.get("valid", true)):
		_fail("Unreachable GPS route was accepted by vehicle follower.")
		return
	print("PASS: vehicle route target, route adherence, reroute flag and arrival state.")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
