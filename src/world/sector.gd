class_name Sector
extends Node2D

@export var size = Vector2(2048, 1152)
@export var planet_count = 10
@export var min_distance = 50 # Minimum distance between planets

var planets : Array[Planet] = []

signal entered_screen()
signal exited_screen()

signal player_entered(sector:Sector, player: Player)

var coordinates: Vector2 = Vector2()

func set_coords_and_regenerate_planets(coords: Vector2i) -> void:
	self.coordinates = coords
	# Seed the random number generator
	seed(hash(coords))

	# Remove all existing planets
	for planet in planets:
		if (planet != null and !planet.is_queued_for_deletion()):
			planet.queue_free()
	planets.clear()

	# Generate new planets
	for i in range(planet_count):
		var planet = Create.planet()
		var scale_factor = randf_range(0.6, 1)
		
		planets.append(planet)
		add_child(planet)
		
		planet.scale = Vector2(scale_factor, scale_factor)
		set_valid_position_or_destroy(planet, min_distance)

func set_valid_position_or_destroy(planet: Planet, min_dist: float) -> void:
	var max_attempts = 50 # Prevent infinite loops
	for _i in range(max_attempts):
		var pos = Vector2(randf_range(0, size.x), randf_range(0, size.y))
		# Check distance to all existing planets
		var valid = true
		for other in planets:
			if pos.distance_to(other.position) < (min_dist + other.radius + planet.radius):
				valid = false
				break
		if valid:
			planet.position = pos
			return
	# If we fail to find a valid spot after max_attempts, destroy the planet
	planet.queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	entered_screen.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	exited_screen.emit()


func _on_player_detection_body_entered(body: Node2D) -> void:
	if (body is Player):
		player_entered.emit(self, body)
