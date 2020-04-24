extends Area2D

export (int) var attack = 25

var attacks = {}

const PLAYER_ENEMY_COLLISION_LAYER = 3

func _on_Node2D_body_entered(body):
	if not body.get_collision_layer_bit(PLAYER_ENEMY_COLLISION_LAYER):
		return
	
	attacks[body.get_instance_id()] = attack
	body.begin_damage(attack)

func _on_Enemy_body_exited(body):
	if not body.get_collision_layer_bit(PLAYER_ENEMY_COLLISION_LAYER):
		return
	
	body.end_damage(attacks[body.get_instance_id()])
