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
var timer_active = false
onready var player_path = get_parent().get_parent().get_node("Sidescroller/Player")

func _ready()->void:
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
	rotation_degrees = 0

	if timer_active == false:	
		$Timer.start()
		timer_active = true
	
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
	#velocity = (get_global_mouse_position() - global_position).normalized() * throw_speed
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
	if state == IDLE: 
		throw()
		
	timer_active = false

#when axe comes outside of the screen, come back to Gregory
func _on_visibilityNode_screen_exited():
	state = STICK