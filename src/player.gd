class_name Player
extends RigidBody2D

@export var speed: float = 800.0
@export var rotation_speed: float = 3.0  # Lowered for smoother rotation

var throttle: bool = false
var turn: float = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throttle"):
		throttle = true
	elif event.is_action_released("throttle"):
		throttle = false

	# Get rotation input (supports both keyboard and joystick)
	turn = Input.get_axis("ui_left", "ui_right")

func _physics_process(delta: float) -> void:
	# Thrust in the direction the spaceship is facing
	if throttle:
		var direction = Vector2.UP.rotated(rotation)  # Correct forward direction
		apply_central_impulse(direction * speed * delta)

	# Rotate based on input
	if turn != 0:
		angular_velocity = turn * rotation_speed  # Better handling than manual rotate()
	else:
		angular_velocity = 0  # Stop spinning when no input
