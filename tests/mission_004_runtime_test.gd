extends SceneTree

## Headless progression test for the last-train escort mission.
const RUNTIME_SCRIPT = preload("res://scripts/missions/mission_004_runtime.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var world := Node3D.new()
	world.name = "Mission004TestWorld"
	root.add_child(world)
	var player := CharacterBody3D.new()
	player.name = "Mission004TestPlayer"
	world.add_child(player)
	var runtime: CanvasLayer = RUNTIME_SCRIPT.new() as CanvasLayer
	root.add_child(runtime)
	runtime.setup(player)
	runtime._world_root = world
	runtime._start_mission()

	if runtime._phase != 1:
		_fail("Mission 004 did not start at the meet-Mia objective.")
		return

	player.global_position = runtime.MIA_POSITION
	runtime._physics_process(0.1)
	if runtime._phase != 2:
		_fail("Meeting Mia did not unlock the train objective.")
		return

	player.global_position = runtime.TRAIN_START
	runtime._physics_process(0.1)
	if runtime._phase != 3:
		_fail("Reaching the train did not unlock alarm shutdown.")
		return

	if runtime._alarm_markers.size() != 2 or runtime._train == null:
		_fail("The station blockout did not create its train and two alarm panels.")
		return

	for marker in runtime._alarm_markers:
		player.global_position = marker.global_position
		runtime._physics_process(0.1)

	if runtime._alarms_disabled != 2 or runtime._phase != 4:
		_fail("Disabling both alarm panels did not start the escort.")
		return

	for tick in range(22):
		player.global_position = runtime._train.global_position
		runtime._physics_process(1.0)

	if runtime._phase != 5:
		_fail("Staying with the train did not unlock the route choice.")
		return

	player.global_position = runtime.NORTH_ROUTE
	runtime._physics_process(0.1)
	if runtime._phase != 6 or runtime._route_choice != "north":
		_fail("Choosing the north route did not complete the mission.")
		return

	print("PASS: Mission 004 Mia meeting, train access, alarm shutdown, escort and route choice.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
