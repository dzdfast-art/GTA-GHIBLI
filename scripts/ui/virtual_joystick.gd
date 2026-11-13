extends Control

## Analog joystick that captures one finger globally, so dragging remains
## reliable even when the finger moves outside the visual knob.
signal vector_changed(value: Vector2)

var _finger_index := -1
var _mouse_active := false
var _knob_vector := Vector2.ZERO
var _radius := 58.0
var _deadzone := 0.16


func _ready() -> void:
	custom_minimum_size = Vector2(176.0, 176.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_process_input(true)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _finger_index == -1 and get_global_rect().has_point(event.position):
				_finger_index = event.index
				_update_from_viewport_position(event.position)
				get_viewport().set_input_as_handled()
		elif event.index == _finger_index:
			_finger_index = -1
			_reset_stick()
			get_viewport().set_input_as_handled()

	elif event is InputEventScreenDrag and event.index == _finger_index:
		_update_from_viewport_position(event.position)
		get_viewport().set_input_as_handled()

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not _mouse_active and get_global_rect().has_point(event.position):
				_mouse_active = true
				_update_from_viewport_position(event.position)
		else:
			if _mouse_active:
				_mouse_active = false
				_reset_stick()

	elif event is InputEventMouseMotion and _mouse_active:
		_update_from_viewport_position(event.position)


func _update_from_viewport_position(viewport_position: Vector2) -> void:
	var local_position := get_global_transform_with_canvas().affine_inverse() * viewport_position
	var center := size * 0.5
	var offset := local_position - center
	_knob_vector = offset.limit_length(_radius) / _radius
	if _knob_vector.length() < _deadzone:
		_knob_vector = Vector2.ZERO
	vector_changed.emit(_knob_vector)
	queue_redraw()


func _reset_stick() -> void:
	_knob_vector = Vector2.ZERO
	vector_changed.emit(Vector2.ZERO)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, _radius + 8.0, Color(0.02, 0.03, 0.04, 0.52))
	draw_arc(center, _radius, 0.0, TAU, 64, Color(0.92, 0.91, 0.83, 0.82), 3.0, true)
	draw_circle(center + _knob_vector * _radius, 27.0, Color(0.94, 0.91, 0.79, 0.94))
	draw_arc(center + _knob_vector * _radius, 27.0, 0.0, TAU, 48, Color(0.10, 0.12, 0.12, 0.95), 3.0, true)
