extends CharacterBody3D
class_name GhibliCarController

const VEHICLE_PROFILE_SCRIPT = preload("res://scripts/vehicles/vehicle_profile.gd")

@export var max_speed: float = 22.0
@export var acceleration: float = 12.0
@export var braking_force: float = 24.0
@export var steering_rate: float = 1.8

var _is_driven: bool = false
var _dynamics: RefCounted
var _damage_model: RefCounted
var _fuel_model: RefCounted
var _profile: Dictionary = {}
var _impact_cooldown: float = 0.0


func configure_runtime_services(dynamics: RefCounted, damage_model: RefCounted, fuel_model: RefCounted) -> bool:
	if dynamics == null or damage_model == null or fuel_model == null:
		return false
	_dynamics = dynamics
	_damage_model = damage_model
	_fuel_model = fuel_model
	_profile = VEHICLE_PROFILE_SCRIPT.get_profile("sedan")
	if _profile.is_empty():
		return false
	max_speed = float(_profile.get("max_forward_speed", max_speed))
	acceleration = float(_profile.get("acceleration", acceleration))
	braking_force = float(_profile.get("braking", braking_force))
	steering_rate = float(_profile.get("steering_rate", steering_rate))
	var dynamics_ok: bool = bool(_dynamics.call("configure", _profile))
	var damage_ok: bool = bool(_damage_model.call("configure", {}))
	var fuel_ok: bool = bool(_fuel_model.call("configure", 60.0, 0.12))
	return dynamics_ok and damage_ok and fuel_ok


func is_driven() -> bool:
	return _is_driven


func get_runtime_vehicle_status() -> Dictionary:
	return {
		"fuel": float(_fuel_model.get("fuel")) if _fuel_model != null else -1.0,
		"condition": float(_damage_model.call("get_condition_ratio")) if _damage_model != null else -1.0,
		"durability": float(_damage_model.get("durability")) if _damage_model != null else -1.0,
		"driven": _is_driven
	}


func apply_impact(relative_speed: float) -> Dictionary:
	if _damage_model == null:
		return {"valid": false, "damage": 0.0}
	return _damage_model.call("apply_impact", relative_speed)


func repair_vehicle(amount: float) -> float:
	if _damage_model == null:
		return 0.0
	return float(_damage_model.call("repair", amount))


func _ready() -> void:
	add_to_group("drivable_vehicles")
	_create_collision_and_visuals()


func set_driven(value: bool) -> void:
	_is_driven = value
	if not value:
		velocity = Vector3.ZERO


func get_vehicle_label() -> String:
	return "Harbor Sedan"


func _physics_process(delta: float) -> void:
	_impact_cooldown = maxf(0.0, _impact_cooldown - delta)
	if not _is_driven:
		velocity = Vector3.ZERO
		return

	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steering := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var brake_pressed := Input.is_action_pressed("vehicle_brake")
	var forward := -global_basis.z
	var current_speed := velocity.dot(forward)
	if _fuel_model != null and throttle > 0.0 and not bool(_fuel_model.call("can_drive")):
		throttle = 0.0

	if _dynamics != null:
		current_speed = float(_dynamics.call("step_speed", current_speed, throttle, brake_pressed, delta))
	elif brake_pressed:
		current_speed = move_toward(current_speed, 0.0, braking_force * delta)
	else:
		current_speed = move_toward(current_speed, throttle * max_speed, acceleration * delta)

	if absf(current_speed) > 0.25:
		rotation.y -= steering * steering_rate * delta * signf(current_speed)

	var previous_position := global_position
	forward = -global_basis.z
	velocity.x = forward.x * current_speed
	velocity.z = forward.z * current_speed
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= 18.0 * delta
	move_and_slide()

	if _fuel_model != null:
		var distance_km := previous_position.distance_to(global_position) / 1000.0
		_fuel_model.call("travel", distance_km)

	if _damage_model != null and _impact_cooldown <= 0.0 and get_slide_collision_count() > 0:
		for collision_index in range(get_slide_collision_count()):
			var collision := get_slide_collision(collision_index)
			if absf(collision.get_normal().y) < 0.65:
				var remaining_speed := absf(velocity.dot(forward))
				var impact_speed := maxf(0.0, absf(current_speed) - remaining_speed)
				if impact_speed > 4.0:
					apply_impact(impact_speed)
					_impact_cooldown = 0.65
				break


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
