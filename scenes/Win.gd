extends CanvasLayer

var next_map

func receive_params(params):
	next_map = params.next_map
	$Content/MarginContainer/VBoxContainer/XPLabel.text = "XP: " + str(params.xp)

func _on_ContinueButton_pressed():
	if ResourceLoader.exists("res://layouts/" + next_map + ".tscn"):
		Root.goto_scene("layouts/" + next_map)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Root.goto_scene("scenes/Start")
