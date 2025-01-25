extends Node2D
@onready var player: RigidBody2D = %Player
@onready var camera: Camera2D = %Camera
@onready var canvas_modulate: CanvasModulate = %CanvasModulate


func _ready() -> void:
	Events.game_over.connect(_on_game_over)

func _process(delta: float) -> void:
	camera.position = player.position

func _on_game_over(win: bool):
	var tween = create_tween()
	tween.tween_property(canvas_modulate, "modulate", Color.BLACK, 2.69)
	await tween.finished
	get_tree().change_scene_to_file("res://credits.tscn")
