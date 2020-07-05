extends CanvasLayer

var next_scene
var hide_mouse
var play_cutscene

func _ready():
	$Content/MarginContainer/VBoxContainer/ContinueButton.grab_focus()

func receive_params(params):
	next_scene = params.next_scene
	hide_mouse = params.hide_mouse
	play_cutscene = params.play_cutscene
	$Content/MarginContainer/VBoxContainer/XPLabel.text = "XP: " + str(params.xp)

func _on_ContinueButton_pressed():
	if ResourceLoader.exists("res://" + next_scene + ".tscn"):
		if play_cutscene == true:
			Root.goto_scene(next_scene, "LevelSelection")
		else:
			Root.goto_scene(next_scene)
		if hide_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Root.goto_scene("scenes/Start")
