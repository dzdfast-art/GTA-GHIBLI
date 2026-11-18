extends CanvasLayer

## Mobile-friendly in-engine cinematic with moving camera, letterbox bars and Arabic subtitles.
## Real Arabic voice recordings and authored character animation remain separate production assets.

const STORY_PATH := "res://data/story/chapter_01_opening.json"
const SHOT_OFFSETS: Array[Vector3] = [
	Vector3(0.0, 5.5, 11.0),
	Vector3(-8.0, 3.2, 5.5),
	Vector3(7.0, 2.8, 4.0),
	Vector3(0.0, 6.0, -8.0),
	Vector3(0.0, 4.0, 9.0)
]
var _lines: Array[Dictionary] = []
var _index := -1
var _line_time := 0.0
var _active := false
var _title: Label
var _subtitle: Label
var _chapter: Label
var _top_bar: ColorRect
var _bottom_bar: ColorRect
var _hint: Label
var _player: Node3D
var _cinematic_camera: Camera3D
var _camera_original_top_level := false
var _player_physics_was_enabled := true


func _ready() -> void:
	layer = 20
	_build_overlay()
	_load_story()
	if not _lines.is_empty():
		start_opening()


func _build_overlay() -> void:
	_top_bar = ColorRect.new()
	_top_bar.color = Color(0.0, 0.0, 0.0, 0.96)
	_top_bar.anchor_right = 1.0
	_top_bar.anchor_bottom = 0.105
	add_child(_top_bar)

	_bottom_bar = ColorRect.new()
	_bottom_bar.color = Color(0.0, 0.0, 0.0, 0.96)
	_bottom_bar.anchor_top = 0.82
	_bottom_bar.anchor_right = 1.0
	_bottom_bar.anchor_bottom = 1.0
	add_child(_bottom_bar)

	_chapter = Label.new()
	_chapter.anchor_left = 0.08
	_chapter.anchor_top = 0.025
	_chapter.anchor_right = 0.92
	_chapter.anchor_bottom = 0.09
	_chapter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_chapter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_chapter.add_theme_font_size_override("font_size", 18)
	_chapter.add_theme_color_override("font_color", Color(0.88, 0.78, 0.56))
	add_child(_chapter)

	_title = Label.new()
	_title.anchor_left = 0.08
	_title.anchor_top = 0.34
	_title.anchor_right = 0.92
	_title.anchor_bottom = 0.48
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title.add_theme_font_size_override("font_size", 30)
	_title.add_theme_color_override("font_color", Color(1.0, 0.91, 0.72))
	add_child(_title)

	_subtitle = Label.new()
	_subtitle.anchor_left = 0.07
	_subtitle.anchor_top = 0.835
	_subtitle.anchor_right = 0.93
	_subtitle.anchor_bottom = 0.94
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle.text_direction = Control.TEXT_DIRECTION_RTL
	_subtitle.add_theme_font_size_override("font_size", 19)
	_subtitle.add_theme_color_override("font_color", Color.WHITE)
	add_child(_subtitle)

	_hint = Label.new()
	_hint.text = "المس الشاشة للتخطي أو المتابعة"
	_hint.anchor_left = 0.58
	_hint.anchor_top = 0.95
	_hint.anchor_right = 0.96
	_hint.anchor_bottom = 0.99
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.add_theme_font_size_override("font_size", 11)
	_hint.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75))
	add_child(_hint)


func _load_story() -> void:
	if not FileAccess.file_exists(STORY_PATH):
		push_warning("Opening story data is missing.")
		return
	var file := FileAccess.open(STORY_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_warning("Opening story data must be a JSON object.")
		return
	_chapter.text = str(parsed.get("chapter_title_ar", "الفصل الأول"))
	var entries = parsed.get("opening", [])
	if entries is Array:
		for entry in entries:
			if entry is Dictionary:
				_lines.append(entry)


func start_opening() -> void:
	if _lines.is_empty() or _active:
		return
	_player = get_tree().get_first_node_in_group("player") as Node3D
	if _player != null:
		_player_physics_was_enabled = _player.is_physics_processing()
		_player.set_physics_process(false)
		var camera := _player.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") as Camera3D
		if camera != null:
			_cinematic_camera = camera
			_camera_original_top_level = camera.is_set_as_top_level()
			camera.set_as_top_level(true)
			camera.current = true
	_active = true
	_index = -1
	_advance()


func _process(delta: float) -> void:
	if not _active:
		return
	if _cinematic_camera != null and is_instance_valid(_cinematic_camera) and _player != null:
		_cinematic_camera.look_at(_player.global_position + Vector3(0.0, 1.0, 0.0), Vector3.UP)
	_line_time -= delta
	if _line_time <= 0.0:
		_advance()


func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventScreenTouch and event.pressed:
		_advance()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_SPACE, KEY_ENTER]:
		_advance()


func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		_finish()
		return
	var entry := _lines[_index]
	_title.text = str(entry.get("shot_title_ar", ""))
	_subtitle.text = str(entry.get("subtitle_ar", ""))
	_line_time = maxf(float(entry.get("duration_seconds", 4.0)), 1.5)
	_title.modulate.a = 0.0
	_subtitle.modulate.a = 0.0
	var text_tween := create_tween()
	text_tween.set_parallel(true)
	text_tween.tween_property(_title, "modulate:a", 1.0, 0.45)
	text_tween.tween_property(_subtitle, "modulate:a", 1.0, 0.45)
	if _cinematic_camera != null and is_instance_valid(_cinematic_camera) and _player != null:
		var offset: Vector3 = SHOT_OFFSETS[posmod(_index, SHOT_OFFSETS.size())]
		var destination := _player.global_position + offset
		var camera_tween := create_tween()
		camera_tween.tween_property(_cinematic_camera, "global_position", destination, 1.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _finish() -> void:
	_active = false
	if _cinematic_camera != null and is_instance_valid(_cinematic_camera):
		_cinematic_camera.set_as_top_level(_camera_original_top_level)
		_cinematic_camera.current = true
	if _player != null and is_instance_valid(_player):
		_player.set_physics_process(_player_physics_was_enabled)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)
