extends Area2D

func _on_DeathArea_body_entered(body):
	body.die()
