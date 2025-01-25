extends Node2D

@onready var scroll_container: ScrollContainer = %ScrollContainer

func _ready() -> void:
	Symphony.full_ensemble()
	Symphony.beat.connect(_on_beat)

func _on_beat(number: int) -> void:
	if (number % 4 == 0):
		Symphony.pop_instrument()

func _physics_process(_delta: float) -> void:
	scroll_container.set_deferred("scroll_vertical", scroll_container.scroll_vertical +2)
