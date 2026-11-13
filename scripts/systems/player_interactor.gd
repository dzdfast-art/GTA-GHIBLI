extends Node

## Routes the shared interact action to the nearest registered interaction area.
## Interactable parents implement: interact() -> void.
## Their Area3D child joins the "interaction_areas" group and uses collision layer 2.

const INTERACTION_MASK := 2
const DETECTION_RADIUS := 0.1

var _nearby_areas: Array[Area3D] = []


func _ready() -> void:
	_register_interaction_action()
	_create_detection_area()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_interact_with_nearest()


func _register_interaction_action() -> void:
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
	var has_keyboard_binding := false
	for event in InputMap.action_get_events("interact"):
		if event is InputEventKey and event.physical_keycode == KEY_E:
			has_keyboard_binding = true
			break
	if not has_keyboard_binding:
		var key_event := InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("interact", key_event)


func _create_detection_area() -> void:
	var detector := Area3D.new()
	detector.name = "InteractionDetector"
	detector.collision_layer = 0
	detector.collision_mask = INTERACTION_MASK
	detector.monitoring = true
	detector.position.y = 0.9
	add_child(detector)

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = DETECTION_RADIUS
	collision.shape = sphere
	detector.add_child(collision)

	detector.area_entered.connect(_on_interaction_area_entered)
	detector.area_exited.connect(_on_interaction_area_exited)


func _on_interaction_area_entered(area: Area3D) -> void:
	if area.is_in_group("interaction_areas") and not _nearby_areas.has(area):
		_nearby_areas.append(area)


func _on_interaction_area_exited(area: Area3D) -> void:
	_nearby_areas.erase(area)


func _interact_with_nearest() -> void:
	var target := _get_nearest_target()
	if target != null:
		try_interact(target)


func _get_nearest_target() -> Node:
	var actor := get_parent() as Node3D
	if actor == null:
		return null

	var nearest_target: Node = null
	var nearest_distance := INF
	for area in _nearby_areas:
		if not is_instance_valid(area) or not area.is_inside_tree():
			continue
		var candidate := area.get_parent()
		if candidate == null or not candidate.has_method("interact"):
			continue
		var candidate_3d := candidate as Node3D
		if candidate_3d == null:
			continue
		var distance := actor.global_position.distance_squared_to(candidate_3d.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_target = candidate
	return nearest_target


func try_interact(target: Node) -> bool:
	if not is_instance_valid(target) or not target.has_method("interact"):
		return false
	target.call("interact")
	return true
