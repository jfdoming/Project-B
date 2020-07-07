extends "res://layout_elements/kinematicBody.gd"

signal health

onready var player_node = get_parent().get_node("Sidescroller/Player")
export var killExp = 100

#Barrel scene itself
export (PackedScene) var barrel_scene

#Barrel spawning
export (NodePath) var barrel_spawn_path
onready var barrel_spawn = get_node(barrel_spawn_path)

#Barrel physics
export (int) var barrel_gravity = 10000
export (int) var barrel_speed = 400
export (float) var barrel_angle = 350
var directional_force = Vector2()

var timerActive = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)
	health = max_health
	emit_signal("health",max_health,max_health)
	$AnimatedSprite.play("standLeft")
	update_directional_force()
	$AnimatedSprite.connect("animation_finished", self, "playNextAnimation")
	
func _physics_process(delta):
	if timerActive == false && !isDead:
		throw()
		$BarrelTimer.start()
		timerActive = true
	
func throw():
	$AnimatedSprite.play("throwLeft")
	#Here, a callback after throw animation will execute in
	# playNextAnimation() function - so that the barrel will 
	# instantiate.

func playNextAnimation():
	if($AnimatedSprite.get_animation() == "throwLeft"):
		#Instance barrel scene
		var barrel = barrel_scene.instance() 

		#Place it in spawn point
		barrel.set_global_position(barrel_spawn.get_global_position()) 
	
		#    Barrel is acting independently of thrower's position
		#  after the throw, so we add it to "Level" instead of 
		#  BarrelThrowingEnemy.
		get_parent().add_child(barrel)
	
		#Now, the barrel will go on independently
		barrel.shoot(directional_force,barrel_gravity)
		$AnimatedSprite.play("standLeft")
	
	elif($AnimatedSprite.get_animation() == "throwRight"):
		$AnimatedSprite.play("standRight")
	
func update_directional_force():
	directional_force = Vector2(cos(barrel_angle*(PI/180)),sin(barrel_angle*(PI/180))) * barrel_speed


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
	$AnimatedSprite.play("dieLeft")
	$DamageDetection/CollisionShape2D.queue_free()
	$CollisionShape2D.queue_free()
	$LeftDeathCollisionShape2D.set_disabled(false)
	$DeathTimer.start()		
	
func _on_DeathTimer_timeout():
	queue_free()
