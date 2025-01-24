extends RigidBody2D

@export var speed: float = 400.0

var throttle: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throttle"):
		throttle = true
		print("Throttle")
	elif event.is_action_released("throttle"):
		throttle = false
		print("No Throttle")


func _process(delta: float) -> void:
	if throttle:
		apply_central_impulse(Vector2(0, -speed))
		throttle = false
