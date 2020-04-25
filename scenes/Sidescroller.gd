extends Node2D

func _ready():
	$HUD/CrosshairAnimation.play("Crosshair")
	Root.load_game()

func _process(_delta):
	if Input.is_action_pressed("pause"):
		$Pause.pause()

var next_map

func _on_Player_win(map):
	next_map = map
	$WinTimer.start()

func _on_WinTimer_timeout():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Root.goto_scene("scenes/Win", {"xp": $Player.xp, "next_map": next_map})
