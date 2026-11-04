extends Node

## Central SFX and music playback with a small round-robin voice pool.

const SFX := {
	"shoot": preload("res://assets/audio/sfx/shoot.wav"),
	"shotgun": preload("res://assets/audio/sfx/shotgun.wav"),
	"jump": preload("res://assets/audio/sfx/jump.wav"),
	"hit": preload("res://assets/audio/sfx/hit.wav"),
	"explosion": preload("res://assets/audio/sfx/explosion.wav"),
	"pickup": preload("res://assets/audio/sfx/pickup.wav"),
	"death": preload("res://assets/audio/sfx/death.wav"),
	"victory": preload("res://assets/audio/sfx/victory.wav"),
	"hurt": preload("res://assets/audio/sfx/hurt.wav"),
}

const MUSIC := preload("res://assets/audio/music/level_theme.wav")
const VOICE_COUNT := 8

var _voices: Array[AudioStreamPlayer] = []
var _next_voice := 0
var _music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for index in VOICE_COUNT:
		var voice := AudioStreamPlayer.new()
		voice.volume_db = -8.0
		add_child(voice)
		_voices.append(voice)

	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = -12.0
	add_child(_music_player)
	_music_player.finished.connect(_music_player.play)


func play_sfx(sound_name: String) -> void:
	if not SFX.has(sound_name) or _voices.is_empty():
		return

	var voice := _voices[_next_voice]
	_next_voice = (_next_voice + 1) % _voices.size()
	voice.stream = SFX[sound_name]
	voice.play()


func play_music() -> void:
	if _music_player == null:
		return
	if _music_player.stream == null:
		_music_player.stream = MUSIC
	if not _music_player.playing:
		_music_player.play()


func stop_music() -> void:
	if _music_player != null:
		_music_player.stop()
		_music_player.stream = null


func has_sfx(sound_name: String) -> bool:
	return SFX.has(sound_name)


func has_music() -> bool:
	return MUSIC != null


func _exit_tree() -> void:
	if _music_player != null:
		_music_player.stop()
		_music_player.stream = null
	for voice in _voices:
		voice.stop()
		voice.stream = null
