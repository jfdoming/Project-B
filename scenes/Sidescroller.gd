extends Node2D

#set objective names inside list in order from first completed to last
export var objectives = []
#set this to the scene name, for example if level file is Level2.tscn name it Level2
export var level_name = ""
var objectives_count 
var level_complete = false

func _enter_tree():
	if objectives.empty() == true:
		objectives.append("None")
	if CheckLevelUnlocked.is_objective_complete.has(level_name) == false:
		var temp = {}
		for i in objectives:
			temp[i] = false
		CheckLevelUnlocked.is_objective_complete[level_name] = temp
	CheckLevelUnlocked.are_levels_complete[level_name] = level_complete

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
	
#call with objective name to complete that objective
func objective_complete(objective_name):	
	CheckLevelUnlocked.is_objective_complete[level_name][objective_name] = true
	objectives.erase(objective_name)
	var temp = true
	for i in CheckLevelUnlocked.is_objective_complete[level_name].values():
		print(CheckLevelUnlocked.is_objective_complete[level_name].values())
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
		
