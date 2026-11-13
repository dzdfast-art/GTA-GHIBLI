extends CharacterBody3D

## Mobile-first third-person movement controller.
## The built-in ui_* actions are also driven by the on-screen buttons.

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var turn_speed: float = 12.0

@onready var camera_pivot: Node3D = $CameraPivot


func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	var camera_right: Vector3 = camera_pivot.global_basis.x
	var camera_forward: Vector3 = -camera_pivot.global_basis.z
	camera_right.y = 0.0
	camera_forward.y = 0.0
	camera_right = camera_right.normalized()
	camera_forward = camera_forward.normalized()

	# The camera defines what "forward" means on both desktop and touch.
	var move_direction: Vector3 = (
		camera_right * input_vector.x
		+ camera_forward * -input_vector.y
	)
	if move_direction.length_squared() > 1.0:
		move_direction = move_direction.normalized()

	velocity.x = move_toward(
		velocity.x,
		move_direction.x * move_speed,
		acceleration * delta
	)
	velocity.z = move_toward(
		velocity.z,
		move_direction.z * move_speed,
		acceleration * delta
	)

	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
	else:
		velocity.y -= gravity * delta

	if move_direction.length_squared() > 0.001:
		var target_angle: float = atan2(-move_direction.x, -move_direction.z)
		rotation.y = lerp_angle(
			rotation.y,
			target_angle,
			clampf(turn_speed * delta, 0.0, 1.0)
		)

	move_and_slide()
