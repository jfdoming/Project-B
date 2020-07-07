extends Area2D

func _on_Event_Triggered_body_entered(body):
	get_node("sample_text").visible = true


func _on_Event_Triggered_body_exited(body):
	get_node("sample_text").visible = false
