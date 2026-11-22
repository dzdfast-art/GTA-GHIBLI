extends Node3D
signal beacon_state_changed(active: bool)
const SWEEP_SPEED := 0.58
const FEEDBACK_SECONDS := 3.0
var _beacon_active := false
var _player_nearby := false
var _feedback_remaining := 0.0
var _clock: Node
var _sweep: Node3D
var _spot: SpotLight3D
var _glow: OmniLight3D
var _prompt: Label3D
var _feedback: Label3D

func _ready() -> void:
	add_to_group("world_landmarks")
	set_meta("location_id", "sapphire_coast_lighthouse")
	_sweep = get_node_or_null("BeaconSweep") as Node3D
	_spot = get_node_or_null("BeaconSweep/RotatingBeam") as SpotLight3D
	_glow = get_node_or_null("BeaconGlow") as OmniLight3D
	_build_collision()
	_build_interaction_area()
	_build_labels()
	_clock = get_tree().get_first_node_in_group("world_clock")
	if _clock != null and _clock.has_signal("time_changed"):
		_clock.connect("time_changed", _on_clock_time_changed)
		if _clock.has_method("get_phase"):
			set_day_phase(str(_clock.call("get_phase")))
		else:
			set_day_phase("day")
	else:
		set_day_phase("day")

func _process(delta: float) -> void:
	if _beacon_active and _sweep != null:
		_sweep.rotation.y = wrapf(_sweep.rotation.y + SWEEP_SPEED * maxf(0.0, delta), 0.0, TAU)
	_feedback_remaining = maxf(0.0, _feedback_remaining - delta)
	if _feedback_remaining <= 0.0 and _feedback != null:
		_feedback.visible = false
	if _prompt != null:
		_prompt.visible = _player_nearby

func set_day_phase(phase: String) -> void:
	var active := phase == "dawn" or phase == "dusk" or phase == "night"
	_beacon_active = active
	if _spot != null:
		_spot.visible = active
	if _glow != null:
		_glow.visible = active
	beacon_state_changed.emit(active)

func is_beacon_active() -> bool:
	return _beacon_active

func interact() -> bool:
	if not _player_nearby:
		return false
	var clock_text := "نهار"
	if _clock != null and _clock.has_method("get_clock_text"):
		clock_text = str(_clock.call("get_clock_text"))
	var state := "يعمل ويدور" if _beacon_active else "متوقف نهاراً"
	_show_feedback("منارة ساحل الياقوت\nضوء المنارة: %s\nالوقت: %s" % [state, clock_text])
	return true

func _build_collision() -> void:
	var body := StaticBody3D.new()
	body.name = "LighthouseCollision"
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 2.32
	cylinder.height = 19.0
	shape.shape = cylinder
	shape.position.y = 9.5
	body.add_child(shape)

func _build_interaction_area() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 2
	area.collision_mask = 1
	area.monitoring = true
	area.add_to_group("interaction_areas")
	add_child(area)
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 5.6
	collision.shape = sphere
	collision.position.y = 1.0
	area.add_child(collision)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _build_labels() -> void:
	_prompt = Label3D.new()
	_prompt.name = "InteractionPrompt"
	_prompt.text = "منارة ساحل الياقوت\nاضغط للتفاعل"
	_prompt.position = Vector3(0.0, 4.1, 0.0)
	_prompt.font_size = 29
	_prompt.outline_size = 7
	_prompt.modulate = Color(1.0, 0.88, 0.61)
	_prompt.visible = false
	add_child(_prompt)
	_feedback = Label3D.new()
	_feedback.name = "LandmarkFeedback"
	_feedback.position = Vector3(0.0, 5.0, 0.0)
	_feedback.font_size = 24
	_feedback.outline_size = 7
	_feedback.modulate = Color(0.81, 0.94, 1.0)
	_feedback.visible = false
	add_child(_feedback)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		if _prompt != null:
			_prompt.visible = false

func _on_clock_time_changed(_hour: int, _minute: int, _day: int, phase: String) -> void:
	set_day_phase(phase)

func _show_feedback(message: String) -> void:
	if _feedback == null:
		return
	_feedback.text = message
	_feedback.visible = true
	_feedback_remaining = FEEDBACK_SECONDS
