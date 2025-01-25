class_name Planet
extends Node2D

@onready var gravity_well: Area2D = %GravityWell
@onready var gravity_well_shape: CollisionShape2D = %GravityWell/Shape
@onready var sprite: Sprite2D = %Sprite
@onready var negate_gravity_shape: CollisionShape2D = %NegateGravity/Shape

const BROWN_RAMS = preload("res://assets/img/planets/Brown RAMS.png")
const GREENGRAY_MOON = preload("res://assets/img/planets/greengray moon.png")
const MARS_1 = preload("res://assets/img/planets/MARS 1.png")
const MARS_2 = preload("res://assets/img/planets/MARS 2.png")
const MARS_3 = preload("res://assets/img/planets/MARS 3.png")
const OG_MOON = preload("res://assets/img/planets/OG moon.png")
const PINK_PURPLE_MOON = preload("res://assets/img/planets/pink purple moon.png")
const PIXIL_FRAME_0__16_ = preload("res://assets/img/planets/pixil-frame-0 (16).png")
const PURPLE_ARRET = preload("res://assets/img/planets/PURPLE ARRET.png")
const PURPLE_RAMS = preload("res://assets/img/planets/Purple RAMS.png")
const RAMS_BLUE_CYAN_PURPLE = preload("res://assets/img/planets/RAMS BLUE CYAN PURPLE.png")
const RAMS_GREEN_RED = preload("res://assets/img/planets/RAMS GREEN RED.png")
const RAMS_PURPLE = preload("res://assets/img/planets/RAMS Purple.png")
const RED_RAMS = preload("res://assets/img/planets/RED RAMS.png")
const TERRA_2 = preload("res://assets/img/planets/TERRA 2.png")
const TERRA = preload("res://assets/img/planets/TERRA.png")
const WEIRD_ARRET = preload("res://assets/img/planets/WEIRD ARRET.png")

var sprites = [
	BROWN_RAMS
	, GREENGRAY_MOON
	, MARS_1
	, MARS_2
	, MARS_3
	, OG_MOON
	, PINK_PURPLE_MOON
	, PIXIL_FRAME_0__16_
	, PURPLE_ARRET
	, PURPLE_RAMS
	, RAMS_BLUE_CYAN_PURPLE
	, RAMS_GREEN_RED
	, RAMS_PURPLE
	, RED_RAMS
	, TERRA_2
	, TERRA
	, WEIRD_ARRET
]

var size : float = 1.0

var radius: float:
	get:
		return gravity_well_shape.shape.radius * size

func set_size(s: float):
	size = s
	scale = Vector2(s,s)
	gravity_well.gravity_point_unit_distance = negate_gravity_shape.shape.radius * size
	print("gravity_well.gravity_point_unit_distance set to %s" % gravity_well.gravity_point_unit_distance)

func _ready() -> void:
	sprite.texture = sprites.pick_random()


func _on_gravity_well_body_entered(body: Node2D) -> void:
	if (body is Player):
		Symphony.add_instrument()
