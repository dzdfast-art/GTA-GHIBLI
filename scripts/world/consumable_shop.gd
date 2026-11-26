extends Node3D

const MARKET_WOOD_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_market_wood.svg")
const MARKET_CANVAS_TEXTURE: Texture2D = preload("res://assets/environment/materials/willow_market_canvas.svg")

## Small village grocery stand with a functional Arabic purchase panel.
signal purchase_completed(item_id: String, remaining_balance: int)
const PRICES := {
	"village_bread": 15,
	"apple": 10,
	"date_snack": 12,
	"water_bottle": 8,
	"herbal_tea": 14,
	"field_meal": 25,
	"carrot": 9,
	"wild_berries": 18
}
const ITEM_ORDER := ["village_bread", "apple", "date_snack", "water_bottle", "herbal_tea", "field_meal", "carrot", "wild_berries"]

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
	wood.albedo_color = Color(0.72, 0.58, 0.39)
	wood.albedo_texture = MARKET_WOOD_TEXTURE
	wood.uv1_scale = Vector3(1.8, 1.8, 1.8)
	wood.roughness = 0.94
	counter.material_override = wood
	add_child(counter)
	var awning := MeshInstance3D.new()
	awning.name = "GroceryAwning"
	var awning_mesh := BoxMesh.new()
	awning_mesh.size = Vector3(3.5, 0.18, 1.8)
	awning.mesh = awning_mesh
	awning.position = Vector3(0.0, 1.5, -0.1)
	var cloth := StandardMaterial3D.new()
	cloth.albedo_color = Color(0.94, 0.88, 0.74)
	cloth.albedo_texture = MARKET_CANVAS_TEXTURE
	cloth.uv1_scale = Vector3(2.0, 1.0, 1.0)
	cloth.roughness = 1.0
	awning.material_override = cloth
	add_child(awning)
	var sign := Label3D.new()
	sign.name = "ShopSign"
	sign.text = "متجر القرية"
	sign.position = Vector3(0.0, 2.05, 0.0)
	sign.font_size = 32
	sign.modulate = Color(1.0, 0.91, 0.7)
	add_child(sign)
	_build_market_details()

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


func _build_market_details() -> void:
	# Structural supports make the awning read as a real timber-and-canvas stall.
	var dark_wood := _market_material(Color(0.30, 0.19, 0.12), MARKET_WOOD_TEXTURE)
	var canvas := _market_material(Color(0.96, 0.91, 0.79), MARKET_CANVAS_TEXTURE)
	var post_mesh := CylinderMesh.new()
	post_mesh.top_radius = 0.055
	post_mesh.bottom_radius = 0.075
	post_mesh.height = 1.72
	post_mesh.radial_segments = 8
	for side in [-1.0, 1.0]:
		var post := MeshInstance3D.new()
		post.name = "AwningSupport_%s" % ("Left" if side < 0.0 else "Right")
		post.mesh = post_mesh
		post.position = Vector3(side * 1.56, 0.86, 0.62)
		post.material_override = dark_wood
		add_child(post)

	var valance := MeshInstance3D.new()
	valance.name = "StripedCanvasValance"
	var valance_mesh := BoxMesh.new()
	valance_mesh.size = Vector3(3.48, 0.25, 0.075)
	valance.mesh = valance_mesh
	valance.position = Vector3(0.0, 1.36, 0.79)
	valance.material_override = canvas
	add_child(valance)

	for beam_name in ["AwningFrontBeam", "AwningLeftBeam", "AwningRightBeam"]:
		var beam := MeshInstance3D.new()
		beam.name = beam_name
		var beam_mesh := BoxMesh.new()
		if beam_name == "AwningFrontBeam":
			beam_mesh.size = Vector3(3.58, 0.075, 0.09)
			beam.position = Vector3(0.0, 1.48, 0.72)
		else:
			beam_mesh.size = Vector3(0.09, 0.075, 1.72)
			beam.position = Vector3(-1.70 if beam_name == "AwningLeftBeam" else 1.70, 1.48, -0.08)
		beam.mesh = beam_mesh
		beam.material_override = dark_wood
		add_child(beam)

	_build_produce_crates(dark_wood)
	_build_market_barrel(dark_wood)
	_build_market_chalkboard(dark_wood)


func _build_produce_crates(wood: StandardMaterial3D) -> void:
	var fruit_colors := [
		Color(0.82, 0.16, 0.12, 1.0),
		Color(0.98, 0.56, 0.12, 1.0),
		Color(0.40, 0.70, 0.24, 1.0)
	]
	for crate_index in range(3):
		var crate := Node3D.new()
		crate.name = "ProduceCrate_%02d" % crate_index
		crate.position = Vector3(-0.94 + float(crate_index) * 0.94, 1.12, 0.08)
		add_child(crate)
		_add_market_box(crate, "CrateBase", Vector3(0.82, 0.08, 0.62),
			Vector3(0.0, 0.04, 0.0), wood)
		for side in [-1.0, 1.0]:
			_add_market_box(crate, "CrateLongRim_%s" % str(side),
				Vector3(0.84, 0.24, 0.07), Vector3(0.0, 0.17, side * 0.275), wood)
			_add_market_box(crate, "CrateEndRim_%s" % str(side),
				Vector3(0.07, 0.24, 0.48), Vector3(side * 0.375, 0.17, 0.0), wood)

		var fruit_mesh := SphereMesh.new()
		fruit_mesh.radius = 0.11
		fruit_mesh.height = 0.19
		fruit_mesh.radial_segments = 8
		fruit_mesh.rings = 6
		var fruit_material := StandardMaterial3D.new()
		fruit_material.vertex_color_use_as_albedo = true
		fruit_material.roughness = 0.72
		var fruit_batch := MultiMeshInstance3D.new()
		fruit_batch.name = "FruitBatch"
		var instances := MultiMesh.new()
		instances.transform_format = MultiMesh.TRANSFORM_3D
		instances.use_colors = true
		instances.mesh = fruit_mesh
		instances.instance_count = 6
		for fruit_index in range(instances.instance_count):
			var column := fruit_index % 3
			var row := int(fruit_index / 3)
			var offset := Vector3(-0.22 + float(column) * 0.22, 0.27, -0.13 + float(row) * 0.26)
			var scale_factor := 0.88 + float((fruit_index + crate_index) % 3) * 0.06
			var basis := Basis(Vector3.UP, float(fruit_index) * 0.41).scaled(
				Vector3(scale_factor, 1.0, scale_factor))
			instances.set_instance_transform(fruit_index, Transform3D(basis, offset))
			instances.set_instance_color(fruit_index, fruit_colors[crate_index])
		fruit_batch.multimesh = instances
		fruit_batch.material_override = fruit_material
		crate.add_child(fruit_batch)


func _build_market_barrel(wood: StandardMaterial3D) -> void:
	var barrel := Node3D.new()
	barrel.name = "MarketBarrel"
	barrel.position = Vector3(1.98, 0.0, 0.22)
	add_child(barrel)
	var body := CylinderMesh.new()
	body.top_radius = 0.29
	body.bottom_radius = 0.35
	body.height = 0.88
	body.radial_segments = 12
	var body_instance := MeshInstance3D.new()
	body_instance.name = "BarrelBody"
	body_instance.mesh = body
	body_instance.position.y = 0.44
	body_instance.material_override = wood
	barrel.add_child(body_instance)
	var hoop_material := StandardMaterial3D.new()
	hoop_material.albedo_color = Color(0.25, 0.29, 0.29)
	hoop_material.metallic = 0.48
	hoop_material.roughness = 0.62
	for hoop_index in range(2):
		var hoop_mesh := CylinderMesh.new()
		hoop_mesh.top_radius = 0.355
		hoop_mesh.bottom_radius = 0.355
		hoop_mesh.height = 0.055
		hoop_mesh.radial_segments = 12
		var hoop := MeshInstance3D.new()
		hoop.name = "BarrelHoop_%02d" % hoop_index
		hoop.mesh = hoop_mesh
		hoop.position.y = 0.22 + float(hoop_index) * 0.45
		hoop.material_override = hoop_material
		barrel.add_child(hoop)


func _build_market_chalkboard(trim: StandardMaterial3D) -> void:
	var board := MeshInstance3D.new()
	board.name = "GroceryChalkboard"
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(0.66, 0.82, 0.075)
	board.mesh = board_mesh
	board.position = Vector3(-1.93, 1.05, 0.78)
	board.material_override = trim
	add_child(board)
	var writing_surface := MeshInstance3D.new()
	writing_surface.name = "ChalkboardWritingSurface"
	var surface_mesh := BoxMesh.new()
	surface_mesh.size = Vector3(0.57, 0.72, 0.018)
	writing_surface.mesh = surface_mesh
	writing_surface.position = Vector3(-1.93, 1.05, 0.825)
	var chalk_material := StandardMaterial3D.new()
	chalk_material.albedo_color = Color(0.075, 0.11, 0.10)
	chalk_material.roughness = 1.0
	writing_surface.material_override = chalk_material
	add_child(writing_surface)
	var chalk_text := Label3D.new()
	chalk_text.name = "ArabicMarketList"
	chalk_text.text = "خبز طازج\nفاكهة موسمية\nماء بارد"
	chalk_text.position = Vector3(-1.93, 1.05, 0.84)
	chalk_text.font_size = 21
	chalk_text.modulate = Color(0.94, 0.90, 0.74)
	chalk_text.outline_size = 2
	add_child(chalk_text)


func _add_market_box(parent: Node3D, node_name: String, size: Vector3,
		position: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	parent.add_child(instance)
	return instance


func _market_material(color: Color, texture: Texture2D) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.albedo_texture = texture
	material.uv1_scale = Vector3(1.7, 1.7, 1.7)
	material.roughness = 0.94
	return material
