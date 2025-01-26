extends Node2D

@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var logo: Sprite2D = %Logo

func _ready() -> void:
	Symphony.full_ensemble()
	Symphony.beat.connect(_on_beat)

func _on_beat(number: int) -> void:
	if (number % 4 == 0):
		if (!Symphony.pop_instrument()):
			logo.show()
			logo.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(scroll_container, "modulate:a", 0.0, 1.69)
			tween.tween_property(logo, "modulate:a", 1.0, 1.69)

func _physics_process(_delta: float) -> void:
	scroll_container.set_deferred("scroll_vertical", scroll_container.scroll_vertical + 2)
