extends Control

## Analog touch joystick. Emits a normalized vector while held.
signal vector_changed(value: Vector2)

var _finger_active := false
var _knob_vector := Vector2.ZERO
var _radius := 58.0
var _deadzone := 0.16


func _ready() -> void:
	custom_minimum_size = Vector2(176.0, 176.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_finger_active = true
			_update_from_position(event.position)
			accept_event()
		else:
			_reset_stick()
			accept_event()
	elif event is InputEventScreenDrag and _finger_active:
		_update_from_position(event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_finger_active = true
			_update_from_position(event.position)
		else:
			_reset_stick()
		accept_event()
	elif event is InputEventMouseMotion and _finger_active:
		_update_from_position(event.position)
		accept_event()


func _update_from_position(position: Vector2) -> void:
	var center := size * 0.5
	var offset := position - center
	_knob_vector = offset.limit_length(_radius) / _radius
	if _knob_vector.length() < _deadzone:
		_knob_vector = Vector2.ZERO
	vector_changed.emit(_knob_vector)
	queue_redraw()


func _reset_stick() -> void:
	_finger_active = false
	_knob_vector = Vector2.ZERO
	vector_changed.emit(Vector2.ZERO)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, _radius + 8.0, Color(0.02, 0.03, 0.04, 0.52))
	draw_arc(center, _radius, 0.0, TAU, 64, Color(0.92, 0.91, 0.83, 0.82), 3.0, true)
	draw_circle(center + _knob_vector * _radius, 27.0, Color(0.94, 0.91, 0.79, 0.94))
	draw_arc(center + _knob_vector * _radius, 27.0, 0.0, TAU, 48, Color(0.10, 0.12, 0.12, 0.95), 3.0, true)
