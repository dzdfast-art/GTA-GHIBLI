extends RefCounted
class_name GhibliContextualInputMap
var contexts: Dictionary={}
func bind_action(context: String, action: String, key: String) -> bool:
	if context.is_empty() or action.is_empty() or key.is_empty(): return false
	if not contexts.has(context): contexts[context]={}
	contexts[context][action]=key
	return true
func get_binding(context: String, action: String) -> String:
	return str(contexts.get(context,{}).get(action,""))
func resolve(context: String, key: String) -> String:
	for action in contexts.get(context,{}):
		if contexts[context][action]==key: return str(action)
	return ""
func clear_context(context: String) -> bool:
	return contexts.erase(context)