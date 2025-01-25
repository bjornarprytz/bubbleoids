class_name Player
extends RigidBody2D

@export var speed: float = 100.0
@export var rotation_speed: float = 3.0 # Lowered for smoother rotation

@onready var exhaust: CPUParticles2D = %Exhaust
@onready var hud: PanelContainer = %Hud
@onready var goal: RichTextLabel = %Goal
@onready var trace: Line2D = %Trace

#var throttle: bool = false
var throttle_plus: bool = false
var throttle_minus: bool = false
var turn: float = 0.0
var force_show_hud = false

var nearby_planets: Array[Planet] = []
var host_planet = null

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
	if event.is_action_pressed("throttle_plus"):
		throttle_plus = true
		exhaust.emitting = true
	elif event.is_action_released("throttle_plus"):
		throttle_plus = false
		exhaust.emitting = false
	if event.is_action_pressed("throttle_minus"):
		throttle_minus = true
		exhaust.emitting = true
	elif event.is_action_released("throttle_minus"):
		throttle_minus = false
		exhaust.emitting = false
	
	if event.is_action_pressed("hud"):
		force_show_hud = true
		show_hud()
	elif event.is_action_released("hud"):
		force_show_hud = false
		hud.hide()
	

	# Get rotation input (supports both keyboard and joystick)
	turn = Input.get_axis("ui_left", "ui_right")

func get_gravity_at(delta: float, position: Vector2) -> Vector2:
	var gravity = Vector2(0, 0)
	var nearest_planet_r = 10_000_000
	host_planet = null
	for i in range(len(nearby_planets)):
		var planet = nearby_planets[i]
		var vec = planet.global_position - self.global_position
		var dir = vec.normalized()
		var r = vec.length()/1000+0.2 
		if r < nearest_planet_r and r < 1:
			nearest_planet_r = r
			host_planet = planet
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
	
	#if throttle and nearest_planet_dir:
	#	var direction = Vector2.UP.rotated(rotation) # Correct forward direction
	#	apply_central_impulse(direction * speed * delta)
		
		
	var gravity = get_gravity_at(delta, global_position)

	apply_central_impulse(gravity)
	
	var p = Vector2(0, 0)
	var v = -transform.basis_xform_inv(linear_velocity)
	for i in range(len(trace.points)):
		p += -v*delta
		var g = get_gravity_at(delta, global_position + transform.basis_xform(v))
		v += -transform.basis_xform_inv(g)
		trace.points[i] = p
	
	var target_speed  = 200
	if linear_velocity.length() > target_speed:
		apply_central_impulse(-0.25*linear_velocity.normalized()*(linear_velocity.length()-target_speed)/target_speed)
	
	if host_planet:
		var vec = host_planet.global_position - self.global_position
		var nearest_planet_dir = vec.normalized()
		#var nearest_planet_pos = host_planet.global_position
		var throttle_dir = (linear_velocity 
							- nearest_planet_dir
							* nearest_planet_dir.dot(linear_velocity)).normalized()
		
		look_at(global_position - nearest_planet_dir)
		
		if throttle_plus:
			apply_central_impulse(2*throttle_dir * speed * delta)	
		if throttle_minus:
			apply_central_impulse(-2*throttle_dir * speed * delta)
			look_at(global_position + nearest_planet_dir)
	
	print("speed: %.1f " % linear_velocity.length())
		
	# Rotate based on input
	#if turn != 0:
	#	angular_velocity = turn * rotation_speed # Better handling than manual rotate()
	#else:
	#	angular_velocity = 0 # Stop spinning when no input
