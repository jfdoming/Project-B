extends KinematicBody2D

signal health

export (int) var max_health = 100
var health = max_health

onready var player_path = get_parent().get_node("Sidescroller/Player")

const FLOOR_NORMAL: = Vector2.UP

#Starting velocity - value will fluctuate
var _velocity: = Vector2.ZERO

#Max and Min speed for velocity
export var speed: = Vector2(100.0,100.0)

#Vector increases by this factor 
export var gravity: = 2000.0

var isDead = false

func _ready():
	emit_signal("health",max_health,max_health)
	set_physics_process(false)
	_velocity.x = -speed.x
	$StandAnimation.play()
	
	#This function executes in a loop all the time, updating the enemy's position & movements
func _physics_process(delta):
	rotate_gregory()
	if isDead == false:
		_velocity.y += gravity * delta
		_velocity.y = min(_velocity.y,speed.y) # smooth falling, speed won't increase max speed
	
		if is_on_wall():
			_velocity.x *= -1.0 #change vertical direction
		
		# We dont do _velocity = move_and_slide(..) , because _velocity.x
		# would restart to 0, and we don't want that. We want to be able to
		# control _velocity.x manually.
		_velocity.y = move_and_slide(_velocity,FLOOR_NORMAL).y
	
func rotate_gregory():
	rotation_degrees = 0
	if (player_path.global_position.x - global_position.x) > 0 :
		#Player is on left side
		flip_left()
	else:
		#Player is on right side
		flip_right()
		
func flip_right():
	$StandAnimation.flip_h = true

func flip_left():
	$StandAnimation.flip_h = false

func take_damage(damage):
	if damage == 0:
		return
	
	health = max(health - damage, 0)
	
	emit_signal("health",health,max_health)
	
	if health == 0:
		die()
		return
	
func _on_VisibilityEnabler2D_screen_entered():
	set_physics_process(true)

func _on_StompDetector_body_entered(body):
	if isDead == false:
		if "Player" in body.name:
			if body.global_position.y < get_node("StompDetector").global_position.y:
				take_damage(20)
			
		

func die():
	isDead = true
	queue_free()
