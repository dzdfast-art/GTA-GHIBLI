extends CharacterBody3D

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var turn_speed: float = 12.0

var is_driving := false

@onready var camera_pivot: Node3D = $CameraPivot


func _ready() -> void:
	if not InputMap.has_action("sprint"):
		InputMap.add_action("sprint")
	var has_shift_binding := false
	for event in InputMap.action_get_events("sprint"):
		if event is InputEventKey and event.physical_keycode == KEY_SHIFT:
			has_shift_binding = true
			break
	if not has_shift_binding:
		var shift_event := InputEventKey.new()
		shift_event.physical_keycode = KEY_SHIFT
		InputMap.action_add_event("sprint", shift_event)


func _physics_process(delta: float) -> void:
	if is_driving:
		velocity = Vector3.ZERO
		return
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var camera_right: Vector3 = camera_pivot.global_basis.x
	var camera_forward: Vector3 = -camera_pivot.global_basis.z
	camera_right.y = 0.0
	camera_forward.y = 0.0
	camera_right = camera_right.normalized()
	camera_forward = camera_forward.normalized()
	var move_direction: Vector3 = camera_right * input_vector.x + camera_forward * -input_vector.y
	if move_direction.length_squared() > 1.0:
		move_direction = move_direction.normalized()
	var effective_move_speed := move_speed
	if Input.is_action_pressed("sprint") and input_vector.length_squared() > 0.05:
		effective_move_speed *= 1.45
	var needs := get_node_or_null("PlayerNeeds")
	if needs != null and needs.has_method("get_movement_multiplier"):
		effective_move_speed *= clampf(float(needs.call("get_movement_multiplier")), 0.4, 1.0)
	velocity.x = move_toward(velocity.x, move_direction.x * effective_move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_direction.z * effective_move_speed, acceleration * delta)
	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta
	if move_direction.length_squared() > 0.001:
		var target_angle: float = atan2(-move_direction.x, -move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, clampf(turn_speed * delta, 0.0, 1.0))
	move_and_slide()
