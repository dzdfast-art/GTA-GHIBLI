extends RefCounted
class_name GhibliAmbientAudioState
var region: String="default"
var period: String="day"
var weather: String="clear"
var intensity: float=1.0
func update_context(region_id: String, time_period: String, weather_id: String) -> bool:
	if region_id.is_empty() or not ["morning","day","evening","night"].has(time_period) or not ["clear","rain","storm","fog"].has(weather_id): return false
	region=region_id
	period=time_period
	weather=weather_id
	return true
func set_intensity(value: float) -> void:
	intensity=clampf(value,0.0,1.0)
func get_mix_profile() -> Dictionary:
	return {"region":region,"period":period,"weather":weather,"intensity":intensity}