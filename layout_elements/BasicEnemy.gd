extends "res://layout_elements/kinematicBody.gd"

export var killExp = 10

const FLOOR_NORMAL: = Vector2.UP
#Starting velocity - value will fluctuate
var _velocity: = Vector2.ZERO
#Max and Min speed for velocity
export var speed: = Vector2(300.0,800.0)
#Vector increases by this factor 
export var gravity: = 2000.0
var isDead = false

func _ready():
	_velocity.x = -speed.x
	$AnimatedSprite.play("walkLeft")
	
func _on_StompDetector_body_entered(body):
	if isDead == false:
		if "Player" in body.name:
			if body.jumping ==true  && body.global_position.y < get_node("StompDetector").global_position.y:
				die()
			else:
				body.take_damage(body.basic_enemy_damage)

				
#This function executes in a loop all the time, updating the enemy's position & movements
func _physics_process(delta):
	if isDead == false:
		_velocity.y += gravity * delta
		_velocity.y = min(_velocity.y,speed.y) # smooth falling, speed won't increase max speed
	
		if is_on_wall():
			if $AnimatedSprite.animation == "walkRight":
				$AnimatedSprite.play("walkLeft")
			else:
				$AnimatedSprite.play("walkRight")
				
			_velocity.x *= -1.0 #change vertical direction
		
		# We dont do _velocity = move_and_slide(..) , because _velocity.x
		# would restart to 0, and we don't want that. We want to be able to
		# control _velocity.x manually.
		_velocity.y = move_and_slide(_velocity,FLOOR_NORMAL).y	
		
func _on_Timer_timeout():
	queue_free() #Enemy vanishes

func _on_VisibilityEnabler2D_screen_exited():
		set_physics_process(false)

func _on_VisibilityEnabler2D_screen_entered():
		set_physics_process(true)

func _on_BodyDamageDetector_body_entered(body):
	if body.name == "Bullet":
		die()
		
func die():
	isDead = true
	player_node.on_kill(killExp)
	get_node("CollisionShape2D").disabled = true
	$AnimatedSprite.play("dead")
	$Timer.start() #After this time, enemy vanishes
