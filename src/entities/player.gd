class_name Player
extends CharacterBody2D

## CharacterBody2D adapter for the pure PlayerMotion model.

var input_source: InputSource
var motion := PlayerMotion.new()
var aim_direction := Vector2.RIGHT

@onready var _camera: PlayerCamera = get_node_or_null("Camera2D") as PlayerCamera


func _ready() -> void:
	if input_source == null:
		input_source = LocalInputSource.new()


func _physics_process(delta: float) -> void:
	aim_direction = input_source.get_aim_direction(global_position, get_global_mouse_position())

	velocity = motion.tick(
		delta,
		input_source.get_move_axis(),
		input_source.was_jump_just_pressed(),
		input_source.was_jump_just_released(),
		is_on_floor()
	)

	move_and_slide()

	motion.velocity = velocity
	motion.grounded = is_on_floor()

	if _camera != null:
		_camera.update_look_ahead(aim_direction)
