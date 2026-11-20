extends Node3D

## Public plaza fountain. Uses the shared player_interactor "interact" contract.
signal water_drunk(amount: float, new_thirst: float)

@export_range(1.0, 60.0, 1.0) var hydration_restore := 30.0
@export_range(0.0, 10.0, 0.5) var use_cooldown_seconds := 2.5

var _player_nearby := false
var _cooldown_remaining := 0.0
var _feedback_remaining := 0.0
var _prompt: Label3D
var _feedback: Label3D


func _ready() -> void:
	_build_solid_collision()
	_build_interaction_area()
	_build_labels()


func _process(delta: float) -> void:
	_cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)
	_feedback_remaining = maxf(0.0, _feedback_remaining - delta)
	if _feedback_remaining <= 0.0 and _feedback != null:
		_feedback.visible = false
	if _prompt != null:
		_prompt.visible = _player_nearby


func interact() -> bool:
	if not _player_nearby:
		return false
	if _cooldown_remaining > 0.0:
		_show_feedback("انتظر قليلاً قبل الشرب مرة أخرى.")
		return false

	var player := get_tree().get_first_node_in_group("player") as Node
	if player == null:
		_show_feedback("تعذر العثور على اللاعب.")
		return false
	var needs := player.get_node_or_null("PlayerNeeds")
	if needs == null or not needs.has_method("drink"):
		_show_feedback("نظام احتياجات اللاعب غير جاهز.")
		return false

	var current_thirst := clampf(float(needs.get("thirst")), 0.0, 100.0)
	if current_thirst >= 99.0:
		_show_feedback("لست بحاجة إلى الماء الآن.")
		return false

	needs.call("drink", hydration_restore)
	var new_thirst := clampf(float(needs.get("thirst")), 0.0, 100.0)
	var restored := maxf(0.0, new_thirst - current_thirst)
	if restored <= 0.0:
		_show_feedback("لم تستطع شرب الماء الآن.")
		return false

	_cooldown_remaining = use_cooldown_seconds
	_show_feedback("شربت ماءً نظيفاً. العطش: %d%%" % roundi(new_thirst))
	water_drunk.emit(restored, new_thirst)
	return true


func _build_solid_collision() -> void:
	var body := StaticBody3D.new()
	body.name = "FountainCollision"
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)

	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.82
	cylinder.height = 1.65
	shape.shape = cylinder
	shape.position.y = 0.88
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
	sphere.radius = 3.2
	collision.shape = sphere
	collision.position.y = 1.0
	area.add_child(collision)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _build_labels() -> void:
	_prompt = Label3D.new()
	_prompt.name = "InteractionPrompt"
	_prompt.text = "نافورة عامة\nاضغط E للشرب"
	_prompt.position = Vector3(0.0, 2.75, 0.0)
	_prompt.font_size = 28
	_prompt.outline_size = 7
	_prompt.modulate = Color(0.96, 0.91, 0.72)
	_prompt.visible = false
	add_child(_prompt)

	_feedback = Label3D.new()
	_feedback.name = "InteractionFeedback"
	_feedback.position = Vector3(0.0, 3.35, 0.0)
	_feedback.font_size = 24
	_feedback.outline_size = 6
	_feedback.modulate = Color(0.77, 0.94, 1.0)
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


func _show_feedback(message: String) -> void:
	if _feedback == null:
		return
	_feedback.text = message
	_feedback.visible = true
	_feedback_remaining = 2.5
