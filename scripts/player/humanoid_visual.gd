extends Node3D

## Lightweight original humanoid visual for Android. The parent Player remains
## responsible for collision, movement and camera; this script only renders body parts.
@export var skin_tone := Color(0.68, 0.47, 0.34)
@export var shirt_color := Color(0.93, 0.91, 0.83)
@export var pants_color := Color(0.12, 0.25, 0.62)
@export var shoe_color := Color(0.045, 0.052, 0.06)
@export var hair_color := Color(0.055, 0.045, 0.04)

var _left_arm: Node3D
var _right_arm: Node3D
var _left_leg: Node3D
var _right_leg: Node3D
var _locomotion_weight := 0.0
var _animation_time := 0.0


func _ready() -> void:
	_build_humanoid()
	_left_arm = get_node("LeftArm") as Node3D
	_right_arm = get_node("RightArm") as Node3D
	_left_leg = get_node("LeftLeg") as Node3D
	_right_leg = get_node("RightLeg") as Node3D


func _process(delta: float) -> void:
	var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var target_weight := clampf(movement.length(), 0.0, 1.0)
	_locomotion_weight = move_toward(_locomotion_weight, target_weight, delta * 6.0)
	_animation_time += delta
	var swing := sin(_animation_time * 8.5) * 0.48 * _locomotion_weight
	var breathing := sin(_animation_time * 2.2) * 0.012 * (1.0 - _locomotion_weight)
	_left_leg.rotation.x = swing
	_right_leg.rotation.x = -swing
	_left_arm.rotation.x = -swing * 0.78
	_right_arm.rotation.x = swing * 0.78
	rotation.z = lerpf(rotation.z, -movement.x * 0.035 * _locomotion_weight,
		clampf(delta * 7.0, 0.0, 1.0))
	position.y = breathing


func get_locomotion_weight() -> float:
	return _locomotion_weight


func _build_humanoid() -> void:
	var skin := _make_material(skin_tone, 0.92)
	var shirt := _make_material(shirt_color, 0.94)
	var pants := _make_material(pants_color, 0.94)
	var shoes := _make_material(shoe_color, 0.96)
	var hair := _make_material(hair_color, 0.88)
	var eye_material := _make_material(Color(0.055, 0.04, 0.035), 0.72)

	_add_capsule(self, "Head", 0.175, 0.36, Vector3(0.0, 1.62, 0.0), skin)
	_add_sphere(self, "Hair", Vector3(0.0, 1.81, 0.015),
		Vector3(0.185, 0.105, 0.19), hair)
	_add_sphere(self, "LeftEye", Vector3(-0.062, 1.65, -0.157),
		Vector3(0.018, 0.022, 0.012), eye_material)
	_add_sphere(self, "RightEye", Vector3(0.062, 1.65, -0.157),
		Vector3(0.018, 0.022, 0.012), eye_material)
	_add_sphere(self, "Nose", Vector3(0.0, 1.60, -0.18),
		Vector3(0.027, 0.038, 0.035), skin)

	var torso := Node3D.new()
	torso.name = "Torso"
	add_child(torso)
	_add_capsule(torso, "Shirt", 0.245, 0.82, Vector3(0.0, 1.13, 0.0), shirt)
	_add_capsule(torso, "Neck", 0.075, 0.16, Vector3(0.0, 1.58, 0.0), skin)

	_left_arm = _create_arm("LeftArm", -0.285, skin)
	_right_arm = _create_arm("RightArm", 0.285, skin)
	_left_leg = _create_leg("LeftLeg", -0.125, pants, shoes)
	_right_leg = _create_leg("RightLeg", 0.125, pants, shoes)


func _create_arm(node_name: String, x_offset: float, skin: StandardMaterial3D) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = node_name
	pivot.position = Vector3(x_offset, 1.36, 0.0)
	add_child(pivot)
	_add_capsule(pivot, "UpperArm", 0.075, 0.48, Vector3(0.0, -0.25, 0.0), skin)
	_add_sphere(pivot, "Hand", Vector3(0.0, -0.52, -0.015),
		Vector3(0.075, 0.085, 0.065), skin)
	return pivot


func _create_leg(node_name: String, x_offset: float, pants: StandardMaterial3D,
		shoes: StandardMaterial3D) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = node_name
	pivot.position = Vector3(x_offset, 0.78, 0.0)
	add_child(pivot)
	_add_capsule(pivot, "Pants", 0.105, 0.74, Vector3(0.0, -0.34, 0.0), pants)
	var shoe := BoxMesh.new()
	shoe.size = Vector3(0.19, 0.12, 0.34)
	var shoe_instance := MeshInstance3D.new()
	shoe_instance.name = "Shoe"
	shoe_instance.mesh = shoe
	shoe_instance.position = Vector3(0.0, -0.75, -0.055)
	shoe_instance.material_override = shoes
	pivot.add_child(shoe_instance)
	return pivot


func _add_capsule(parent: Node3D, node_name: String, radius: float, height: float,
		at: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = at
	instance.material_override = material
	parent.add_child(instance)
	return instance


func _add_sphere(parent: Node3D, node_name: String, at: Vector3,
		shape_scale: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.1
	mesh.height = 0.2
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = at
	instance.scale = shape_scale / 0.1
	instance.material_override = material
	parent.add_child(instance)
	return instance


func _make_material(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material
