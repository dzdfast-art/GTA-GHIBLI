extends CharacterBody3D

@export var max_forward_speed := 12.0
@export var max_reverse_speed := 4.5
@export var acceleration := 8.0
@export var braking_force := 16.0
@export var direction_change_rate := 36.0
@export var steering_rate := 1.65
@export var gravity := 18.0
@export_range(1.0, 1000.0, 1.0) var max_vehicle_health := 100.0
@export_range(1.0, 30.0, 0.5) var collision_damage_threshold := 6.0
@export_range(0.1, 5.0, 0.1) var collision_damage_multiplier := 1.2
@export_range(0.1, 5.0, 0.1) var collision_damage_cooldown := 0.9

signal vehicle_health_changed(current: float, maximum: float)
signal vehicle_disabled(source_id: StringName)

var driver: CharacterBody3D
var vehicle_health := 100.0
var _speed := 0.0
var _saved_collision_layer := 1
var _saved_collision_mask := 1
var _collision_cooldown := 0.0
var _wheel_nodes: Array[MeshInstance3D] = []
var _brake_light_materials: Array[StandardMaterial3D] = []

func _ready() -> void:
	add_to_group("vehicles")
	collision_layer = 1
	collision_mask = 1
	vehicle_health = clampf(vehicle_health, 0.0, max_vehicle_health)
	_build_vehicle_visuals()
	_build_interaction_area()
	if not InputMap.has_action("vehicle_brake"):
		InputMap.add_action("vehicle_brake")

func _physics_process(delta: float) -> void:
	_collision_cooldown = maxf(0.0, _collision_cooldown - delta)
	if driver == null or not is_instance_valid(driver):
		_set_brake_lights(false)
		return
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var throttle := -input_vector.y
	var condition_ratio := get_vehicle_health_ratio()
	var handling_ratio := lerpf(0.55, 1.0, condition_ratio)
	var target_speed := throttle * (max_forward_speed if throttle >= 0.0 else max_reverse_speed) * handling_ratio
	var braking := Input.is_action_pressed("vehicle_brake")
	if braking:
		_speed = move_toward(_speed, 0.0, braking_force * delta)
	else:
		var speed_response := acceleration * handling_ratio
		if absf(target_speed) > 0.1 and absf(_speed) > 0.1 and signf(target_speed) != signf(_speed):
			speed_response = maxf(braking_force, direction_change_rate)
		_speed = move_toward(_speed, target_speed, speed_response * delta)
	_set_brake_lights(braking or (absf(_speed) > 0.1 and absf(target_speed) < 0.1))
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
	var velocity_before_move := velocity
	move_and_slide()
	_apply_collision_damage(velocity_before_move)
	_update_wheels(delta)
	_sync_driver_pose()

func interact() -> void:
	if driver != null and is_instance_valid(driver):
		_exit_vehicle()
		return
	var player := _find_player()
	if player != null:
		_enter_vehicle(player)

func _enter_vehicle(player: CharacterBody3D) -> void:
	if driver != null or not is_vehicle_operational():
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
	_add_brake_light("LeftBrakeLight", Vector3(-0.62, 0.91, 1.98))
	_add_brake_light("RightBrakeLight", Vector3(0.62, 0.91, 1.98))
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
	_wheel_nodes.append(wheel)

func _add_brake_light(node_name: String, local_position: Vector3) -> void:
	var light := MeshInstance3D.new()
	light.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.38, 0.20, 0.055)
	light.mesh = mesh
	light.position = local_position
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.20, 0.025, 0.02)
	material.emission_enabled = true
	material.emission = Color(0.035, 0.003, 0.002)
	material.emission_energy_multiplier = 0.2
	light.material_override = material
	_brake_light_materials.append(material)
	add_child(light)

func _set_brake_lights(enabled: bool) -> void:
	for material in _brake_light_materials:
		material.albedo_color = Color(1.0, 0.055, 0.025) if enabled else Color(0.20, 0.025, 0.02)
		material.emission = Color(1.0, 0.035, 0.012) if enabled else Color(0.035, 0.003, 0.002)
		material.emission_energy_multiplier = 1.1 if enabled else 0.2

func _update_wheels(delta: float) -> void:
	var rotation_step := -_speed * delta / 0.42
	for wheel in _wheel_nodes:
		if is_instance_valid(wheel):
			wheel.rotate_object_local(Vector3.RIGHT, rotation_step)

func _apply_collision_damage(velocity_before_move: Vector3) -> void:
	if _collision_cooldown > 0.0 or get_slide_collision_count() <= 0:
		return
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		if absf(collision.get_normal().y) > 0.65:
			continue
		var relative_velocity := velocity_before_move - collision.get_collider_velocity()
		var impact_speed := Vector2(relative_velocity.x, relative_velocity.z).length()
		if impact_speed > collision_damage_threshold:
			var damage := (impact_speed - collision_damage_threshold) * collision_damage_multiplier
			apply_damage(damage, &"collision")
			_collision_cooldown = collision_damage_cooldown
			return

func apply_damage(amount: float, source_id: StringName = &"unknown") -> bool:
	if amount <= 0.0 or vehicle_health <= 0.0:
		return false
	var before := vehicle_health
	vehicle_health = maxf(0.0, vehicle_health - amount)
	if is_equal_approx(before, vehicle_health):
		return false
	vehicle_health_changed.emit(vehicle_health, max_vehicle_health)
	if vehicle_health <= 0.0:
		_speed = 0.0
		velocity.x = 0.0
		velocity.z = 0.0
		vehicle_disabled.emit(source_id)
		if driver != null and is_instance_valid(driver):
			_exit_vehicle()
	return true

func repair_vehicle(amount: float = -1.0) -> bool:
	if amount == 0.0 or vehicle_health >= max_vehicle_health:
		return false
	var repair_amount := max_vehicle_health if amount < 0.0 else amount
	var before := vehicle_health
	vehicle_health = minf(max_vehicle_health, vehicle_health + repair_amount)
	if is_equal_approx(before, vehicle_health):
		return false
	vehicle_health_changed.emit(vehicle_health, max_vehicle_health)
	return true

func get_vehicle_health_ratio() -> float:
	return clampf(vehicle_health / maxf(1.0, max_vehicle_health), 0.0, 1.0)

func is_vehicle_operational() -> bool:
	return vehicle_health > 0.0

func get_vehicle_save_snapshot() -> Dictionary:
	return {"health": vehicle_health, "max_health": max_vehicle_health}

func apply_vehicle_save_snapshot(snapshot: Dictionary) -> bool:
	if not snapshot.has("health"):
		return false
	vehicle_health = clampf(float(snapshot.get("health", max_vehicle_health)), 0.0, max_vehicle_health)
	_speed = 0.0
	velocity = Vector3.ZERO
	vehicle_health_changed.emit(vehicle_health, max_vehicle_health)
	return true

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
