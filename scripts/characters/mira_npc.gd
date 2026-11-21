extends Node3D
signal dialogue_spoken
const DIALOGUE_DATA_PATH := "res://data/dialogue/mira_intro_ar.json"
var _player_nearby := false
var _dialogue_panel: PanelContainer
var _dialogue_label: Label
var _emotion_label: Label
var _hint_label: Label
var _voice_player: AudioStreamPlayer
var _voice_request: HTTPRequest
var _greeting: Dictionary = {}
var _npc_brain: Node

func _ready() -> void:
	_load_dialogue_data()
	_build_character()
	_build_interaction_area()
	_build_dialogue_ui()
	_attach_npc_brain()

func _load_dialogue_data() -> void:
	if not FileAccess.file_exists(DIALOGUE_DATA_PATH):
		push_warning("Mira Arabic dialogue data is missing.")
		return
	var file := FileAccess.open(DIALOGUE_DATA_PATH,FileAccess.READ)
	if file == null:
		push_warning("Could not open Mira Arabic dialogue data.")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_greeting = parsed.get("greeting",{})
	else:
		push_warning("Mira Arabic dialogue data has an invalid format.")

func _build_character() -> void:
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius=0.42
	body_mesh.height=1.35
	_add_mesh("Body",body_mesh,Vector3(0,0.85,0),Color(0.42,0.57,0.39))
	var head_mesh := SphereMesh.new()
	head_mesh.radius=0.28
	head_mesh.height=0.56
	_add_mesh("Head",head_mesh,Vector3(0,1.72,0),Color(0.91,0.72,0.57))
	var hair_mesh := SphereMesh.new()
	hair_mesh.radius=0.30
	hair_mesh.height=0.28
	_add_mesh("Hair",hair_mesh,Vector3(0,1.91,-0.035),Color(0.25,0.17,0.12))
	var apron_mesh := BoxMesh.new()
	apron_mesh.size=Vector3(0.48,0.62,0.08)
	_add_mesh("Apron",apron_mesh,Vector3(0,0.83,0.25),Color(0.83,0.77,0.58))
	var tag:=Label3D.new()
	tag.name="NameTag"
	tag.text="ميرا"
	tag.position=Vector3(0,2.35,0)
	tag.font_size=32
	tag.modulate=Color(1,0.94,0.75)
	add_child(tag)

func _build_interaction_area() -> void:
	var area:=Area3D.new()
	area.name="InteractionArea"
	area.collision_layer=2
	area.collision_mask=1
	area.add_to_group("interaction_areas")
	add_child(area)
	var collision:=CollisionShape3D.new()
	var sphere:=SphereShape3D.new()
	sphere.radius=3.0
	collision.shape=sphere
	collision.position.y=1.0
	area.add_child(collision)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _build_dialogue_ui() -> void:
	var layer:=CanvasLayer.new()
	layer.name="MiraDialogue"
	layer.layer=5
	add_child(layer)
	_voice_player=AudioStreamPlayer.new()
	_voice_player.name="ArabicDialogueVoice"
	_voice_player.bus="Dialogue"
	add_child(_voice_player)
	_voice_request=HTTPRequest.new()
	_voice_request.timeout=25.0
	_voice_request.body_size_limit=2097152
	_voice_request.request_completed.connect(_on_voice_downloaded)
	add_child(_voice_request)
	var root:=Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter=Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)
	_hint_label=Label.new()
	_hint_label.text="اقترب من ميرا واضغط زر التفاعل"
	_hint_label.text_direction=Control.TEXT_DIRECTION_RTL
	_hint_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.anchor_left=0.18
	_hint_label.anchor_top=0.61
	_hint_label.anchor_right=0.82
	_hint_label.anchor_bottom=0.67
	_hint_label.visible=false
	_hint_label.add_theme_font_size_override("font_size",16)
	_hint_label.add_theme_color_override("font_color",Color(1,0.82,0.34,1))
	root.add_child(_hint_label)
	_dialogue_panel=PanelContainer.new()
	_dialogue_panel.name="GoldenDialogueBox"
	_dialogue_panel.anchor_left=0.055
	_dialogue_panel.anchor_top=0.72
	_dialogue_panel.anchor_right=0.945
	_dialogue_panel.anchor_bottom=0.96
	_dialogue_panel.visible=false
	var style:=StyleBoxFlat.new()
	style.bg_color=Color(0.105,0.073,0.022,0.94)
	style.border_color=Color(1,0.72,0.16,1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(7)
	style.content_margin_left=22.0
	style.content_margin_right=22.0
	style.content_margin_top=12.0
	style.content_margin_bottom=12.0
	_dialogue_panel.add_theme_stylebox_override("panel",style)
	root.add_child(_dialogue_panel)
	var content:=VBoxContainer.new()
	content.add_theme_constant_override("separation",5)
	_dialogue_panel.add_child(content)
	_emotion_label=Label.new()
	_emotion_label.name="SpeakerAndEmotion"
	_emotion_label.text="ميرا — سعيدة ومرحّبة"
	_emotion_label.text_direction=Control.TEXT_DIRECTION_RTL
	_emotion_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	_emotion_label.add_theme_font_size_override("font_size",16)
	_emotion_label.add_theme_color_override("font_color",Color(1,0.78,0.25,1))
	content.add_child(_emotion_label)
	_dialogue_label=Label.new()
	_dialogue_label.name="GoldenDialogueText"
	_dialogue_label.text="صباح الخير!"
	_dialogue_label.text_direction=Control.TEXT_DIRECTION_RTL
	_dialogue_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	_dialogue_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.add_theme_font_size_override("font_size",24)
	_dialogue_label.add_theme_color_override("font_color",Color(1,0.88,0.48,1))
	content.add_child(_dialogue_label)

func _attach_npc_brain() -> void:
	var brain_script=preload("res://scripts/systems/npc_brain.gd")
	_npc_brain=Node.new()
	_npc_brain.name="NPCBrain"
	_npc_brain.set_script(brain_script)
	add_child(_npc_brain)
	_npc_brain.state_changed.connect(_on_brain_state_changed)

func _on_brain_state_changed(state_id:String,emotion_ar:String)->void:
	if _emotion_label!=null:
		_emotion_label.text="ميرا — "+emotion_ar
	if not _player_nearby or _hint_label==null:return
	match state_id:
		"friendly": _hint_label.text="ميرا تبتسم لك — اضغط زر التفاعل للتحدث"
		"cautious": _hint_label.text="ميرا تتراجع بحذر — اقترب بهدوء"
		"alarmed": _hint_label.text="ميرا خائفة من اقترابك السريع"
		"curious": _hint_label.text="ميرا تلاحظ وجودك"
		_: _hint_label.text="اقترب من ميرا واضغط زر التفاعل"

func _on_body_entered(body:Node3D)->void:
	if body is CharacterBody3D:
		_player_nearby=true
		_hint_label.text="اقترب من ميرا واضغط زر التفاعل"
		_hint_label.visible=true

func _on_body_exited(body:Node3D)->void:
	if body is CharacterBody3D:
		_player_nearby=false
		_dialogue_panel.visible=false
		_hint_label.visible=false
		_voice_player.stop()

func interact()->void:
	if _player_nearby:
		if _npc_brain!=null:_npc_brain.call("record_interaction","talk")
		_show_dialogue()

func _show_dialogue()->void:
	if _greeting.is_empty():
		_dialogue_label.text="صباح الخير! أهلاً بك في قرية الصفصاف."
		_emotion_label.text="ميرا — سعيدة ومرحّبة"
	else:
		_dialogue_label.text=str(_greeting.get("text_ar","صباح الخير! أهلاً بك في قرية الصفصاف."))
		_emotion_label.text="ميرا — "+str(_greeting.get("emotion_ar","سعيدة ومرحّبة"))
	_dialogue_panel.visible=true
	_hint_label.text="اضغط زر التفاعل لإعادة سماع ميرا"
	_hint_label.visible=true
	dialogue_spoken.emit()
	_play_greeting_voice()

func _play_greeting_voice()->void:
	_apply_greeting_voice_mix()
	if _voice_player==null or _greeting.is_empty():return
	var path:=str(_greeting.get("audio_path",""))
	if not path.is_empty() and ResourceLoader.exists(path):
		_voice_player.stream=load(path)
		_voice_player.play()
		return
	var cache:="user://voice_cache/mira_greeting_001.mp3"
	if FileAccess.file_exists(cache):
		_play_cached(cache)
		return
	var url:=str(_greeting.get("audio_url",""))
	if OS.has_feature("web"):
		return
	if not url.is_empty():
		var error:=_voice_request.request(url)
		if error!=OK:push_warning("Could not start Mira voice download.")

func _apply_greeting_voice_mix()->void:
	# A small tonal adjustment is only a mix aid; the final emotional delivery must be recorded in the voice take.
	var emotion_id:=str(_greeting.get("emotion_id","joy"))
	match emotion_id:
		"sadness": _voice_player.pitch_scale=0.985; _voice_player.volume_db=-1.5
		"fear": _voice_player.pitch_scale=1.015; _voice_player.volume_db=-1.0
		"anger": _voice_player.pitch_scale=1.0; _voice_player.volume_db=0.5
		"surprise": _voice_player.pitch_scale=1.045; _voice_player.volume_db=0.0
		"tenderness": _voice_player.pitch_scale=0.97; _voice_player.volume_db=-1.0
		_: _voice_player.pitch_scale=1.025; _voice_player.volume_db=-0.5

func _on_voice_downloaded(result:int,response_code:int,_headers:PackedStringArray,body:PackedByteArray)->void:
	if result!=HTTPRequest.RESULT_SUCCESS or response_code!=200 or body.is_empty():
		push_warning("Mira Arabic voice download failed.")
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://voice_cache"))
	var cache:="user://voice_cache/mira_greeting_001.mp3"
	var file:=FileAccess.open(cache,FileAccess.WRITE)
	if file==null:return
	file.store_buffer(body)
	file.close()
	_play_cached(cache)

func _play_cached(path:String)->void:
	var file:=FileAccess.open(path,FileAccess.READ)
	if file==null:return
	var mp3:=AudioStreamMP3.new()
	mp3.data=file.get_buffer(file.get_length())
	_voice_player.stream=mp3
	_voice_player.play()

func _add_mesh(node_name:String,mesh:Mesh,local_position:Vector3,color:Color)->void:
	var instance:=MeshInstance3D.new()
	instance.name=node_name
	instance.mesh=mesh
	instance.position=local_position
	var material:=StandardMaterial3D.new()
	material.albedo_color=color
	material.roughness=0.9
	instance.material_override=material
	add_child(instance)
