extends StaticBody3D

## Interactive original harbor gantry crane. Shared E/interact toggles the cargo hoist.
@export var min_lift_height := 2.8
@export var max_lift_height := 8.2
@export var lift_speed := 3.8
const BOOM_UNDERSIDE_Y := 12.45
const TROLLEY_Z := 11.0
var _lift_height := 2.8
var _target_lift_height := 2.8
var _hoist: Node3D
var _cable: MeshInstance3D
var _status_label: Label3D

func _ready() -> void:
	add_to_group("harbor_equipment")
	_lift_height = min_lift_height
	_target_lift_height = min_lift_height
	_build_moving_hoist()
	_build_interaction_area()
	_build_status_label()
	_update_hoist_geometry()

func _process(delta: float) -> void:
	var next_height := move_toward(_lift_height, _target_lift_height, lift_speed * delta)
	if not is_equal_approx(next_height, _lift_height):
		_lift_height = next_height
		_update_hoist_geometry()
		_update_status_label()

func interact() -> void:
	if _target_lift_height < (min_lift_height + max_lift_height) * 0.5:
		_target_lift_height = max_lift_height
	else:
		_target_lift_height = min_lift_height
	_update_status_label()

func get_lift_height() -> float:
	return _lift_height

func get_target_lift_height() -> float:
	return _target_lift_height

func get_hoist_node() -> Node3D:
	return _hoist

func _build_moving_hoist() -> void:
	_cable = MeshInstance3D.new()
	_cable.name = "HoistCable"
	var cable_mesh := CylinderMesh.new()
	cable_mesh.top_radius = 0.045
	cable_mesh.bottom_radius = 0.045
	cable_mesh.radial_segments = 10
	_cable.mesh = cable_mesh
	_cable.material_override = _material(Color(0.12, 0.14, 0.14), 0.72, 0.62)
	add_child(_cable)
	_hoist = Node3D.new()
	_hoist.name = "MovingHoist"
	_hoist.position = Vector3(0.0, _lift_height, TROLLEY_Z)
	add_child(_hoist)
	var spreader := MeshInstance3D.new()
	spreader.name = "ContainerSpreader"
	var spreader_mesh := BoxMesh.new()
	spreader_mesh.size = Vector3(5.25, 0.20, 2.65)
	spreader.mesh = spreader_mesh
	spreader.position.y = -0.10
	spreader.material_override = _material(Color(0.88, 0.64, 0.16), 0.68, 0.45)
	_hoist.add_child(spreader)
	var container := MeshInstance3D.new()
	container.name = "SuspendedCargoContainer"
	var container_mesh := BoxMesh.new()
	container_mesh.size = Vector3(4.8, 2.35, 2.35)
	container.mesh = container_mesh
	container.position.y = -1.36
	container.material_override = _material(Color(0.48, 0.22, 0.16), 0.18, 0.78)
	_hoist.add_child(container)
	for index in range(19):
		var x := -2.22 + float(index) * 0.247
		_add_container_rib(container, "FrontRib_%02d" % index, Vector3(x, 0.0, 1.19))
		_add_container_rib(container, "RearRib_%02d" % index, Vector3(x, 0.0, -1.19))
	for index in range(4):
		var z := -0.86 + float(index) * 0.57
		_add_container_rib(container, "LeftDoorRib_%02d" % index, Vector3(-2.43, 0.0, z))
		_add_container_rib(container, "RightDoorRib_%02d" % index, Vector3(2.43, 0.0, z))

func _add_container_rib(parent: Node3D, node_name: String, at: Vector3) -> void:
	var rib := MeshInstance3D.new()
	rib.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.055, 2.22, 0.055)
	rib.mesh = mesh
	rib.position = at
	rib.material_override = _material(Color(0.26, 0.15, 0.12), 0.12, 0.82)
	parent.add_child(rib)

func _build_interaction_area() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 2
	area.collision_mask = 0
	area.position = Vector3(5.2, 1.35, -3.5)
	area.add_to_group("interaction_areas")
	add_child(area)
	var shape := SphereShape3D.new()
	shape.radius = 2.7
	var collision := CollisionShape3D.new()
	collision.name = "ControlInteractionRange"
	collision.shape = shape
	area.add_child(collision)

func _build_status_label() -> void:
	_status_label = Label3D.new()
	_status_label.name = "CraneStatus"
	_status_label.text = "رافعة الميناء\nاضغط للتشغيل"
	_status_label.position = Vector3(5.3, 8.1, -3.5)
	_status_label.font_size = 30
	_status_label.outline_size = 7
	_status_label.modulate = Color(1.0, 0.88, 0.52)
	add_child(_status_label)

func _update_hoist_geometry() -> void:
	if _hoist == null or _cable == null:
		return
	_hoist.position.y = _lift_height
	var cable_mesh := _cable.mesh as CylinderMesh
	var cable_length := maxf(0.35, BOOM_UNDERSIDE_Y - _lift_height - 0.10)
	cable_mesh.height = cable_length
	_cable.position = Vector3(0.0, _lift_height + 0.10 + cable_length * 0.5, TROLLEY_Z)

func _update_status_label() -> void:
	if _status_label == null:
		return
	if is_equal_approx(_lift_height, _target_lift_height):
		_status_label.text = "رافعة الميناء\n" + ("الحاوية مرفوعة" if _lift_height > (min_lift_height + max_lift_height) * 0.5 else "الحاوية منخفضة")
	else:
		_status_label.text = "رافعة الميناء\n" + ("جارٍ الرفع" if _target_lift_height > _lift_height else "جارٍ الخفض")

func _material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material
