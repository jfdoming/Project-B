extends Node2D

func _ready():
	$HUD/CrosshairAnimation.play("Crosshair")
	Root.load_game()

func _process(_delta):
	if Input.is_action_pressed("pause"):
		$Pause.pause()

var win_params = {}

func _on_Player_win(next_scene, hide_mouse):
	win_params.xp = $Player.xp
	win_params.next_scene = next_scene
	win_params.hide_mouse = hide_mouse
	
	$WinTimer.start()

func _on_WinTimer_timeout():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Root.goto_scene("scenes/Win", win_params)
