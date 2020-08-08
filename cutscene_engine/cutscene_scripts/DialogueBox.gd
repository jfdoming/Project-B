extends Control
class_name DialogueBox

signal dialogue_ended

onready var dialogue_player: DialoguePlayer = get_node("DialoguePlayer")

onready var name_label := get_node("Panel/TextureRect/Colums/Name") as Label
onready var text_label := get_node("Panel/TextureRect/Colums/RichText") as RichTextLabel
onready var tween_text := get_node("Panel/TextureRect/Colums/Tween_text") as Tween

onready var button_next := get_node("Panel/TextureRect/Colums/ButtonNext") as Button
onready var button_finished := get_node("Panel/TextureRect/Colums/ButtonFinished") as Button

onready var portrait := $Portrait as TextureRect

onready var next_indicator = $Panel/TextureRect/Colums/menacing_next_indicator

var dialogue_index = 0
var icon_finished = false
var in_progress = false

func _ready():
	pass
	
func start(dialogue: Dictionary) -> void:
	# Reinitializes the UI and asks the DialoguePlayer to 
	# play the dialogue
	button_finished.hide()
	button_next.show()
	button_next.grab_focus()
	button_next.text = "Next"
	dialogue_player.start(dialogue)
	update_content()
	show()

func _on_ButtonNext_pressed() -> void:
	if in_progress:
		tween_text.remove(text_label, "percent_visible")
		text_label.percent_visible = 1
		in_progress = false
	else:
		dialogue_player.next()
		update_content()

func _on_DialoguePlayer_finished() -> void:
	button_next.hide()
	button_finished.grab_focus()
	button_finished.show()

func _on_ButtonFinished_pressed() -> void:
	emit_signal("dialogue_ended")
	hide()

func update_content() -> void:
	#code for text scrolling and text scroll cancelation
	tween_text.remove(text_label, "percent_visible")
	var dialogue_player_name = dialogue_player.title
	name_label.text = dialogue_player_name
	text_label.text = dialogue_player.text
	portrait.texture = DialogueDatabase.get_texture(
		dialogue_player_name, dialogue_player.expression
	)
	text_label.percent_visible = 0
	text_label.bbcode_text = dialogue_player.text
	tween_text.interpolate_property(
		text_label, "percent_visible", 0, 1, float(dialogue_player.text.length())/25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween_text.start()
	in_progress = true
	
func _on_Tween_text_tween_completed(object, key):
	in_progress = false
