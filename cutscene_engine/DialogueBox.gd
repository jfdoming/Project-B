extends Control

#export (String, FILE, "*.json") var dialogue_file_path : String

#func interact() -> void:
	#var dialogue : Dictionary = load_dialogue(dialogue_file_path)
	
	
var dialogue = [
	'Sieg Heil! this is Stroheim!',
	'So glad you can join me today in testing out the new cutscene engine!',
	'Stay tuned for more progress on Project B Stroheim!'
]

var dialogue_index = 0
var finished = false

func _ready():
	load_dialogue()
	test_modulate()
	
func _process(delta):
	$"menacing_next_indicator".visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		load_dialogue()
	if Input.is_action_just_pressed("fire"):
		test_modulate()
	
func load_dialogue():
	if dialogue_index < dialogue.size():
		finished = false
		$RichTextLabel.bbcode_text = dialogue[dialogue_index]
		$RichTextLabel.percent_visible = 0
		$Tween_text.interpolate_property(
			$RichTextLabel, "percent_visible", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween_text.start()
	else:
		queue_free()
	dialogue_index += 1
	
func test_modulate():
	var stroheim_pfp = $stroheim_profile_ph
	var stroheim_tween = $Tween_profile
	var current_color = stroheim_pfp.self_modulate
	if Input.is_action_just_pressed("fire"):
		stroheim_tween.interpolate_property(stroheim_pfp, "self_modulate", current_color, Color8(1,1,1,0),0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		#stroheim_tween.interpolate_property(stroheim_pfp, "self_modulate", Color8(1,1,1,0), current_color,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		# target object, property, start, final, duration, transition type, ease type
		stroheim_tween.start()
	

func _on_Tween_tween_completed(object, key):
	finished = true
