extends CanvasLayer

func _on_StartButton_pressed():
	Root.goto_scene("Sidescroller")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
