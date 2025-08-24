extends Node2D

signal beat(number: int)

@onready var main: AudioStreamPlayer = %Main
@onready var music: AudioStreamPlayer = %Music

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
var time_counter: float = 0.0
var seconds_per_beat: float = 60.0 / tempo

var start_beat = false
func _process(delta: float) -> void:
	if !start_beat:
		return
	time_counter += delta
	if time_counter > seconds_per_beat:
		time_counter -= seconds_per_beat
		beat_number += 1
		beat.emit(beat_number)

func start_intro():
	main.volume_db = 0.0
	main.stream = intro
	main.play()

# Make sure it stays in sync
func _restart_beat():
	time_counter = 0.0
	beat_number = 0
	music.play()
	push_warning("restart beat!")

func _ready() -> void:
	music.finished.connect(_restart_beat)

func full_ensemble():
	switch_to_track(track_progression.size() - 1)

func switch_to_track(number: int):
	current_track_index = number
	var track = track_progression[current_track_index] as AudioStream

	var current_playback_position: float = 0.0
	if (music.stream != null):
		current_playback_position = music.get_playback_position()
		music.stop()
	
	music.stream = track
	music.play(current_playback_position)

func next_track():
	if (main.playing):
		var tween = create_tween()
		tween.tween_property(main, "volume_db", -80.0, 1.69)
		tween.tween_callback(main.stop)

	if (current_track_index >= track_progression.size()):
		return

	# Start the beat along with the first instrument
	if music.stream == null:
		start_beat = true
		time_counter = 0.0

	switch_to_track(current_track_index)
	current_track_index += 1

func pop_instrument() -> bool:
	if current_track_index <= 0:
		start_beat = false
		time_counter = 0.0
		music.stop()
		return false

	current_track_index -= 1
	switch_to_track(current_track_index)
	return true
