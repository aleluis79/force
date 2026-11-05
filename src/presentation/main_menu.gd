class_name MainMenu
extends Control

## Initial menu with play, options, controls and quit actions.

const LEVEL_SCENE := "res://scenes/level_01.tscn"
const VOLUME_STEPS := [1.0, 0.75, 0.5, 0.25, 0.0]

var fullscreen := false
var volume_index := 0

@onready var _main_panel: Control = $MainCenter/MainPanel
@onready var _options_panel: Control = $OptionsCenter/OptionsPanel
@onready var _controls_panel: Control = $ControlsCenter/ControlsPanel
@onready var _play_button: Button = $MainCenter/MainPanel/PlayButton
@onready var _fullscreen_button: Button = $OptionsCenter/OptionsPanel/FullscreenButton
@onready var _volume_button: Button = $OptionsCenter/OptionsPanel/VolumeButton


func _ready() -> void:
	fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_play_button.pressed.connect(_on_play_pressed)
	$MainCenter/MainPanel/OptionsButton.pressed.connect(_on_options_pressed)
	$MainCenter/MainPanel/ControlsButton.pressed.connect(_on_controls_pressed)
	$MainCenter/MainPanel/QuitButton.pressed.connect(_on_quit_pressed)
	_fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	_volume_button.pressed.connect(_on_volume_pressed)
	$OptionsCenter/OptionsPanel/OptionsBackButton.pressed.connect(_on_back_pressed)
	$ControlsCenter/ControlsPanel/ControlsBackButton.pressed.connect(_on_back_pressed)

	_apply_volume()
	_refresh_options()
	_show_main()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _options_panel.visible or _controls_panel.visible:
		_show_main()
		get_viewport().set_input_as_handled()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_SCENE)


func _on_options_pressed() -> void:
	_show_options()


func _on_controls_pressed() -> void:
	_show_controls()


func _on_back_pressed() -> void:
	_show_main()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_fullscreen_pressed() -> void:
	fullscreen = not fullscreen
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
		)
	_refresh_options()


func _on_volume_pressed() -> void:
	volume_index = (volume_index + 1) % VOLUME_STEPS.size()
	_apply_volume()
	_refresh_options()


func _show_main() -> void:
	_main_panel.show()
	_options_panel.hide()
	_controls_panel.hide()
	_play_button.grab_focus()


func _show_options() -> void:
	_main_panel.hide()
	_options_panel.show()
	_controls_panel.hide()
	_fullscreen_button.grab_focus()


func _show_controls() -> void:
	_main_panel.hide()
	_options_panel.hide()
	_controls_panel.show()
	$ControlsCenter/ControlsPanel/ControlsBackButton.grab_focus()


func _apply_volume() -> void:
	var linear: float = VOLUME_STEPS[volume_index]
	AudioServer.set_bus_mute(0, linear <= 0.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(linear, 0.001)))


func _refresh_options() -> void:
	_fullscreen_button.text = "PANTALLA COMPLETA: %s" % ("SÍ" if fullscreen else "NO")
	_volume_button.text = "VOLUMEN: %d%%" % roundi(VOLUME_STEPS[volume_index] * 100.0)
