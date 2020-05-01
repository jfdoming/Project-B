extends Area2D

# Gameplay-related options.
export (int) var attack = 25
export (int) var max_health = 175
export (int) var reward = 5

# Cosmetic-related options.
export (float) var passive_time = 1
export (float) var passive_flicker_time = 0.1

var attacks = {}
var health = max_health

const PLAYER_ENEMY_COLLISION_LAYER = 3

func reset():
	health = max_health
	attacks.clear()
	show()

func die():
	$NoAttackTimer.stop()
	$NoAttackFlickerTimer.stop()
	hide()

func take_damage(amt):
	if health == 0 or amt == 0:
		return
	
	health = max(health - amt, 0)
	if health == 0:
		die()
		return
	
	$NoAttackTimer.start(passive_time)
	$NoAttackFlickerTimer.start(passive_flicker_time)

func _on_NoAttackTimer_timeout():
	$NoAttackFlickerTimer.stop()
	show()
	
	for body in get_overlapping_bodies():
		_on_Enemy_body_entered(body)

func _on_NoAttackFlickerTimer_timeout():
	if visible:
		hide()
	else:
		show()

func _on_Enemy_body_entered(body):
	if health == 0:
		return
	if body.get_collision_layer_bit(PLAYER_ENEMY_COLLISION_LAYER):
		var counter_attack = body.begin_damage(attack)
		attacks[body.get_instance_id()] = attack
		take_damage(counter_attack)
	else:
		if not body.has_method("on_enemy_entered"):
			return
		body.on_enemy_entered(self)
	
	if health == 0:
		# We were killed by the body which entered us!
		if body.has_method("on_kill"):
			body.on_kill(reward)

func _on_Enemy_body_exited(body):
	if health == 0:
		return
	if not body.get_collision_layer_bit(PLAYER_ENEMY_COLLISION_LAYER):
		return
	if not body.get_instance_id() in attacks:
		return
	
	body.end_damage(attacks[body.get_instance_id()])
