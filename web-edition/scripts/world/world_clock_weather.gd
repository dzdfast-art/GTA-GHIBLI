extends RefCounted
class_name GhibliWorldClockWeather
var minute_of_day: int=8*60
var weather: String="clear"
func advance_minutes(minutes: int) -> int:
	if minutes<0: return minute_of_day
	minute_of_day=(minute_of_day+minutes)%1440
	return minute_of_day
func set_weather(value: String) -> bool:
	if not ["clear","cloudy","rain","storm","fog"].has(value): return false
	weather=value
	return true
func get_period() -> String:
	if minute_of_day<360 or minute_of_day>=1200: return "night"
	if minute_of_day<600: return "morning"
	if minute_of_day<1020: return "day"
	return "evening"
func get_time_string() -> String:
	return "%02d:%02d" % [minute_of_day/60,minute_of_day%60]