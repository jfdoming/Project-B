extends Control

#make this the root of your cutscene

var level
var key = null

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode != KEY_ENTER:
			if key != event.scancode:
				key = event.scancode	
				$Canvas/Label.show()
			else:
				goto_level()
			
func receive_params(level_name):
	level = level_name
	print(level)
#call when cutscene is over
func goto_level():
	Root.goto_scene("scenes/" + level)
	
	
