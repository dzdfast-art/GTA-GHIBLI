extends RefCounted
class_name GhibliAccessibilityOptions
var subtitles: bool=true
var high_contrast: bool=false
var reduced_camera_motion: bool=false
var text_scale: float=1.0
func set_text_scale(value: float) -> bool:
	if value<0.75 or value>1.75: return false
	text_scale=value
	return true
func set_option(option: String, enabled: bool) -> bool:
	match option:
		"subtitles": subtitles=enabled
		"high_contrast": high_contrast=enabled
		"reduced_camera_motion": reduced_camera_motion=enabled
		_: return false
	return true
func snapshot() -> Dictionary:
	return {"subtitles":subtitles,"high_contrast":high_contrast,"reduced_camera_motion":reduced_camera_motion,"text_scale":text_scale}