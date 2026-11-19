extends Node

## Deterministic time/weather source for vehicle-light regression tests.
var game_hour := 12.0
var weather_id := "clear"

func get_game_hour() -> float:
	return game_hour

func get_weather() -> String:
	return weather_id
