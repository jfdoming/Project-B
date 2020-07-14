extends Node2D

#set objective names inside list in order from first completed to last
export var objectives = []
#set this to the scene name, for example if level file is Level2.tscn name it Level2
export var level_name = ""
var is_objective_complete = {}
var objectives_count 
var level_complete = false
var cutscene_index = 0

func _enter_tree():
	if objectives.empty() == true:
		objectives.append("None")
	for i in objectives:
		is_objective_complete[i] = false
	CheckLevelUnlocked.are_levels_complete[level_name] = level_complete

func _ready():
	if not $Player.in_cutscene:
		$HUD/CrosshairAnimation.play("Crosshair")
	Root.load_game()
	objectives_count = objectives.size()
	
func _process(_delta):
	if Input.is_action_pressed("pause"):
		$Pause.pause()

var win_params = {}

func _on_Player_win(next_scene, hide_mouse):
	win_params.xp = $Player.xp
	win_params.next_scene = next_scene
	win_params.hide_mouse = hide_mouse
	
	$WinTimer.start()

func _on_WinTimer_timeout():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Root.goto_scene("scenes/Win", win_params)
	
#call with objective name to complete that objective
func objective_complete(objective_name):	
	is_objective_complete[objective_name] = true
	objectives.erase(objective_name)
	var temp = true
	for i in is_objective_complete.values():
		if i == false:
			temp = false
			break
	if temp == false: 
		$Pause/ObjectiveLabel.update_objective_text()
	else:
		$Pause/ObjectiveLabel.update_objective_text(true)
		level_complete = true
		CheckLevelUnlocked.are_levels_complete[level_name] = level_complete
		$Player.obtain_goal("scenes/LevelSelection")
	$Player.obtain_checkpoint(cutscene_index, $Player.position)
	cutscene_index += 1
