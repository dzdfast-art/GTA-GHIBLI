extends SceneTree

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/player.tscn")
const CAR_SCENE: PackedScene = preload("res://scenes/vehicles/starter_car.tscn")
const TEST_ENVIRONMENT_STATE = preload("res://tests/helpers/test_environment_state.gd")

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

	var environment_state: Node = TEST_ENVIRONMENT_STATE.new()
	environment_state.add_to_group("world_clock")
	environment_state.add_to_group("world_weather")
	root.add_child(environment_state)

	var player := PLAYER_SCENE.instantiate() as CharacterBody3D
	player.name = "Player"
	player.add_to_group("player")
	player.position = Vector3(0.0, 0.95, 0.0)
	root.add_child(player)

	var car := CAR_SCENE.instantiate() as CharacterBody3D
	car.position = Vector3(2.4, 0.0, 0.0)
	root.add_child(car)

	for required_visual in ["Roof", "FrontGrille", "FrontWindshield", "RearWindshield", "FrontWheelLeft", "RearWheelRight", "HeadlightBeamLeft", "HeadlightBeamRight", "BrakeLightLeft", "ReverseLightRight", "FrontIndicatorLeft", "RearIndicatorRight", "Dashboard", "FrontSeatBackLeft", "FrontSeatBackRight", "RearSeatBack", "CenterConsole", "SteeringColumn", "SteeringWheelPivot", "SteeringWheelPivot/SteeringWheel", "SteeringWheelHub"]:
		if car.get_node_or_null(required_visual) == null:
			_fail("The detailed sedan visual is missing: " + required_visual)
			return

	var steering_wheel_mesh := (car.get_node("SteeringWheelPivot/SteeringWheel") as MeshInstance3D).mesh
	if steering_wheel_mesh == null or not steering_wheel_mesh is TorusMesh:
		_fail("The sedan interior is missing a rendered steering-wheel ring.")
		return
	var steering_wheel_pivot := car.get_node("SteeringWheelPivot") as Node3D
	var steering_wheel_neutral_basis := steering_wheel_pivot.basis
	for _frame in range(3):
		await physics_frame

	var original_layer := player.collision_layer
	var original_mask := player.collision_mask
	car.call("interact")
	if car.get("driver") != player or not bool(player.get("is_driving")):
		_fail("The player could not enter the vehicle.")
		return
	if player.collision_layer != 0 or player.collision_mask != 0:
		_fail("Player collision was not disabled while driving.")
		return
	if not bool(player.get_node("Visual").visible):
		_fail("The humanoid driver was hidden while seated in the car.")
		return

	# Verify automatic headlights respond to night and storm conditions, but switch off in clear daylight.
	var left_beam := car.get_node("HeadlightBeamLeft") as SpotLight3D
	var right_beam := car.get_node("HeadlightBeamRight") as SpotLight3D
	environment_state.set("game_hour", 22.0)
	environment_state.set("weather_id", "clear")
	car.call("_update_vehicle_lighting", Vector2.ZERO, 0.016)
	if not left_beam.visible or not right_beam.visible:
		_fail("Automatic headlights did not turn on at night.")
		return
	var headlamp_material := (car.get_node("HeadlampLeft") as MeshInstance3D).material_override as StandardMaterial3D
	if headlamp_material == null or headlamp_material.emission_energy_multiplier < 1.5:
		_fail("Headlamp lenses did not illuminate at night.")
		return
	environment_state.set("game_hour", 14.0)
	car.call("_update_vehicle_lighting", Vector2.ZERO, 0.016)
	if left_beam.visible or right_beam.visible:
		_fail("Automatic headlights stayed on during clear daylight.")
		return
	environment_state.set("weather_id", "storm")
	car.call("_update_vehicle_lighting", Vector2.ZERO, 0.016)
	if not left_beam.visible or not right_beam.visible:
		_fail("Automatic headlights did not turn on during a daytime storm.")
		return
	environment_state.set("weather_id", "clear")
	car.call("_update_vehicle_lighting", Vector2.ZERO, 0.016)

	# Forward acceleration also animates the visible wheels.
	var front_wheel := car.get_node("FrontWheelRight") as Node3D
	var wheel_roll_before := front_wheel.rotation.x
	var start_z := car.global_position.z
	Input.action_press("ui_up")
	for _frame in range(30):
		await physics_frame
	Input.action_release("ui_up")
	if car.global_position.z >= start_z - 0.5:
		_fail("Forward input did not move the vehicle.")
		return
	if absf(wrapf(front_wheel.rotation.x - wheel_roll_before, -PI, PI)) < 0.05:
		_fail("Forward driving did not spin the visible front wheel.")
		return

	# Reverse must move the car back along its current heading.
	var reverse_start_z := car.global_position.z
	Input.action_press("ui_down")
	for _frame in range(30):
		await physics_frame
	var reverse_light_material := (car.get_node("ReverseLightLeft") as MeshInstance3D).material_override as StandardMaterial3D
	if reverse_light_material == null or reverse_light_material.emission_energy_multiplier < 1.0:
		_fail("Reverse lights did not illuminate while reversing.")
		return
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
	if absf(front_wheel.rotation.y) < deg_to_rad(5.0):
		_fail("Steering input did not angle the visible front wheels.")
		return
	if steering_wheel_pivot.basis.is_equal_approx(steering_wheel_neutral_basis):
		_fail("Steering input did not rotate the visible steering wheel.")
		return
	for _frame in range(24):
		await physics_frame
	if not steering_wheel_pivot.basis.is_equal_approx(steering_wheel_neutral_basis):
		_fail("The visible steering wheel did not return to center after steering input was released.")
		return
	car.set("_turn_signal_clock", 0.0)
	car.call("_update_vehicle_lighting", Vector2(1.0, 0.0), 0.1)
	var right_indicator_material := (car.get_node("FrontIndicatorRight") as MeshInstance3D).material_override as StandardMaterial3D
	var left_indicator_material := (car.get_node("FrontIndicatorLeft") as MeshInstance3D).material_override as StandardMaterial3D
	var right_rear_indicator_material := (car.get_node("RearIndicatorRight") as MeshInstance3D).material_override as StandardMaterial3D
	var left_rear_indicator_material := (car.get_node("RearIndicatorLeft") as MeshInstance3D).material_override as StandardMaterial3D
	if right_indicator_material == null or right_indicator_material.emission_energy_multiplier < 1.5:
		_fail("Right front turn indicator did not flash while steering right.")
		return
	if right_rear_indicator_material == null or right_rear_indicator_material.emission_energy_multiplier < 1.5:
		_fail("Right rear turn indicator did not flash while steering right.")
		return
	if left_indicator_material == null or left_indicator_material.emission_energy_multiplier > 0.2 or left_rear_indicator_material.emission_energy_multiplier > 0.2:
		_fail("Left turn indicators incorrectly flashed during a right turn.")
		return
	car.set("_turn_signal_clock", 0.0)
	car.call("_update_vehicle_lighting", Vector2(-1.0, 0.0), 0.1)
	if left_indicator_material.emission_energy_multiplier < 1.5 or left_rear_indicator_material.emission_energy_multiplier < 1.5:
		_fail("Both left turn indicators did not flash while steering left.")
		return
	if right_indicator_material.emission_energy_multiplier > 0.2 or right_rear_indicator_material.emission_energy_multiplier > 0.2:
		_fail("Right turn indicators incorrectly flashed during a left turn.")
		return
	car.set("_turn_signal_clock", 0.5)
	car.call("_update_vehicle_lighting", Vector2(-1.0, 0.0), 0.016)
	if left_indicator_material.emission_energy_multiplier > 0.2 or left_rear_indicator_material.emission_energy_multiplier > 0.2:
		_fail("Left turn indicators did not switch off between flashes.")
		return

	# Braking should reduce speed instead of continuing to accelerate.
	var speed_before_braking: float = absf(float(car.get("_speed")))
	Input.action_press("ui_up")
	Input.action_press("vehicle_brake")
	for _frame in range(12):
		await physics_frame
	var brake_light_material := (car.get_node("BrakeLightLeft") as MeshInstance3D).material_override as StandardMaterial3D
	if brake_light_material == null or brake_light_material.emission_energy_multiplier < 2.0:
		_fail("Brake lights did not brighten while braking.")
		return
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
