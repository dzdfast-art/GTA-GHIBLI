extends CharacterBody3D
class_name GhibliCarController

@export var max_speed: float = 22.0
@export var acceleration: float = 12.0
@export var braking_force: float = 24.0
@export var steering_rate: float = 1.8

var _is_driven: bool = false


func _ready() -> void:
	add_to_group("drivable_vehicles")
	_create_collision_and_visuals()


func set_driven(value: bool) -> void:
	_is_driven = value
	if not value:
		velocity = Vector3.ZERO


func get_vehicle_label() -> String:
	return "Harbor Sedan"


func get_save_id() -> String:
	return "harbor_sedan"


func _physics_process(delta: float) -> void:
	if not _is_driven:
		velocity = Vector3.ZERO
		return

	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steering := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var brake_pressed := Input.is_action_pressed("vehicle_brake")
	var forward := -global_basis.z
	var current_speed := velocity.dot(forward)

	if brake_pressed:
		current_speed = move_toward(current_speed, 0.0, braking_force * delta)
	else:
		current_speed = move_toward(current_speed, throttle * max_speed, acceleration * delta)

	if absf(current_speed) > 0.25:
		rotation.y -= steering * steering_rate * delta * signf(current_speed)

	forward = -global_basis.z
	velocity.x = forward.x * current_speed
	velocity.z = forward.z * current_speed
	if is_on_floor():
		velocity.y = 0.0
	else:
		velocity.y -= 18.0 * delta
	move_and_slide()


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
