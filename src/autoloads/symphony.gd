extends Node2D

signal beat(number: int)

@onready var main: AudioStreamPlayer = %Main
@onready var music: AudioStreamPlayer = %Music
@onready var music_2: AudioStreamPlayer = %Music2

var current_player_index: int = 0
var music_players: Array[AudioStreamPlayer]:
	get:
		return [music, music_2]

func get_current_player() -> AudioStreamPlayer:
	return music_players[current_player_index]

func switch_player() -> AudioStreamPlayer:
	current_player_index = (current_player_index + 1) % music_players.size()
	return get_current_player()

const tempo: int = 102
const intro = preload("res://assets/audio/SoundshipSPACE_.wav")

var current_track_index: int = 0

var track_progression: Array[AudioStream] = [
	preload("res://assets/audio/symphony/Soundship01.wav"),
	preload("res://assets/audio/symphony/Soundship02.wav"),
	preload("res://assets/audio/symphony/Soundship03.wav"),
	preload("res://assets/audio/symphony/Soundship04.wav"),
	preload("res://assets/audio/symphony/Soundship05.wav"),
	preload("res://assets/audio/symphony/Soundship06.wav"),
	preload("res://assets/audio/symphony/Soundship07.wav"),
	preload("res://assets/audio/symphony/Soundship08.wav"),
	preload("res://assets/audio/symphony/Soundship09.wav"),
	preload("res://assets/audio/symphony/Soundship10.wav"),
	preload("res://assets/audio/symphony/Soundship11.wav"),
	preload("res://assets/audio/symphony/Soundship12.wav"),
	preload("res://assets/audio/symphony/Soundship13.wav"),
	preload("res://assets/audio/symphony/Soundship14.wav"),
	preload("res://assets/audio/symphony/Soundship15.wav")
]

var beat_number: int = 0
var seconds_per_beat: float = 60.0 / tempo
var track_length = track_progression[0].get_length()
var highest_beat = int(track_length / seconds_per_beat) + 1

var start_beat = false

var prev_playback_position: float = 0.0

func _physics_process(_delta: float) -> void:
	if !start_beat:
		return

	var current_player = get_current_player()
	var current_playback_position: float = current_player.get_playback_position()
	
	var next_beat = (int)(current_playback_position / seconds_per_beat) % highest_beat

	if next_beat != beat_number:
		beat_number = next_beat
		beat.emit(beat_number)
		print("%s/%s" % [beat_number, highest_beat])

func start_intro():
	main.volume_db = 0.0
	main.stream = intro
	main.play()

func full_ensemble():
	switch_to_track(track_progression.size() - 1)

func switch_to_track(number: int):
	if !start_beat:
		start_beat = true
	current_track_index = number
	var track = track_progression[current_track_index] as AudioStream

	var current_playback_position: float = 0.0
	# Start the beat along with the first instrument
	var current_player = get_current_player()
	if current_player.stream != null:
		current_playback_position = current_player.get_playback_position() + AudioServer.get_time_since_last_mix()
		current_player.stop()
	
	var player = switch_player()
	player.volume_db = 0.0
	player.stream = track
	player.play(current_playback_position)

func next_track():
	if (main.playing):
		var tween = create_tween()
		tween.tween_property(main, "volume_db", -80.0, 1.69)
		tween.tween_callback(main.stop)

	if (current_track_index >= track_progression.size()):
		return

	switch_to_track(current_track_index)
	current_track_index += 1

func pop_instrument() -> bool:
	if current_track_index <= 0:
		start_beat = false
		var current_player = get_current_player()
		current_player.stop()
		return false

	current_track_index -= 1
	switch_to_track(current_track_index)
	return true
