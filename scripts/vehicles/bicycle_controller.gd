extends CharacterBody3D

@export var max_forward_speed := 9.5
@export var max_reverse_speed := 2.0
@export var pedal_acceleration := 4.2
@export var coasting_drag := 1.0
@export var brake_force := 12.0
@export var steering_rate := 2.1
@export var gravity := 18.0

var driver: CharacterBody3D
var steering_method := "analog"
var _speed := 0.0
var _saved_collision_layer := 1
var _saved_collision_mask := 1
var _visual_root: Node3D
var _front_wheel: Node3D
var _rear_wheel: Node3D


func _ready() -> void:
	add_to_group("vehicles")
	add_to_group("bicycles")
	_register_input_actions()
	_build_bicycle_visuals()
	_build_collision()
	_build_interaction_area()


func _register_input_actions() -> void:
	for action in [&"bike_pedal", &"bike_brake", &"bike_steer_left", &"bike_steer_right"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)


func set_steering_method(method: String) -> void:
	if ["analog", "buttons", "flick"].has(method):
		steering_method = method


func _physics_process(delta: float) -> void:
	if driver == null or not is_instance_valid(driver):
		velocity.x = 0.0
		velocity.z = 0.0
		if is_on_floor():
			velocity.y = 0.0
		else:
			velocity.y -= gravity * delta
		move_and_slide()
		return

	var steering_input := Input.get_axis("bike_steer_left", "bike_steer_right")
	if Input.is_action_pressed("bike_pedal"):
		_speed = move_toward(_speed, max_forward_speed, pedal_acceleration * delta)
	elif Input.is_action_pressed("bike_brake"):
		if _speed > 0.18:
			_speed = move_toward(_speed, 0.0, brake_force * delta)
		else:
			_speed = move_toward(_speed, -max_reverse_speed, pedal_acceleration * 0.42 * delta)
	else:
		_speed = move_toward(_speed, 0.0, coasting_drag * delta)

	if absf(_speed) > 0.15:
		var steering_strength := clampf(absf(_speed) / 2.0, 0.18, 1.0)
		rotation.y -= steering_input * steering_rate * steering_strength * delta

	var forward := -global_basis.z
	velocity.x = forward.x * _speed
	velocity.z = forward.z * _speed
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	move_and_slide()
	_sync_driver_pose()
	_animate_bicycle(delta, steering_input)


func interact() -> void:
	if driver != null and is_instance_valid(driver):
		_exit_bicycle()
		return
	var player := _find_player()
	if player != null:
		_enter_bicycle(player)


func _enter_bicycle(player: CharacterBody3D) -> void:
	if driver != null:
		return
	driver = player
	_saved_collision_layer = player.collision_layer
	_saved_collision_mask = player.collision_mask
	player.collision_layer = 0
	player.collision_mask = 0
	player.set("is_driving", true)
	player.velocity = Vector3.ZERO
	var player_visual := player.get_node_or_null("Visual") as Node3D
	if player_visual != null:
		player_visual.visible = false
	player.global_position = global_position + Vector3.UP * 0.78
	player.rotation.y = rotation.y
	_speed = 0.0
	_set_hud_bicycle_mode(true)


func _exit_bicycle() -> void:
	if driver == null or not is_instance_valid(driver):
		driver = null
		return
	var player := driver
	player.global_position = global_position + global_basis.x * 1.25 + Vector3.UP * 0.12
	player.rotation.y = rotation.y
	player.velocity = Vector3.ZERO
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
	_set_hud_bicycle_mode(false)


func _sync_driver_pose() -> void:
	if driver == null or not is_instance_valid(driver):
		return
	driver.global_position = global_position + Vector3.UP * 0.78
	driver.rotation.y = rotation.y


func _find_player() -> CharacterBody3D:
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is CharacterBody3D and candidate.get("is_driving") == false:
			return candidate as CharacterBody3D
	return null


func _set_hud_bicycle_mode(active: bool) -> void:
	var hud := get_tree().get_first_node_in_group("mobile_hud")
	if hud != null and hud.has_method("set_bicycle_mode"):
		hud.call("set_bicycle_mode", active)


func _build_bicycle_visuals() -> void:
	_visual_root = Node3D.new()
	_visual_root.name = "BicycleVisuals"
	add_child(_visual_root)

	var tire_material := _make_material(Color(0.045, 0.052, 0.05), 0.96)
	var metal_material := _make_material(Color(0.72, 0.28, 0.16), 0.58, 0.35)
	var dark_metal := _make_material(Color(0.19, 0.22, 0.22), 0.72, 0.2)
	var seat_material := _make_material(Color(0.10, 0.085, 0.07), 0.95)
	_front_wheel = _create_wheel("FrontWheel", Vector3(0.0, 0.55, -0.92), tire_material, dark_metal)
	_rear_wheel = _create_wheel("RearWheel", Vector3(0.0, 0.55, 0.92), tire_material, dark_metal)

	var rear_hub := Vector3(0.0, 0.55, 0.92)
	var front_hub := Vector3(0.0, 0.55, -0.92)
	var crank := Vector3(0.0, 0.60, 0.28)
	var seat_joint := Vector3(0.0, 1.13, 0.50)
	var head_joint := Vector3(0.0, 1.12, -0.56)
	_add_frame_tube("RearStay", crank, rear_hub, dark_metal, 0.065)
	_add_frame_tube("SeatTube", crank, seat_joint, metal_material, 0.075)
	_add_frame_tube("TopTube", seat_joint, head_joint, metal_material, 0.075)
	_add_frame_tube("DownTube", crank, head_joint, metal_material, 0.075)
	_add_frame_tube("ChainStay", rear_hub, crank, dark_metal, 0.055)
	_add_frame_tube("FrontFork", head_joint, front_hub, dark_metal, 0.065)
	_add_frame_tube("SeatPost", seat_joint, Vector3(0.0, 1.38, 0.52), dark_metal, 0.06)

	_add_box("Saddle", Vector3(0.30, 0.10, 0.43), Vector3(0.0, 1.43, 0.56), seat_material)
	_add_box("Handlebar", Vector3(1.02, 0.07, 0.09), Vector3(0.0, 1.35, -0.66), dark_metal)
	_add_box("PedalCrank", Vector3(0.12, 0.72, 0.10), crank, dark_metal)


func _create_wheel(node_name: String, center: Vector3,
		tire_material: StandardMaterial3D, hub_material: StandardMaterial3D) -> Node3D:
	var wheel_root := Node3D.new()
	wheel_root.name = node_name
	wheel_root.position = center
	_visual_root.add_child(wheel_root)

	var tire := MeshInstance3D.new()
	tire.name = "Tire"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.405
	torus.outer_radius = 0.49
	torus.rings = 20
	torus.ring_segments = 8
	tire.mesh = torus
	tire.rotation.y = PI * 0.5
	tire.material_override = tire_material
	wheel_root.add_child(tire)

	var hub := MeshInstance3D.new()
	hub.name = "Hub"
	var hub_mesh := CylinderMesh.new()
	hub_mesh.top_radius = 0.055
	hub_mesh.bottom_radius = 0.055
	hub_mesh.height = 0.15
	hub_mesh.radial_segments = 12
	hub.mesh = hub_mesh
	hub.rotation.z = PI * 0.5
	hub.material_override = hub_material
	wheel_root.add_child(hub)
	return wheel_root


func _add_frame_tube(node_name: String, start: Vector3, finish: Vector3,
		material: StandardMaterial3D, thickness: float) -> void:
	var delta := finish - start
	var tube := MeshInstance3D.new()
	tube.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = Vector3(thickness, thickness, delta.length())
	tube.mesh = mesh
	tube.position = (start + finish) * 0.5
	tube.rotation.x = -atan2(delta.y, delta.z)
	tube.material_override = material
	_visual_root.add_child(tube)


func _add_box(node_name: String, size: Vector3, local_position: Vector3,
		material: StandardMaterial3D) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.position = local_position
	visual.material_override = material
	_visual_root.add_child(visual)


func _make_material(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material


func _animate_bicycle(delta: float, steering_input: float) -> void:
	if _front_wheel != null:
		_front_wheel.rotate_object_local(Vector3.RIGHT, -_speed * delta / 0.49)
	if _rear_wheel != null:
		_rear_wheel.rotate_object_local(Vector3.RIGHT, -_speed * delta / 0.49)
	if _visual_root != null:
		var target_lean := -steering_input * 0.12
		_visual_root.rotation.z = lerp(_visual_root.rotation.z, target_lean,
			clampf(delta * 5.0, 0.0, 1.0))


func _build_collision() -> void:
	collision_layer = 1
	collision_mask = 1
	var collision := CollisionShape3D.new()
	collision.name = "BicycleCollision"
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.55, 1.10, 1.9)
	collision.shape = shape
	collision.position.y = 0.62
	add_child(collision)


func _build_interaction_area() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 2
	area.collision_mask = 0
	area.add_to_group("interaction_areas")
	area.position.y = 0.85
	add_child(area)
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.8
	collision.shape = sphere
	area.add_child(collision)
