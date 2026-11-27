extends CharacterBody3D

@export var move_speed: float = 5.0
@export_range(1.0, 2.5, 0.05) var sprint_multiplier: float = 1.6
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var turn_speed: float = 12.0
@export var jump_velocity: float = 6.2
@export var sprint_multiplier: float = 1.45

var is_driving := false
var _jump_was_pressed := false

@onready var camera_pivot: Node3D = $CameraPivot
@onready var player_camera: Camera3D = get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D

func _ready() -> void:
	for action in ["jump", "attack", "sprint"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)

func _physics_process(delta: float) -> void:
	if is_driving:
		velocity = Vector3.ZERO
		_jump_was_pressed = false
		return
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var movement_basis: Basis = player_camera.global_basis if is_instance_valid(player_camera) else camera_pivot.global_basis
	var camera_right: Vector3 = movement_basis.x
	var camera_forward: Vector3 = -movement_basis.z
	camera_right.y = 0.0
	camera_forward.y = 0.0
	camera_right = camera_right.normalized()
	camera_forward = camera_forward.normalized()
	var move_direction: Vector3 = camera_right * input_vector.x + camera_forward * -input_vector.y
	if move_direction.length_squared() > 1.0:
		move_direction = move_direction.normalized()
	var effective_move_speed := move_speed
	if InputMap.has_action("sprint") and Input.is_action_pressed("sprint"):
		effective_move_speed *= maxf(1.0, sprint_multiplier)
	var needs := get_node_or_null("PlayerNeeds")
	if needs != null and needs.has_method("get_movement_multiplier"):
		effective_move_speed *= clampf(float(needs.call("get_movement_multiplier")), 0.4, 1.0)
	if Input.is_action_pressed("sprint"):
		effective_move_speed *= maxf(1.0, sprint_multiplier)
	velocity.x = move_toward(velocity.x, move_direction.x * effective_move_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, move_direction.z * effective_move_speed, acceleration * delta)
	var jump_is_pressed := Input.is_action_pressed("jump")
	var jump_started := Input.is_action_just_pressed("jump") or (jump_is_pressed and not _jump_was_pressed)
	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
		if jump_started:
			velocity.y = jump_velocity
	else:
		velocity.y -= gravity * delta
	_jump_was_pressed = jump_is_pressed
	if move_direction.length_squared() > 0.001:
		var target_angle: float = atan2(-move_direction.x, -move_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, clampf(turn_speed * delta, 0.0, 1.0))
	move_and_slide()
