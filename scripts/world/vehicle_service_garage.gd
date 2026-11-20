extends Node3D

## Amber Valley mechanic. Repairs nearby, stationary driveable cars through their shared health API.
signal repair_completed(vehicle_name: String, restored_health: float, remaining_balance: int)

const LABOR_COST_PER_HEALTH := 1.5
const VEHICLE_SERVICE_RADIUS := 10.0
const PARKED_SPEED_LIMIT := 0.35

var _player_nearby := false
var _player: Node3D
var _wallet: Node
var _vehicle: Node3D
var _panel: PanelContainer
var _vehicle_label: Label
var _price_label: Label
var _status_label: Label
var _repair_button: Button


func _ready() -> void:
	_build_structure_collision()
	_build_interaction_area()
	_build_prompt()
	_build_service_ui()


func interact() -> void:
	if not _player_nearby:
		return
	_panel.visible = not _panel.visible
	if _panel.visible:
		_refresh_service_ui()


func _process(_delta: float) -> void:
	if _panel != null and _panel.visible:
		_refresh_service_ui()


func _resolve_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node3D
	_wallet = _player.get_node_or_null("PlayerWallet") if _player != null else null


func _find_service_vehicle() -> Node3D:
	_resolve_player()
	if _player == null:
		return null
	var closest: Node3D
	var closest_distance := INF
	for candidate in get_tree().get_nodes_in_group("vehicles"):
		var vehicle := candidate as Node3D
		if vehicle == null or not vehicle.has_method("repair_vehicle"):
			continue
		var is_driver: bool = vehicle.get("driver") == _player
		var distance := _player.global_position.distance_to(vehicle.global_position)
		if not is_driver and distance > VEHICLE_SERVICE_RADIUS:
			continue
		var speed := absf(float(vehicle.get("_speed")))
		if speed > PARKED_SPEED_LIMIT:
			continue
		if is_driver:
			return vehicle
		if distance < closest_distance:
			closest = vehicle
			closest_distance = distance
	return closest


func _quote_for(vehicle: Node3D) -> int:
	if vehicle == null:
		return 0
	var maximum := maxf(1.0, float(vehicle.get("max_vehicle_health")))
	var current := clampf(float(vehicle.get("vehicle_health")), 0.0, maximum)
	var missing := maximum - current
	if missing <= 0.01:
		return 0
	return maxi(10, ceili(missing * LABOR_COST_PER_HEALTH))


func _refresh_service_ui() -> void:
	if _panel == null:
		return
	_vehicle = _find_service_vehicle()
	if _vehicle == null:
		_vehicle_label.text = "لا توجد سيارة متوقفة قرب الورشة."
		_price_label.text = "أوقف السيارة قرب الرافعة ثم اقترب من الورشة."
		_repair_button.text = "لا توجد سيارة"
		_repair_button.disabled = true
		return
	var health := clampf(float(_vehicle.get("vehicle_health")), 0.0, float(_vehicle.get("max_vehicle_health")))
	var maximum := maxf(1.0, float(_vehicle.get("max_vehicle_health")))
	var quote := _quote_for(_vehicle)
	_vehicle_label.text = "حالة المركبة: %d / %d" % [roundi(health), roundi(maximum)]
	if quote <= 0:
		_price_label.text = "المركبة سليمة ولا تحتاج إلى إصلاح."
		_repair_button.text = "المركبة سليمة"
		_repair_button.disabled = true
	else:
		_price_label.text = "تكلفة الإصلاح الكامل: %d قطعة نقدية" % quote
		_repair_button.text = "إصلاح كامل — %d" % quote
		_repair_button.disabled = _wallet == null or int(_wallet.call("get_balance")) < quote
	_status_label.text = "الرصيد: %d" % int(_wallet.call("get_balance")) if _wallet != null else "المحفظة غير متاحة"


func _perform_repair() -> bool:
	if not _player_nearby:
		return false
	_vehicle = _find_service_vehicle()
	if _vehicle == null or _wallet == null:
		_set_status("أوقف مركبة قريبة أولاً.")
		return false
	var quote := _quote_for(_vehicle)
	if quote <= 0:
		_set_status("المركبة سليمة بالفعل.")
		return false
	if int(_wallet.call("get_balance")) < quote:
		_set_status("رصيدك لا يكفي للإصلاح الكامل.")
		return false
	var before := float(_vehicle.get("vehicle_health"))
	if not bool(_wallet.call("spend_money", quote)):
		_set_status("تعذر خصم تكلفة الإصلاح.")
		return false
	if not bool(_vehicle.call("repair_vehicle")):
		_wallet.call("add_money", quote)
		_set_status("تعذر إصلاح المركبة؛ أُعيد المبلغ إلى محفظتك.")
		return false
	var after := float(_vehicle.get("vehicle_health"))
	var restored := maxf(0.0, after - before)
	if restored <= 0.0:
		_wallet.call("add_money", quote)
		_set_status("لم تتغير حالة المركبة؛ أُعيد المبلغ.")
		return false
	var balance := int(_wallet.call("get_balance"))
	_set_status("اكتمل الإصلاح! أُعيدت %d نقطة. الرصيد: %d" % [roundi(restored), balance])
	repair_completed.emit(str(_vehicle.name), restored, balance)
	_refresh_service_ui()
	return true


func _set_status(message: String) -> void:
	if _status_label != null:
		_status_label.text = message


func _build_structure_collision() -> void:
	# Keep the workshop's front bay open so a car can enter the service lift.
	var body := StaticBody3D.new()
	body.name = "GarageCollision"
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)
	_add_collision_box(body, "LeftWall", Vector3(-5.0, 2.1, 0.0), Vector3(0.28, 4.2, 7.4))
	_add_collision_box(body, "RightWall", Vector3(5.0, 2.1, 0.0), Vector3(0.28, 4.2, 7.4))
	_add_collision_box(body, "RearWall", Vector3(0.0, 2.25, 3.55), Vector3(10.0, 4.5, 0.3))
	_add_collision_box(body, "LeftFrontPillar", Vector3(-4.85, 2.1, -3.55), Vector3(0.3, 4.2, 0.3))
	_add_collision_box(body, "RightFrontPillar", Vector3(4.85, 2.1, -3.55), Vector3(0.3, 4.2, 0.3))


func _add_collision_box(parent: StaticBody3D, node_name: String, local_position: Vector3, dimensions: Vector3) -> void:
	var collision := CollisionShape3D.new()
	collision.name = node_name
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	collision.position = local_position
	parent.add_child(collision)


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
	sphere.radius = 5.8
	collision.shape = sphere
	collision.position.y = 1.0
	area.add_child(collision)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _build_prompt() -> void:
	var prompt := Label3D.new()
	prompt.name = "GaragePrompt"
	prompt.text = "ورشة الوادي\nاضغط للتفاعل"
	prompt.position = Vector3(0.0, 5.1, -3.9)
	prompt.font_size = 30
	prompt.outline_size = 8
	prompt.modulate = Color(1.0, 0.83, 0.35)
	prompt.visible = false
	add_child(prompt)
	_prompt_node = prompt


var _prompt_node: Label3D


func _build_service_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "VehicleServiceUI"
	layer.layer = 10
	add_child(layer)
	_panel = PanelContainer.new()
	_panel.name = "ServicePanel"
	_panel.anchor_left = 0.18
	_panel.anchor_top = 0.19
	_panel.anchor_right = 0.82
	_panel.anchor_bottom = 0.81
	_panel.visible = false
	layer.add_child(_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	_panel.add_child(content)
	var heading := Label.new()
	heading.text = "ورشة الوادي — صيانة المركبات"
	heading.text_direction = Control.TEXT_DIRECTION_RTL
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(heading)
	_vehicle_label = Label.new()
	_vehicle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_vehicle_label)
	_price_label = Label.new()
	_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_price_label)
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_status_label)
	_repair_button = Button.new()
	_repair_button.pressed.connect(_perform_repair)
	content.add_child(_repair_button)
	var close_button := Button.new()
	close_button.text = "إغلاق"
	close_button.pressed.connect(func(): _panel.visible = false)
	content.add_child(close_button)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		if _prompt_node != null:
			_prompt_node.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		if _panel != null:
			_panel.visible = false
		if _prompt_node != null:
			_prompt_node.visible = false
