extends Node3D

## Small village grocery stand with a functional Arabic purchase panel.
signal purchase_completed(item_id: String, remaining_balance: int)
const PRICES := {
	"village_bread": 15,
	"apple": 10,
	"date_snack": 12,
	"water_bottle": 8,
	"herbal_tea": 14,
	"field_meal": 25
}
const ITEM_ORDER := ["village_bread", "apple", "date_snack", "water_bottle", "herbal_tea", "field_meal"]

var _panel: PanelContainer
var _status_label: Label
var _balance_label: Label
var _player_nearby := false
var _wallet: Node
var _inventory: Node

func _ready() -> void:
	_build_stall()
	_build_interaction_area()
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
	if not PRICES.has(item_id):
		_status_label.text = "هذا المنتج غير متوفر."
		return
	_resolve_player_services()
	if _wallet == null or _inventory == null:
		_status_label.text = "حقيبة اللاعب أو المحفظة غير جاهزة."
		return
	var cost := int(PRICES[item_id])
	if not _wallet.call("spend_money", cost):
		_status_label.text = "رصيدك لا يكفي لشراء هذا المنتج."
		return
	if not _inventory.call("add_item", item_id, 1):
		_wallet.call("add_money", cost)
		_status_label.text = "تعذر إضافة المنتج؛ أُعيد المبلغ إلى محفظتك."
		return
	var item_name := str(_inventory.call("get_item_name", item_id))
	_status_label.text = "اشتريت %s بنجاح." % item_name
	purchase_completed.emit(item_id, int(_wallet.call("get_balance")))
	_update_shop_labels()

func _build_stall() -> void:
	var counter := MeshInstance3D.new()
	counter.name = "GroceryCounter"
	var counter_mesh := BoxMesh.new()
	counter_mesh.size = Vector3(3.0, 1.05, 1.2)
	counter.mesh = counter_mesh
	counter.position = Vector3(0.0, 0.55, 0.0)
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color(0.42, 0.27, 0.16)
	wood.roughness = 0.9
	counter.material_override = wood
	add_child(counter)
	var awning := MeshInstance3D.new()
	awning.name = "GroceryAwning"
	var awning_mesh := BoxMesh.new()
	awning_mesh.size = Vector3(3.5, 0.18, 1.8)
	awning.mesh = awning_mesh
	awning.position = Vector3(0.0, 1.5, -0.1)
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = Color(0.72, 0.34, 0.25)
	awning.material_override = cloth
	add_child(awning)
	var sign := Label3D.new()
	sign.name = "ShopSign"
	sign.text = "متجر القرية"
	sign.position = Vector3(0.0, 2.05, 0.0)
	sign.font_size = 32
	sign.modulate = Color(1.0, 0.91, 0.7)
	add_child(sign)

func _build_interaction_area() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 2
	area.collision_mask = 1
	area.add_to_group("interaction_areas")
	add_child(area)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 3.2
	shape.shape = sphere
	shape.position.y = 1.0
	area.add_child(shape)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = true

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		_panel.visible = false

func _build_shop_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "VillageShopUI"
	layer.layer = 8
	add_child(layer)
	_panel = PanelContainer.new()
	_panel.name = "ShopPanel"
	_panel.anchor_left = 0.22
	_panel.anchor_top = 0.12
	_panel.anchor_right = 0.78
	_panel.anchor_bottom = 0.88
	_panel.visible = false
	layer.add_child(_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	_panel.add_child(content)
	var heading := Label.new()
	heading.text = "متجر القرية — الطعام والشراب"
	heading.text_direction = Control.TEXT_DIRECTION_RTL
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(heading)
	_balance_label = Label.new()
	_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_balance_label)
	for item_id in ITEM_ORDER:
		var price := int(PRICES[item_id])
		var row := HBoxContainer.new()
		content.add_child(row)
		var name_label := Label.new()
		name_label.text = "%s — %d" % [_item_name_from_catalog(item_id), price]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(name_label)
		var buy_button := Button.new()
		buy_button.text = "شراء"
		buy_button.pressed.connect(_buy_item.bind(item_id))
		row.add_child(buy_button)
	_status_label = Label.new()
	_status_label.text = "اختر ما تحتاجه."
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_status_label)
	var close_button := Button.new()
	close_button.text = "إغلاق"
	close_button.pressed.connect(func(): _panel.visible = false)
	content.add_child(close_button)

func _item_name_from_catalog(item_id: String) -> String:
	var file := FileAccess.open("res://data/items/consumables.json", FileAccess.READ)
	if file == null:
		return item_id
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		for item in parsed.get("items", []):
			if item is Dictionary and str(item.get("id", "")) == item_id:
				return str(item.get("name_ar", item_id))
	return item_id

func _update_shop_labels() -> void:
	if _wallet == null:
		_balance_label.text = "المحفظة غير متاحة"
	else:
		_balance_label.text = "رصيدك: %d قطعة نقدية" % int(_wallet.call("get_balance"))
