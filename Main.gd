extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Crosshair.play("Crosshair")

func _on_Layout_death():
	$Player.respawn()


func _on_Layout_win():
	print("win!")
