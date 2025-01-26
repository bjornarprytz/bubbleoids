extends Node2D
@onready var player: Player = %Player
@onready var camera: Camera2D = %Camera
@onready var goal: RichTextLabel = %Goal
@onready var state: RichTextLabel = %State
@onready var controls: RichTextLabel = %Controls
@onready var fade_out: ColorRect = %FadeOut

var discovered: Array[String] = []

func _ready() -> void:
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
	controls.text = "Strafe: active"

func _on_atmosphere_entered(planet: Planet):
	if planet.type in discovered:
		return

	discovered.push_back(planet.type)
	Symphony.add_instrument()
	_update_goal()

	if (discovered.size() >= Events.goal):
		Events.game_over.emit(true)

func _update_goal():
	goal.text = "%s / %s" % [discovered.size(), Events.goal]
