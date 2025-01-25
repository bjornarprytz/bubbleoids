extends Node2D

signal beat

var _streamPlayers: Dictionary[String, AudioStreamPlayer] = {}

const tempo: int = 102

var instruments: Array[AudioStream] = [
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

var time_counter: float = 0.0
var seconds_per_beat: float = 60.0 / tempo

var start_beat = false
func _process(delta: float) -> void:
	if !start_beat:
		return
	time_counter += delta
	if time_counter > seconds_per_beat:
		time_counter -= seconds_per_beat
		beat.emit()

func muffle():
	print("Muffle disabled due to poor web performance")
	return
	for player in _streamPlayers.values():
		player.set_bus("Muffle")
func unmuffle():
	return
	for player in _streamPlayers.values():
		player.set_bus("Master")

# Make sure it stays in sync
func _restart_beat():
	time_counter = 0.0

func add_instrument():
	if (instruments.size() == 0):
		print("Found all instruments already")
		return
	
	# Star the beat along with the first instrument
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	if _streamPlayers.size() == 0:
		start_beat = true
		time_counter = 0.0
		player.finished.connect(_restart_beat)
	player.finished.connect(player.play)
	var instrument = instruments.pop_front() as AudioStream
		
	_streamPlayers[instrument.resource_path] = player
	var current_playback_position: float = 0.0
	if (_streamPlayers.size() > 0):
		current_playback_position = _streamPlayers.values()[0].get_playback_position()
		
	player.stream = instrument
	player.play(current_playback_position)
