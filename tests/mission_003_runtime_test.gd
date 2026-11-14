extends SceneTree

## Headless state-flow test for the harbor stealth investigation mission.
const RUNTIME_SCRIPT = preload("res://scripts/missions/mission_003_runtime.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var world := Node3D.new()
	world.name = "TestWorld"
	root.add_child(world)
	var player := CharacterBody3D.new()
	player.name = "TestPlayer"
	world.add_child(player)
	var runtime: CanvasLayer = RUNTIME_SCRIPT.new() as CanvasLayer
	root.add_child(runtime)
	runtime.setup(player)
	runtime._world_root = world
	runtime._start_mission()

	if runtime._phase != 1:
		_fail("Mission 003 did not begin at the contact objective.")
		return

	player.global_position = runtime.CONTACT_POSITION
	runtime._physics_process(0.0)
	if runtime._phase != 2:
		_fail("Meeting Nora did not unlock harbor entry.")
		return

	player.global_position = runtime.HARBOR_GATE_POSITION
	runtime._physics_process(0.0)
	if runtime._phase != 3:
		_fail("Reaching the harbor gate did not start evidence collection.")
		return

	if runtime._evidence_markers.size() != 3 or runtime._guards.size() != 3:
		_fail("The harbor blockout did not create three evidence markers and three guards.")
		return

	var test_guard: Node3D = runtime._guards[0]
	player.global_position = test_guard.global_position + Vector3(0.0, 0.0, -2.0)
	if not runtime._guard_can_see_player(test_guard, 2.0):
		_fail("A player directly in front of a guard was not detected by its field of view.")
		return
	player.global_position = test_guard.global_position + Vector3(0.0, 0.0, 2.0)
	if runtime._guard_can_see_player(test_guard, 2.0):
		_fail("A player behind a guard was incorrectly detected.")
		return

	for marker in runtime._evidence_markers:
		player.global_position = marker.global_position
		runtime._physics_process(0.0)

	if runtime._evidence_found != 3 or runtime._phase != 4:
		_fail("Collecting all three evidence items did not unlock the return objective.")
		return

	player.global_position = runtime.CONTACT_POSITION
	runtime._physics_process(0.0)
	if runtime._phase != 5:
		_fail("Returning to Nora with all evidence did not complete mission 003.")
		return

	print("PASS: Mission 003 contact, harbor entry, evidence collection, and return flow.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
