extends Node3D

@export var travel_speed := 3.2
@export var paint_color := Color(0.18, 0.34, 0.58)

var _wheel_nodes: Array[MeshInstance3D] = []

var _route_start := Vector3.ZERO
var _route_end := Vector3.ZERO
var _lane_offset := Vector3.ZERO
var _route_length := 1.0
var _travel_phase := 0.0
var _configured := false


func configure(route_start: Vector3, route_end: Vector3, speed: float,
		lane_offset: Vector3, start_distance: float, reverse: bool) -> void:
	_route_start = route_start
	_route_end = route_end
	_lane_offset = lane_offset
	travel_speed = maxf(0.1, speed)
	_route_length = maxf(0.1, _route_start.distance_to(_route_end))
	var distance := clampf(start_distance, 0.0, _route_length)
	_travel_phase = distance if not reverse else _route_length * 2.0 - distance
	_configured = true


func _ready() -> void:
	add_to_group("vehicles")
	add_to_group("ambient_traffic_vehicles")
	_build_car_visuals()
	_update_route_position()


func _process(delta: float) -> void:
	if not _configured:
		return
	_travel_phase = fposmod(_travel_phase + travel_speed * delta, _route_length * 2.0)
	_update_route_position()
	_update_wheels(delta)


func get_speed() -> float:
	return travel_speed


func get_route_progress() -> float:
	return _travel_phase


func _update_route_position() -> void:
	var forward := (_route_end - _route_start).normalized()
	var distance_along: float
	var direction := forward
	if _travel_phase <= _route_length:
		distance_along = _travel_phase
	else:
		distance_along = _route_length * 2.0 - _travel_phase
		direction = -forward
	global_position = _route_start.lerp(_route_end, distance_along / _route_length) + _lane_offset
	if direction.length_squared() > 0.001:
		look_at(global_position + direction, Vector3.UP)


func _build_car_visuals() -> void:
	var paint := _material(paint_color, 0.56, 0.24)
	var glass := _material(Color(0.20, 0.42, 0.52), 0.28, 0.08)
	var trim := _material(Color(0.11, 0.13, 0.14), 0.78)
	var tire := _material(Color(0.035, 0.04, 0.045), 0.98)
	var lamp := _material(Color(0.98, 0.84, 0.58), 0.35, 0.05)
	var tail := _material(Color(0.76, 0.08, 0.055), 0.45, 0.08)

	var body := MeshInstance3D.new()
	body.name = "Body"
	var chassis := BoxMesh.new()
	chassis.size = Vector3(1.62, 0.48, 3.05)
	body.mesh = chassis
	body.position.y = 0.56
	body.material_override = paint
	add_child(body)

	var hood := MeshInstance3D.new()
	hood.name = "Hood"
	var hood_mesh := BoxMesh.new()
	hood_mesh.size = Vector3(1.48, 0.16, 0.88)
	hood.mesh = hood_mesh
	hood.position = Vector3(0.0, 0.79, -1.02)
	hood.material_override = paint
	add_child(hood)

	var roof := MeshInstance3D.new()
	roof.name = "Roof"
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(1.32, 0.14, 1.42)
	roof.mesh = roof_mesh
	roof.position = Vector3(0.0, 1.18, 0.08)
	roof.material_override = paint
	add_child(roof)

	var windows := Node3D.new()
	windows.name = "Windows"
	add_child(windows)
	_add_glass(windows, "Windshield", Vector3(0.0, 0.96, -0.77),
		Vector3(1.36, 0.48, 0.09), glass, Vector3(-0.20, 0.0, 0.0))
	_add_glass(windows, "RearWindow", Vector3(0.0, 0.96, 0.91),
		Vector3(1.30, 0.42, 0.09), glass, Vector3(0.19, 0.0, 0.0))
	_add_glass(windows, "LeftSideWindow", Vector3(-0.69, 0.98, 0.09),
		Vector3(0.08, 0.42, 1.28), glass, Vector3.ZERO)
	_add_glass(windows, "RightSideWindow", Vector3(0.69, 0.98, 0.09),
		Vector3(0.08, 0.42, 1.28), glass, Vector3.ZERO)

	for side in [-1.0, 1.0]:
		for axle_z in [-1.0, 1.0]:
			var wheel := MeshInstance3D.new()
			wheel.name = "Wheel_%s_%s" % [str(side), str(axle_z)]
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.32
			wheel_mesh.bottom_radius = 0.32
			wheel_mesh.height = 0.18
			wheel_mesh.radial_segments = 12
			wheel.mesh = wheel_mesh
			wheel.rotation.z = PI * 0.5
			wheel.position = Vector3(side * 0.82, 0.34, axle_z * 1.0)
			wheel.material_override = tire
			add_child(wheel)
			_wheel_nodes.append(wheel)

			var hub := MeshInstance3D.new()
			hub.name = "WheelHub_%d_%d" % [int(side), int(axle_z)]
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = 0.145
			hub_mesh.bottom_radius = 0.145
			hub_mesh.height = 0.035
			hub_mesh.radial_segments = 10
			hub.mesh = hub_mesh
			hub.rotation.z = PI * 0.5
			hub.position = Vector3(side * 0.925, 0.34, axle_z * 1.0)
			hub.material_override = trim
			add_child(hub)

		var headlight := MeshInstance3D.new()
		headlight.name = "Headlight_%s" % str(side)
		var lamp_mesh := SphereMesh.new()
		lamp_mesh.radius = 0.095
		headlight.mesh = lamp_mesh
		headlight.position = Vector3(side * 0.56, 0.68, -1.54)
		headlight.material_override = lamp
		add_child(headlight)

		var tail_light := MeshInstance3D.new()
		tail_light.name = "TailLight_%s" % str(side)
		var tail_mesh := BoxMesh.new()
		tail_mesh.size = Vector3(0.20, 0.14, 0.06)
		tail_light.mesh = tail_mesh
		tail_light.position = Vector3(side * 0.57, 0.69, 1.54)
		tail_light.material_override = tail
		add_child(tail_light)

	# Brand-neutral details give the traffic cars clearer late-2000s compact-sedan shapes.
	for side in [-1.0, 1.0]:
		var side_trim := MeshInstance3D.new()
		side_trim.name = "DoorSeam_%s" % str(side)
		var seam_mesh := BoxMesh.new()
		seam_mesh.size = Vector3(0.035, 0.28, 1.0)
		side_trim.mesh = seam_mesh
		side_trim.position = Vector3(side * 0.816, 0.60, 0.10)
		side_trim.material_override = trim
		add_child(side_trim)

		var door_handle := MeshInstance3D.new()
		door_handle.name = "DoorHandle_%d" % int(side)
		var handle_mesh := BoxMesh.new()
		handle_mesh.size = Vector3(0.035, 0.055, 0.24)
		door_handle.mesh = handle_mesh
		door_handle.position = Vector3(side * 0.835, 0.77, 0.14)
		door_handle.material_override = trim
		add_child(door_handle)

		var mirror := MeshInstance3D.new()
		mirror.name = "SideMirror_%s" % str(side)
		var mirror_mesh := BoxMesh.new()
		mirror_mesh.size = Vector3(0.18, 0.11, 0.18)
		mirror.mesh = mirror_mesh
		mirror.position = Vector3(side * 0.88, 1.01, -0.67)
		mirror.material_override = paint
		add_child(mirror)

	var grille := MeshInstance3D.new()
	grille.name = "FrontGrille"
	var grille_mesh := BoxMesh.new()
	grille_mesh.size = Vector3(0.58, 0.18, 0.055)
	grille.mesh = grille_mesh
	grille.position = Vector3(0.0, 0.61, -1.56)
	grille.material_override = trim
	add_child(grille)

	var front_plate := MeshInstance3D.new()
	front_plate.name = "FrontPlate"
	var plate_mesh := BoxMesh.new()
	plate_mesh.size = Vector3(0.40, 0.12, 0.035)
	front_plate.mesh = plate_mesh
	front_plate.position = Vector3(0.0, 0.43, -1.57)
	front_plate.material_override = _material(Color(0.82, 0.82, 0.76), 0.92)
	add_child(front_plate)

	var rear_plate := MeshInstance3D.new()
	rear_plate.name = "RearPlate"
	rear_plate.mesh = plate_mesh
	rear_plate.position = Vector3(0.0, 0.43, 1.57)
	rear_plate.material_override = _material(Color(0.82, 0.82, 0.76), 0.92)
	add_child(rear_plate)

	var bumper := MeshInstance3D.new()
	bumper.name = "Bumper"
	var bumper_mesh := BoxMesh.new()
	bumper_mesh.size = Vector3(1.68, 0.12, 0.10)
	bumper.mesh = bumper_mesh
	bumper.position = Vector3(0.0, 0.40, 1.56)
	bumper.material_override = trim
	add_child(bumper)


func _add_glass(parent: Node3D, node_name: String, at: Vector3, dimensions: Vector3,
		material: StandardMaterial3D, tilt: Vector3) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	visual.position = at
	visual.rotation = tilt
	visual.material_override = material
	parent.add_child(visual)


func _update_wheels(delta: float) -> void:
	var rotation_step := -travel_speed * delta / 0.32
	for wheel in _wheel_nodes:
		if is_instance_valid(wheel):
			wheel.rotate_object_local(Vector3.RIGHT, rotation_step)


func _material(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	return material
