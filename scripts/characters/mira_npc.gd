extends Node3D

## First village NPC: Mira, the caretaker. Lightweight procedural prototype.

var _player_nearby := false
var _dialogue_panel: PanelContainer
var _dialogue_label: Label
var _hint_label: Label


func _ready() -> void:
	_register_interaction_action()
	_build_character()
	_build_interaction_area()
	_build_dialogue_ui()


func _process(_delta: float) -> void:
	if _player_nearby and Input.is_action_just_pressed("interact"):
		_show_dialogue()


func _register_interaction_action() -> void:
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		var key_event := InputEventKey.new()
		key_event.physical_keycode = KEY_E
		InputMap.action_add_event("interact", key_event)


func _build_character() -> void:
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.42
	body_mesh.height = 1.35
	_add_mesh("Body", body_mesh, Vector3(0.0, 0.85, 0.0), Color(0.42, 0.57, 0.39))

	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.28
	head_mesh.height = 0.56
	_add_mesh("Head", head_mesh, Vector3(0.0, 1.72, 0.0), Color(0.91, 0.72, 0.57))

	var hair_mesh := SphereMesh.new()
	hair_mesh.radius = 0.30
	hair_mesh.height = 0.28
	_add_mesh("Hair", hair_mesh, Vector3(0.0, 1.91, -0.035), Color(0.25, 0.17, 0.12))

	var apron_mesh := BoxMesh.new()
	apron_mesh.size = Vector3(0.48, 0.62, 0.08)
	_add_mesh("Apron", apron_mesh, Vector3(0.0, 0.83, 0.25), Color(0.83, 0.77, 0.58))

	var name_tag := Label3D.new()
	name_tag.name = "NameTag"
	name_tag.text = "MIRA"
	name_tag.position = Vector3(0.0, 2.35, 0.0)
	name_tag.font_size = 32
	name_tag.modulate = Color(1.0, 0.94, 0.75)
	add_child(name_tag)


func _build_interaction_area() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 0
	area.collision_mask = 1
	add_child(area)

	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 3.0
	collision.shape = sphere
	collision.position.y = 1.0
	area.add_child(collision)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _build_dialogue_ui() -> void:
	var layer := CanvasLayer.new()
	layer.name = "MiraDialogue"
	layer.layer = 5
	add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.anchor_left = 0.12
	_dialogue_panel.anchor_top = 0.72
	_dialogue_panel.anchor_right = 0.88
	_dialogue_panel.anchor_bottom = 0.96
	_dialogue_panel.visible = false
	root.add_child(_dialogue_panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	_dialogue_panel.add_child(content)

	_dialogue_label = Label.new()
	_dialogue_label.text = "Mira"
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_dialogue_label)

	_hint_label = Label.new()
	_hint_label.text = "Press E or tap TALK to continue exploring."
	_hint_label.add_theme_font_size_override("font_size", 13)
	content.add_child(_hint_label)


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_player_nearby = true
		_hint_label.text = "Press E or tap TALK to speak with Mira."


func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		_player_nearby = false
		_dialogue_panel.visible = false


func _show_dialogue() -> void:
	_dialogue_label.text = "Mira: Good morning, traveler! Welcome to Willow Village.\nThe garden needs a little care. Visit it when you are ready."
	_dialogue_panel.visible = true


func _add_mesh(node_name: String, mesh: Mesh, local_position: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = local_position
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	instance.material_override = material
	add_child(instance)
