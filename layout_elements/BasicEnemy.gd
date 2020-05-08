extends KinematicBody2D

const FLOOR_NORMAL: = Vector2.UP

#Starting velocity - value will fluctuate
var _velocity: = Vector2.ZERO

#Max and Min speed for velocity
export var speed: = Vector2(300.0,800.0)

#Vector increases by this factor 
export var gravity: = 2000.0

#isDead is a variable that dictates whether physics_process will play
# aka, whether this enemy will move, etc.

var isDead = false

func _ready():
	#Prevent enemy from moving if it's outside of current view
	set_physics_process(false) 
	_velocity.x = -speed.x
	$AnimatedSprite.play("walkLeft")
	
func _on_StompDetector_body_entered(body):
	if isDead == false:
		if "Player" in body.name:
			if body.global_position.y > get_node("StompDetector").global_position.y:
				return
	
			get_node("CollisionShape2D").disabled = true
			body.on_kill(5) #player takes damage
			$AnimatedSprite.play("dead")
			isDead = true
			$Timer.start() #After this time, enemy vanishes
			#queue_free() #use this only if you want the enemy to disappear completly

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
