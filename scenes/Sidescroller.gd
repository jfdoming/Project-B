extends Node2D

func _ready():
	$HUD/CrosshairAnimation.play("Crosshair")
	Root.load_game()

func _process(_delta):
	if Input.is_action_pressed("pause"):
		$Pause.pause()

func _on_Layout_win():
	$Player.may_move = false
	$WinTimer.start()

func _on_WinTimer_timeout():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Root.goto_scene("Start")
