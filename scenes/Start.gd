extends CanvasLayer

func _on_StartButton_pressed():
	Root.goto_scene("Sidescroller")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_ResetButton_pressed():
	Root.delete_game()

func _on_QuitButton_pressed():
	get_tree().quit()
