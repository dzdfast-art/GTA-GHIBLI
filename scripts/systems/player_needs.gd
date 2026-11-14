extends Node

## Lightweight survival needs for the open world. Values are 0..100.
signal needs_changed(hunger: float, thirst: float, energy: float)
signal critical_need(need_id: String, value: float)

const SAVE_PATH := "user://player_needs.json"
const AUTOSAVE_INTERVAL := 30.0

@export_range(0.0, 10.0, 0.1) var hunger_loss_per_minute := 0.7
@export_range(0.0, 10.0, 0.1) var thirst_loss_per_minute := 1.1
@export_range(0.0, 10.0, 0.1) var energy_loss_per_minute := 0.25
@export var persistence_enabled := true

var hunger := 100.0
var thirst := 100.0
var energy := 100.0
var _autosave_timer := 0.0
var _critical_latched := {}

func _ready() -> void:
	_load_state()
	_emit_state()

func _process(delta: float) -> void:
	var minutes := delta / 60.0
	hunger = maxf(0.0, hunger - hunger_loss_per_minute * minutes)
	thirst = maxf(0.0, thirst - thirst_loss_per_minute * minutes)
	energy = maxf(0.0, energy - energy_loss_per_minute * minutes)
	_check_critical("hunger", hunger)
	_check_critical("thirst", thirst)
	_check_critical("energy", energy)
	_autosave_timer += delta
	if _autosave_timer >= AUTOSAVE_INTERVAL:
		_autosave_timer = 0.0
		_save_state()

func consume_food(nutrition: float, hydration: float = 0.0, energy_restore: float = 0.0) -> void:
	hunger = clampf(hunger + maxf(0.0, nutrition), 0.0, 100.0)
	thirst = clampf(thirst + maxf(0.0, hydration), 0.0, 100.0)
	energy = clampf(energy + maxf(0.0, energy_restore), 0.0, 100.0)
	_emit_state()
	_save_state()

func drink(hydration: float) -> void:
	thirst = clampf(thirst + maxf(0.0, hydration), 0.0, 100.0)
	_emit_state()
	_save_state()

func rest(minutes: float) -> void:
	energy = clampf(energy + maxf(0.0, minutes) * 1.2, 0.0, 100.0)
	hunger = maxf(0.0, hunger - maxf(0.0, minutes) * hunger_loss_per_minute / 60.0)
	thirst = maxf(0.0, thirst - maxf(0.0, minutes) * thirst_loss_per_minute / 60.0)
	_emit_state()
	_save_state()

func get_movement_multiplier() -> float:
	if thirst < 10.0 or hunger < 8.0:
		return 0.72
	if energy < 15.0:
		return 0.82
	return 1.0

func _check_critical(need_id: String, value: float) -> void:
	var is_critical := value <= 15.0
	if is_critical and not bool(_critical_latched.get(need_id, false)):
		_critical_latched[need_id] = true
		critical_need.emit(need_id, value)
	elif value > 20.0:
		_critical_latched[need_id] = false

func _emit_state() -> void:
	needs_changed.emit(hunger, thirst, energy)

func _save_state() -> void:
	if not persistence_enabled:
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not save player needs.")
		return
	file.store_string(JSON.stringify({
		"schema_version": 1,
		"hunger": hunger,
		"thirst": thirst,
		"energy": energy
	}, "\t"))

func _load_state() -> void:
	if not persistence_enabled or not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		hunger = clampf(float(parsed.get("hunger", hunger)), 0.0, 100.0)
		thirst = clampf(float(parsed.get("thirst", thirst)), 0.0, 100.0)
		energy = clampf(float(parsed.get("energy", energy)), 0.0, 100.0)
