extends "res://layout_elements/kinematicBody.gd"

signal health

onready var player_node = get_parent().get_node("Sidescroller/Player")
export var killExp = 100

#Barrel scene itself
export (PackedScene) var barrel_scene

#Barrel spawning
export (NodePath) var barrel_spawn_path_left
export (NodePath) var barrel_spawn_path_right
onready var barrel_spawn_left = get_node(barrel_spawn_path_left)
onready var barrel_spawn_right = get_node(barrel_spawn_path_right)

#Barrel physics
export (int) var barrel_gravity = 10000
export (int) var barrel_speed = 400
export (float) var barrel_angle = 350
var directional_force = Vector2()

var facing_direction = "left"

var timerActive = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	health = max_health
	emit_signal("health",max_health,max_health)
	$AnimatedSprite.play("stand")
	update_directional_force()
	$AnimatedSprite.connect("animation_finished", self, "playNextAnimation")
	
func _physics_process(delta):
	if timerActive == false && !isDead:
		throw()
		$BarrelTimer.start()
		timerActive = true
	
	#Rotate goering
	if isDead == false:
		rotate_goering()
	
func rotate_goering():

	if (player_node.global_position.x - global_position.x) < 0 :
		#Player is on left side
		flip_left()
	else:
		#Player is on right side
		flip_right()
		
func flip_right():
	print("flipping right")
	facing_direction = "right"

func flip_left():
	print("flipping left")
	facing_direction = "left"
	
func throw():
	if facing_direction == "left":
		$AnimatedSprite.play("throwLeft")
	else:
		$AnimatedSprite.play("throwRight")
	#Here, a callback after throw animation will execute in
	# playNextAnimation() function - so that the barrel will 
	# instantiate.

func playNextAnimation():
	if(($AnimatedSprite.get_animation() == "throwLeft") || ($AnimatedSprite.get_animation() == "throwRight")):
		#Instance barrel scene
		var barrel = barrel_scene.instance() 
		
		#Place it in spawn point & update direction
		if $AnimatedSprite.get_animation() == "throwLeft":
			barrel.set_global_position(barrel_spawn_left.get_global_position()) 
			directional_force.x = abs(directional_force.x) * -1
		else:
			barrel.set_global_position(barrel_spawn_right.get_global_position()) 
			directional_force.x = abs(directional_force.x)
	
		#    Barrel is acting independently of thrower's position
		#  after the throw, so we add it to "Level" instead of 
		#  BarrelThrowingEnemy.
		get_parent().add_child(barrel)	
			
		#Now, the barrel will go on independently
		barrel.shoot(directional_force,barrel_gravity)
		
		if $AnimatedSprite.get_animation() == "throwLeft":
			$AnimatedSprite.play("goBackLeft")
		elif $AnimatedSprite.get_animation() == "throwRight":
			$AnimatedSprite.play("goBackRight")
		
	elif ($AnimatedSprite.get_animation() == "goBackLeft" || $AnimatedSprite.get_animation() == "goBackRight"):
		$AnimatedSprite.play("stand")
		
	
func update_directional_force():
	
	directional_force = Vector2(abs(cos(barrel_angle*(PI/180))),sin(barrel_angle*(PI/180))) * barrel_speed
	


func _on_VisibilityEnabler2D_screen_exited():
	set_physics_process(false)


func _on_VisibilityEnabler2D_screen_entered():
	set_physics_process(true)


func _on_BarrelTimeout_timeout():
	timerActive = false
	

func _on_DamageDetection_body_entered(body):
	if body.name == "Bullet":
		take_damage(player_node.bullet_damage)

func die():
	player_node.on_kill(killExp)
	isDead = true
	$HealthBar.queue_free()
	$AnimatedSprite.play("die")
	$DamageDetection/CollisionShape2D.queue_free()
	$CollisionShape2D.queue_free()
	$LeftDeathCollisionShape2D.set_disabled(false)
	$DeathTimer.start()		
	
func _on_DeathTimer_timeout():
	queue_free()
