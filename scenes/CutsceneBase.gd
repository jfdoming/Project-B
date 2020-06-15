extends Node

#make this the root of the cutscene scene

var level

func receive_params(level_name):
	level = level_name
	
#call when cutscene is over
func goto_level():
	Root.goto_scene("scenes/" + level)
	
	
