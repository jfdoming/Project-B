extends CanvasLayer

func _ready():
	$Content/MarginContainer/VBoxContainer/ContinueButton.grab_focus()

func _on_ContinueButton_pressed():
	Root.goto_scene("layouts/Layout1")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
