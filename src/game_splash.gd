extends Control

@onready var logo: Sprite2D = %Logo
@onready var controls: TextureRect = %Controls


func _ready() -> void:
	Symphony.start_intro()
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(logo, "scale", Vector2.ONE, 2.0)
	
	await tween.finished
	controls.visible = true


func _input(event: InputEvent) -> void:
	if (event is not InputEventMouseMotion and event is not InputEventJoypadMotion and event.is_pressed()):
		_next_scene()

func _next_scene():
	get_tree().change_scene_to_file("res://main.tscn")
