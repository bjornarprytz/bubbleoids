extends Node2D
@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera
@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var goal: RichTextLabel = %Goal

var discovered: Array[String] = []

func _ready() -> void:
	Events.game_over.connect(_on_game_over)
	player.atmosphere_entered.connect(_on_orbit_entered)

func _process(delta: float) -> void:
	camera.position = player.position

func _on_game_over(win: bool):
	var tween = create_tween()
	tween.tween_property(canvas_modulate, "modulate", Color.BLACK, 2.69)
	await tween.finished
	get_tree().change_scene_to_file("res://credits.tscn")

func _on_orbit_entered(planet: Planet):
	if planet.type in discovered:
		return

	discovered.push_back(planet.type)
	Symphony.add_instrument()
	_update_goal()

	if (discovered.size() >= Events.goal):
		Events.game_over.emit(true)

func _update_goal():
	goal.text = "%s / %s" % [discovered.size(), Events.goal]
