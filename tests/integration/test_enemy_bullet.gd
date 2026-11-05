extends GutTest

const ENEMY_BULLET_SCENE := "res://scenes/enemy_bullet.tscn"


func after_each() -> void:
	for bullet in get_tree().get_nodes_in_group("enemy_projectiles"):
		if is_instance_valid(bullet):
			bullet.free()


func test_enemy_bullet_moves_in_its_direction() -> void:
	var bullet := _make_bullet(Vector2.ZERO)
	bullet.setup(Vector2.RIGHT, null)

	await _wait_physics_frames(5)

	assert_gt(bullet.global_position.x, 5.0)


func test_enemy_bullet_damages_the_player_and_disappears() -> void:
	var packed := load("res://scenes/player.tscn") as PackedScene
	var player := packed.instantiate() as Player
	player.position = Vector2(100, 200)
	add_child_autoqfree(player)
	player.set_physics_process(false)

	var bullet := _make_bullet(player.global_position + Vector2(-24, 0))
	bullet.setup(Vector2.RIGHT, null)

	await _wait_physics_frames(20)

	assert_lt(player.health.current, player.health.max_health, "enemy bullet must damage the player")
	assert_false(is_instance_valid(bullet), "enemy bullet must disappear after hitting")


func test_enemy_bullet_does_not_destroy_terrain() -> void:
	var terrain := DestructibleTerrain.new()
	add_child_autoqfree(terrain)
	var solid_before := terrain.get_solid_cell_count()

	var bullet := _make_bullet(Vector2(100, 200))
	bullet.setup(Vector2.DOWN, terrain)

	await _wait_physics_frames(20)

	assert_eq(terrain.get_solid_cell_count(), solid_before, "enemy bullets must not destroy terrain")
	assert_false(is_instance_valid(bullet), "enemy bullet must disappear against terrain")


func test_crouching_dodges_a_torso_shot() -> void:
	var ground := StaticBody2D.new()
	ground.position = Vector2(240, 250)
	var ground_shape := CollisionShape2D.new()
	var ground_rect := RectangleShape2D.new()
	ground_rect.size = Vector2(480, 32)
	ground_shape.shape = ground_rect
	ground.add_child(ground_shape)
	add_child_autoqfree(ground)

	var input := ScriptedInputSource.new()
	var packed := load("res://scenes/player.tscn") as PackedScene
	var player := packed.instantiate() as Player
	player.input_source = input
	player.position = Vector2(100, 200)
	add_child_autoqfree(player)

	await _wait_physics_frames(60)
	input.crouch_pressed = true
	await _wait_physics_frames(2)

	var crouched_shot := _make_bullet(player.global_position + Vector2(-40, -10))
	crouched_shot.setup(Vector2.RIGHT, null)
	await _wait_physics_frames(20)

	assert_eq(player.health.current, player.health.max_health, "crouching must dodge the torso shot")

	input.crouch_pressed = false
	await _wait_physics_frames(2)
	var standing_shot := _make_bullet(player.global_position + Vector2(-40, -10))
	standing_shot.setup(Vector2.RIGHT, null)
	await _wait_physics_frames(20)

	assert_lt(player.health.current, player.health.max_health, "standing must be hit by the torso shot")


func test_player_bullet_destroys_an_enemy_bullet() -> void:
	var enemy_bullet := _make_bullet(Vector2(200, 200))
	enemy_bullet.setup(Vector2.LEFT, null)

	var pool := BulletPool.new()
	add_child_autoqfree(pool)
	pool.spawn(Vector2(100, 200), Vector2.RIGHT, WeaponStats.rifle(), null)

	await _wait_physics_frames(12)

	assert_false(is_instance_valid(enemy_bullet), "player bullets must destroy enemy projectiles")


func test_enemy_bullet_can_be_destroyed_by_damage() -> void:
	var bullet := _make_bullet(Vector2.ZERO)

	assert_eq(bullet.take_damage(10), 10)
	await _wait_physics_frames(2)

	assert_false(is_instance_valid(bullet), "damaged enemy bullet must disappear")


func _make_bullet(position: Vector2) -> EnemyBullet:
	var packed := load(ENEMY_BULLET_SCENE) as PackedScene
	assert_not_null(packed, "enemy bullet scene must load")
	var bullet := packed.instantiate() as EnemyBullet
	bullet.position = position
	add_child_autoqfree(bullet)
	return bullet


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame
