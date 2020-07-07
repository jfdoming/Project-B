extends RigidBody2D

signal kill_obtained

export (int) var damage = 0 #Gets updated by Player node

func _on_Timer_timeout():
	queue_free()

func on_enemy_entered(body):
	body.take_damage(damage)
	queue_free()

func on_kill(reward):
	emit_signal("kill_obtained", reward)

#This function destroys the bullet if it hits something
# for example wall or enemy
func _on_DestroyDetector_body_entered(body):
	if body is TileMap || body is KinematicBody2D && body.name!="Player":
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
		queue_free()
