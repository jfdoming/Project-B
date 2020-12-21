extends Node2D

const doorClosed = preload("res://.import/Room.png-7eaa21d23bc561b2d57336d6d3d999f0.stex")
const doorOpenBG = preload("res://.import/RoomBG.png-8da8f79bf98d8daa5b59f4300c2a2018.stex")
const doorOpenFG = preload("res://.import/RoomFG.png-5ae7133845ad5819531884a4ba1671fb.stex")
# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("Sidescroller/Player")
	# Make Stroheim face left
	player.direction = player.LEFT
	player.scale.x = -1

func _on_Player_collided(collision):
	if collision.collider.name == "LeftWallBody":
		$BackGround.set_texture(doorOpenBG)
		$ForeGround.visible = true
		get_node("LeftWallBody/LeftWall").disabled = true

func _on_LevelSwitch_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene("res://scenes/Stalingrad/Stalingrad.tscn")
