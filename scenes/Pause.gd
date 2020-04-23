extends CanvasLayer

func pause():
	get_tree().paused = true
	
	$ColorRect.show()
	$Buttons.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_ResumeButton_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$ColorRect.hide()
	$Buttons.hide()
	
	get_tree().paused = false

func _on_QuitButton_pressed():
	Root.goto_scene("Start")
