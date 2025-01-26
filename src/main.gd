extends Node2D
@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera
@onready var goal: RichTextLabel = %Goal
@onready var state: RichTextLabel = %State
@onready var controls: RichTextLabel = %Controls
@onready var fade_out: ColorRect = %FadeOut
@onready var tutorial: PanelContainer = %Tutorial

func _ready() -> void:
	Events.discovered = []
	Events.game_over.connect(_on_game_over)
	player.atmosphere_entered.connect(_on_atmosphere_entered)
	player.orbit_entered.connect(_on_orbit_entered)
	player.orbit_exited.connect(_on_orbit_exited)
	
func _process(delta: float) -> void:
	camera.position = player.position

func _on_game_over(win: bool):
	var tween = create_tween()
	fade_out.show()
	fade_out.modulate.a = 0.0
	tween.tween_property(fade_out, "modulate:a", 1.0, 7.69)
	await tween.finished
	get_tree().change_scene_to_file("res://credits.tscn")

func _on_orbit_exited():
	state.text = "ROAMING"
	controls.text = "Autopilot: off"
	
func _on_orbit_entered(_planet: Planet):
	state.text = "IN ORBIT"
	controls.text = "Autopilot: active"

func _on_atmosphere_entered(planet: Planet):
	if planet.type in Events.discovered:
		return

	Events.discovered.push_back(planet.type)
	Symphony.add_instrument()
	_update_goal()
	
	if (Events.discovered.size() > 2):
		# Assume mastery
		var tween = create_tween()
		tween.tween_property(tutorial, "modulate:a", 0.0, 0.69)
		tween.tween_callback(tutorial.hide)

	if (Events.discovered.size() >= Events.goal):
		Events.game_over.emit(true)

func _update_goal():
	goal.text = "%s / %s" % [Events.discovered.size(), Events.goal]
