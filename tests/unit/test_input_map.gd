extends GutTest

const ACTIONS: Array[String] = [
	"move_left",
	"move_right",
	"aim_left",
	"aim_right",
	"aim_up",
	"aim_down",
	"jump",
	"shoot",
	"special",
	"pause",
	"restart",
]

const KEYBOARD_OR_MOUSE_ACTIONS: Array[String] = [
	"move_left",
	"move_right",
	"jump",
	"shoot",
	"special",
	"pause",
	"restart",
]


func test_all_actions_exist() -> void:
	for action in ACTIONS:
		assert_true(InputMap.has_action(action), "missing input action: %s" % action)


func test_gameplay_actions_have_keyboard_or_mouse_bindings() -> void:
	for action in KEYBOARD_OR_MOUSE_ACTIONS:
		assert_true(
			_has_event_of_type(action, "key_or_mouse"),
			"%s must have a keyboard or mouse binding" % action
		)


func test_all_actions_have_gamepad_bindings() -> void:
	for action in ACTIONS:
		assert_true(
			_has_event_of_type(action, "gamepad"),
			"%s must have a gamepad binding" % action
		)


func test_pause_and_restart_do_not_require_mouse() -> void:
	for action in ["pause", "restart"]:
		assert_true(
			_has_event_of_type(action, "key"),
			"%s must have a keyboard binding" % action
		)


func _has_event_of_type(action: String, kind: String) -> bool:
	for event in InputMap.action_get_events(action):
		match kind:
			"key":
				if event is InputEventKey:
					return true
			"key_or_mouse":
				if event is InputEventKey or event is InputEventMouseButton:
					return true
			"gamepad":
				if event is InputEventJoypadButton or event is InputEventJoypadMotion:
					return true
	return false
