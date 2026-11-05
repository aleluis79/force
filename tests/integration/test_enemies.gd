extends GutTest

const PLAYER_POSITION := Vector2(80, 200)


func after_each() -> void:
	for bullet in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(bullet):
			bullet.free()


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

	assert_lt(player.health.current, player.health.max_health, "grunt contact must damage the player")


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

	assert_lt(player.health.current, player.health.max_health, "kamikaze contact must damage the player")
	assert_false(is_instance_valid(kamikaze), "kamikaze must die on contact")


func test_grunt_fires_at_the_player_in_range() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200), Vector2(200, 200))
	var grunt: Grunt = setup.enemy
	grunt._shoot_cooldown = 0.0

	await _wait_physics_frames(2)

	assert_eq(grunt.shots_fired, 1, "grunt must fire when the player is in range")


func test_grunt_respects_its_shooting_cadence() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200), Vector2(200, 200))
	var grunt: Grunt = setup.enemy
	grunt._shoot_cooldown = 0.0

	await _wait_physics_frames(2)
	var shots_after_first: int = grunt.shots_fired
	await _wait_physics_frames(5)

	assert_eq(grunt.shots_fired, shots_after_first, "grunt must wait before firing again")


func test_grunt_fires_again_after_its_interval() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200), Vector2(200, 200))
	var grunt: Grunt = setup.enemy
	grunt._shoot_cooldown = 0.0

	await _wait_physics_frames(2)
	var first_shot: int = grunt.shots_fired
	await _wait_physics_frames(60)

	assert_gt(grunt.shots_fired, first_shot, "grunt must keep firing at a sustained cadence")


func test_grunt_does_not_fire_out_of_range() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200), Vector2(900, 200))
	var grunt: Grunt = setup.enemy
	grunt._shoot_cooldown = 0.0

	await _wait_physics_frames(5)

	assert_eq(grunt.shots_fired, 0, "grunt must not fire outside its range")


func test_dead_grunt_stops_firing() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200), Vector2(200, 200))
	var grunt: Grunt = setup.enemy
	grunt._shoot_cooldown = 0.0

	grunt.take_damage(999)
	await _wait_physics_frames(5)

	assert_false(is_instance_valid(grunt), "dead grunt must be removed and stop shooting")


func test_grunt_aims_at_the_player_torso() -> void:
	var setup := _make_world("res://scenes/grunt.tscn", Vector2(300, 200), Vector2(200, 200))
	var grunt: Grunt = setup.enemy
	grunt._shoot_cooldown = 0.0

	await _wait_physics_frames(2)

	var bullets := get_tree().get_nodes_in_group("enemy_projectiles")
	assert_gt(bullets.size(), 0, "grunt must spawn an enemy projectile")
	if not bullets.is_empty():
		var bullet := bullets[0] as EnemyBullet
		assert_gt(bullet.direction.y, 0.0, "grunt must aim below its muzzle toward the torso")


func test_bullet_hits_a_grunt_at_head_height() -> void:
	var terrain := DestructibleTerrain.new()
	add_child_autoqfree(terrain)
	terrain.rebuild(60, 34, 6, [])

	var enemy_packed := load("res://scenes/grunt.tscn") as PackedScene
	var grunt := enemy_packed.instantiate() as Grunt
	grunt.position = Vector2(200, 200)
	add_child_autoqfree(grunt)
	grunt.set_physics_process(false)

	var pool := BulletPool.new()
	add_child_autoqfree(pool)
	# The grunt sprite extends 30 px above its origin; the old shape only reached -12.
	var head_height := grunt.global_position + Vector2(-24, -22)
	pool.spawn(head_height, Vector2.RIGHT, WeaponStats.rifle(), terrain)

	await _wait_physics_frames(5)

	assert_lt(grunt.health.current, grunt.health.max_health, "headshots must damage the grunt")


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
