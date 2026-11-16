extends Node3D

@export var room_title_ar := "منزل الصفصاف"
@export var room_offset := Vector3(0.0, -60.0, 0.0)

var _is_inside := false
var _saved_player_transform := Transform3D.IDENTITY
var _marker: Node3D


func _ready() -> void:
	add_to_group("building_portals")
	_build_marker()
	_build_interior()
	_build_interaction_area("ExteriorEntry", Vector3(0.0, 0.9, 0.0))
	_build_interaction_area("InteriorExit", room_offset + Vector3(0.0, 0.9, 3.1))


func _process(_delta: float) -> void:
	if _marker != null and _marker.visible:
		var pulse := 1.0 + sin(float(Time.get_ticks_msec()) * 0.004) * 0.10
		_marker.scale.y = pulse


func interact() -> void:
	var player := _find_player()
	if player == null:
		return
	if not _is_inside:
		_saved_player_transform = player.global_transform
		player.global_position = global_position + room_offset + Vector3(0.0, 1.0, 2.8)
		player.rotation.y = 0.0
		_is_inside = true
		_marker.visible = false
	else:
		player.global_transform = _saved_player_transform
		_is_inside = false
		_marker.visible = true
	player.velocity = Vector3.ZERO


func _find_player() -> CharacterBody3D:
	for candidate in get_tree().get_nodes_in_group("player"):
		if candidate is CharacterBody3D and candidate.get("is_driving") == false:
			return candidate as CharacterBody3D
	return null


func _build_marker() -> void:
	_marker = Node3D.new()
	_marker.name = "RedHouseEntryMarker"
	_marker.position = Vector3(0.0, 0.75, 0.0)
	add_child(_marker)

	var beam := MeshInstance3D.new()
	beam.name = "RedMarkerGlow"
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.16
	mesh.bottom_radius = 0.52
	mesh.height = 1.4
	mesh.radial_segments = 20
	beam.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.13, 0.09, 0.48)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = Color(0.85, 0.06, 0.035)
	material.emission_energy_multiplier = 1.4
	beam.material_override = material
	_marker.add_child(beam)

	var beacon := OmniLight3D.new()
	beacon.name = "EntryMarkerLight"
	beacon.light_color = Color(1.0, 0.12, 0.07)
	beacon.light_energy = 0.65
	beacon.omni_range = 4.0
	_marker.add_child(beacon)


func _build_interior() -> void:
	var room := Node3D.new()
	room.name = "OriginalHouseInterior"
	room.position = room_offset
	add_child(room)

	_add_room_box(room, "RoomFloor", Vector3(0.0, 0.0, 0.0),
		Vector3(9.0, 0.24, 9.0), Color(0.48, 0.37, 0.27), true)
	_add_room_box(room, "BackWall", Vector3(0.0, 2.0, -4.38),
		Vector3(9.0, 4.0, 0.24), Color(0.79, 0.70, 0.57), true)
	_add_room_box(room, "LeftWall", Vector3(-4.38, 2.0, 0.0),
		Vector3(0.24, 4.0, 9.0), Color(0.74, 0.66, 0.53), true)
	_add_room_box(room, "RightWall", Vector3(4.38, 2.0, 0.0),
		Vector3(0.24, 4.0, 9.0), Color(0.74, 0.66, 0.53), true)
	_add_room_box(room, "FrontWallLeft", Vector3(-3.15, 2.0, 4.38),
		Vector3(2.7, 4.0, 0.24), Color(0.78, 0.68, 0.54), true)
	_add_room_box(room, "FrontWallRight", Vector3(3.15, 2.0, 4.38),
		Vector3(2.7, 4.0, 0.24), Color(0.78, 0.68, 0.54), true)

	_add_room_box(room, "Rug", Vector3(0.0, 0.14, 0.2),
		Vector3(3.5, 0.035, 2.8), Color(0.58, 0.26, 0.19), false)
	_add_room_box(room, "BedBase", Vector3(-2.2, 0.42, -2.0),
		Vector3(2.2, 0.42, 3.2), Color(0.31, 0.25, 0.22), false)
	_add_room_box(room, "BedCover", Vector3(-2.2, 0.68, -2.0),
		Vector3(2.1, 0.16, 3.1), Color(0.68, 0.61, 0.49), false)
	_add_room_box(room, "BedPillow", Vector3(-2.2, 0.82, -3.1),
		Vector3(1.4, 0.16, 0.55), Color(0.88, 0.83, 0.70), false)
	_add_room_box(room, "WoodenTable", Vector3(2.1, 0.72, -1.8),
		Vector3(1.6, 0.16, 1.2), Color(0.35, 0.22, 0.13), false)
	_add_room_box(room, "Bookshelf", Vector3(3.75, 1.45, -2.4),
		Vector3(0.28, 2.7, 1.6), Color(0.30, 0.20, 0.14), false)
	_add_room_box(room, "Window", Vector3(0.0, 2.25, -4.22),
		Vector3(2.3, 1.15, 0.04), Color(0.42, 0.68, 0.79), false)

	var title := Label3D.new()
	title.name = "InteriorRoomTitle"
	title.text = room_title_ar
	title.position = Vector3(0.0, 3.0, -4.20)
	title.font_size = 28
	title.modulate = Color(1.0, 0.88, 0.68)
	room.add_child(title)


func _add_room_box(parent: Node3D, node_name: String, local_position: Vector3,
		size: Vector3, color: Color, solid: bool) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	var box := BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.position = local_position
	mesh_instance.material_override = _room_material(color)
	parent.add_child(mesh_instance)
	if solid:
		var body := StaticBody3D.new()
		body.name = node_name + "Collision"
		body.position = local_position
		var shape := BoxShape3D.new()
		shape.size = size
		var collision := CollisionShape3D.new()
		collision.shape = shape
		body.add_child(collision)
		parent.add_child(body)


func _room_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material


func _build_interaction_area(area_name: String, local_position: Vector3) -> void:
	var area := Area3D.new()
	area.name = area_name
	area.position = local_position
	area.collision_layer = 2
	area.collision_mask = 0
	area.add_to_group("interaction_areas")
	add_child(area)

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.8
	collision.shape = sphere
	area.add_child(collision)
