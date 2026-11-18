extends Node3D

## Lightweight wildlife prototype: ambient roaming, flee response and simple feeding bonds.
signal wildlife_befriended(species_id: String, bond_level: int)
signal feeding_needed(species_id: String)

@export var species_id := "rabbit"
@export var species_name_ar := "أرنب"
@export var roam_radius := 8.0
@export var walk_speed := 1.0
@export var flee_speed := 3.2
@export var flee_distance := 11.0
@export var follow_distance := 7.0

var bond_level := 0
var _home_position := Vector3.ZERO
var _wander_target := Vector3.ZERO
var _player_nearby := false
var _target_timer := 0.0
var _scan_timer := 0.0
var _player: Node3D
var _rng := RandomNumberGenerator.new()
var _interaction_area: Area3D
var _body_color := Color(0.56, 0.42, 0.31)

func _ready() -> void:
	_rng.randomize()
	_home_position = global_position
	_wander_target = global_position
	_build_model()
	_build_interaction_area()

func _process(delta: float) -> void:
	_target_timer -= delta
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.35
		_find_player()
	if _player != null and is_instance_valid(_player):
		var distance := global_position.distance_to(_player.global_position)
		if bond_level >= 2 and distance <= follow_distance:
			_wander_target = _player.global_position + Vector3(1.4, 0.0, 1.4)
			_move_toward_target(delta, walk_speed * 1.15)
			return
		if distance <= flee_distance:
			var away := global_position - _player.global_position
			away.y = 0.0
			if away.length_squared() > 0.001:
				_wander_target = global_position + away.normalized() * (roam_radius + 5.0)
			_target_timer = 0.4
			_move_toward_target(delta, flee_speed)
			return
	if _target_timer <= 0.0 or global_position.distance_to(_wander_target) < 0.5:
		_target_timer = _rng.randf_range(2.0, 5.0)
		var offset := Vector3(_rng.randf_range(-roam_radius, roam_radius), 0.0,
			_rng.randf_range(-roam_radius, roam_radius))
		_wander_target = _home_position + offset
	_move_toward_target(delta, walk_speed)

func interact() -> void:
	if not _player_nearby:
		return
	var player := get_tree().get_first_node_in_group("player") as Node
	if player == null:
		return
	var inventory := player.get_node_or_null("ConsumableInventory")
	if inventory == null or not inventory.has_method("remove_item"):
		feeding_needed.emit(species_id)
		return
	var fed := bool(inventory.call("remove_item", "wild_berries", 1))
	if not fed:
		fed = bool(inventory.call("remove_item", "carrot", 1))
	if not fed:
		feeding_needed.emit(species_id)
		return
	bond_level += 1
	wildlife_befriended.emit(species_id, bond_level)

func get_wildlife_state() -> String:
	if bond_level >= 2 and _player != null:
		return "following"
	if _player != null and global_position.distance_to(_player.global_position) <= flee_distance:
		return "fleeing"
	return "wandering"

func _find_player() -> void:
	_player = null
	var candidate := get_tree().get_first_node_in_group("player") as Node3D
	if candidate == null:
		return
	if global_position.distance_to(candidate.global_position) <= flee_distance + follow_distance + 4.0:
		_player = candidate

func _move_toward_target(delta: float, speed: float) -> void:
	var direction := _wander_target - global_position
	direction.y = 0.0
	if direction.length_squared() < 0.04:
		return
	global_position += direction.normalized() * speed * delta
	var target_yaw := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, clampf(delta * 5.0, 0.0, 1.0))

func _build_model() -> void:
	match species_id:
		"deer": _build_deer()
		"gull": _build_gull()
		"dog": _build_dog()
		"cat": _build_cat()
		"chicken": _build_chicken()
		"cow": _build_cow()
		"horse": _build_horse()
		_: _build_rabbit()

func _build_dog()->void:
	_body_color=Color(0.55,0.34,0.20)
	_add_sphere("Body",Vector3(0,0.58,0),Vector3(1.05,0.62,0.54),_body_color)
	_add_sphere("Head",Vector3(0,0.94,-0.48),Vector3(0.54,0.52,0.48),Color(0.68,0.46,0.29))
	_add_sphere("Muzzle",Vector3(0,0.78,-0.82),Vector3(0.30,0.22,0.28),Color(0.85,0.72,0.57))
	for x in [-0.22,0.22]: _add_capsule("Ear",Vector3(x,1.30,-0.40),0.12,0.42,_body_color)
	for x in [-0.34,0.34]:
		for z in [-0.32,0.32]: _add_cylinder("Leg",Vector3(x,0.22,z),0.09,0.44,_body_color)

func _build_cat()->void:
	_body_color=Color(0.34,0.32,0.31)
	_add_sphere("Body",Vector3(0,0.48,0),Vector3(0.90,0.52,0.48),_body_color)
	_add_sphere("Head",Vector3(0,0.83,-0.40),Vector3(0.48,0.46,0.42),Color(0.48,0.44,0.40))
	for x in [-0.25,0.25]: _add_cylinder("Ear",Vector3(x,1.20,-0.40),0.10,0.34,_body_color)
	for x in [-0.29,0.29]:
		for z in [-0.28,0.28]: _add_cylinder("Leg",Vector3(x,0.18,z),0.07,0.36,_body_color)

func _build_chicken()->void:
	_body_color=Color(0.88,0.78,0.54)
	_add_sphere("Body",Vector3(0,0.46,0),Vector3(0.76,0.70,0.64),_body_color)
	_add_sphere("Head",Vector3(0,0.92,-0.34),Vector3(0.34,0.34,0.34),Color(0.93,0.86,0.70))
	_add_sphere("Comb",Vector3(0,1.22,-0.34),Vector3(0.20,0.15,0.12),Color(0.72,0.16,0.12))
	_add_box("Beak",Vector3(0,0.88,-0.68),Vector3(0.20,0.12,0.24),Color(0.90,0.58,0.18))
	for x in [-0.18,0.18]: _add_cylinder("Leg",Vector3(x,0.12,0.08),0.035,0.24,Color(0.85,0.52,0.22))

func _build_cow()->void:
	_body_color=Color(0.82,0.80,0.73)
	_add_sphere("Body",Vector3(0,0.90,0),Vector3(1.55,0.92,0.72),_body_color)
	_add_sphere("Head",Vector3(0,1.52,-0.58),Vector3(0.54,0.58,0.50),_body_color)
	_add_sphere("Muzzle",Vector3(0,1.28,-0.98),Vector3(0.34,0.22,0.22),Color(0.86,0.62,0.59))
	for x in [-0.52,0.52]:
		for z in [-0.44,0.44]: _add_cylinder("Leg",Vector3(x,0.36,z),0.10,0.72,Color(0.66,0.64,0.58))

func _build_horse()->void:
	_body_color=Color(0.48,0.27,0.15)
	_add_sphere("Body",Vector3(0,1.12,0),Vector3(1.55,0.82,0.64),_body_color)
	_add_sphere("Neck",Vector3(0,1.58,-0.44),Vector3(0.46,0.94,0.42),_body_color)
	_add_sphere("Head",Vector3(0,2.10,-0.72),Vector3(0.42,0.48,0.42),Color(0.58,0.34,0.22))
	for x in [-0.42,0.42]:
		for z in [-0.42,0.42]: _add_cylinder("Leg",Vector3(x,0.42,z),0.09,0.84,_body_color)
func _build_deer() -> void:
	_body_color = Color(0.48, 0.30, 0.18)
	_add_sphere("Body", Vector3(0.0, 0.95, 0.0), Vector3(1.45, 0.72, 0.58), _body_color)
	_add_sphere("Neck", Vector3(0.0, 1.38, -0.38), Vector3(0.42, 0.82, 0.40), _body_color)
	_add_sphere("Head", Vector3(0.0, 1.92, -0.62), Vector3(0.48, 0.42, 0.42), Color(0.58, 0.38, 0.24))
	for x in [-0.42, 0.42]:
		for z in [-0.42, 0.38]:
			_add_cylinder("Leg", Vector3(x, 0.36, z), 0.10, 0.82, _body_color)
	_add_cylinder("AntlerLeft", Vector3(-0.25, 2.43, -0.57), 0.035, 0.55, Color(0.74, 0.62, 0.44))
	_add_cylinder("AntlerRight", Vector3(0.25, 2.43, -0.57), 0.035, 0.55, Color(0.74, 0.62, 0.44))

func _build_rabbit() -> void:
	_body_color = Color(0.64, 0.54, 0.43)
	_add_sphere("Body", Vector3(0.0, 0.44, 0.0), Vector3(0.92, 0.62, 0.58), _body_color)
	_add_sphere("Head", Vector3(0.0, 0.76, -0.43), Vector3(0.52, 0.48, 0.46), Color(0.73, 0.62, 0.52))
	_add_capsule("EarLeft", Vector3(-0.18, 1.25, -0.42), 0.10, 0.68, Color(0.77, 0.53, 0.53))
	_add_capsule("EarRight", Vector3(0.18, 1.25, -0.42), 0.10, 0.68, Color(0.77, 0.53, 0.53))
	_add_sphere("Tail", Vector3(0.0, 0.56, 0.48), Vector3(0.22, 0.22, 0.22), Color(0.92, 0.88, 0.80))

func _build_gull() -> void:
	_body_color = Color(0.84, 0.85, 0.80)
	_add_sphere("Body", Vector3(0.0, 0.72, 0.0), Vector3(1.0, 0.54, 0.56), _body_color)
	_add_sphere("Head", Vector3(0.0, 1.02, -0.36), Vector3(0.42, 0.38, 0.40), Color(0.92, 0.92, 0.86))
	_add_box("WingLeft", Vector3(-0.70, 0.88, 0.08), Vector3(1.0, 0.10, 0.48), Color(0.42, 0.48, 0.52))
	_add_box("WingRight", Vector3(0.70, 0.88, 0.08), Vector3(1.0, 0.10, 0.48), Color(0.42, 0.48, 0.52))
	_add_box("Beak", Vector3(0.0, 0.98, -0.75), Vector3(0.16, 0.12, 0.34), Color(0.88, 0.66, 0.24))
	for x in [-0.20, 0.20]:
		_add_cylinder("Leg", Vector3(x, 0.18, 0.12), 0.035, 0.34, Color(0.84, 0.60, 0.25))

func _build_interaction_area() -> void:
	_interaction_area = Area3D.new()
	_interaction_area.name = "InteractionArea"
	_interaction_area.collision_layer = 2
	_interaction_area.collision_mask = 1
	_interaction_area.add_to_group("interaction_areas")
	add_child(_interaction_area)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.0
	shape.shape = sphere
	shape.position.y = 0.85
	_interaction_area.add_child(shape)
	_interaction_area.body_entered.connect(_on_body_entered)
	_interaction_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false

func _add_sphere(node_name: String, at: Vector3, dimensions: Vector3, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	visual.mesh = mesh
	visual.position = at
	visual.scale = dimensions
	visual.material_override = _material(tint)
	add_child(visual)

func _add_capsule(node_name: String, at: Vector3, radius: float, height: float, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	visual.mesh = mesh
	visual.position = at
	visual.material_override = _material(tint)
	add_child(visual)

func _add_cylinder(node_name: String, at: Vector3, radius: float, height: float, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.8
	mesh.bottom_radius = radius
	mesh.height = height
	visual.mesh = mesh
	visual.position = at
	visual.material_override = _material(tint)
	add_child(visual)

func _add_box(node_name: String, at: Vector3, dimensions: Vector3, tint: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	visual.position = at
	visual.material_override = _material(tint)
	add_child(visual)

func _material(tint: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.88
	return material
