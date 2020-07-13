extends KinematicBody2D


var _gravity = 0
var _movement = Vector2()
var isDead = false
export var barrel_damage = 15

func _ready():
	$AnimatedSprite.play("rollLeft")
	$LiveTimer.start()
	
func _physics_process(delta):
	#Simulate gravity
	_movement.y = delta * _gravity
	#Move
	move_and_slide(_movement)
	
func shoot(directional_force,gravity):
	_movement = directional_force
	_gravity = gravity
	set_physics_process(true)


func _on_Area2D_body_entered(body):
	if body.name == "Player" && isDead == false:
		print(body.name)
		body.take_damage(barrel_damage)
		die()
	if body.name == "Bullet" && isDead == false:
		die()

func die():
	isDead = true
	_movement = Vector2(0,0) #Stops moving
	$AnimatedSprite.play("explode")
	_gravity = 0 #Barrell won't fall due to disabling collision shapes
	$CollisionPolygon2D.queue_free()
	$Area2D/CollisionPolygon2D.queue_free()#set_disabled(true)
	$StompDetector/CollisionShape2D.queue_free()#set_disabled(true)
	$Timer.start()
	
	
func _on_Timer_timeout():
	queue_free()

func _on_StompDetector_body_entered(body):
	if isDead == false:
		if "Player" in body.name:
			if body.jumping ==true  && body.global_position.y < get_node("StompDetector").global_position.y:
				die()
			else:
				body.take_damage(barrel_damage)


func _on_LiveTimer_timeout():
	die()
