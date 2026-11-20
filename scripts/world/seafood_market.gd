extends Node3D

## Sapphire Coast seafood vendor, using the shared interact() system.
signal purchase_completed(item_id: String, remaining_balance: int)

const PRICES := {"grilled_sardines": 22, "seafood_stew": 38, "red_mullet_plate": 44}
const ITEM_ORDER := ["grilled_sardines", "seafood_stew", "red_mullet_plate"]
const ITEM_NAMES := {
	"grilled_sardines": "سردين مشوي",
	"seafood_stew": "حساء السمك",
	"red_mullet_plate": "طبق البوري الأحمر"
}

var _player_nearby := false
var _wallet: Node
var _inventory: Node
var _panel: PanelContainer
var _status_label: Label
var _balance_label: Label


func _ready() -> void:
	_build_collision()
	_build_interaction_area()
	_build_sign()
	_build_shop_ui()


func interact() -> void:
	if not _player_nearby:
		return
	_resolve_player_services()
	_panel.visible = not _panel.visible
	_update_shop_labels()


func _resolve_player_services() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node
	if player == null:
		_wallet = null
		_inventory = null
		return
	_wallet = player.get_node_or_null("PlayerWallet")
	_inventory = player.get_node_or_null("ConsumableInventory")


func _buy_item(item_id: String) -> void:
	if not _player_nearby:
		_status_label.text = "اقترب من البائع أولاً."
		return
	if not PRICES.has(item_id):
		_status_label.text = "هذا المنتج غير متوفر."
		return
	_resolve_player_services()
	if _wallet == null or _inventory == null:
		_status_label.text = "المحفظة أو حقيبة الطعام غير جاهزة."
		return
	var cost := int(PRICES[item_id])
	if not _wallet.call("spend_money", cost):
		_status_label.text = "رصيدك لا يكفي لشراء هذا الطبق."
		return
	if not _inventory.call("add_item", item_id, 1):
		_wallet.call("add_money", cost)
		_status_label.text = "تعذرت إضافة الطبق؛ أُعيد المبلغ إلى محفظتك."
		return
	_status_label.text = "اشتريت %s بنجاح." % ITEM_NAMES[item_id]
	purchase_completed.emit(item_id, int(_wallet.call("get_balance")))
	_update_shop_labels()


func _build_collision() -> void:
	var body := StaticBody3D.new()
	body.name = "MarketCollision"
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.7, 1.7, 1.8)
	shape.shape = box
	shape.position.y = 0.85
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
	sphere.radius = 3.8
	collision.shape = sphere
	collision.position.y = 1.0
	area.add_child(collision)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _build_sign() -> void:
	var sign := Label3D.new()
	sign.name = "MarketSign"
	sign.text = "سوق صيادي الساحل"
	sign.position = Vector3(0.0, 3.0, -0.55)
	sign.font_size = 28
	sign.outline_size = 7
	sign.modulate = Color(1.0, 0.89, 0.65)
	add_child(sign)


func _build_shop_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "SeafoodMarketUI"
	layer.layer = 9
	add_child(layer)
	_panel = PanelContainer.new()
	_panel.name = "MarketPanel"
	_panel.anchor_left = 0.18
	_panel.anchor_top = 0.17
	_panel.anchor_right = 0.82
	_panel.anchor_bottom = 0.83
	_panel.visible = false
	layer.add_child(_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	_panel.add_child(content)
	var heading := Label.new()
	heading.text = "سوق صيادي الساحل — أطباق بحرية"
	heading.text_direction = Control.TEXT_DIRECTION_RTL
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(heading)
	_balance_label = Label.new()
	_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_balance_label)
	for item_id in ITEM_ORDER:
		var row := HBoxContainer.new()
		content.add_child(row)
		var name_label := Label.new()
		name_label.text = "%s — %d" % [ITEM_NAMES[item_id], int(PRICES[item_id])]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(name_label)
		var buy_button := Button.new()
		buy_button.text = "شراء"
		buy_button.pressed.connect(_buy_item.bind(item_id))
		row.add_child(buy_button)
	_status_label = Label.new()
	_status_label.text = "اختر طبقاً طازجاً من الساحل."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_status_label)
	var close_button := Button.new()
	close_button.text = "إغلاق"
	close_button.pressed.connect(func(): _panel.visible = false)
	content.add_child(close_button)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		_panel.visible = false


func _update_shop_labels() -> void:
	if _wallet == null:
		_balance_label.text = "المحفظة غير متاحة"
	else:
		_balance_label.text = "رصيدك: %d قطعة نقدية" % int(_wallet.call("get_balance"))
