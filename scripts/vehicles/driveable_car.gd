extends CharacterBody3D

@export var max_forward_speed := 12.0
@export var max_reverse_speed := 4.5
@export var acceleration := 8.0
@export var braking_force := 16.0
@export var direction_change_rate := 36.0
@export var steering_rate := 1.65
@export var gravity := 18.0

var driver: CharacterBody3D
var _speed := 0.0
var _saved_collision_layer := 1
var _saved_collision_mask := 1

func _ready() -> void:
	add_to_group("vehicles")
	collision_layer = 1
	collision_mask = 1
	_build_vehicle_visuals()
	_build_interaction_area()
	if not InputMap.has_action("vehicle_brake"):
		InputMap.add_action("vehicle_brake")

func _physics_process(delta: float) -> void:
	if driver == null or not is_instance_valid(driver):
		return
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var throttle := -input_vector.y
	var target_speed := throttle * (max_forward_speed if throttle >= 0.0 else max_reverse_speed)
	if Input.is_action_pressed("vehicle_brake"):
		_speed = move_toward(_speed, 0.0, braking_force * delta)
	else:
		var speed_response := acceleration
		if absf(target_speed) > 0.1 and absf(_speed) > 0.1 and signf(target_speed) != signf(_speed):
			speed_response = maxf(braking_force, direction_change_rate)
		_speed = move_toward(_speed, target_speed, speed_response * delta)
	if absf(_speed) > 0.15:
		var steering_strength := clampf(absf(_speed) / 3.0, 0.25, 1.0)
		rotation.y -= input_vector.x * steering_rate * steering_strength * delta
	var forward := -global_basis.z
	velocity.x = forward.x * _speed
	velocity.z = forward.z * _speed
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	move_and_slide()
	_sync_driver_pose()

func interact() -> void:
	if driver != null and is_instance_valid(driver):
		_exit_vehicle()
		return
	var player := _find_player()
	if player != null:
		_enter_vehicle(player)

func _enter_vehicle(player: CharacterBody3D) -> void:
	if driver != null:
		return
	driver = player
	_saved_collision_layer = player.collision_layer
	_saved_collision_mask = player.collision_mask
	player.collision_layer = 0
	player.collision_mask = 0
	player.set("is_driving", true)
	var player_visual := player.get_node_or_null("Visual") as Node3D
	if player_visual != null:
		player_visual.visible = false
	player.global_position = global_position + Vector3.UP
	player.rotation.y = rotation.y
	_speed = 0.0
	_set_hud_vehicle_mode(true)

func _exit_vehicle() -> void:
	if driver == null or not is_instance_valid(driver):
		driver = null
		return
	var player := driver
	player.global_position = global_position + global_basis.x * 1.8 + Vector3.UP * 0.12
	player.rotation.y = rotation.y
	player.collision_layer = _saved_collision_layer
	player.collision_mask = _saved_collision_mask
	player.set("is_driving", false)
	var player_visual := player.get_node_or_null("Visual") as Node3D
	if player_visual != null:
		player_visual.visible = true
	driver = null
	_speed = 0.0
	velocity.x = 0.0
	velocity.z = 0.0
	_set_hud_vehicle_mode(false)

func _sync_driver_pose() -> void:
	if driver == null or not is_instance_valid(driver):
		return
	driver.global_position = global_position + Vector3.UP
	driver.rotation.y = rotation.y

func _find_player() -> CharacterBody3D:
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is CharacterBody3D and candidate.get("is_driving") == false:
			return candidate as CharacterBody3D
	return null

func _set_hud_vehicle_mode(active: bool) -> void:
	var hud := get_tree().get_first_node_in_group("mobile_hud")
	if hud != null and hud.has_method("set_vehicle_mode"):
		hud.call("set_vehicle_mode", active)

func _build_vehicle_visuals() -> void:
	_add_box("LowerBody", Vector3(1.9, 0.72, 3.9), Vector3(0.0, 0.86, 0.0), Color(0.22, 0.43, 0.35))
	_add_box("Cabin", Vector3(1.55, 0.78, 1.9), Vector3(0.0, 1.58, 0.22), Color(0.25, 0.48, 0.48))
	_add_box("FrontGlass", Vector3(1.38, 0.48, 0.06), Vector3(0.0, 1.63, -0.76), Color(0.48, 0.70, 0.75))
	_add_box("RearGlass", Vector3(1.35, 0.42, 0.06), Vector3(0.0, 1.62, 1.19), Color(0.42, 0.64, 0.70))
	_add_box("FrontBumper", Vector3(1.95, 0.16, 0.16), Vector3(0.0, 0.48, -1.98), Color(0.16, 0.18, 0.17))
	_add_box("RearBumper", Vector3(1.95, 0.16, 0.16), Vector3(0.0, 0.48, 1.98), Color(0.16, 0.18, 0.17))
	_add_box("LeftHeadlight", Vector3(0.38, 0.22, 0.08), Vector3(-0.62, 0.91, -1.98), Color(1.0, 0.91, 0.66))
	_add_box("RightHeadlight", Vector3(0.38, 0.22, 0.08), Vector3(0.62, 0.91, -1.98), Color(1.0, 0.91, 0.66))
	_add_wheel("FrontLeftWheel", Vector3(-0.98, 0.43, -1.25))
	_add_wheel("FrontRightWheel", Vector3(0.98, 0.43, -1.25))
	_add_wheel("RearLeftWheel", Vector3(-0.98, 0.43, 1.25))
	_add_wheel("RearRightWheel", Vector3(0.98, 0.43, 1.25))
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.85, 0.82, 3.85)
	var collision := CollisionShape3D.new()
	collision.name = "VehicleCollision"
	collision.shape = shape
	collision.position.y = 0.86
	add_child(collision)

func _add_box(node_name: String, dimensions: Vector3, local_position: Vector3, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	visual.position = local_position
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.72
	visual.material_override = material
	add_child(visual)

func _add_wheel(node_name: String, local_position: Vector3) -> void:
	var wheel := MeshInstance3D.new()
	wheel.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.42
	mesh.bottom_radius = 0.42
	mesh.height = 0.28
	mesh.radial_segments = 12
	wheel.mesh = mesh
	wheel.position = local_position
	wheel.rotation.z = PI * 0.5
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.075, 0.08, 0.075)
	material.roughness = 1.0
	wheel.material_override = material
	add_child(wheel)

func _build_interaction_area() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 2
	area.collision_mask = 0
	area.add_to_group("interaction_areas")
	add_child(area)
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.8
	collision.shape = sphere
	collision.position.y = 0.9
	area.add_child(collision)
