extends "res://scenes/CutsceneBase.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("Player")
	player.direction = player.LEFT
	player.scale.x = -1
