extends Node3D

## Gentle idle motion for the Sapphire Coast fishing boat.
## The simplified AnimatableBody3D collider follows the visible hull.

@export_range(0.0, 0.20, 0.01) var bob_height: float = 0.05
@export_range(0.1, 3.0, 0.1) var bob_speed: float = 1.1
@export_range(0.0, 4.0, 0.1) var roll_degrees: float = 1.1

var _rest_position := Vector3.ZERO
var _rest_rotation := Vector3.ZERO
var _elapsed := 0.0

func _ready() -> void:
	_rest_position = position
	_rest_rotation = rotation
	_elapsed = float(get_instance_id() % 997) / 997.0 * TAU
	add_to_group("world_landmarks")
	set_process(true)

func _process(delta: float) -> void:
	_elapsed += delta
	position.y = _rest_position.y + sin(_elapsed * bob_speed) * bob_height
	rotation.z = _rest_rotation.z + sin(_elapsed * bob_speed * 0.75) * deg_to_rad(roll_degrees)

func get_motion_phase() -> float:
	return _elapsed

func get_bob_offset() -> float:
	return position.y - _rest_position.y
