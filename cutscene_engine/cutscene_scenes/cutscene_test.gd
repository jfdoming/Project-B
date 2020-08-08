extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var dialogue_starter = [$TileMap/DialogueStarter, $TileMap/DialogueStarter2]
	
	#func load_dialogue(file_path) -> Dictionary:
	"""
	Parses a JSON file and returns it as a dictionary
	"""
	
	var file = File.new()
	assert (file.file_exists("res://cutscene_engine/data/test_stroheim_dialogue1.json"))
	
	file.open("res://cutscene_engine/data/test_stroheim_dialogue1.json", file.READ)
	var dialogue = parse_json(file.get_as_text())
	assert (dialogue.size() > 0)
	
	for box in dialogue_starter:
		box.load_dialogue(dialogue)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
