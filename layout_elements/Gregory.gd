extends "res://layout_elements/kinematicBody.gd"

signal health

export var killExp = 100

onready var parent_node = get_parent()
onready var player_path = "Sidescroller/Player"
onready var player_node = get_parent().get_node(player_path)

const FLOOR_NORMAL: = Vector2.UP

#Starting velocity - value will fluctuate
var _velocity: = Vector2.ZERO

#Max and Min speed for velocity
export var speed: = Vector2(100.0,100.0)

#Vector increases by this factor 
export var gravity: = 2000.0

var isDead = false
var isOnScreen = false

#Damage that the player causes when jumping on Gregory
export var jumpDamage = 20 

var jumping = false
var just_jumped = false
export (int) var jump_speed = 800
export (float) var jump_bonus = 0.15

func _ready():
	health = max_health
	
	emit_signal("health",max_health,max_health)
	set_physics_process(false)
	_velocity.x = -speed.x
	$Animation.play("stand")
	
	#This function executes in a loop all the time, updating the enemy's position & movements
func _physics_process(delta):
	
	if isDead == false:
		rotate_gregory()
		
		_velocity.y += gravity * delta
		_velocity.y = min(_velocity.y,speed.y) # smooth falling, speed won't increase max speed
	
		if is_on_wall():
			_velocity.x *= -1.0 #change vertical direction
		
		# We dont do _velocity = move_and_slide(..) , because _velocity.x
		# would restart to 0, and we don't want that. We want to be able to
		# control _velocity.x manually.
		_velocity.y = move_and_slide(_velocity,FLOOR_NORMAL).y
		
		#if is_on_floor():
			#jumping = true
			#just_jumped = true
			#_velocity.y = -jump_speed - jump_bonus * abs(_velocity.x)	
	
func rotate_gregory():
	rotation_degrees = 0
	if (player_node.global_position.x - global_position.x) > 0 :
		#Player is on left side
		flip_left()
	else:
		#Player is on right side
		flip_right()
		
func flip_right():
	$Animation.flip_h = true

func flip_left():
	$Animation.flip_h = false

	
func _on_VisibilityEnabler2D_screen_entered():
	set_physics_process(true)

func _on_StompDetector_body_entered(body):
	if isDead == false:
		if "Player" in body.name:
			var bodyHeight = body.get_node("BodyCollisionShape").shape.get_extents().y + body.get_node("HeadCollisionShape").shape.get_extents().y
			
			if body.jumping==true && ((body.global_position.y + bodyHeight) < get_node("StompDetector").global_position.y):
				take_damage(jumpDamage)
	else:
		body.on_kill(killExp)
		$StompDetector/CollisionShape2D.disabled = true

func die():
	isDead = true
	$HealthBar.queue_free()
	$Boomerang.queue_free()
	$Animation.play("die")
	$Timer.start()

func _on_VisibilityEnabler2D_screen_exited():
	if isDead == false && has_node("Boomerang"):
		$Boomerang.set_stick()

func _on_Timer_timeout():
	queue_free()
	
