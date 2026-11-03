extends GutTest

const INTERNAL_WIDTH := 480
const INTERNAL_HEIGHT := 270
const WINDOW_WIDTH := 1440
const WINDOW_HEIGHT := 810


func test_internal_resolution_is_480x270() -> void:
	assert_eq(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		INTERNAL_WIDTH,
		"internal viewport width must be 480"
	)
	assert_eq(
		ProjectSettings.get_setting("display/window/size/viewport_height"),
		INTERNAL_HEIGHT,
		"internal viewport height must be 270"
	)


func test_window_starts_at_3x_scale() -> void:
	assert_eq(
		ProjectSettings.get_setting("display/window/size/window_width_override"),
		WINDOW_WIDTH,
		"window width override must be 1440"
	)
	assert_eq(
		ProjectSettings.get_setting("display/window/size/window_height_override"),
		WINDOW_HEIGHT,
		"window height override must be 810"
	)


func test_stretch_keeps_aspect_and_uses_integer_scale() -> void:
	assert_eq(
		ProjectSettings.get_setting("display/window/stretch/mode"),
		"canvas_items",
		"stretch mode must be canvas_items"
	)
	assert_eq(
		ProjectSettings.get_setting("display/window/stretch/aspect"),
		"keep",
		"aspect must be kept to avoid deformation"
	)
	assert_eq(
		ProjectSettings.get_setting("display/window/stretch/scale_mode"),
		"integer",
		"scale mode must be integer"
	)


func test_nearest_filter_and_pixel_snap_are_enabled() -> void:
	assert_eq(
		ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter"),
		0,
		"default texture filter must be nearest"
	)
	assert_true(
		ProjectSettings.get_setting("rendering/2d/snap/snap_2d_transforms_to_pixel"),
		"2D transforms must snap to pixel"
	)
	assert_true(
		ProjectSettings.get_setting("rendering/2d/snap/snap_2d_vertices_to_pixel"),
		"2D vertices must snap to pixel"
	)


func test_renderer_is_gl_compatibility() -> void:
	assert_eq(
		ProjectSettings.get_setting("rendering/renderer/rendering_method"),
		"gl_compatibility",
		"renderer must be gl_compatibility"
	)


func test_physics_runs_at_60_ticks() -> void:
	assert_eq(
		ProjectSettings.get_setting("physics/common/physics_ticks_per_second"),
		60,
		"physics must run at 60 ticks per second"
	)


func test_main_scene_is_bootstrap() -> void:
	assert_eq(
		ProjectSettings.get_setting("application/run/main_scene"),
		"res://scenes/bootstrap.tscn",
		"main scene must be the bootstrap scene"
	)
