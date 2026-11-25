extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var root_script = load("res://scripts/game_root.gd")
	if root_script == null:
		_fail("Game root script did not load.")
		return
	var game = root_script.new()
	root.add_child(game)

	var system_ids: Array[String] = game.call("get_runtime_system_ids")
	if system_ids.size() != 56:
		_fail("The game root did not initialize the complete runtime systems registry.")
		return
	if game.call("get_runtime_system", "wanted_level") == null or game.call("get_runtime_system", "police_pursuit") == null:
		_fail("Core wanted-level and police-pursuit services are not exposed by the game root.")
		return

	var health: Dictionary = game.call("get_runtime_health_report")
	if int(health.get("total", 0)) != 62 or int(health.get("passed", 0)) != 62 or not bool(health.get("healthy", false)):
		_fail("Runtime integration health checks did not pass: " + str(health))
		return
	var acceptance: Dictionary = game.call("get_web_acceptance_status")
	if not bool(acceptance.get("can_release", false)):
		_fail("Web acceptance gate is missing runtime systems: " + str(acceptance))
		return

	var markers: Array = game.call("get_runtime_system", "map_marker_manager").call("get_markers")
	if markers.size() != 6:
		_fail("World points of interest were not registered in the runtime marker manager.")
		return
	if str(game.call("get_runtime_system", "region_registry").call("find_region", Vector2(-114.0, 0.0))) != "harbor_city":
		_fail("The active world region was not registered with the runtime region service.")
		return

	if not bool(game.call("set_language", "ar")):
		_fail("Runtime localization could not switch to Arabic.")
		return
	if int(game.call("report_crime", 2)) != 2:
		_fail("Crime events were not connected to the wanted-level service.")
		return
	if str(game.call("update_police_sighting", false, 5.0)) != "searching":
		_fail("Wanted-level events were not connected to the police-pursuit service.")
		return
	if not bool(game.call("try_reserve_traffic_vehicle")) or int(game.call("release_traffic_vehicle", 1)) != 0:
		_fail("Traffic spawn reservations were not exposed by the runtime.")
		return

	print("PASS: game-root runtime registry, world wiring, acceptance gate, localization, wanted level, pursuit and traffic budget.")
	game.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
