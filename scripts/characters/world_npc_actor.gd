extends Node3D
@export var character_id := "nader_harbor"
@export var character_name_ar := "نادر"
@export var outfit_color := Color(0.28,0.43,0.62)
@export var skin_color := Color(0.78,0.58,0.43)
@export var hair_color := Color(0.16,0.12,0.10)
@export var hidden_story_character := false
const BRAIN = preload("res://scripts/systems/npc_brain.gd")
var _lines: Array = []
var _line_index := 0
var _near := false
var _brain: Node
var _voice: AudioStreamPlayer
var _panel: PanelContainer
var _name_label: Label
var _text_label: Label
var _hint: Label
var _arms: Array[MeshInstance3D] = []
var _legs: Array[MeshInstance3D] = []
var _clock := 0.0
var _last_pos := Vector3.ZERO

func _ready() -> void:
	_last_pos = global_position
	_load_lines()
	_build_model()
	_build_interaction()
	_build_ui()
	_brain = Node.new()
	_brain.name = "NPCBrain"
	_brain.set_script(BRAIN)
	_brain.set("persistence_id", character_id)
	_brain.set("schedule_enabled", true)
	_brain.set("home_position", global_position)
	_brain.set("work_position", global_position + Vector3(1.5,0,1))
	add_child(_brain)
	if hidden_story_character:
		visible = false

func _process(delta: float) -> void:
	_clock += delta
	var speed := global_position.distance_to(_last_pos) / maxf(delta,0.001)
	_last_pos = global_position
	var swing := sin(_clock*8.0)*clampf(speed*0.5,0,1)*0.42
	for i in range(_arms.size()): _arms[i].rotation.x = swing if i==0 else -swing
	for i in range(_legs.size()): _legs[i].rotation.x = -swing*0.7 if i==0 else swing*0.7

func get_character_id() -> String:
	return character_id

func interact() -> void:
	if hidden_story_character or not _near: return
	_brain.call("record_interaction","talk")
	if _lines.is_empty():
		_text_label.text = "أهلاً بك! يسعدني أن أراك هنا."
		_panel.visible = true
		return
	var line: Dictionary = _lines[_line_index % _lines.size()]
	_line_index += 1
	_name_label.text = character_name_ar + " — " + str(line.get("emotion_ar","يتحدث"))
	_text_label.text = str(line.get("text_ar",""))
	_panel.visible = true
	_hint.text = "اضغط زر التفاعل لسماع جملة أخرى"
	var path := str(line.get("audio_path",""))
	if ResourceLoader.exists(path):
		_voice.stream = load(path)
		_voice.play()

func _load_lines() -> void:
	var f := FileAccess.open("res://data/characters/world_dialogue_ar.json",FileAccess.READ)
	if f == null: return
	var parsed = JSON.parse_string(f.get_as_text())
	if not parsed is Dictionary: return
	var data: Dictionary = parsed.get("characters",{}).get(character_id,{})
	character_name_ar = str(data.get("name_ar",character_name_ar))
	var lines = data.get("lines",[])
	if lines is Array: _lines = lines

func _build_model() -> void:
	_mesh("Torso",_capsule(0.34,1.12),Vector3(0,1.02,0),outfit_color)
	_mesh("Head",_sphere(0.27),Vector3(0,1.88,0),skin_color)
	_mesh("Hair",_sphere(0.285),Vector3(0,2.04,-0.02),hair_color)
	_arms.append(_mesh("ArmLeft",_capsule(0.105,0.82),Vector3(-0.43,1.02,0),outfit_color))
	_arms.append(_mesh("ArmRight",_capsule(0.105,0.82),Vector3(0.43,1.02,0),outfit_color))
	_legs.append(_mesh("LegLeft",_capsule(0.13,0.84),Vector3(-0.17,0.39,0),Color(0.16,0.20,0.27)))
	_legs.append(_mesh("LegRight",_capsule(0.13,0.84),Vector3(0.17,0.39,0),Color(0.16,0.20,0.27)))
	var tag := Label3D.new()
	tag.name = "NameTag"
	tag.text = character_name_ar
	tag.position.y = 2.48
	tag.font_size = 26
	tag.modulate = Color(1,0.92,0.70)
	tag.outline_size = 5
	add_child(tag)

func _build_interaction() -> void:
	var area := Area3D.new()
	area.name = "InteractionArea"
	area.collision_layer = 2
	area.collision_mask = 1
	area.add_to_group("interaction_areas")
	add_child(area)
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.8
	shape.shape = sphere
	shape.position.y = 1.0
	area.add_child(shape)
	area.body_entered.connect(_on_enter)
	area.body_exited.connect(_on_exit)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 6
	add_child(layer)
	_voice = AudioStreamPlayer.new()
	_voice.bus = "Dialogue"
	add_child(_voice)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	_hint = Label.new()
	_hint.text = "اقترب من " + character_name_ar + " واضغط زر التفاعل"
	_hint.text_direction = Control.TEXT_DIRECTION_RTL
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.anchor_left=0.18
	_hint.anchor_top=0.61
	_hint.anchor_right=0.82
	_hint.anchor_bottom=0.68
	_hint.visible=false
	_hint.add_theme_font_size_override("font_size",17)
	_hint.add_theme_color_override("font_color",Color(1,0.83,0.38))
	root.add_child(_hint)
	_panel = PanelContainer.new()
	_panel.name = "GoldenDialogueBox"
	_panel.anchor_left=0.055
	_panel.anchor_top=0.72
	_panel.anchor_right=0.945
	_panel.anchor_bottom=0.96
	_panel.visible=false
	var style := StyleBoxFlat.new()
	style.bg_color=Color(0.10,0.07,0.025,0.95)
	style.border_color=Color(1,0.72,0.16)
	style.set_border_width_all(3)
	style.set_corner_radius_all(7)
	_panel.add_theme_stylebox_override("panel",style)
	root.add_child(_panel)
	var box := VBoxContainer.new()
	_panel.add_child(box)
	_name_label=Label.new()
	_name_label.text=character_name_ar
	_name_label.text_direction=Control.TEXT_DIRECTION_RTL
	_name_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	_name_label.add_theme_color_override("font_color",Color(1,0.78,0.25))
	box.add_child(_name_label)
	_text_label=Label.new()
	_text_label.text_direction=Control.TEXT_DIRECTION_RTL
	_text_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	_text_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size",22)
	_text_label.add_theme_color_override("font_color",Color(1,0.88,0.50))
	box.add_child(_text_label)

func _on_enter(body: Node3D) -> void:
	if body.is_in_group("player"):
		_near=true
		_hint.visible=true

func _on_exit(body: Node3D) -> void:
	if body.is_in_group("player"):
		_near=false
		_panel.visible=false
		_hint.visible=false
		_voice.stop()

func _mesh(n:String,m:Mesh,p:Vector3,c:Color)->MeshInstance3D:
	var node:=MeshInstance3D.new()
	node.name=n
	node.mesh=m
	node.position=p
	var mat:=StandardMaterial3D.new()
	mat.albedo_color=c
	mat.roughness=0.82
	node.material_override=mat
	add_child(node)
	return node

func _capsule(r:float,h:float)->CapsuleMesh:
	var m:=CapsuleMesh.new()
	m.radius=r
	m.height=h
	return m

func _sphere(r:float)->SphereMesh:
	var m:=SphereMesh.new()
	m.radius=r
	m.height=r*2
	return m
