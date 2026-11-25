extends SceneTree

const SAVE_MANAGER_SCRIPT: Script = preload("res://scripts/world/save_slot_manager.gd")
const HUD_SCRIPT: Script = preload("res://scripts/ui/game_hud.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager: RefCounted = SAVE_MANAGER_SCRIPT.new()
	if typeof(manager.call("is_storage_persistent")) != TYPE_BOOL:
		_fail("The save manager did not expose a boolean user:// persistence status.")
		return

	var persistent_message := str(manager.call(
		"get_storage_status_message", true, true, "en", true
	))
	if persistent_message != "BROWSER STORAGE — may be cleared by browser":
		_fail("Persistent browser storage did not receive the cautious browser-storage message.")
		return

	var temporary_message := str(manager.call(
		"get_storage_status_message", false, true, "en", true
	))
	if temporary_message != "SESSION ONLY — allow browser storage":
		_fail("Unavailable browser persistence did not produce a session-only warning.")
		return

	var failed_message := str(manager.call(
		"get_storage_status_message", true, true, "en", false
	))
	if failed_message != "SAVE FAILED — check browser storage":
		_fail("A failed save did not produce a visible storage error.")
		return

	var arabic_temporary_message := str(manager.call(
		"get_storage_status_message", false, true, "ar", true
	))
	if arabic_temporary_message != "حفظ مؤقت فقط — اسمح بتخزين المتصفح":
		_fail("The temporary-storage warning is missing its Arabic message.")
		return

	var native_message := str(manager.call(
		"get_storage_status_message", true, false, "en", true
	))
	if native_message != "LOCAL SAVE — stored on this device":
		_fail("The native storage message incorrectly describes a local save as browser-only.")
		return

	var hud: CanvasLayer = HUD_SCRIPT.new()
	root.add_child(hud)
	await process_frame
	hud.call("set_save_storage_status", temporary_message, false, true)
	if str(hud.call("get_save_storage_status_text")) != temporary_message:
		_fail("The gameplay HUD did not display the session-only save warning.")
		return
	hud.call("set_save_storage_status", failed_message, true, false)
	if str(hud.call("get_save_storage_status_text")) != failed_message:
		_fail("The gameplay HUD did not display the failed-save warning.")
		return

	print("PASS: persistent, session-only, native and failed-save status messages are distinct.")
	print("PASS: browser persistence warnings include Arabic text and reach the gameplay HUD.")
	quit(0)


func _fail(message: String) -> void:
	push_error("FAIL: " + message)
	quit(1)
