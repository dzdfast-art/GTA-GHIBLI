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
	car.call("interact")
	if car.get("driver") != player or not bool(player.get("is_driving")):
		_fail("The player could not enter the vehicle.")
		return
	var start_z := car.global_position.z
	Input.action_press("ui_up")
	for _frame in range(30):
		await physics_frame
	Input.action_release("ui_up")
	if car.global_position.z >= start_z - 0.5:
		_fail("Forward input did not move the vehicle.")
		return
	car.call("interact")
	if car.get("driver") != null or bool(player.get("is_driving")):
		_fail("The player could not exit the vehicle.")
		return
	if not bool(player.get_node("Visual").visible):
		_fail("The player visual was not restored after exiting.")
		return
	print("PASS: player enters, drives forward, and exits the starter car.")
	quit(0)

func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
