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
const WHEEL_RADIUS := 0.43
const MAX_FRONT_STEER_ANGLE := deg_to_rad(28.0)
const WHEEL_STEER_RESPONSE := 10.0
const STEERING_WHEEL_RATIO := 3.5
var _steering_wheel_pivot: Node3D
var _front_wheels: Array[Node3D] = []
var _rear_wheels: Array[Node3D] = []
var _wheel_roll_angle := 0.0
var _visual_steer_angle := 0.0
var _headlight_spots: Array[SpotLight3D] = []
var _headlight_materials: Array[StandardMaterial3D] = []
var _brake_light_materials: Array[StandardMaterial3D] = []
var _reverse_light_materials: Array[StandardMaterial3D] = []
var _left_indicator_materials: Array[StandardMaterial3D] = []
var _right_indicator_materials: Array[StandardMaterial3D] = []
var _turn_signal_clock := 0.0

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
		_update_wheel_visuals(0.0, delta)
		_update_vehicle_lighting(Vector2.ZERO, delta)
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
	_update_wheel_visuals(input_vector.x, delta)
	_update_vehicle_lighting(input_vector, delta)
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
	player.set("driven_vehicle_kind", &"car")
	var player_visual := player.get_node_or_null("Visual") as Node3D
	if player_visual != null:
		player_visual.visible = true
	player.global_position = global_position + Vector3(0.0, 0.22, 0.12)
	player.rotation.y = rotation.y
	_speed = 0.0
	_set_hud_vehicle_mode(true)

func _exit_vehicle() -> void:
	if driver == null or not is_instance_valid(driver):
		driver = null
		return
	var player := driver
	player.global_position = global_position + global_basis.x * 1.8 + Vector3.UP * 0.05
	player.rotation.y = rotation.y
	player.collision_layer = _saved_collision_layer
	player.collision_mask = _saved_collision_mask
	player.set("is_driving", false)
	player.set("driven_vehicle_kind", &"vehicle")
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
	driver.global_position = global_position + Vector3(0.0, 0.22, 0.12)
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
	# Original compact sedan silhouette: chassis, hood, trunk, glass, trim, lights and wheels.
	_add_box("Undercarriage", Vector3(1.82, 0.34, 3.82), Vector3(0.0, 0.60, 0.0), Color(0.075, 0.09, 0.085))
	_add_box("LowerBody", Vector3(1.92, 0.62, 4.05), Vector3(0.0, 0.91, 0.0), Color(0.19, 0.40, 0.31))
	_add_box("FrontHood", Vector3(1.86, 0.22, 1.15), Vector3(0.0, 1.30, -1.38), Color(0.22, 0.47, 0.35))
	_add_box("RearTrunk", Vector3(1.82, 0.22, 0.78), Vector3(0.0, 1.28, 1.56), Color(0.18, 0.39, 0.30))
	_add_box("Cabin", Vector3(1.53, 0.84, 2.10), Vector3(0.0, 1.62, 0.08), Color(0.16, 0.34, 0.28))
	_add_box("Roof", Vector3(1.42, 0.16, 1.34), Vector3(0.0, 2.12, 0.12), Color(0.20, 0.43, 0.32))
	_build_vehicle_interior()
	_add_box_rotated("FrontWindshield", Vector3(1.40, 0.62, 0.055), Vector3(0.0, 1.70, -0.82), Vector3(deg_to_rad(-24.0), 0.0, 0.0), Color(0.10, 0.20, 0.24))
	_add_box_rotated("RearWindshield", Vector3(1.34, 0.54, 0.055), Vector3(0.0, 1.69, 1.05), Vector3(deg_to_rad(24.0), 0.0, 0.0), Color(0.10, 0.20, 0.24))
	for side in [-1.0, 1.0]:
		_add_box_rotated("FrontSideWindow", Vector3(0.055, 0.53, 0.78), Vector3(side * 0.785, 1.73, -0.35), Vector3(0.0, 0.0, 0.0), Color(0.11, 0.22, 0.25))
		_add_box_rotated("RearSideWindow", Vector3(0.055, 0.53, 0.78), Vector3(side * 0.785, 1.73, 0.53), Vector3(0.0, 0.0, 0.0), Color(0.11, 0.22, 0.25))
		_add_box("WindowPillar", Vector3(0.08, 0.72, 0.10), Vector3(side * 0.79, 1.70, 0.08), Color(0.075, 0.10, 0.10))
		_add_box("SideMirror", Vector3(0.22, 0.16, 0.25), Vector3(side * 0.97, 1.62, -0.63), Color(0.12, 0.16, 0.15))
		_add_box("DoorHandleFront", Vector3(0.055, 0.08, 0.30), Vector3(side * 0.975, 1.08, -0.18), Color(0.78, 0.72, 0.56))
		_add_box("DoorHandleRear", Vector3(0.055, 0.08, 0.30), Vector3(side * 0.975, 1.08, 0.78), Color(0.78, 0.72, 0.56))
	_add_box("FrontBumper", Vector3(1.98, 0.18, 0.18), Vector3(0.0, 0.52, -2.02), Color(0.10, 0.13, 0.12))
	_add_box("RearBumper", Vector3(1.98, 0.18, 0.18), Vector3(0.0, 0.52, 2.02), Color(0.10, 0.13, 0.12))
	_add_box("FrontGrille", Vector3(0.88, 0.30, 0.075), Vector3(0.0, 0.91, -2.015), Color(0.045, 0.065, 0.06))
	_add_box("FrontPlate", Vector3(0.46, 0.16, 0.045), Vector3(0.0, 0.62, -2.12), Color(0.82, 0.82, 0.73))
	_add_box("RearPlate", Vector3(0.46, 0.16, 0.045), Vector3(0.0, 0.74, 2.07), Color(0.82, 0.82, 0.73))
	for side in [-1.0, 1.0]:
		var wheel_side := "Left" if side < 0.0 else "Right"
		_add_box("Headlamp" + wheel_side, Vector3(0.42, 0.24, 0.08), Vector3(side * 0.65, 1.03, -2.025), Color(1.0, 0.91, 0.68))
		var headlamp := get_node("Headlamp" + wheel_side) as MeshInstance3D
		var headlamp_material := _make_emissive_material(Color(0.72, 0.67, 0.48), Color(1.0, 0.87, 0.55), 0.12)
		headlamp.material_override = headlamp_material
		_headlight_materials.append(headlamp_material)
		var beam := SpotLight3D.new()
		beam.name = "HeadlightBeam" + wheel_side
		beam.position = Vector3(side * 0.65, 1.03, -2.04)
		beam.light_color = Color(1.0, 0.88, 0.66)
		beam.light_energy = 1.5
		beam.spot_range = 22.0
		beam.spot_angle = 34.0
		beam.shadow_enabled = false
		beam.visible = false
		add_child(beam)
		_headlight_spots.append(beam)
		_add_box("TailLamp" + wheel_side, Vector3(0.42, 0.22, 0.08), Vector3(side * 0.65, 1.02, 2.025), Color(0.48, 0.035, 0.025))
		_add_box("BrakeLight" + wheel_side, Vector3(0.30, 0.13, 0.055), Vector3(side * 0.65, 1.03, 2.075), Color(0.62, 0.04, 0.025))
		var brake_visual := get_node("BrakeLight" + wheel_side) as MeshInstance3D
		var brake_material := _make_emissive_material(Color(0.48, 0.025, 0.018), Color(1.0, 0.035, 0.012), 0.10)
		brake_visual.material_override = brake_material
		_brake_light_materials.append(brake_material)
		_add_box("ReverseLight" + wheel_side, Vector3(0.15, 0.10, 0.045), Vector3(side * 0.27, 1.02, 2.075), Color(0.70, 0.76, 0.78))
		var reverse_visual := get_node("ReverseLight" + wheel_side) as MeshInstance3D
		var reverse_material := _make_emissive_material(Color(0.55, 0.60, 0.62), Color(0.80, 0.91, 1.0), 0.08)
		reverse_visual.material_override = reverse_material
		_reverse_light_materials.append(reverse_material)
		_add_box("FrontIndicator" + wheel_side, Vector3(0.15, 0.12, 0.055), Vector3(side * 0.89, 1.03, -2.045), Color(0.68, 0.30, 0.04))
		var front_indicator := get_node("FrontIndicator" + wheel_side) as MeshInstance3D
		var front_indicator_material := _make_emissive_material(Color(0.55, 0.22, 0.025), Color(1.0, 0.34, 0.015), 0.08)
		front_indicator.material_override = front_indicator_material
		if side < 0.0:
			_left_indicator_materials.append(front_indicator_material)
		else:
			_right_indicator_materials.append(front_indicator_material)
		_add_box("RearIndicator" + wheel_side, Vector3(0.15, 0.12, 0.055), Vector3(side * 0.89, 1.03, 2.045), Color(0.68, 0.30, 0.04))
		var rear_indicator := get_node("RearIndicator" + wheel_side) as MeshInstance3D
		var rear_indicator_material := _make_emissive_material(Color(0.55, 0.22, 0.025), Color(1.0, 0.34, 0.015), 0.08)
		rear_indicator.material_override = rear_indicator_material
		if side < 0.0:
			_left_indicator_materials.append(rear_indicator_material)
		else:
			_right_indicator_materials.append(rear_indicator_material)
		var front_wheel := _add_wheel("FrontWheel" + wheel_side, Vector3(side * 0.99, 0.43, -1.28))
		_front_wheels.append(front_wheel)
		var rear_wheel := _add_wheel("RearWheel" + wheel_side, Vector3(side * 0.99, 0.43, 1.28))
		_rear_wheels.append(rear_wheel)
	_add_box("FrontBumperTrim", Vector3(1.38, 0.045, 0.045), Vector3(0.0, 0.43, -2.12), Color(0.55, 0.58, 0.54))
	_add_box("RearBumperTrim", Vector3(1.38, 0.045, 0.045), Vector3(0.0, 0.43, 2.12), Color(0.55, 0.58, 0.54))
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.88, 1.35, 3.98)
	var collision := CollisionShape3D.new()
	collision.name = "VehicleCollision"
	collision.shape = shape
	collision.position.y = 0.91
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

func _add_box_rotated(node_name: String, dimensions: Vector3, local_position: Vector3, local_rotation: Vector3, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	visual.position = local_position
	visual.rotation = local_rotation
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.28
	material.metallic = 0.08
	visual.material_override = material
	add_child(visual)

func _add_wheel(node_name: String, local_position: Vector3) -> Node3D:
	var wheel_root := Node3D.new()
	wheel_root.name = node_name
	wheel_root.position = local_position
	add_child(wheel_root)
	var tyre := MeshInstance3D.new()
	tyre.name = "Tyre"
	var tyre_mesh := CylinderMesh.new()
	tyre_mesh.top_radius = 0.43
	tyre_mesh.bottom_radius = 0.43
	tyre_mesh.height = 0.30
	tyre_mesh.radial_segments = 20
	tyre.mesh = tyre_mesh
	tyre.rotation.z = PI * 0.5
	var tyre_material := StandardMaterial3D.new()
	tyre_material.albedo_color = Color(0.045, 0.052, 0.05)
	tyre_material.roughness = 0.98
	tyre.material_override = tyre_material
	wheel_root.add_child(tyre)
	var rim := MeshInstance3D.new()
	rim.name = "AlloyRim"
	var rim_mesh := CylinderMesh.new()
	rim_mesh.top_radius = 0.275
	rim_mesh.bottom_radius = 0.275
	rim_mesh.height = 0.315
	rim_mesh.radial_segments = 16
	rim.mesh = rim_mesh
	rim.rotation.z = PI * 0.5
	var rim_material := StandardMaterial3D.new()
	rim_material.albedo_color = Color(0.48, 0.52, 0.51)
	rim_material.metallic = 0.72
	rim_material.roughness = 0.32
	rim.material_override = rim_material
	wheel_root.add_child(rim)
	var hub := MeshInstance3D.new()
	hub.name = "WheelHub"
	var hub_mesh := SphereMesh.new()
	hub_mesh.radius = 0.105
	hub_mesh.height = 0.21
	hub.mesh = hub_mesh
	hub.scale = Vector3(1.0, 0.72, 1.0)
	var hub_material := StandardMaterial3D.new()
	hub_material.albedo_color = Color(0.76, 0.78, 0.73)
	hub_material.metallic = 0.8
	hub.material_override = hub_material
	wheel_root.add_child(hub)
	return wheel_root

func _update_wheel_visuals(steering_input: float, delta: float) -> void:
	var target_steer := -clampf(steering_input, -1.0, 1.0) * MAX_FRONT_STEER_ANGLE
	if absf(_speed) <= 0.15:
		target_steer = 0.0
	_visual_steer_angle = move_toward(_visual_steer_angle, target_steer, WHEEL_STEER_RESPONSE * delta)
	if is_instance_valid(_steering_wheel_pivot):
		var steering_wheel_angle := _visual_steer_angle * STEERING_WHEEL_RATIO
		_steering_wheel_pivot.basis = Basis(Vector3.RIGHT, PI * 0.5) * Basis(Vector3.UP, steering_wheel_angle)
	_wheel_roll_angle = wrapf(_wheel_roll_angle + (_speed / WHEEL_RADIUS) * delta, -PI, PI)
	for wheel in _front_wheels:
		if is_instance_valid(wheel):
			wheel.rotation = Vector3(_wheel_roll_angle, _visual_steer_angle, 0.0)
	for wheel in _rear_wheels:
		if is_instance_valid(wheel):
			wheel.rotation = Vector3(_wheel_roll_angle, 0.0, 0.0)

func _build_vehicle_interior() -> void:
	# Dark, low-cost interior pieces remain visible through the tinted glazing.
	var seat_color := Color(0.075, 0.095, 0.085)
	var seat_trim := Color(0.13, 0.16, 0.14)
	var dashboard_color := Color(0.055, 0.075, 0.072)
	var metal_trim := Color(0.34, 0.39, 0.36)
	_add_box("Dashboard", Vector3(1.42, 0.26, 0.34), Vector3(0.0, 1.38, -0.76), dashboard_color)
	_add_box("DashboardTop", Vector3(1.48, 0.07, 0.38), Vector3(0.0, 1.55, -0.77), Color(0.09, 0.12, 0.11))
	_add_box("InstrumentCluster", Vector3(0.43, 0.16, 0.10), Vector3(-0.47, 1.51, -0.57), Color(0.025, 0.045, 0.043))
	_add_box("InstrumentDisplay", Vector3(0.28, 0.075, 0.035), Vector3(-0.47, 1.52, -0.514), Color(0.12, 0.33, 0.31))
	_add_box("GloveBox", Vector3(0.54, 0.16, 0.08), Vector3(0.43, 1.29, -0.57), seat_trim)
	_add_box("CenterConsole", Vector3(0.30, 0.18, 0.82), Vector3(0.0, 1.12, -0.02), dashboard_color)
	_add_box("CenterConsoleTrim", Vector3(0.22, 0.035, 0.42), Vector3(0.0, 1.235, -0.10), metal_trim)
	_add_box("GearSelector", Vector3(0.08, 0.17, 0.08), Vector3(0.0, 1.34, 0.04), Color(0.20, 0.23, 0.21))
	_add_box("FrontSeatBaseLeft", Vector3(0.54, 0.17, 0.58), Vector3(-0.43, 1.00, -0.12), seat_color)
	_add_box("FrontSeatBackLeft", Vector3(0.54, 0.72, 0.18), Vector3(-0.43, 1.40, 0.12), seat_color)
	_add_box("FrontSeatHeadrestLeft", Vector3(0.34, 0.24, 0.16), Vector3(-0.43, 1.88, 0.18), seat_trim)
	_add_box("FrontSeatBaseRight", Vector3(0.54, 0.17, 0.58), Vector3(0.43, 1.00, -0.12), seat_color)
	_add_box("FrontSeatBackRight", Vector3(0.54, 0.72, 0.18), Vector3(0.43, 1.40, 0.12), seat_color)
	_add_box("FrontSeatHeadrestRight", Vector3(0.34, 0.24, 0.16), Vector3(0.43, 1.88, 0.18), seat_trim)
	_add_box("RearSeatBase", Vector3(1.24, 0.17, 0.48), Vector3(0.0, 1.00, 0.76), seat_color)
	_add_box("RearSeatBack", Vector3(1.24, 0.64, 0.17), Vector3(0.0, 1.36, 0.98), seat_color)
	_add_box("InteriorDoorLeft", Vector3(0.10, 0.40, 0.94), Vector3(-0.75, 1.08, 0.12), seat_trim)
	_add_box("InteriorDoorRight", Vector3(0.10, 0.40, 0.94), Vector3(0.75, 1.08, 0.12), seat_trim)
	_add_box("InteriorArmrestLeft", Vector3(0.12, 0.08, 0.52), Vector3(-0.70, 1.24, 0.10), metal_trim)
	_add_box("InteriorArmrestRight", Vector3(0.12, 0.08, 0.52), Vector3(0.70, 1.24, 0.10), metal_trim)
	var steering_column := MeshInstance3D.new()
	steering_column.name = "SteeringColumn"
	var column_mesh := CylinderMesh.new()
	column_mesh.top_radius = 0.045
	column_mesh.bottom_radius = 0.055
	column_mesh.height = 0.40
	steering_column.mesh = column_mesh
	steering_column.position = Vector3(-0.48, 1.43, -0.42)
	steering_column.rotation.x = PI * 0.5
	var column_material := StandardMaterial3D.new()
	column_material.albedo_color = Color(0.10, 0.12, 0.11)
	column_material.metallic = 0.28
	steering_column.material_override = column_material
	add_child(steering_column)
	_steering_wheel_pivot = Node3D.new()
	_steering_wheel_pivot.name = "SteeringWheelPivot"
	_steering_wheel_pivot.position = Vector3(-0.48, 1.57, -0.53)
	_steering_wheel_pivot.basis = Basis(Vector3.RIGHT, PI * 0.5)
	add_child(_steering_wheel_pivot)
	var steering_wheel := MeshInstance3D.new()
	steering_wheel.name = "SteeringWheel"
	var wheel_mesh := TorusMesh.new()
	wheel_mesh.inner_radius = 0.245
	wheel_mesh.outer_radius = 0.285
	wheel_mesh.rings = 28
	wheel_mesh.ring_segments = 8
	steering_wheel.mesh = wheel_mesh
	var wheel_material := StandardMaterial3D.new()
	wheel_material.albedo_color = Color(0.045, 0.055, 0.05)
	wheel_material.roughness = 0.46
	wheel_material.metallic = 0.14
	steering_wheel.material_override = wheel_material
	_steering_wheel_pivot.add_child(steering_wheel)
	_add_box("SteeringWheelHub", Vector3(0.12, 0.12, 0.08), Vector3(-0.48, 1.57, -0.55), metal_trim)
	_add_box("FrontWiperLeft", Vector3(0.68, 0.035, 0.035), Vector3(-0.36, 1.36, -0.92), Color(0.035, 0.045, 0.042))
	_add_box("FrontWiperRight", Vector3(0.68, 0.035, 0.035), Vector3(0.36, 1.36, -0.92), Color(0.035, 0.045, 0.042))

func _make_emissive_material(base_color: Color, glow_color: Color, idle_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = base_color
	material.roughness = 0.38
	material.emission_enabled = true
	material.emission = glow_color
	material.emission_energy_multiplier = idle_energy
	return material

func _set_material_emission(materials: Array[StandardMaterial3D], energy: float) -> void:
	for material in materials:
		if is_instance_valid(material):
			material.emission_energy_multiplier = energy

func _set_headlights_enabled(enabled: bool) -> void:
	for beam in _headlight_spots:
		if is_instance_valid(beam):
			beam.visible = enabled
	_set_material_emission(_headlight_materials, 2.2 if enabled else 0.12)

func _update_vehicle_lighting(input_vector: Vector2, delta: float) -> void:
	var game_hour := 12.0
	var clocks := get_tree().get_nodes_in_group("world_clock")
	if not clocks.is_empty() and is_instance_valid(clocks[0]) and clocks[0].has_method("get_game_hour"):
		game_hour = float(clocks[0].call("get_game_hour"))
	var storm_active := false
	var weather_nodes := get_tree().get_nodes_in_group("world_weather")
	if not weather_nodes.is_empty() and is_instance_valid(weather_nodes[0]) and weather_nodes[0].has_method("get_weather"):
		storm_active = str(weather_nodes[0].call("get_weather")) == "storm"
	var night_active := game_hour >= 18.5 or game_hour < 6.0
	_set_headlights_enabled(night_active or storm_active)
	var occupied := driver != null and is_instance_valid(driver)
	var braking := occupied and Input.is_action_pressed("vehicle_brake")
	var reversing := occupied and input_vector.y > 0.25
	_set_material_emission(_brake_light_materials, 2.8 if braking else 0.10)
	_set_material_emission(_reverse_light_materials, 1.8 if reversing else 0.08)
	_turn_signal_clock += delta
	var wants_signal := occupied and absf(input_vector.x) > 0.18 and absf(_speed) > 0.15
	var signal_on := wants_signal and fposmod(_turn_signal_clock, 0.9) < 0.45
	var left_signal_on := signal_on and input_vector.x < -0.18
	var right_signal_on := signal_on and input_vector.x > 0.18
	_set_material_emission(_left_indicator_materials, 2.0 if left_signal_on else 0.08)
	_set_material_emission(_right_indicator_materials, 2.0 if right_signal_on else 0.08)

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
