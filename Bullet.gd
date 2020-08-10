extends RigidBody2D

signal kill_obtained
signal impact

export (int) var damage = 0 #Gets updated by Player node

func _on_Timer_timeout():
	queue_free()

func on_enemy_entered(body):
	body.take_damage(damage)
	queue_free()

func on_kill(reward):
	emit_signal("kill_obtained", reward)

func _on_Bullet_body_entered(body: PhysicsBody2D) -> void:
	# Set to sleeping so impact particle doesn't keep moving
	set_sleeping(true)
	$BulletSprite.hide()
	$ImpactParticle.emitting = true
	$ImpactParticle.show()
	for N in $ImpactParticle.get_children():
		N.emitting = true
		N.show()
	emit_signal("impact")
