extends "res://layout_elements/kinematicBody.gd"

signal health

onready var player_node = get_parent().get_node("Sidescroller/Player")

export var killExp = 100

#Boomerang scene itself
export (PackedScene) var boomerang_scene

#Barrel spawning
export (NodePath) var boomerang_spawn_path_left
export (NodePath) var boomerang_spawn_path_right
export (NodePath) var catch_point
onready var boomerang_spawn_left = get_node(boomerang_spawn_path_left)
onready var boomerang_spawn_right = get_node(boomerang_spawn_path_right)
onready var catch_point_path = get_node(catch_point)

#Starting velocity - value will fluctuate
var _velocity: = Vector2.ZERO

#Max and Min speed for velocity
export var speed: = Vector2(100.0,800.0)

#Vector increases by this factor 
export var gravity: = 2

var isOnScreen = false

var boomerang_active = false
var boomerang_timer_active = false

#Damage that the player causes when jumping on Gregory
export var jumpDamage = 20 

export (float) var jump_bonus = 0.15

var JumpTimerActive = false

func _ready():
	randomize() #Pick seed for random nums
	health = max_health
	
	emit_signal("health",max_health,max_health)
	_velocity.x = -speed.x
	$Animation.play("stand")
	set_physics_process(false)
	
	#This function executes in a loop all the time, updating the enemy's position & movements
func _physics_process(delta):
	
	if boomerang_timer_active == false && boomerang_active == false:
		boomerang_timer_active = true
		$BoomerangTimer.start()	
	
	if isDead == false:
		rotate_gregory()
		
		_velocity.y += gravity * delta
		_velocity.y = min(_velocity.y,speed.y) # smooth falling, speed won't increase max speed
	
		if is_on_wall():
			_velocity.x *= -1.0 #change vertical direction
			
		if is_on_floor():
			if !JumpTimerActive:
				var randomNum = rand_range(0.0,5.0)
				$JumpTimer.wait_time = randomNum
				$JumpTimer.start()
				JumpTimerActive = true
		
		# We dont do _velocity = move_and_slide(..) , because _velocity.x
		# would restart to 0, and we don't want that. We want to be able to
		# control _velocity.x manually.

		_velocity.y += gravity * delta * 1000
		_velocity.y = move_and_slide(_velocity,FLOOR_NORMAL).y	
		
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
	facing_direction = "left"

func flip_left():
	$Animation.flip_h = false
	facing_direction = "right"
	
func _on_VisibilityEnabler2D_screen_entered():
	isOnScreen = true
	set_physics_process(true)

func _on_StompDetector_body_entered(body):
	if isDead == false:
		if "Player" in body.name:
			var bodyHeight = body.get_node("BodyCollisionShape").shape.get_extents().y + body.get_node("HeadCollisionShape").shape.get_extents().y
			
			if ((body.global_position.y + bodyHeight) < get_node("StompDetector").global_position.y):
				if player_node.smashing:
					take_damage(player_node.smash_damage)
				else:
					take_damage(player_node.jump_damage)
				

func die():
	player_node.on_kill(killExp)
	isDead = true
	$HealthBar.queue_free()
	$Boomerang.queue_free()
	$StompDetector.queue_free()
	$Animation.play("die")
	$Death_Timer.start()

func _on_VisibilityEnabler2D_screen_exited():
	isOnScreen=false

	if isDead == false && has_node("Boomerang"):
		$Boomerang.set_stick()

func _on_Death_Timer_timeout():
	queue_free()
	
func _on_BodyDamageDetector_body_entered(body):
	if body.name == "Bullet" && isOnScreen: #We can only damage gregory if he is visible on screen
		take_damage(body.damage)#Bullet has own damage variable


func _on_JumpTimer_timeout():
	#Jump!
	JumpTimerActive = false
	_velocity.y = -speed.y - jump_bonus * abs(_velocity.x)	


func _on_BoomerangTimer_timeout():
	boomerang_timer_active = false
	boomerang_active = true
	#Instance boomerang scene
	var boomerang = boomerang_scene.instance() 
	add_child(boomerang)
