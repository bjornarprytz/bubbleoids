class_name Planet
extends Node2D

@onready var gravity_well: Area2D = %GravityWell
@onready var gravity_well_shape: CollisionShape2D = %GravityWell/Shape
@onready var sprite: Sprite2D = %Sprite
@onready var negate_gravity_shape: CollisionShape2D = %NegateGravity/Shape
@onready var poulace: CPUParticles2D = %Poulace
@onready var debrids_belt: CPUParticles2D = %DebridsBelt
@onready var bubble: Sprite2D = %Bubble
@onready var pop: CPUParticles2D = %Pop

var planet_sprites = [
	preload("res://assets/img/planets/Brown RAMS.png"),
	preload("res://assets/img/planets/greengray moon.png"),
	preload("res://assets/img/planets/MARS 1.png"),
	preload("res://assets/img/planets/MARS 2.png"),
	preload("res://assets/img/planets/MARS 3.png"),
	preload("res://assets/img/planets/OG moon.png"),
	preload("res://assets/img/planets/pink purple moon.png"),
	preload("res://assets/img/planets/pixil-frame-0 (16).png"),
	preload("res://assets/img/planets/PURPLE ARRET.png"),
	preload("res://assets/img/planets/Purple RAMS.png"),
	preload("res://assets/img/planets/RAMS BLUE CYAN PURPLE.png"),
	preload("res://assets/img/planets/RAMS GREEN RED.png"),
	preload("res://assets/img/planets/RAMS Purple.png"),
	preload("res://assets/img/planets/RED RAMS.png"),
	preload("res://assets/img/planets/TERRA 2.png"),
	preload("res://assets/img/planets/TERRA.png"),
	preload("res://assets/img/planets/WEIRD ARRET.png")
]

var size: float = 1.0
var bubble_popped = false
var type: String
var id: float = 0

var radius: float:
	get:
		return gravity_well_shape.shape.radius * size * 0.15

func _ready() -> void:
	var texture = planet_sprites.pick_random()
	sprite.texture = texture
	type = texture.get_path().get_file().get_basename()
	id = randf_range(0, 1)
	

func set_size(s: float):
	size = s
	scale = Vector2(s, s)
	#gravity_well.gravity_point_unit_distance = negate_gravity_shape.shape.radius * size

func _pop_bubble():
	if bubble_popped:
		return
	bubble_popped = true
	Symphony.beat.connect(_on_beat)
	bubble.hide()
	pop.emitting = true

func _on_beat(_number: int):
	var tween = create_tween()
	poulace.emitting = true
	tween.tween_property(sprite, "scale", Vector2.ONE * 1.1, .069)
	tween.tween_property(sprite, "scale", Vector2.ONE, .169)

func _on_gravity_well_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.nearby_planets.erase(self)
		#sprite.visible = true
		print("exited")

func _on_gravity_well_body_entered(body: Node2D) -> void:
	if (body is Player):
		body.nearby_planets.push_back(self)
		print("entered")
		#sprite.visible = false
		#%Player.nearby_planets.

func _on_negate_gravity_body_exited(body: Node2D) -> void:
	if (body is Player):
		Symphony.unmuffle()

func _on_negate_gravity_body_entered(body: Node2D) -> void:
	if (body is Player):
		_pop_bubble()
		body.discover(self)
