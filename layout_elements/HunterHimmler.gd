extends "res://layout_elements/kinematicBody.gd"

signal health

export var gravity: = 2

const LEFT = 0
const RIGHT = 1

var isDead = false
var direction = RIGHT
var velocity = Vector2()


func _ready():
	$Animations.play("default")

func _physics_process(delta):
	if isDead == false:
		rotate_himmler()
		velocity.y += gravity * delta * 1000
		velocity = move_and_slide(velocity, Vector2(0, -1))

func rotate_himmler():
	if (player_node.global_position.x - global_position.x) > 0 :
		if direction == LEFT:
			scale.x = -1
		direction = RIGHT
		
	else:
		if direction == RIGHT:
			scale.x = -1
		direction = LEFT
		

