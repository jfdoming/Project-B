extends RigidBody2D

signal kill_obtained

export (int) var damage = 0

func _on_Timer_timeout():
	queue_free()

func on_enemy_entered(body):
	body.take_damage(damage)
	queue_free()

func on_kill(reward):
	emit_signal("kill_obtained", reward)
