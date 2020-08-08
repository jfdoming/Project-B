# Initializes the map's pawns and emits signals so the
# Game node can start encounters
# Processes in pause mode
extends Node
class_name DialogueStarter

onready var dialogue_box = $DialogueInterface/DialogueBox
#onready var trigger_box_setter = $TriggerBoxSetter

var trigger_counter = 0

export var key = ""
var dialogue_key
#func _ready() -> void:
	#assert(dialogue_box)
	#for action in get_tree().get_nodes_in_group("map_action"):
		#(action as MapAction).initialize(self)
export (String, FILE, "*.json") var dialogue_file_path : String 

func load_dialogue(dialogue_dict):
	"""
	Parses a JSON file and returns it as a dictionary
	"""
	dialogue_key = dialogue_dict[key]
	
func play_dialogue():
	get_tree().paused = true
	#var data = load_dialogue()
	dialogue_box.start(dialogue_key)
	yield(dialogue_box, "dialogue_ended")
	get_tree().paused = false

func _on_Area2D_body_entered(body):
	if trigger_counter < 1:
		play_dialogue()
		trigger_counter += 1
	else:
		pass



