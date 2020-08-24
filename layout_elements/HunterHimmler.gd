extends "res://layout_elements/kinematicBody.gd"

signal health

export var gravity: = 2
export var kill_exp = 10000
export var ground_sweep_damage = 1
export var up_swing_damage = 1
export var up_swing_knockback = 1200
export var uppercut_damage = 1
export var side_knockback = 600
export var tentacle_damage = 50

var is_dead = false
var can_sweep = true
var can_uppercut = true
var can_above = true
var can_tentacle = false
var in_uppercut_range = false
var in_sweep_range = false
var in_above_range = false
var tentacle_follow = false
var attacking = false
var direction = RIGHT
var velocity = Vector2()
var max_speed = 10
var distance_away = 0
var current_attack_hitbox
var test = 0

var above_ref = funcref(self, "_on_PlayerAboveAttackCheck_body_entered")
var uppercut_ref = funcref(self, "_on_UppercutCheck_body_entered")
var sweep_ref = funcref(self, "_on_GroundSweepCheck_body_entered")

var in_ranges = [in_uppercut_range, in_sweep_range, in_above_range]
var in_ranges_keys = [uppercut_ref, sweep_ref, above_ref]

func _ready():
	_stop_all_anim()
	_show_anim($Idle)
	health = max_health
	emit_signal("health",max_health,max_health)
	$TentacleTimer.start()
	
func _physics_process(delta):
	if is_dead == false:
		if not attacking:
			rotate_himmler()
			#prevent superfast flipping when player x is same as himmler x
			if distance_away < -15 or distance_away > 15:
				if direction == LEFT:
					velocity.x = -150
				else:
					velocity.x = 150
		else:
			velocity.x = 0
		#add gravity
		velocity.y += gravity * delta * 1000
		velocity = move_and_slide(velocity, Vector2(0, -1))
		
func _process(delta):
	if tentacle_follow:
		$TentaclePivot.look_at(player_node.global_position)
	
func _stop_all_anim():
	var animations = [
		$Idle,
		$SweepCharge,
		$UpCutCharge, 
		$UpCharge,
		$TentacleCharge
	]
	for anim in animations:
		self._stop_anim(anim)
	
func _stop_anim(anim):
	anim.visible = false
	anim.stop()

func _show_anim(anim):
	if anim.visible:
		# No need to show it again.
		return
	_stop_all_anim()
	
	anim.visible = true
	anim.frame = 0
	anim.play()
	
func rotate_himmler():
	#controls direction himmler faces
	distance_away = player_node.global_position.x - global_position.x
	if distance_away > 0 :
		if direction == LEFT:
			scale.x = -1
		direction = RIGHT
		
	else:
		if direction == RIGHT:
			scale.x = -1
		direction = LEFT
		
func damage_player(damage_type, horizontal_knockback, vertical_knockback):
	player_node.take_damage(damage_type)
	if direction == LEFT:
		player_node.take_knockback(Vector2(horizontal_knockback, vertical_knockback))
	else:
		player_node.take_knockback(Vector2(-horizontal_knockback, vertical_knockback))

func start_attack(attack_hitbox):
	attack_hitbox.disabled = false
	current_attack_hitbox = attack_hitbox
	$AttackUptimeTimer.start()
	
func _on_BodyDamageDetector_body_entered(body):
	if body.name == "Bullet": 
		take_damage(body.damage)

func _on_GroundSweepCheck_body_entered(body):
	if body == player_node:
		in_sweep_range = true
		#print("sweep")
		if can_sweep and not attacking:
			_show_anim($SweepCharge)
			can_sweep = false
			attacking = true

func _on_GroundSweepCheck_body_exited(body):
	if body == player_node:
		in_sweep_range = false
		
func _on_PlayerAboveAttackCheck_body_entered(body):
	if body == player_node:
		in_above_range = true
		#print("above")
		if can_above and not attacking:
			_show_anim($UpCharge)
			can_above = false
			attacking = true
			
func _on_PlayerAboveAttackCheck_body_exited(body):
	if body == player_node:
		in_above_range = false
			
func _on_UppercutCheck_body_entered(body):
	if body == player_node:
		in_uppercut_range = true
		#print("upper")
		if can_uppercut and not attacking:
			_show_anim($UpCutCharge)
			can_uppercut = false
			attacking = true
		
func _on_UppercutCheck_body_exited(body):
	if body == player_node:
		in_uppercut_range = false
		
func _on_SweepAttackTimer_timeout():
	can_sweep = true
	if in_sweep_range:
		_on_GroundSweepCheck_body_entered(player_node)
		
func _on_UppercutTimer_timeout():
	can_uppercut = true
	if in_uppercut_range:
		_on_UppercutCheck_body_entered(player_node)
		
func _on_AboveTimer_timeout():
	can_above = true
	if in_above_range:
		_on_PlayerAboveAttackCheck_body_entered(player_node)
	
func _on_AttackUptimeTimer_timeout():
	current_attack_hitbox.disabled = true
	attacking = false
	_show_anim($Idle)
	#if timer for next tentacle attack is called while attacking
	if can_tentacle:
		can_tentacle = false
		_on_TentacleTimer_timeout()
	else:
		#check if player entered another attack detector while attacking, if player did call that corresponding attack
		in_ranges = [in_uppercut_range, in_sweep_range, in_above_range]
		for index in range(len(in_ranges)):
			if in_ranges[index]:
				in_ranges_keys[index].call_func(player_node)
				break
	
func _on_SweepCharge_animation_finished():
	$SweepAttackTimer.start()
	start_attack($GroundSweepHitbox/CollisionShape2D)
	
func _on_UpCutCharge_animation_finished():
	$UppercutTimer.start()
	start_attack($UppercutHitbox/CollisionShape2D)
	
func _on_UpCharge_animation_finished():
	$AboveTimer.start()
	start_attack($AboveHitBox/CollisionShape2D)

func _on_TentacleCharge_animation_finished():
	$TentacleTimer.start()
	start_attack($TentaclePivot/TentacleHitBox/CollisionShape2D)
	
func _on_TentacleTimer_timeout():
	if not attacking:
		_show_anim($TentacleCharge)
		$TentacleFollowTimer.start()
		tentacle_follow = true
		attacking = true
	else:
		can_tentacle = true
		
func _on_TentacleFollowTimer_timeout():
	tentacle_follow = false
	
func _on_GroundSweepHitbox_body_entered(body):
	if body == player_node:
		damage_player(ground_sweep_damage, side_knockback, 150)

func _on_UppercutHitbox_body_entered(body):
	if body == player_node:
		damage_player(uppercut_damage, 0, up_swing_knockback * 1.5)

func _on_AboveHitBox_body_entered(body):
	if body == player_node:
		damage_player(up_swing_damage, 0, up_swing_knockback)

func _on_TentacleHitBox_body_entered(body):
	if body == player_node:
		damage_player(tentacle_damage, 150, 150)








