extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const CAR_SCENE: PackedScene = preload("res://scenes/vehicles/starter_car.tscn")

func _initialize() -> void:
	call_deferred("_run_test")

func _run_test() -> void:
	var ground := StaticBody3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(100.0, 1.0, 100.0)
	var ground_collision := CollisionShape3D.new()
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.5
	ground.add_child(ground_collision)
	root.add_child(ground)

	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector3(0.0, 0.95, 0.0)
	root.add_child(player)

	var car := CAR_SCENE.instantiate() as CharacterBody3D
	car.position = Vector3(2.4, 0.0, 0.0)
	root.add_child(car)

	for _frame in range(3):
		await physics_frame

	var pbr_model := car.get_node_or_null("PBR_SportCoupe") as Node3D
	if pbr_model == null:
		_fail("The vehicle controller did not instantiate the PBR sport coupe asset.")
		return
	var front_left_wheel := pbr_model.find_child("Wheel_Front_Left", true, false) as Node3D
	if front_left_wheel == null:
		_fail("The imported PBR front-left wheel group is missing.")
		return
	var original_layer := player.collision_layer
	var original_mask := player.collision_mask
	car.call("interact")
	if car.get("driver") != player or not bool(player.get("is_driving")):
		_fail("The player could not enter the vehicle.")
		return
	if player.collision_layer != 0 or player.collision_mask != 0:
		_fail("Player collision was not disabled while driving.")
		return

	# Forward acceleration.
	var start_z := car.global_position.z
	var wheel_rotation_before := front_left_wheel.rotation.x
	Input.action_press("ui_up")
	for _frame in range(30):
		await physics_frame
	Input.action_release("ui_up")
	if car.global_position.z >= start_z - 0.5:
		_fail("Forward input did not move the vehicle.")
		return
	if is_equal_approx(front_left_wheel.rotation.x, wheel_rotation_before):
		_fail("The PBR wheel groups did not rotate with the moving vehicle.")
		return

	# Reverse must move the car back along its current heading.
	var reverse_start_z := car.global_position.z
	Input.action_press("ui_down")
	for _frame in range(30):
		await physics_frame
	Input.action_release("ui_down")
	if car.global_position.z <= reverse_start_z + 0.25:
		_fail("Reverse input did not move the vehicle backward.")
		return

	# Steering must change the vehicle heading while it is moving.
	var start_rotation := car.rotation.y
	Input.action_press("ui_up")
	Input.action_press("ui_right")
	for _frame in range(24):
		await physics_frame
	Input.action_release("ui_up")
	Input.action_release("ui_right")
	if is_equal_approx(car.rotation.y, start_rotation):
		_fail("Steering input did not change the vehicle heading.")
		return

	# Braking should reduce speed instead of continuing to accelerate.
	var speed_before_braking: float = absf(float(car.get("_speed")))
	Input.action_press("ui_up")
	Input.action_press("vehicle_brake")
	for _frame in range(12):
		await physics_frame
	Input.action_release("ui_up")
	Input.action_release("vehicle_brake")
	var speed_after_braking: float = absf(float(car.get("_speed")))
	if speed_after_braking >= speed_before_braking:
		_fail("Brake input did not reduce vehicle speed.")
		return

	car.call("interact")
	if car.get("driver") != null or bool(player.get("is_driving")):
		_fail("The player could not exit the vehicle.")
		return
	if player.collision_layer != original_layer or player.collision_mask != original_mask:
		_fail("Player collision settings were not restored after exiting.")
		return
	if not bool(player.get_node("Visual").visible):
		_fail("The player visual was not restored after exiting.")
		return

	print("PASS: vehicle enter, forward, reverse, steering, braking, and exit flow.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
