extends GutTest


func test_pow_rescues_once_on_contact() -> void:
	var setup := _make_world()
	var pow: Pow = setup.pow
	var rescue_counter := [0]
	pow.rescued.connect(func(): rescue_counter[0] += 1)

	await _wait_physics_frames(20)

	assert_eq(rescue_counter[0], 1, "a POW must only be rescued once")
	assert_false(is_instance_valid(pow), "rescued POW must be freed")


func _make_world() -> Dictionary:
	var terrain := DestructibleTerrain.new()
	add_child_autoqfree(terrain)

	var input := ScriptedInputSource.new()
	var player_packed := load("res://scenes/player.tscn") as PackedScene
	var player := player_packed.instantiate() as Player
	player.input_source = input
	player.position = Vector2(80, 200)
	add_child_autoqfree(player)

	var pow_packed := load("res://scenes/pow.tscn") as PackedScene
	var pow := pow_packed.instantiate() as Pow
	pow.position = Vector2(85, 200)
	add_child_autoqfree(pow)

	return {"player": player, "pow": pow}


func _wait_physics_frames(count: int) -> void:
	for index in count:
		await get_tree().physics_frame
