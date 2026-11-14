extends SceneTree

## Headless progression test for the rescue mission state machine.

const RUNTIME_SCRIPT = preload("res://scripts/missions/mission_002_runtime.gd")
const PLAYER_SCRIPT = preload("res://scripts/player/player_controller.gd")
const CAR_SCRIPT = preload("res://scripts/vehicles/driveable_car.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var player := CharacterBody3D.new()
	player.set_script(PLAYER_SCRIPT)
	root.add_child(player)
	var car := CharacterBody3D.new()
	car.set_script(CAR_SCRIPT)
	root.add_child(car)
	var runtime: CanvasLayer = RUNTIME_SCRIPT.new() as CanvasLayer
	root.add_child(runtime)
	runtime.setup(player, car)
	runtime._start_mission()

	if runtime._phase != 1:
		_fail("Mission 002 did not begin at the vehicle objective.")
		return

	player.is_driving = true
	car.driver = player
	runtime._process(0.0)
	if runtime._phase != 2:
		_fail("Entering the car did not advance the mission.")
		return

	car.global_position = runtime.CHECKPOINT
	runtime._process(0.0)
	if runtime._phase != 3:
		_fail("Reaching the checkpoint did not advance the mission.")
		return

	car.global_position = Vector3(0.0, 0.0, -35.0)
	runtime._process(0.0)
	if runtime._phase != 4:
		_fail("Passing the blockade did not unlock the rescue objective.")
		return

	player.is_driving = false
	car.driver = null
	player.global_position = runtime.WITNESS_POSITION
	runtime._process(0.0)
	if runtime._phase != 5:
		_fail("Approaching the witness did not start the escape phase.")
		return

	player.is_driving = true
	car.driver = player
	car.global_position = runtime.HOME_POSITION
	runtime._process(0.0)
	if runtime._phase != 6:
		_fail("Returning safely to the village did not complete the mission.")
		return

	print("PASS: Mission 002 progresses from vehicle entry through checkpoint, blockade, rescue, and escape.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
