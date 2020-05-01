extends CanvasLayer

func _ready():
	$Buttons/MarginContainer/VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	Root.goto_scene("layouts/Layout1")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_ResetButton_pressed():
	Root.delete_game()

func _on_QuitButton_pressed():
	get_tree().quit()
