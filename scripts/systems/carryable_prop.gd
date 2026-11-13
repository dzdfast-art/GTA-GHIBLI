extends RigidBody3D

## Small physics prop that can be picked up, carried in front of the player, and dropped.

@export var display_name_ar := "غرض"
@export var pickup_radius := 2.5
@export var carry_offset := Vector3(0.0, 1.25, -1.1)

var is_carried := false
var _holder: Node3D
var _original_parent: Node
var _interaction_area: Area3D


func _ready() -> void:
	_original_parent = get_parent()
	_build_visual_and_collision()
	_build_interaction_area()


func interact() -> void:
	if is_carried:
		_drop()
	else:
		_pick_up()


func _pick_up() -> void:
	var player := _find_player()
	if player == null:
		return
	_holder = player
	freeze = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0
	_interaction_area.monitoring = false
	reparent(player, true)
	position = carry_offset
	rotation = Vector3.ZERO
	is_carried = true


func _drop() -> void:
	if _holder == null or not is_instance_valid(_holder):
		return
	var drop_transform := _holder.global_transform
	drop_transform.origin += -_holder.global_basis.z * 1.35 + Vector3.UP * 0.2
	var destination := _original_parent
	if destination == null or not is_instance_valid(destination):
		destination = get_tree().current_scene
	reparent(destination, true)
	global_transform = drop_transform
	collision_layer = 1
	collision_mask = 1
	freeze = false
	linear_velocity = -_holder.global_basis.z * 1.5
	_holder = null
	is_carried = false
	_interaction_area.monitoring = true


func _find_player() -> Node3D:
	var node := get_parent()
	while node != null:
		if node is CharacterBody3D and node.name == "Player":
			return node as Node3D
		node = node.get_parent()
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		return players[0] as Node3D
	return null


func _build_visual_and_collision() -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.32
	mesh.height = 0.64
	var visual := MeshInstance3D.new()
	visual.name = "CarryableVisual"
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.82, 0.57, 0.29)
	material.roughness = 0.82
	visual.material_override = material
	add_child(visual)

	var shape := SphereShape3D.new()
	shape.radius = 0.32
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)


func _build_interaction_area() -> void:
	_interaction_area = Area3D.new()
	_interaction_area.name = "InteractionArea"
	_interaction_area.collision_layer = 2
	_interaction_area.collision_mask = 0
	_interaction_area.add_to_group("interaction_areas")
	add_child(_interaction_area)

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = pickup_radius
	collision.shape = sphere
	_interaction_area.add_child(collision)
