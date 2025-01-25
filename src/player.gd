class_name Player
extends RigidBody2D

@export var speed: float = 100.0
@export var rotation_speed: float = 3.0 # Lowered for smoother rotation

@onready var exhaust: CPUParticles2D = %Exhaust
@onready var hud: PanelContainer = %Hud
@onready var goal: RichTextLabel = %Goal

var throttle: bool = false
var turn: float = 0.0
var force_show_hud = false

var discovered: Array[String] = []

func _ready() -> void:
	goal.text = "%s / %s" % [discovered.size(), Events.goal]

func discover(planet: Planet):
	if planet.type in discovered:
		return
	
	discovered.push_back(planet.type)
	Symphony.add_instrument()
	goal.text = "%s / %s" % [discovered.size(), Events.goal]
	
	if (force_show_hud):
		return
	await show_hud()
	await get_tree().create_timer(2.0).timeout
	if (!force_show_hud):
		hud.hide()
	
	if (discovered.size() >= Events.goal):
		Events.game_over.emit(true)

func show_hud():
	hud.show()
	# flicker the goal text
	await get_tree().create_timer(0.1).timeout
	hud.hide()
	await get_tree().create_timer(0.1).timeout
	hud.show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throttle"):
		throttle = true
		exhaust.emitting = true
	elif event.is_action_released("throttle"):
		throttle = false
		exhaust.emitting = false
	
	if event.is_action_pressed("hud"):
		force_show_hud = true
		show_hud()
	elif event.is_action_released("hud"):
		force_show_hud = false
		hud.hide()
	

	# Get rotation input (supports both keyboard and joystick)
	turn = Input.get_axis("ui_left", "ui_right")

func _physics_process(delta: float) -> void:
	# Thrust in the direction the spaceship is facing
	if throttle:
		var direction = Vector2.UP.rotated(rotation) # Correct forward direction
		apply_central_impulse(direction * speed * delta)

	# Rotate based on input
	if turn != 0:
		angular_velocity = turn * rotation_speed # Better handling than manual rotate()
	else:
		angular_velocity = 0 # Stop spinning when no input
