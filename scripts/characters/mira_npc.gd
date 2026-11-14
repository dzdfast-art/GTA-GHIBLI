extends Node3D

## Mira: first Arabic-speaking NPC prototype.
## Dialogue is data-driven; voice audio is optional until the recorded asset is added.

signal dialogue_spoken

const DIALOGUE_DATA_PATH := "res://data/dialogue/mira_intro_ar.json"

var _player_nearby := false
var _dialogue_panel: PanelContainer
var _dialogue_label: Label
var _emotion_label: Label
var _hint_label: Label
var _voice_player: AudioStreamPlayer
var _greeting: Dictionary = {}\nvar _npc_brain: Node


func _ready() -> void:
	_load_dialogue_data()
	_build_character()
	_build_interaction_area()
	_build_dialogue_ui()


func _load_dialogue_data() -> void:
	if not FileAccess.file_exists(DIALOGUE_DATA_PATH):
		push_warning("Mira Arabic dialogue data is missing.")
		return

	var file := FileAccess.open(DIALOGUE_DATA_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open Mira Arabic dialogue data.")
		return

	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_greeting = parsed.get("greeting", {})
	else:
		push_warning("Mira Arabic dialogue data has an invalid format.")


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
	name_tag.text = "ميرا"
	name_tag.position = Vector3(0.0, 2.35, 0.0)
	name_tag.font_size = 32
	name_tag.modulate = Color(1.0, 0.94, 0.75)
	add_child(name_tag)


func _build_interaction_area() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 2
	area.collision_mask = 1
	area.add_to_group("interaction_areas")
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

	_voice_player = AudioStreamPlayer.new()
	_voice_player.name = "ArabicDialogueVoice"
	add_child(_voice_player)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	_hint_label = Label.new()
	_hint_label.text = "اقترب من ميرا واضغط زر التفاعل"
	_hint_label.text_direction = Control.TEXT_DIRECTION_RTL
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.anchor_left = 0.18
	_hint_label.anchor_top = 0.61
	_hint_label.anchor_right = 0.82
	_hint_label.anchor_bottom = 0.67
	_hint_label.visible = false
	_hint_label.add_theme_font_size_override("font_size", 16)
	root.add_child(_hint_label)

	_dialogue_panel = PanelContainer.new()
	_dialogue_panel.anchor_left = 0.06
	_dialogue_panel.anchor_top = 0.68
	_dialogue_panel.anchor_right = 0.94
	_dialogue_panel.anchor_bottom = 0.96
	_dialogue_panel.visible = false
	root.add_child(_dialogue_panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	_dialogue_panel.add_child(content)

	_emotion_label = Label.new()
	_emotion_label.text = "ميرا — سعيدة ومرحّبة"
	_emotion_label.text_direction = Control.TEXT_DIRECTION_RTL
	_emotion_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_emotion_label.add_theme_font_size_override("font_size", 16)
	content.add_child(_emotion_label)

	_dialogue_label = Label.new()
	_dialogue_label.text = "صباح الخير!"
	_dialogue_label.text_direction = Control.TEXT_DIRECTION_RTL
	_dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override("font_size", 20)
	content.add_child(_dialogue_label)




func _attach_npc_brain() -> void:
	var brain_script = preload("res://scripts/systems/npc_brain.gd")
	_npc_brain = Node.new()
	_npc_brain.name = "NPCBrain"
	_npc_brain.set_script(brain_script)
	add_child(_npc_brain)
	_npc_brain.state_changed.connect(_on_brain_state_changed)


func _on_brain_state_changed(state_id: String, emotion_ar: String) -> void:
	if _emotion_label != null:
		_emotion_label.text = "ميرا — " + emotion_ar
	if not _player_nearby or _hint_label == null:
		return
	match state_id:
		"friendly":
			_hint_label.text = "ميرا تبتسم لك — اضغط زر التفاعل للتحدث"
		"cautious":
			_hint_label.text = "ميرا تتراجع بحذر — اقترب بهدوء"
		"alarmed":
			_hint_label.text = "ميرا خائفة من اقترابك السريع"
		"curious":
			_hint_label.text = "ميرا تلاحظ وجودك"
		_:
			_hint_label.text = "اقترب من ميرا واضغط زر التفاعل"


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		_player_nearby = true
		_hint_label.text = "اقترب من ميرا واضغط زر التفاعل"
		_hint_label.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		_player_nearby = false
		_dialogue_panel.visible = false
		_hint_label.visible = false
		if _voice_player != null:
			_voice_player.stop()


func interact() -> void:
	if _player_nearby:
		_show_dialogue()


func _show_dialogue() -> void:
	if _greeting.is_empty():
		_dialogue_label.text = "صباح الخير! أهلاً بك في قرية الصفصاف."
		_emotion_label.text = "ميرا — سعيدة ومرحّبة"
	else:
		_dialogue_label.text = str(_greeting.get("text_ar", "صباح الخير! أهلاً بك في قرية الصفصاف."))
		_emotion_label.text = "ميرا — " + str(_greeting.get("emotion_ar", "سعيدة ومرحّبة"))

	_dialogue_panel.visible = true
	_hint_label.text = "اضغط زر التفاعل لإعادة سماع ميرا"
	_hint_label.visible = true
	dialogue_spoken.emit()
	_play_greeting_voice()


func _play_greeting_voice() -> void:
	if _voice_player == null or _greeting.is_empty():
		return

	var audio_path := str(_greeting.get("audio_path", ""))
	if audio_path.is_empty() or not ResourceLoader.exists(audio_path):
		return

	var audio_stream = load(audio_path)
	if audio_stream is AudioStream:
		_voice_player.stream = audio_stream
		_voice_player.play()


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
