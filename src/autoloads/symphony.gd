extends Node2D

var _streamPlayers: Dictionary[String, AudioStreamPlayer] = {}

var instruments: Array[AudioStream] = [
	preload("res://assets/audio/Bookworm - MichaelBackson - 16.06.2024, 22.59.wav"),
	#preload("res://assets/audio/Bookworm - mixtape3 - 16.06.2024, 23.07.wav"),
	#preload("res://assets/audio/Bookworm - morningistheend - 16.06.2024, 23.09.wav")
]

func _ready() -> void:
	instruments.shuffle()

func muffle():
	for player in _streamPlayers.values():
		print("muffle")
		player.set_bus("Muffle")
func unmuffle():
	for player in _streamPlayers.values():
		print("unmuffle")
		player.set_bus("Master")

func add_instrument():
	
	if (instruments.size() == 0):
		print("Found all instruments already")
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	player.finished.connect(player.play)
	var instrument = instruments.pop_front() as AudioStream
	
	_streamPlayers[instrument.resource_name] = player
	var current_playback_position: float = 0.0
	if (_streamPlayers.size() > 0):
		current_playback_position = _streamPlayers.values()[0].get_playback_position()
		
	player.stream = instrument
	player.play(current_playback_position)
