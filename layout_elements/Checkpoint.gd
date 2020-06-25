extends Area2D

export (int) var id
export (Vector2) var spawn_location

func _on_Checkpoint_body_entered(body):
	body.obtain_checkpoint(id, spawn_location)

