extends RefCounted
class_name GhibliLocalizationRegistry
var locale: String="en"
var strings: Dictionary={}
func register(key: String, language: String, value: String) -> bool:
	if key.is_empty() or not ["en","ar"].has(language) or value.is_empty(): return false
	if not strings.has(key): strings[key]={}
	strings[key][language]=value
	return true
func set_locale(language: String) -> bool:
	if not ["en","ar"].has(language): return false
	locale=language
	return true
func translate(key: String) -> String:
	if not strings.has(key): return key
	return str(strings[key].get(locale,strings[key].get("en",key)))
func is_rtl() -> bool:
	return locale == "ar"