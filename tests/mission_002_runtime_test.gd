extends SceneTree

## Headless progression test for the rescue mission state machine.

const RUNTIME_SCRIPT = preload("res://scripts/missions/mission_002_runtime.gd")
const WALLET_SCRIPT = preload("res://scripts/systems/player_wallet.gd")
const PLAYER_SCRIPT = preload("res://scripts/player/player_controller.gd")
const CAR_SCRIPT = preload("res://scripts/vehicles/driveable_car.gd")


func _initialize() -> void:
	call_deferred("_run_test")


func _run_test() -> void:
	var world := Node3D.new()
	world.name = "Mission002TestWorld"
	root.add_child(world)
	var player := CharacterBody3D.new()
	player.set_script(PLAYER_SCRIPT)
	var camera_pivot := Node3D.new()
	camera_pivot.name = "CameraPivot"
	player.add_child(camera_pivot)
	world.add_child(player)
	var wallet: Node = WALLET_SCRIPT.new()
	wallet.name = "PlayerWallet"
	wallet.set("persistence_enabled", false)
	wallet.set("initial_balance", 0)
	player.add_child(wallet)
	var car := CharacterBody3D.new()
	car.set_script(CAR_SCRIPT)
	world.add_child(car)
	var runtime: CanvasLayer = RUNTIME_SCRIPT.new() as CanvasLayer
	root.add_child(runtime)
	runtime.setup(player, car)
	runtime._world_root = world
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

	var rescue_snapshot: Dictionary = runtime.get_save_snapshot()
	if not bool(rescue_snapshot.get("passenger_rescued", false)):
		_fail("The active rescue snapshot must record that the witness is now a passenger.")
		return
	for actor in [runtime._pursuer, runtime._backup_pursuer, runtime._witness, runtime._passenger_visual]:
		if is_instance_valid(actor):
			actor.queue_free()
	runtime._pursuer = null
	runtime._backup_pursuer = null
	runtime._witness = null
	runtime._passenger_visual = null
	runtime._visuals_created = false
	await process_frame
	if not runtime.apply_save_snapshot(rescue_snapshot):
		_fail("The unified mission snapshot must restore an active rescue pursuit.")
		return
	if runtime._pursuer == null or not runtime._pursuer.visible or runtime._backup_pursuer == null or not runtime._backup_pursuer.visible:
		_fail("Restoring the escape phase must reactivate both pursuer vehicles.")
		return
	if runtime._witness == null or runtime._witness.visible:
		_fail("Restoring the escape phase must keep the rescued witness hidden at the rescue point.")
		return
	if runtime._passenger_visual == null or runtime._passenger_visual.get_parent() != car:
		_fail("Restoring the escape phase must recreate the rescued passenger inside the saved vehicle.")
		return

	player.is_driving = true
	car.driver = player
	if runtime._backup_pursuer == null or not runtime._backup_pursuer.visible:
		_fail("The backup pursuer was not activated for the escape phase.")
		return
	runtime._pursuer.global_position = car.global_position + Vector3(0.0, 0.0, -14.0)
	runtime._backup_pursuer.global_position = car.global_position + Vector3(0.0, 0.0, -4.5)
	runtime._process(0.0)
	if runtime._vehicle_health != 80:
		_fail("A close backup-pursuer impact did not reduce vehicle health.")
		return

	runtime._pursuer.global_position = Vector3(-2.8, 0.0, -49.0)
	runtime._backup_pursuer.global_position = Vector3(3.4, 0.0, -55.0)
	car.global_position = runtime.HOME_POSITION
	runtime._process(0.0)
	if runtime._phase != 6:
		_fail("Returning safely to the village did not complete the mission.")
		return
	if int(wallet.call("get_balance")) != 180:
		_fail("Completing mission 002 did not credit its reward to the player wallet.")
		return

	print("PASS: Mission 002 progresses from vehicle entry through checkpoint, blockade, rescue, and escape.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
