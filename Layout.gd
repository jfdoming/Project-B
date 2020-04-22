extends Node2D

signal death
signal win

func _on_DeathArea_body_entered(_body):
	emit_signal("death")


func _on_Goal_body_entered(_body):
	emit_signal("win")
