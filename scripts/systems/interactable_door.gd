extends Node3D

## Reusable hinged gate/door. The parent can be placed at the hinge point.
## Its Area3D is registered with the shared player interaction router.

signal state_changed(is_open: bool)

@export var panel_size := Vector3(0.14, 1.15, 2.25)
@export var swing_angle_degrees := 92.0
@export var animation_seconds := 0.32

var is_open := false
var _pivot: Node3D
var _tween: Tween


func _ready() -> void:
	_build_panel()
	_build_interaction_area()


func interact() -> void:
	is_open = not is_open
	if _tween != null and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_IN_OUT)
	var target_angle := deg_to_rad(-swing_angle_degrees if is_open else 0.0)
	_tween.tween_property(_pivot, "rotation:y", target_angle, animation_seconds)
	state_changed.emit(is_open)


func _build_panel() -> void:
	_pivot = Node3D.new()
	_pivot.name = "HingePivot"
	add_child(_pivot)

	var body := AnimatableBody3D.new()
	body.name = "GateBody"
	_pivot.add_child(body)

	var mesh := BoxMesh.new()
	mesh.size = panel_size
	var visual := MeshInstance3D.new()
	visual.name = "WoodenGate"
	visual.mesh = mesh
	visual.position = Vector3(0.0, panel_size.y * 0.5, panel_size.z * 0.5)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.43, 0.27, 0.16)
	material.roughness = 0.96
	visual.material_override = material
	body.add_child(visual)

	var shape := BoxShape3D.new()
	shape.size = panel_size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = visual.position
	body.add_child(collision)

	var handle_mesh := SphereMesh.new()
	handle_mesh.radius = 0.07
	handle_mesh.height = 0.14
	var handle := MeshInstance3D.new()
	handle.name = "GateHandle"
	handle.mesh = handle_mesh
	handle.position = Vector3(0.0, panel_size.y * 0.55, panel_size.z * 0.12)
	var handle_material := StandardMaterial3D.new()
	handle_material.albedo_color = Color(0.82, 0.67, 0.34)
	handle_material.metallic = 0.35
	handle.material_override = handle_material
	body.add_child(handle)


func _build_interaction_area() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 2
	area.collision_mask = 0
	area.add_to_group("interaction_areas")
	add_child(area)

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.6
	collision.shape = sphere
	collision.position = Vector3(0.0, 0.9, panel_size.z * 0.5)
	area.add_child(collision)
