extends Control

#set this to the scene name you want this button to go to  ex: Level2.tscn is Level2
export var level_name = ""
#set to text on button
export var level_box_name = ""
#set to cutscene scene name, same format as level_name
export var cutscene_name = ""
export var play_cutscene_at_start = false
export var is_unlocked = false
export var is_completed = false

var self_index

func enable_or_disable():
	if level_name in CheckLevelUnlocked.are_levels_complete:
		if CheckLevelUnlocked.are_levels_complete[level_name] == true:
			is_completed = true
	if is_unlocked == true:
		_set_enabled()
	if is_completed == true:
		get_parent().open_next_level(self_index)
		
func _set_disabled():
  $LevelButton.disabled = true
  $LevelButton.modulate = Color(0.5, 0.5, 0.5, 1)

func _set_enabled():
  $LevelButton.disabled = false
  $LevelButton.modulate = Color(0.42, 0.93, 0.53, 1)

func _enter_tree():
	$LevelButton.set_text(level_box_name)
	_set_disabled()
	if not CheckLevelUnlocked.levels.has(level_name):
		CheckLevelUnlocked.levels.append(level_name)
		
func _ready():
	enable_or_disable()
	
func _on_LevelButton_pressed():
	#requires levels to be in the same folder
	if play_cutscene_at_start == false:
		Root.goto_scene("scenes/" + level_name)
	else:
		Root.goto_scene("scenes/" + cutscene_name, level_name)
		
	
