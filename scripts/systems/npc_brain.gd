extends Node

## Lightweight, reusable NPC perception, relationship, schedule and group-reaction brain.
## Attach as a child of an NPC Node3D. Movement is intentionally simple until a NavMesh is authored.
signal state_changed(state_id: String, emotion_ar: String)
signal relationship_changed(trust: float, familiarity: float)

@export var detection_range := 12.0
@export var personal_space := 2.2
@export var update_interval := 0.2
@export var turn_speed := 4.0
@export var wander_radius := 1.4
@export var wander_speed := 0.45
@export var friendly_distance := 4.5
@export var alarm_speed_threshold := 5.0
@export var flee_speed := 2.2
@export var relationship_memory_enabled := true
@export_range(-100.0, 100.0, 1.0) var starting_trust := 0.0
@export_range(0.0, 100.0, 1.0) var starting_familiarity := 0.0
@export var schedule_enabled := false
@export_range(0, 23, 1) var work_start_hour := 8
@export_range(0, 23, 1) var work_end_hour := 17
@export var work_position := Vector3.ZERO
@export var home_position := Vector3.ZERO

var state_id := "idle"
var emotion_ar := "هادئ"
var trust := 0.0
var familiarity := 0.0
var world_hour := -1
var _player: Node3D
var _home_position := Vector3.ZERO
var _wander_target := Vector3.ZERO
var _update_timer := 0.0
var _wander_timer := 0.0
var _alarm_timer := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	trust = starting_trust
	familiarity = starting_familiarity
	add_to_group("npc_brains")
	var actor := get_parent() as Node3D
	if actor != null:
		_home_position = actor.global_position
		_wander_target = _home_position
	if home_position == Vector3.ZERO:
		home_position = _home_position
	if work_position == Vector3.ZERO:
		work_position = _home_position


func _process(delta: float) -> void:
	var actor := get_parent() as Node3D
	if actor == null:
		return
	_update_timer -= delta
	if _update_timer <= 0.0:
		_update_timer = maxf(update_interval, 0.05)
		_find_player()
		_evaluate_reaction()
	_alarm_timer = maxf(_alarm_timer - delta, 0.0)
	_update_facing(actor, delta)
	if state_id == "alarmed":
		_flee_from_player(actor, delta)
	elif _player == null:
		_follow_schedule_or_wander(actor, delta)


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
	if _alarm_timer > 0.0:
		_set_state("alarmed", "خائف وينبه من حوله")
		return
	if _player == null:
		if schedule_enabled and world_hour >= 0:
			_set_state("working" if _is_work_hour() else "resting",
				"يعمل حسب جدوله اليومي" if _is_work_hour() else "يرتاح في هذا الوقت")
		else:
			_set_state("idle", "هادئ")
		return
	var actor := get_parent() as Node3D
	var distance := actor.global_position.distance_to(_player.global_position)
	var player_speed := 0.0
	if _player is CharacterBody3D:
		player_speed = (_player as CharacterBody3D).velocity.length()
	if distance <= personal_space and (player_speed >= alarm_speed_threshold or trust <= -35.0):
		_set_state("alarmed", "مذعور ومتراجع")
	elif distance <= personal_space:
		_set_state("cautious", "حذر ويحافظ على مسافته")
	elif distance <= friendly_distance and trust >= 15.0:
		_set_state("friendly", "ودود ويتذكرك")
	elif distance <= friendly_distance:
		_set_state("curious", "فضولي ويراقبك")
	else:
		_set_state("curious", "فضولي ويراقب")


func record_interaction(kind: String = "talk") -> void:
	if not relationship_memory_enabled:
		return
	match kind:
		"talk":
			trust = clampf(trust + 3.0, -100.0, 100.0)
			familiarity = clampf(familiarity + 8.0, 0.0, 100.0)
		"help":
			trust = clampf(trust + 12.0, -100.0, 100.0)
			familiarity = clampf(familiarity + 15.0, 0.0, 100.0)
		"gift":
			trust = clampf(trust + 8.0, -100.0, 100.0)
			familiarity = clampf(familiarity + 10.0, 0.0, 100.0)
		"threat":
			trust = clampf(trust - 18.0, -100.0, 100.0)
		"aggression":
			record_player_action("aggression")
			return
	relationship_changed.emit(trust, familiarity)


func record_player_action(action: String) -> void:
	if not relationship_memory_enabled:
		return
	if action in ["aggression", "attack", "steal"]:
		trust = clampf(trust - 35.0, -100.0, 100.0)
		familiarity = clampf(familiarity + 5.0, 0.0, 100.0)
		relationship_changed.emit(trust, familiarity)
		hear_alarm(Vector3.ZERO)


func set_world_hour(hour: int) -> void:
	world_hour = posmod(hour, 24)
	if schedule_enabled and _player == null:
		_evaluate_reaction()


func _is_work_hour() -> bool:
	if work_start_hour == work_end_hour:
		return true
	if work_start_hour < work_end_hour:
		return world_hour >= work_start_hour and world_hour < work_end_hour
	return world_hour >= work_start_hour or world_hour < work_end_hour


func hear_alarm(source_position: Vector3) -> void:
	var actor := get_parent() as Node3D
	if actor == null:
		return
	if source_position != Vector3.ZERO and actor.global_position.distance_to(source_position) > detection_range * 1.5:
		return
	_alarm_timer = 3.0
	_set_state("alarmed", "سمع إنذاراً ويحذّر الآخرين")


func _follow_schedule_or_wander(actor: Node3D, delta: float) -> void:
	if schedule_enabled and world_hour >= 0:
		var destination := work_position if _is_work_hour() else home_position
		_move_toward(actor, destination, wander_speed, delta)
		return
	_wander_timer -= delta
	if _wander_timer <= 0.0 or actor.global_position.distance_to(_wander_target) < 0.25:
		_wander_timer = _rng.randf_range(2.5, 5.0)
		var offset := Vector3(_rng.randf_range(-wander_radius, wander_radius), 0.0,
			_rng.randf_range(-wander_radius, wander_radius))
		_wander_target = _home_position + offset
	_move_toward(actor, _wander_target, wander_speed, delta)


func _move_toward(actor: Node3D, destination: Vector3, speed: float, delta: float) -> void:
	var direction := destination - actor.global_position
	direction.y = 0.0
	if direction.length_squared() > 0.04:
		actor.global_position += direction.normalized() * speed * delta


func _flee_from_player(actor: Node3D, delta: float) -> void:
	if _player == null:
		return
	var away := actor.global_position - _player.global_position
	away.y = 0.0
	if away.length_squared() > 0.001:
		actor.global_position += away.normalized() * flee_speed * delta


func _update_facing(actor: Node3D, delta: float) -> void:
	if _player == null:
		return
	var direction := _player.global_position - actor.global_position
	direction.y = 0.0
	if direction.length_squared() < 0.001:
		return
	var target_yaw := atan2(-direction.x, -direction.z)
	actor.rotation.y = lerp_angle(actor.rotation.y, target_yaw, clampf(turn_speed * delta, 0.0, 1.0))


func _set_state(next_state: String, next_emotion: String) -> void:
	if state_id == next_state:
		return
	state_id = next_state
	emotion_ar = next_emotion
	state_changed.emit(state_id, emotion_ar)
	if next_state == "alarmed":
		var actor := get_parent() as Node3D
		if actor != null:
			for other in get_tree().get_nodes_in_group("npc_brains"):
				if other == self or not is_instance_valid(other):
					continue
				if other.has_method("hear_alarm"):
					other.call("hear_alarm", actor.global_position)
