extends Node3D

## Touch-drag camera restricted to the far-right area to avoid joystick overlap.
## The pivot follows the player position, but its world yaw stays independent
## from the player's facing direction so walking forward cannot orbit the camera.

@export_range(0.001, 0.03, 0.001) var look_sensitivity: float = 0.006
@export_range(10.0, 85.0, 1.0) var look_down_limit_degrees: float = 55.0
@export_range(10.0, 85.0, 1.0) var look_up_limit_degrees: float = 35.0
@export_range(2.5, 6.0, 0.1) var on_foot_camera_distance := 3.6
@export_range(3.5, 7.0, 0.1) var vehicle_camera_distance := 5.2
@export_range(1.0, 12.0, 0.5) var camera_distance_response := 6.0

var _active_touch_index: int = -1
var _mouse_look_active: bool = false
var _camera_yaw: float = 0.0
var _camera_pitch: float = 0.0
var _spring_arm: SpringArm3D


func _ready() -> void:
	add_to_group("third_person_cameras")
	_camera_yaw = global_rotation.y
	_camera_pitch = global_rotation.x
	_apply_camera_rotation()

	_spring_arm = $SpringArm3D as SpringArm3D
	_spring_arm.spring_length = on_foot_camera_distance
	var followed_body: Node = get_parent()
	if followed_body is CollisionObject3D:
		_spring_arm.add_excluded_object(followed_body.get_rid())


func _process(delta: float) -> void:
	# On foot, keep the character large enough in frame to match the close
	# residential follow camera from the reference. Pull back while riding.
	var followed_body := get_parent()
	var is_driving := bool(followed_body.get("is_driving")) if followed_body != null else false
	var target_distance := vehicle_camera_distance if is_driving else on_foot_camera_distance
	if _spring_arm != null:
		_spring_arm.spring_length = move_toward(
			_spring_arm.spring_length, target_distance,
			camera_distance_response * delta
		)
	# Player yaw is independent of world-space camera yaw.
	_apply_camera_rotation()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var screen_width: float = get_viewport().get_visible_rect().size.x
			if _active_touch_index == -1 and event.position.x >= screen_width * 0.72:
				_active_touch_index = event.index
		elif event.index == _active_touch_index:
			_active_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == _active_touch_index:
			_apply_look(event.relative)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_mouse_look_active = event.pressed

	elif event is InputEventMouseMotion and _mouse_look_active:
		_apply_look(event.screen_relative)


func _apply_look(pointer_delta: Vector2) -> void:
	_camera_yaw -= pointer_delta.x * look_sensitivity
	_camera_pitch = clampf(
		_camera_pitch - pointer_delta.y * look_sensitivity,
		-deg_to_rad(look_down_limit_degrees),
		deg_to_rad(look_up_limit_degrees)
	)
	_apply_camera_rotation()


func _apply_camera_rotation() -> void:
	# Set world rotation explicitly: rotating the player body must not rotate
	# the camera's viewing direction as a side effect.
	global_rotation = Vector3(_camera_pitch, _camera_yaw, 0.0)
