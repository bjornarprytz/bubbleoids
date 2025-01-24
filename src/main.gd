extends Node2D
@onready var player: RigidBody2D = %Player
@onready var camera: Camera2D = %Camera


func _process(delta: float) -> void:
	camera.position = player.position
