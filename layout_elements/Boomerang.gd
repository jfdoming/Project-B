extends Node2D

#Note: this boomerang axe follows the player, so there needs to be a player node if
# there's a boomerang node.

enum {IDLE, FLY, STICK}
export (float) var throw_speed = 2 * 200
onready var parent: = get_parent()
var state: int = IDLE
var velocity: = Vector2.ZERO
var pos: = Vector2.ZERO
var spin_speed: float = 4*220
onready var player_path = get_parent().get_parent().get_node("Sidescroller/Player")
var isDead = false
var isOnScreen = false
var timerActive = false
#var timerDisabled = false

func _ready()->void:
	#set_physics_process(false)
	idle_position()

func _physics_process(delta):
	match state:
		IDLE:
			idle()
		FLY:
			fly(delta)
		STICK:
			stick(delta)

func idle()->void:
	rotate_axe()
	if timerActive == false:# && timerDisabled == false:
		$Timer.start()
		timerActive = true
	
func rotate_axe():
	rotation_degrees = 0
	if (player_path.global_position.x - global_position.x) > 0 :
		#Player is on right side
		flip_right()
	else:
		#Player is on left side
		flip_left()
		
func flip_right():
	$Sprite.flip_h = true

func flip_left():
	$Sprite.flip_h = false
	
func fly(delta:float)->void:
	pos += velocity*delta #variable for disconnecting from parent movement
	global_position = pos
	#spin
	rotation_degrees += spin_speed*delta

func stick(delta:float)->void:
	#place for your solution
	var target: = get_target()
	var dist = global_position.distance_to(target)
	if dist < throw_speed * delta:
		idle_position()
	else:
		pos = pos.linear_interpolate(target, (throw_speed * delta)/dist)
		global_position = pos
		#spin
		rotation_degrees += spin_speed*delta

func throw()->void:
	state = FLY
	#$Timer.start()
	velocity = (player_path.global_position - global_position).normalized()*throw_speed
	pos = global_position #variable for disconnecting from parent movement

#Position of axe in the hands of Gregory
func idle_position()->void:
	state = IDLE
	global_position = get_target()

#Returns position of Gregory
func get_target()->Vector2:
	return parent.global_position + Vector2(0,-2)

#When timeout happens, axe flies back to Gregory
func _on_Timer_timeout()->void:
	timerActive = false
	if state == IDLE && isOnScreen:
		throw()

#when axe comes outside of the screen, come back to Gregory
func _on_visibilityNode_screen_exited():
	state = STICK

func _on_CollisionDetection_body_entered(body):
	if body.name == "Player":
		state = STICK

func _on_VisibilityEnabler2D_screen_entered():
	isOnScreen = true
	#timerDisabled = false
	
func _on_VisibilityEnabler2D_screen_exited():
	state = STICK
	isOnScreen = false
	#timerDisabled = true

func set_stick():
	state=STICK


