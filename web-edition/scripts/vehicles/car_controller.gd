extends CharacterBody3D
class_name GhibliCarController

@export var max_speed: float = 22.0
@export var acceleration: float = 12.0
@export var braking_force: float = 24.0
@export var steering_rate: float = 1.8

var _is_driven: bool = false
var _runtime_profile: Dictionary = {}
var _runtime_dynamics: RefCounted
var _runtime_fuel: RefCounted
var _runtime_damage: RefCounted


func _ready() -> void:
	add_to_group("drivable_vehicles")
	_create_collision_and_visuals()


func configure_runtime(profile: Dictionary, dynamics: RefCounted, fuel: RefCounted, damage: RefCounted) -> bool:
	if profile.is_empty() or dynamics == null or fuel == null or damage == null:
		return false
	_runtime_profile = profile.duplicate(true)
	_runtime_dynamics = dynamics
	_runtime_fuel = fuel
	_runtime_damage = damage
	max_speed = float(profile.get("max_forward_speed", max_speed))
	acceleration = float(profile.get("acceleration", acceleration))
	braking_force = float(profile.get("braking", braking_force))
	steering_rate = float(profile.get("steering_rate", steering_rate))
	return true


func has_runtime_models() -> bool:
	return not _runtime_profile.is_empty() and _runtime_dynamics != null and _runtime_fuel != null and _runtime_damage != null


func can_be_driven() -> bool:
	return (_runtime_fuel == null or bool(_runtime_fuel.call("can_drive"))) and (_runtime_damage == null or not bool(_runtime_damage.call("is_disabled")))


func get_fuel_remaining() -> float:
	return float(_runtime_fuel.get("fuel")) if _runtime_fuel != null else -1.0


func get_durability() -> float:
	return float(_runtime_damage.get("durability")) if _runtime_damage != null else 100.0


func consume_runtime_fuel(distance_meters: float) -> float:
	if _runtime_fuel == null or distance_meters <= 0.0:
		return 0.0
	return float(_runtime_fuel.call("travel", distance_meters / 1000.0))


func apply_runtime_impact(relative_speed: float) -> Dictionary:
	if _runtime_damage == null:
		return {"valid": false, "damage": 0.0}
	return _runtime_damage.call("apply_impact", relative_speed)


func calculate_runtime_speed(current_speed: float, throttle: float, brake_pressed: bool, delta: float) -> float:
	if _runtime_dynamics != null:
		return float(_runtime_dynamics.call("step_speed", current_speed, throttle, brake_pressed, delta))
	if brake_pressed:
		return move_toward(current_speed, 0.0, braking_force * delta)
	return move_toward(current_speed, throttle * max_speed, acceleration * delta)


func set_driven(value: bool) -> void:
	if value and not can_be_driven():
		_is_driven = false
		return
	_is_driven = value
	if not value:
		velocity = Vector3.ZERO


func get_vehicle_label() -> String:
	return "Harbor Sedan"


func _physics_process(delta: float) -> void:
	if not _is_driven:
		velocity = Vector3.ZERO
		return

	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steering := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var brake_pressed := Input.is_action_pressed("vehicle_brake")
	if not can_be_driven():
		throttle = 0.0
	var forward := -global_basis.z
	var current_speed := velocity.dot(forward)
	current_speed = calculate_runtime_speed(current_speed, throttle, brake_pressed, delta)
	if _runtime_damage != null and bool(_runtime_damage.call("is_disabled")):
		current_speed = 0.0

	if absf(current_speed) > 0.25:
		rotation.y -= steering * steering_rate * delta * signf(current_speed)

	forward = -global_basis.z
	var incoming_velocity := Vector3(forward.x * current_speed, velocity.y, forward.z * current_speed)
	var previous_position := global_position
	velocity.x = incoming_velocity.x
	velocity.z = incoming_velocity.z
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= 18.0 * delta
	move_and_slide()
	consume_runtime_fuel(previous_position.distance_to(global_position))
	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		var impact_speed := absf(incoming_velocity.dot(collision.get_normal()))
		if impact_speed > 0.1:
			apply_runtime_impact(impact_speed)


func _create_collision_and_visuals() -> void:
	collision_layer = 1
	collision_mask = 1

	var body_collision := CollisionShape3D.new()
	var body_shape := BoxShape3D.new()
	body_shape.size = Vector3(2.0, 0.9, 3.8)
	body_collision.shape = body_shape
	body_collision.position = Vector3(0.0, 0.58, 0.0)
	add_child(body_collision)

	var body_mesh := MeshInstance3D.new()
	var body_box := BoxMesh.new()
	body_box.size = Vector3(2.0, 0.85, 3.8)
	body_mesh.mesh = body_box
	body_mesh.position = Vector3(0.0, 0.85, 0.0)
	body_mesh.material_override = _make_material(Color(0.12, 0.31, 0.56))
	add_child(body_mesh)

	var cabin := MeshInstance3D.new()
	var cabin_box := BoxMesh.new()
	cabin_box.size = Vector3(1.55, 0.72, 1.8)
	cabin.mesh = cabin_box
	cabin.position = Vector3(0.0, 1.55, -0.15)
	cabin.material_override = _make_material(Color(0.24, 0.49, 0.68))
	add_child(cabin)

	for x in [-0.96, 0.96]:
		for z in [-1.25, 1.25]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.36
			wheel_mesh.bottom_radius = 0.36
			wheel_mesh.height = 0.22
			wheel.mesh = wheel_mesh
			wheel.rotation.z = PI * 0.5
			wheel.position = Vector3(x, 0.34, z)
			wheel.material_override = _make_material(Color(0.035, 0.04, 0.045))
			add_child(wheel)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	return material
