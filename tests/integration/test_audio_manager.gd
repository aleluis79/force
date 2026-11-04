extends GutTest


func test_sfx_catalog_is_complete() -> void:
	for sound_name in [
		"shoot", "shotgun", "jump", "hit", "explosion",
		"pickup", "death", "victory", "hurt",
	]:
		assert_true(AudioManager.has_sfx(sound_name), "missing SFX: %s" % sound_name)


func test_music_is_available() -> void:
	assert_true(AudioManager.has_music())


func test_unknown_sfx_is_safe() -> void:
	AudioManager.play_sfx("does_not_exist")
	assert_false(AudioManager.has_sfx("does_not_exist"))
