extends Node

## Lightweight reusable NPC perception and reaction prototype.
## Attach as a child of an NPC Node3D. Uses distance-based updates for mobile.
signal state_changed(state_id: String, emotion_ar: String)

@export var detection_range := 10.0
@export var personal_space := 2.2
@export var update_interval := 0.18
@export var turn_speed := 4.0
@export var wander_radius := 1.4
@export var wander_speed := 0.45
@export var friendly_distance := 4.5
@export var alarm_speed_threshold := 5.0

var state_id := "idle"
var emotion_ar := "هادئ"
var _player: Node3D
var _home_position := Vector3.ZERO
var _wander_target := Vector3.ZERO
var _update_timer := 0.0
var _wander_timer := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	var actor := get_parent() as Node3D
	if actor != null:
		_home_position = actor.global_position
		_wander_target = _home_position


func _process(delta: float) -> void:
	var actor := get_parent() as Node3D
	if actor == null:
		return
	_update_timer -= delta
	if _update_timer <= 0.0:
		_update_timer = update_interval
		_find_player()
		_evaluate_reaction()
	_update_facing(actor, delta)
	if state_id == "idle" and _player == null:
		_wander_idle(actor, delta)


func _find_player() -> void:
	_player = null
	var actor := get_parent() as Node3D
	if actor == null:
		return
	var best_distance := detection_range
	for candidate in get_tree().get_nodes_in_group("player"):
		var possible := candidate as Node3D
		if possible == null or not is_instance_valid(possible):
			continue
		var distance := actor.global_position.distance_to(possible.global_position)
		if distance < best_distance:
			best_distance = distance
			_player = possible


func _evaluate_reaction() -> void:
	if _player == null:
		_set_state("idle", "هادئ")
		return
	var actor := get_parent() as Node3D
	var distance := actor.global_position.distance_to(_player.global_position)
	var player_speed := 0.0
	if _player is CharacterBody3D:
		player_speed = (_player as CharacterBody3D).velocity.length()
	if distance <= personal_space and player_speed >= alarm_speed_threshold:
		_set_state("alarmed", "مذعور ومتراجع")
	elif distance <= personal_space:
		_set_state("cautious", "حذر ويحافظ على مسافته")
	elif distance <= friendly_distance:
		_set_state("friendly", "ودود ومنتبه")
	else:
		_set_state("curious", "فضولي ويراقب")


func _set_state(next_state: String, next_emotion: String) -> void:
	if state_id == next_state:
		return
	state_id = next_state
	emotion_ar = next_emotion
	state_changed.emit(state_id, emotion_ar)


func _update_facing(actor: Node3D, delta: float) -> void:
	if _player == null:
		return
	var direction := _player.global_position - actor.global_position
	direction.y = 0.0
	if direction.length_squared() < 0.001:
		return
	var target_yaw := atan2(-direction.x, -direction.z)
	actor.rotation.y = lerp_angle(actor.rotation.y, target_yaw, clampf(turn_speed * delta, 0.0, 1.0))


func _wander_idle(actor: Node3D, delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0.0 or actor.global_position.distance_to(_wander_target) < 0.25:
		_wander_timer = _rng.randf_range(2.5, 5.0)
		var offset := Vector3(_rng.randf_range(-wander_radius, wander_radius), 0.0,
			_rng.randf_range(-wander_radius, wander_radius))
		_wander_target = _home_position + offset
	var direction := _wander_target - actor.global_position
	direction.y = 0.0
	if direction.length_squared() > 0.04:
		actor.global_position += direction.normalized() * wander_speed * delta
