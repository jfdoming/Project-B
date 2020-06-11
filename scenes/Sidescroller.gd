extends Node2D

#set objective names inside list in order from first to last
export var objectives = []
#set this to the scene name, for example if stage file is Level2.tscn name it Level2
export var stage_name = ""
var current_objective
var objective_index = 0
var objectives_count 
var level_complete = false


func _enter_tree():
	if objectives.empty() == true:
		objectives.append("None")
	current_objective = objectives[objective_index]
	CheckLevelUnlocked.are_levels_complete[stage_name] = level_complete

func _ready():
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
	

func _on_Player_objective_complete():
	objective_index += 1
	if objective_index < objectives_count: 
		current_objective = objectives[objective_index]
		$HUD/ObjectiveLabel.update_objective_text()
	else:
		$HUD/ObjectiveLabel.update_objective_text(true)
		level_complete = true
		CheckLevelUnlocked.are_levels_complete[stage_name] = level_complete
		$Player.obtain_goal("scenes/LevelSelection")
		
