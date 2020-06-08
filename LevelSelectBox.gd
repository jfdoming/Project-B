extends Control

#set this to the scene name you want this button to go to
export var level_name = ""
export var level_box_name = ""

func _enter_tree():
	$LevelButton.set_text(level_box_name)

func _on_LevelButton_pressed():
	#requires levels to be in the same folder
	Root.goto_scene("scenes/" + level_name)
