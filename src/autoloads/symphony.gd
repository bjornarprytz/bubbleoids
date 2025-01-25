extends Node2D

var _streamPlayers: Dictionary[String, AudioStreamPlayer] = {}

var instruments: Array[AudioStream] = [
	preload("res://assets/audio/Bookworm - MichaelBackson - 16.06.2024, 22.59.wav"),
	preload("res://assets/audio/Bookworm - mixtape3 - 16.06.2024, 23.07.wav"),
	preload("res://assets/audio/Bookworm - morningistheend - 16.06.2024, 23.09.wav")
]

func _ready() -> void:
	instruments.shuffle()

func add_instrument():
	print("Symphony disabled until we add actual tracks")
	return
	
	if (instruments.size() == 0):
		print("Found all instruments already")
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	player.finished.connect(player.play)
	var instrument = instruments.pop_front()
	
	var current_playback_position: float = 0.0
	if (_streamPlayers.size() > 0):
		current_playback_position = _streamPlayers.values()[0].get_playback_position()
		
	player.stream = instrument
	player.play(current_playback_position)
