extends CharacterBody3D

const RED_PAINT_TEXTURE: Texture2D = preload("res://assets/vehicles/materials/ghibli_sports_car_red.svg")
const GLASS_TEXTURE: Texture2D = preload("res://assets/environment/materials/ghibli_city_glass.svg")
const PBR_SPORT_COUPE_SCENE: PackedScene = preload("res://assets/vehicles/models/ghibli_sport_coupe.gltf")
const WHEEL_NODE_NAMES: Array[String] = ["Wheel_Front_Left", "Wheel_Front_Right", "Wheel_Rear_Left", "Wheel_Rear_Right"]

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
var _vehicle_model: Node3D
var _wheel_nodes: Array[Node3D] = []

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
	_animate_vehicle_wheels(delta, input_vector.x)
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
	if PBR_SPORT_COUPE_SCENE == null:
		push_warning("PBR sport coupe asset could not be loaded; using the safe procedural fallback.")
		_build_fallback_vehicle_visuals()
		return
	_vehicle_model = PBR_SPORT_COUPE_SCENE.instantiate() as Node3D
	if _vehicle_model == null:
		push_warning("PBR sport coupe scene did not instantiate; using the procedural fallback.")
		_build_fallback_vehicle_visuals()
		return
	_vehicle_model.name = "PBR_SportCoupe"
	add_child(_vehicle_model)
	_wheel_nodes.clear()
	for wheel_name in WHEEL_NODE_NAMES:
		var wheel := _vehicle_model.get_node_or_null(wheel_name) as Node3D
		if wheel != null:
			_wheel_nodes.append(wheel)
	if _wheel_nodes.size() != WHEEL_NODE_NAMES.size():
		push_warning("PBR sport coupe wheel groups are incomplete; expected four independently rotating wheels.")

func _animate_vehicle_wheels(delta: float, steering_input: float) -> void:
	if _wheel_nodes.is_empty():
		return
	var spin_angle := (_speed / 0.34) * delta
	for index in range(_wheel_nodes.size()):
		var wheel := _wheel_nodes[index]
		if wheel == null or not is_instance_valid(wheel):
			continue
		if index < 2:
			wheel.rotation.y = -steering_input * 0.30
		wheel.rotate_object_local(Vector3.RIGHT, spin_angle)

func _build_fallback_vehicle_visuals() -> void:
	_add_box("LowerBody", Vector3(1.9, 0.72, 3.9), Vector3(0.0, 0.86, 0.0), Color(0.88, 0.055, 0.045))
	_add_box("Cabin", Vector3(1.55, 0.78, 1.9), Vector3(0.0, 1.58, 0.22), Color(0.12, 0.25, 0.34))
	_add_box("FrontGlass", Vector3(1.38, 0.48, 0.06), Vector3(0.0, 1.63, -0.76), Color(0.16, 0.39, 0.49))
	_add_box("RearGlass", Vector3(1.35, 0.42, 0.06), Vector3(0.0, 1.62, 1.19), Color(0.14, 0.32, 0.42))
	_add_box("FrontBumper", Vector3(1.95, 0.16, 0.16), Vector3(0.0, 0.48, -1.98), Color(0.16, 0.18, 0.17))
	_add_box("RearBumper", Vector3(1.95, 0.16, 0.16), Vector3(0.0, 0.48, 1.98), Color(0.16, 0.18, 0.17))
	_add_box("LeftHeadlight", Vector3(0.38, 0.22, 0.08), Vector3(-0.62, 0.91, -1.98), Color(1.0, 0.91, 0.66))
	_add_box("RightHeadlight", Vector3(0.38, 0.22, 0.08), Vector3(0.62, 0.91, -1.98), Color(1.0, 0.91, 0.66))
	_add_wheel("FrontLeftWheel", Vector3(-0.98, 0.43, -1.25))
	_add_wheel("FrontRightWheel", Vector3(0.98, 0.43, -1.25))
	_add_wheel("RearLeftWheel", Vector3(-0.98, 0.43, 1.25))
	_add_wheel("RearRightWheel", Vector3(0.98, 0.43, 1.25))

	_add_box("SportHood", Vector3(1.48, 0.13, 1.22), Vector3(0.0, 1.23, -1.24), Color(0.94, 0.10, 0.075))
	_add_box("RearDeck", Vector3(1.42, 0.13, 0.86), Vector3(0.0, 1.21, 1.48), Color(0.84, 0.045, 0.04))
	_add_box("SportRoof", Vector3(1.34, 0.14, 1.03), Vector3(0.0, 2.00, 0.28), Color(0.82, 0.055, 0.05))
	_add_box("FrontGrille", Vector3(0.62, 0.19, 0.07), Vector3(0.0, 0.78, -1.99), Color(0.055, 0.065, 0.075))
	_add_box("RearDiffuser", Vector3(1.15, 0.18, 0.10), Vector3(0.0, 0.48, 1.99), Color(0.045, 0.05, 0.06))
	_add_box("LeftTailLight", Vector3(0.48, 0.18, 0.07), Vector3(-0.62, 0.91, 1.98), Color(0.92, 0.06, 0.045))
	_add_box("RightTailLight", Vector3(0.48, 0.18, 0.07), Vector3(0.62, 0.91, 1.98), Color(0.92, 0.06, 0.045))
	_add_box("LeftSideSkirt", Vector3(0.12, 0.18, 2.45), Vector3(-0.91, 0.54, 0.0), Color(0.10, 0.11, 0.12))
	_add_box("RightSideSkirt", Vector3(0.12, 0.18, 2.45), Vector3(0.91, 0.54, 0.0), Color(0.10, 0.11, 0.12))
	_add_box("Spoiler", Vector3(1.58, 0.10, 0.25), Vector3(0.0, 1.80, 1.70), Color(0.12, 0.13, 0.14))
	_add_box("SpoilerSupportLeft", Vector3(0.08, 0.35, 0.08), Vector3(-0.52, 1.60, 1.68), Color(0.12, 0.13, 0.14))

	_add_box("SpoilerSupportRight", Vector3(0.08, 0.35, 0.08), Vector3(0.52, 1.60, 1.68), Color(0.12, 0.13, 0.14))
	_add_box("LeftSideWindow", Vector3(0.055, 0.40, 0.78), Vector3(-0.79, 1.63, 0.30), Color(0.10, 0.28, 0.37))
	_add_box("RightSideWindow", Vector3(0.055, 0.40, 0.78), Vector3(0.79, 1.63, 0.30), Color(0.10, 0.28, 0.37))
	_add_box("LeftQuarterWindow", Vector3(0.055, 0.34, 0.42), Vector3(-0.79, 1.62, 0.94), Color(0.10, 0.25, 0.34))
	_add_box("RightQuarterWindow", Vector3(0.055, 0.34, 0.42), Vector3(0.79, 1.62, 0.94), Color(0.10, 0.25, 0.34))
	_add_box("LeftMirrorArm", Vector3(0.22, 0.07, 0.08), Vector3(-0.90, 1.63, -0.68), Color(0.10, 0.11, 0.12))
	_add_box("RightMirrorArm", Vector3(0.22, 0.07, 0.08), Vector3(0.90, 1.63, -0.68), Color(0.10, 0.11, 0.12))
	_add_box("LeftMirror", Vector3(0.22, 0.16, 0.20), Vector3(-1.03, 1.67, -0.68), Color(0.12, 0.20, 0.25))
	_add_box("RightMirror", Vector3(0.22, 0.16, 0.20), Vector3(1.03, 1.67, -0.68), Color(0.12, 0.20, 0.25))
	_add_box("LeftDoorSeam", Vector3(0.025, 0.52, 0.025), Vector3(-0.96, 0.92, 0.18), Color(0.45, 0.035, 0.03))
	_add_box("RightDoorSeam", Vector3(0.025, 0.52, 0.025), Vector3(0.96, 0.92, 0.18), Color(0.45, 0.035, 0.03))
	_add_box("LeftDoorHandle", Vector3(0.08, 0.055, 0.22), Vector3(-0.98, 1.05, 0.42), Color(0.74, 0.76, 0.77))
	_add_box("RightDoorHandle", Vector3(0.08, 0.055, 0.22), Vector3(0.98, 1.05, 0.42), Color(0.74, 0.76, 0.77))
	_add_box("FrontSplitter", Vector3(1.95, 0.08, 0.44), Vector3(0.0, 0.39, -1.96), Color(0.045, 0.05, 0.055))
	_add_box("LeftAirIntake", Vector3(0.32, 0.19, 0.07), Vector3(-0.66, 0.70, -1.99), Color(0.035, 0.04, 0.045))
	_add_box("RightAirIntake", Vector3(0.32, 0.19, 0.07), Vector3(0.66, 0.70, -1.99), Color(0.035, 0.04, 0.045))
	_add_box("LeftExhaust", Vector3(0.22, 0.12, 0.16), Vector3(-0.62, 0.42, 2.02), Color(0.54, 0.58, 0.61))
	_add_box("RightExhaust", Vector3(0.22, 0.12, 0.16), Vector3(0.62, 0.42, 2.02), Color(0.54, 0.58, 0.61))
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
	var is_paint := node_name in ["LowerBody", "SportHood", "RearDeck", "SportRoof"]
	material.albedo_color = Color.WHITE if is_paint else tint
	material.roughness = 0.34
	material.metallic = 0.22
	if is_paint:
		material.albedo_texture = RED_PAINT_TEXTURE
		material.roughness = 0.27
		material.metallic = 0.42
	if node_name.contains("Glass") or node_name.contains("Window"):
		material.albedo_color = Color.WHITE
		material.albedo_texture = GLASS_TEXTURE
		material.roughness = 0.20
		material.metallic = 0.30
	if node_name.contains("Bumper") or node_name.contains("Diffuser") or node_name.contains("Skirt"):
		material.roughness = 0.76
		material.metallic = 0.08
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

	var hub := MeshInstance3D.new()
	hub.name = node_name + "Hub"
	var hub_mesh := CylinderMesh.new()
	hub_mesh.top_radius = 0.22
	hub_mesh.bottom_radius = 0.22
	hub_mesh.height = 0.30
	hub_mesh.radial_segments = 12
	hub.mesh = hub_mesh
	var hub_material := StandardMaterial3D.new()
	hub_material.albedo_color = Color(0.56, 0.61, 0.64)
	hub_material.metallic = 0.72
	hub_material.roughness = 0.32
	hub.material_override = hub_material
	wheel.add_child(hub)

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
