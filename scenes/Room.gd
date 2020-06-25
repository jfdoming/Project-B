extends "res://scenes/CutsceneBase.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("Player")
	player.direction = player.LEFT
	player.scale.x = -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
