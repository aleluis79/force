extends GutTest

const PLAYER_POSITION := Vector2(80, 200)


func test_grunt_moves_toward_the_player() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200))
	var grunt: Grunt = setup.enemy

	await _wait_physics_frames(60)
	var start_x := grunt.global_position.x
	await _wait_physics_frames(30)

	assert_lt(grunt.global_position.x, start_x - 5.0, "grunt must walk toward the player")


func test_grunt_damages_the_player_on_contact() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(100, 200))
	var player: Player = setup.player

	await _wait_physics_frames(30)

	assert_false(player.alive, "grunt contact must kill the player")


func test_kamikaze_moves_toward_the_player() -> void:
	var setup := _make_world("res://scenes/kamikaze.tscn", Vector2(300, 100))
	var kamikaze: Kamikaze = setup.enemy
	var player: Player = setup.player
	var initial_distance := kamikaze.global_position.distance_to(player.global_position)

	await _wait_physics_frames(20)

	assert_lt(
		kamikaze.global_position.distance_to(player.global_position),
		initial_distance,
		"kamikaze must fly toward the player"
	)


func test_kamikaze_damages_and_dies_on_contact() -> void:
	var setup := _make_world("res://scenes/kamikaze.tscn", Vector2(80, 200))
	var player: Player = setup.player
	var kamikaze: Kamikaze = setup.enemy

	await _wait_physics_frames(10)

	assert_false(player.alive, "kamikaze contact must kill the player")
	assert_false(is_instance_valid(kamikaze), "kamikaze must die on contact")


func test_enemy_death_emits_score() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200))
	var grunt: Grunt = setup.enemy
	watch_signals(grunt)

	grunt.take_damage(30)

	assert_signal_emitted_with_parameters(grunt, "died", [100])


func _make_world(
	enemy_scene: String,
	enemy_position: Vector2,
	player_position: Vector2 = PLAYER_POSITION
) -> Dictionary:
	var terrain := DestructibleTerrain.new()
	add_child_autoqfree(terrain)

	var input := ScriptedInputSource.new()
	var player_packed := load("res://scenes/player.tscn") as PackedScene
	var player := player_packed.instantiate() as Player
	player.input_source = input
	player.position = player_position
	add_child_autoqfree(player)

	var enemy_packed := load(enemy_scene) as PackedScene
	var enemy := enemy_packed.instantiate()
	enemy.position = enemy_position
	add_child_autoqfree(enemy)

	return {"player": player, "enemy": enemy}


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame


func test_grunt_faces_left_when_the_player_is_left() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200))
	var grunt: Grunt = setup.enemy

	await _wait_physics_frames(30)

	var sprite := grunt.get_node("Sprite") as Sprite2D
	assert_false(sprite.flip_h, "grunt art faces left by default")


func test_grunt_faces_right_when_the_player_is_right() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(100, 200), Vector2(300, 200))
	var grunt: Grunt = setup.enemy

	await _wait_physics_frames(30)

	var sprite := grunt.get_node("Sprite") as Sprite2D
	assert_true(sprite.flip_h, "grunt must flip when chasing to the right")


func test_kamikaze_faces_its_flight_direction() -> void:
	var setup := _make_world("res://scenes/kamikaze.tscn", Vector2(300, 100))
	var kamikaze: Kamikaze = setup.enemy
	var player: Player = setup.player

	await _wait_physics_frames(2)

	var expected := (player.global_position - kamikaze.global_position).normalized().angle()
	assert_almost_eq(kamikaze.rotation, expected, 0.2)
	var sprite := kamikaze.get_node("Sprite") as Sprite2D
	assert_true(sprite.flip_h, "missile art points left and must be flipped")
