extends CharacterBody3D
class_name GhibliPlayerController

signal prompt_changed(text: String)
signal map_toggled
signal vehicle_state_changed(is_driving: bool, vehicle_name: String)

@export var walk_speed: float = 6.0
@export var sprint_multiplier: float = 1.55
@export var jump_velocity: float = 7.0
@export var gravity: float = 19.0

var _camera_pivot: Node3D
var _spring_arm: SpringArm3D
var _visual: MeshInstance3D
var _orbiting: bool = false
var _current_target: Node3D
var _driven_vehicle: Node3D
var _camera_sensitivity: float = 0.0045


func _ready() -> void:
	_register_input_actions()
	_create_character()
	_create_camera()
	collision_layer = 1
	collision_mask = 1


func _process(_delta: float) -> void:
	if _driven_vehicle != null:
		prompt_changed.emit("E — Exit vehicle")
		return
	_current_target = _find_nearest_target()
	if _current_target == null:
		prompt_changed.emit("WASD — Move   Shift — Run   Space — Jump   E — Interact")
	elif _current_target.is_in_group("drivable_vehicles"):
		prompt_changed.emit("E — Enter " + str(_current_target.call("get_vehicle_label")))
	else:
		prompt_changed.emit("E — " + str(_current_target.get("display_name")))


func _physics_process(delta: float) -> void:
	if _driven_vehicle != null:
		global_position = _driven_vehicle.global_position
		velocity = Vector3.ZERO
		return

	var input_axis := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var camera_forward := -_camera_pivot.global_basis.z
	var camera_right := _camera_pivot.global_basis.x
	camera_forward.y = 0.0
	camera_right.y = 0.0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	var move_direction := camera_right * input_axis.x - camera_forward * input_axis.y
	if move_direction.length_squared() > 1.0:
		move_direction = move_direction.normalized()

	var speed := walk_speed
	if Input.is_action_pressed("sprint"):
		speed *= sprint_multiplier

	velocity.x = move_toward(velocity.x, move_direction.x * speed, 22.0 * delta)
	velocity.z = move_toward(velocity.z, move_direction.z * speed, 22.0 * delta)
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
		else:
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

	if move_direction.length_squared() > 0.002:
		var target_angle := atan2(-move_direction.x, -move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, clampf(13.0 * delta, 0.0, 1.0))
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_RIGHT:
			_orbiting = mouse_button.pressed
			get_viewport().set_input_as_handled()
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_button.pressed:
			_spring_arm.spring_length = maxf(3.0, _spring_arm.spring_length - 0.5)
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_button.pressed:
			_spring_arm.spring_length = minf(10.0, _spring_arm.spring_length + 0.5)
	elif event is InputEventMouseMotion and _orbiting:
		var motion := event as InputEventMouseMotion
		_camera_pivot.rotate_y(-motion.relative.x * _camera_sensitivity)
		_camera_pivot.rotation.x = clampf(
			_camera_pivot.rotation.x - motion.relative.y * _camera_sensitivity,
			-0.72,
			0.32
		)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_map"):
		map_toggled.emit()
		get_viewport().set_input_as_handled()


func _try_interact() -> void:
	if _driven_vehicle != null:
		_exit_vehicle()
		return

	var target := _find_nearest_target()
	if target == null:
		return
	if target.is_in_group("drivable_vehicles"):
		_enter_vehicle(target)
	elif target.has_method("activate"):
		target.call("activate")


func _enter_vehicle(vehicle: Node3D) -> void:
	_driven_vehicle = vehicle
	if vehicle.has_method("set_driven"):
		vehicle.call("set_driven", true)
	_visual.visible = false
	vehicle_state_changed.emit(true, str(vehicle.call("get_vehicle_label")))


func _exit_vehicle() -> void:
	if _driven_vehicle == null:
		return
	var vehicle := _driven_vehicle
	if vehicle.has_method("set_driven"):
		vehicle.call("set_driven", false)
	global_position = vehicle.global_position + vehicle.global_basis.x * 2.4 + Vector3(0.0, 0.03, 0.0)
	_driven_vehicle = null
	_visual.visible = true
	vehicle_state_changed.emit(false, "")


func _find_nearest_target() -> Node3D:
	var nearest: Node3D
	var nearest_distance := 3.6
	var candidates: Array[Node] = []
	candidates.append_array(get_tree().get_nodes_in_group("interactables"))
	candidates.append_array(get_tree().get_nodes_in_group("drivable_vehicles"))
	for candidate in candidates:
		if not candidate is Node3D or not is_instance_valid(candidate):
			continue
		var target := candidate as Node3D
		var distance := global_position.distance_to(target.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = target
	return nearest


func _register_input_actions() -> void:
	_bind_key("move_forward", KEY_W)
	_bind_key("move_back", KEY_S)
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("jump", KEY_SPACE)
	_bind_key("sprint", KEY_SHIFT)
	_bind_key("interact", KEY_E)
	_bind_key("toggle_map", KEY_M)
	_bind_key("vehicle_brake", KEY_CTRL)


func _bind_key(action_name: StringName, key_code: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for existing in InputMap.action_get_events(action_name):
		if existing is InputEventKey and (existing as InputEventKey).physical_keycode == key_code:
			return
	var key_event := InputEventKey.new()
	key_event.physical_keycode = key_code
	InputMap.action_add_event(action_name, key_event)


func _create_character() -> void:
	var shape_node := CollisionShape3D.new()
	var capsule_shape := CapsuleShape3D.new()
	capsule_shape.radius = 0.38
	capsule_shape.height = 1.8
	shape_node.shape = capsule_shape
	shape_node.position.y = 0.9
	add_child(shape_node)

	_visual = MeshInstance3D.new()
	var capsule_mesh := CapsuleMesh.new()
	capsule_mesh.radius = 0.38
	capsule_mesh.height = 1.8
	_visual.mesh = capsule_mesh
	_visual.position.y = 0.9
	_visual.material_override = _make_material(Color(0.90, 0.89, 0.81))
	add_child(_visual)

	var trousers := MeshInstance3D.new()
	var trousers_mesh := CapsuleMesh.new()
	trousers_mesh.radius = 0.34
	trousers_mesh.height = 0.9
	trousers.mesh = trousers_mesh
	trousers.position = Vector3(0.0, 0.44, 0.0)
	trousers.material_override = _make_material(Color(0.12, 0.25, 0.49))
	_visual.add_child(trousers)


func _create_camera() -> void:
	_camera_pivot = Node3D.new()
	_camera_pivot.name = "CameraPivot"
	_camera_pivot.position = Vector3(0.0, 1.55, 0.0)
	_camera_pivot.rotation.x = -0.16
	add_child(_camera_pivot)

	_spring_arm = SpringArm3D.new()
	_spring_arm.spring_length = 6.5
	_spring_arm.margin = 0.25
	_spring_arm.collision_mask = 1
	_camera_pivot.add_child(_spring_arm)

	var camera := Camera3D.new()
	camera.current = true
	camera.fov = 68.0
	_spring_arm.add_child(camera)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material
