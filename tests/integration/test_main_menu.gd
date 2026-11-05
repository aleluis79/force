extends GutTest

const MENU_SCENE := "res://scenes/main_menu.tscn"


func test_menu_scene_has_expected_panels_and_buttons() -> void:
	var menu = await _make_menu()
	assert_not_null(menu)
	if menu == null:
		return

	assert_true(menu.get_node("MainCenter/MainPanel").visible)
	assert_false(menu.get_node("OptionsCenter/OptionsPanel").visible)
	assert_false(menu.get_node("ControlsCenter/ControlsPanel").visible)

	var play_button := menu.get_node("MainCenter/MainPanel/PlayButton") as Button
	assert_not_null(play_button)
	assert_true(play_button.has_focus(), "Play must start focused")


func test_options_and_controls_panels_switch() -> void:
	var menu = await _make_menu()
	assert_not_null(menu)
	if menu == null:
		return

	menu._on_options_pressed()
	assert_false(menu.get_node("MainCenter/MainPanel").visible)
	assert_true(menu.get_node("OptionsCenter/OptionsPanel").visible)

	menu._on_back_pressed()
	assert_true(menu.get_node("MainCenter/MainPanel").visible)
	assert_false(menu.get_node("OptionsCenter/OptionsPanel").visible)

	menu._on_controls_pressed()
	assert_true(menu.get_node("ControlsCenter/ControlsPanel").visible)
	assert_false(menu.get_node("MainCenter/MainPanel").visible)


func test_escape_returns_to_main_panel() -> void:
	var menu = await _make_menu()
	assert_not_null(menu)
	if menu == null:
		return

	menu._on_options_pressed()
	var event := InputEventKey.new()
	event.keycode = KEY_ESCAPE
	event.physical_keycode = KEY_ESCAPE
	event.pressed = true
	menu._unhandled_input(event)

	assert_true(menu.get_node("MainCenter/MainPanel").visible)
	assert_false(menu.get_node("OptionsCenter/OptionsPanel").visible)


func test_volume_option_cycles_and_updates_label() -> void:
	var menu = await _make_menu()
	assert_not_null(menu)
	if menu == null:
		return

	var volume_button := menu.get_node("OptionsCenter/OptionsPanel/VolumeButton") as Button
	var before: int = menu.volume_index

	menu._on_volume_pressed()

	assert_ne(menu.volume_index, before)
	assert_true(volume_button.text.contains("%"))


func test_fullscreen_option_toggles_state() -> void:
	var menu = await _make_menu()
	assert_not_null(menu)
	if menu == null:
		return

	var before: bool = menu.fullscreen
	menu._on_fullscreen_pressed()
	assert_ne(menu.fullscreen, before)
	menu._on_fullscreen_pressed()
	assert_eq(menu.fullscreen, before)


func test_menu_points_to_the_playable_level() -> void:
	assert_eq(MainMenu.LEVEL_SCENE, "res://scenes/level_01.tscn")


func test_quit_button_is_connected() -> void:
	var menu = await _make_menu()
	assert_not_null(menu)
	if menu == null:
		return

	var quit_button := menu.get_node("MainCenter/MainPanel/QuitButton") as Button
	var connected := false
	for connection in quit_button.pressed.get_connections():
		if connection.callable.get_method() == "_on_quit_pressed":
			connected = true

	assert_true(connected, "quit button must invoke the quit handler")


func _make_menu() -> Control:
	var packed := load(MENU_SCENE) as PackedScene
	assert_not_null(packed, "main menu scene must load")
	if packed == null:
		return null
	var menu := packed.instantiate() as Control
	add_child_autoqfree(menu)
	await get_tree().process_frame
	return menu
