extends Node3D

## Procedural walk/idle motion for the lightweight reference character blockout.
## Keeps the scene dependency-free while giving the limbs a visible gait.
@export_range(2.0, 12.0, 0.5) var walk_frequency: float = 7.0
@export_range(0.0, 0.9, 0.05) var leg_swing_radians: float = 0.48
@export_range(0.0, 0.6, 0.05) var arm_swing_radians: float = 0.30

var _phase := 0.0
var _elapsed := 0.0
var _left_leg: MeshInstance3D
var _right_leg: MeshInstance3D
var _left_arm: MeshInstance3D
var _right_arm: MeshInstance3D
var _torso: MeshInstance3D
var _torso_rest_y := 1.13


func _ready() -> void:
	_left_leg = get_node_or_null("LeftLeg") as MeshInstance3D
	_right_leg = get_node_or_null("RightLeg") as MeshInstance3D
	_left_arm = get_node_or_null("LeftArm") as MeshInstance3D
	_right_arm = get_node_or_null("RightArm") as MeshInstance3D
	_torso = get_node_or_null("WhiteSleevelessShirt") as MeshInstance3D
	if _torso != null:
		_torso_rest_y = _torso.position.y


func _process(delta: float) -> void:
	var player := get_parent() as CharacterBody3D
	if player == null:
		return
	_elapsed += delta
	var speed := Vector2(player.velocity.x, player.velocity.z).length()
	var moving := not bool(player.get("is_driving")) and speed > 0.18
	var intensity := clampf(speed / 5.2, 0.0, 1.0) if moving else 0.0
	if intensity > 0.0:
		_phase += delta * walk_frequency * lerpf(0.75, 1.2, intensity)
	else:
		_phase += delta * 1.4

	var stride := sin(_phase) * leg_swing_radians * intensity
	var counter_stride := -stride
	if _left_leg != null:
		_left_leg.rotation.x = stride
	if _right_leg != null:
		_right_leg.rotation.x = counter_stride
	if _left_arm != null:
		_left_arm.rotation.x = -stride * (arm_swing_radians / maxf(0.01, leg_swing_radians))
	if _right_arm != null:
		_right_arm.rotation.x = -counter_stride * (arm_swing_radians / maxf(0.01, leg_swing_radians))
	if _torso != null:
		var breathing := sin(_elapsed * 2.1) * 0.008
		var step_bob := absf(sin(_phase * 2.0)) * 0.028 * intensity
		_torso.position.y = _torso_rest_y + breathing + step_bob
