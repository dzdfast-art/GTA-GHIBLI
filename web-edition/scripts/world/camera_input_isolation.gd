extends RefCounted
class_name GhibliCameraInputIsolation
var move_input: Vector2=Vector2.ZERO
var look_input: Vector2=Vector2.ZERO
func set_move(value: Vector2) -> void:
	move_input=value.limit_length(1.0)
func set_look(value: Vector2) -> void:
	look_input=value.limit_length(1.0)
func consume_move() -> Vector2:
	var value=move_input
	move_input=Vector2.ZERO
	return value
func consume_look() -> Vector2:
	var value=look_input
	look_input=Vector2.ZERO
	return value
func clear_all() -> void:
	move_input=Vector2.ZERO
	look_input=Vector2.ZERO