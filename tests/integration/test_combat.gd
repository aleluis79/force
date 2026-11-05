extends GutTest

const PLAYER_POSITION := Vector2(80, 200)
const DUMMY_POSITION := Vector2(200, 200)


func test_player_spawns_bullets_when_shooting() -> void:
	var setup := _make_combat_setup()
	var input: ScriptedInputSource = setup.input

	input.aim_direction = Vector2.RIGHT
	input.shoot_pressed = true
	input.shoot_just_pressed = true
	await _wait_physics_frames(3)
	input.shoot_just_pressed = false

	assert_gt(setup.player.bullet_pool.active_count(), 0, "shooting must spawn bullets")


func test_player_damages_the_training_dummy() -> void:
	var setup := _make_combat_setup()
	var input: ScriptedInputSource = setup.input
	var dummy: TrainingDummy = setup.dummy

	input.aim_direction = Vector2.RIGHT
	input.shoot_pressed = true
	input.shoot_just_pressed = true
	await _wait_physics_frames(3)
	input.shoot_pressed = false
	input.shoot_just_pressed = false

	await _wait_physics_frames(30)

	assert_lt(dummy.health.current, dummy.health.max_health, "bullet must damage the dummy")


func test_bullet_reports_the_damage_it_applies() -> void:
	var setup := _make_combat_setup()
	var input: ScriptedInputSource = setup.input
	var pool: BulletPool = setup.player.bullet_pool
	watch_signals(pool)

	input.aim_direction = Vector2.RIGHT
	input.shoot_pressed = true
	input.shoot_just_pressed = true
	await _wait_physics_frames(3)
	input.shoot_pressed = false
	input.shoot_just_pressed = false

	await _wait_physics_frames(30)

	assert_signal_emitted(pool, "hit_confirmed")
	var parameters = get_signal_parameters(pool, "hit_confirmed")
	assert_not_null(parameters)
	if parameters != null:
		assert_eq(parameters[2], WeaponStats.rifle().damage)


func test_bullet_destroys_terrain_on_impact() -> void:
	var setup := _make_combat_setup()
	var input: ScriptedInputSource = setup.input
	var terrain: DestructibleTerrain = setup.terrain
	var before := terrain.get_solid_cell_count()

	input.aim_direction = Vector2.DOWN
	input.shoot_pressed = true
	input.shoot_just_pressed = true
	await _wait_physics_frames(3)
	input.shoot_pressed = false
	input.shoot_just_pressed = false

	await _wait_physics_frames(20)

	assert_lt(terrain.get_solid_cell_count(), before, "bullet must destroy terrain")


func test_firing_applies_recoil_against_the_aim() -> void:
	var setup := _make_combat_setup()
	var player: Player = setup.player
	player.aim_direction = Vector2.RIGHT
	player.velocity = Vector2.ZERO

	player._fire()

	assert_lt(player.velocity.x, 0.0, "recoil must push opposite to the aim")


func _make_combat_setup() -> Dictionary:
	var terrain := DestructibleTerrain.new()
	add_child_autoqfree(terrain)

	var dummy_packed := load("res://scenes/training_dummy.tscn") as PackedScene
	var dummy := dummy_packed.instantiate() as TrainingDummy
	dummy.position = DUMMY_POSITION
	add_child_autoqfree(dummy)

	var input := ScriptedInputSource.new()
	var player_packed := load("res://scenes/player.tscn") as PackedScene
	var player := player_packed.instantiate() as Player
	player.input_source = input
	player.position = PLAYER_POSITION
	add_child_autoqfree(player)

	return {"player": player, "input": input, "terrain": terrain, "dummy": dummy}


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame


func test_bullets_spawn_from_the_gun_on_the_right() -> void:
	var setup := _make_combat_setup()
	var player: Player = setup.player
	player.aim_direction = Vector2.RIGHT

	player._fire()

	var bullets := _visible_bullets(player)
	assert_eq(bullets.size(), 1)
	var bullet: Bullet = bullets[0]
	assert_lt(bullet.global_position.y, player.global_position.y - 2.0)
	assert_gt(bullet.global_position.x, player.global_position.x + 8.0)


func test_bullets_spawn_from_the_gun_on_the_left() -> void:
	var setup := _make_combat_setup()
	var player: Player = setup.player
	player.aim_direction = Vector2.LEFT

	player._fire()

	var bullets := _visible_bullets(player)
	assert_eq(bullets.size(), 1)
	var bullet: Bullet = bullets[0]
	assert_lt(bullet.global_position.y, player.global_position.y - 2.0)
	assert_lt(bullet.global_position.x, player.global_position.x - 8.0)


func test_bullets_spawn_above_when_aiming_up() -> void:
	var setup := _make_combat_setup()
	var player: Player = setup.player
	player.aim_direction = Vector2.UP

	player._fire()

	var bullets := _visible_bullets(player)
	assert_eq(bullets.size(), 1)
	var bullet: Bullet = bullets[0]
	assert_lt(bullet.global_position.y, player.global_position.y - 10.0)


func _visible_bullets(player: Player) -> Array:
	var bullets := []
	for child in player.bullet_pool.get_children():
		if child is Bullet and child.visible:
			bullets.append(child)
	return bullets
