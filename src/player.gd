class_name Player
extends RigidBody2D

signal atmosphere_entered(planet: Planet)

@export var speed: float = 150.0
@export var rotation_speed: float = 3.0 # Lowered for smoother rotation

@onready var exhaust: CPUParticles2D = %Exhaust
@onready var burn: CPUParticles2D = %Burn
@onready var trace: Line2D = %Trace

var throttle: bool = false
var turn: float = 0.0
var force_show_hud = false

var nearby_planets: Array[Planet] = []
var host_planet = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("throttle"):
		throttle = true
		exhaust.emitting = true
	elif event.is_action_released("throttle"):
		throttle = false
		exhaust.emitting = false

	# Get rotation input (supports both keyboard and joystick)
	turn = Input.get_axis("ui_left", "ui_right")

func get_gravity_at(delta: float, position: Vector2) -> Vector2:
	var gravity = Vector2(0, 0)
	var nearest_planet_r = 10_000_000
	for i in range(len(nearby_planets)):
		var planet = nearby_planets[i]
		var vec = planet.global_position - self.global_position
		var dir = vec.normalized()
		var r = vec.length()/1000+0.2 
		if r < nearest_planet_r and r < 1:
			nearest_planet_r = r
		if r<0.4:
			r = r -(r-0.4)*0.7
		if r>1:
			r = r**2
		#print(i, " ", len(nearby_planets), " ", planet.id, " ", r)
		var fudge: float = 0.4;
		gravity += 150.0 * delta * dir * planet.size**2 / (r**2+fudge)
		#print("applied", 1/(r**2.0)*2_000_000*delta)
		#print("applied", speed * delta)
	return gravity

func _physics_process(delta: float) -> void:
	# Thrust in the direction the spaceship is facing
	burn.emitting = false
	var gravity = get_gravity_at(delta, global_position)

	apply_central_impulse(gravity)
	
	var p = Vector2(0, 0)
	var v = -transform.basis_xform_inv(linear_velocity)
	for i in range(len(trace.points)):
		p += -v*delta
		var g = get_gravity_at(delta, global_position + transform.basis_xform(v))
		v += -transform.basis_xform_inv(g)
		trace.points[i] = p

	if host_planet:
		# Lerp rotation to face away from the planet

		rotation = lerp_angle(rotation, (host_planet.global_position - global_position).angle() - (PI /2) , 0.1)

		var vec = host_planet.global_position - self.global_position
		var nearest_planet_dir = vec.normalized()
		#var nearest_planet_pos = host_planet.global_position
		var throttle_dir = (linear_velocity 
							- nearest_planet_dir
							* nearest_planet_dir.dot(linear_velocity)).normalized()
		if throttle:
			apply_central_impulse(2*throttle_dir * speed * delta)
		else:
			# Apply a dampening force
			apply_central_impulse(-0.25*linear_velocity * delta)
			
			if linear_velocity.length() > 1.0:
				burn.emitting = true
		

	
	else:
		# Rotate based on input
		if turn != 0:
			angular_velocity = turn * rotation_speed # Better handling than manual rotate()
		else:
			angular_velocity = 0 # Stop spinning when no input
		
		# Apply thrust
		if throttle:
			apply_central_impulse(Vector2.UP.rotated(rotation) * speed * delta)
	
	var target_speed  = 200
	if linear_velocity.length() > target_speed:
		apply_central_impulse(-0.25*linear_velocity.normalized()*(linear_velocity.length()-target_speed)/target_speed)

func entered_orbit(planet: Planet) -> void:
	host_planet = planet
	print("entered orbit of ", planet.type)
	

func exited_orbit() -> void:
	host_planet = null
	print("exited orbit")
