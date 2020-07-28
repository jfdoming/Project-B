extends "res://layout_elements/kinematicBody.gd"

signal health

export var gravity: = 2
export var kill_exp = 10000
export var ground_sweep_damage = 1
export var up_swing_damage = 1
export var up_swing_knockback = 1200
export var uppercut_damage = 1
export var side_knockback = 600

var is_dead = false
var can_sweep = true
var attacking = false
var direction = RIGHT
var velocity = Vector2()
var max_speed = 10
var current_attack_hitbox

func _ready():
	_stop_all_anim()
	_show_anim($Idle)
	health = max_health
	emit_signal("health",max_health,max_health)
	
func _physics_process(delta):
	if is_dead == false:
		if not attacking:
			rotate_himmler()
			if direction == LEFT:
				velocity.x = -150
			else:
				velocity.x = 150
		else:
			velocity.x = 0
		#add gravity
		velocity.y += gravity * delta * 1000
		velocity = move_and_slide(velocity, Vector2(0, -1))

func _stop_all_anim():
	var animations = [
		$Idle,
		$SweepCharge,
		$UpCutCharge, 
		$UpCharge
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
	if (player_node.global_position.x - global_position.x) > 0 :
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
	if body == player_node and can_sweep and not attacking:
		_show_anim($SweepCharge)
		can_sweep = false
		attacking = true
		
func _on_PlayerAboveCheck_body_entered(body):
	if body == player_node and not attacking:
		_show_anim($UpCharge)
		attacking = true

func _on_UppercutCheck_body_entered(body):
	if body == player_node and not attacking:
		_show_anim($UpCutCharge)
		attacking = true
	
func _on_SweepAttackTimer_timeout():
	can_sweep = true

func _on_AttackUptimeTimer_timeout():
	current_attack_hitbox.disabled = true
	attacking = false
	
func _on_SweepCharge_animation_finished():
	$SweepAttackTimer.start()
	start_attack($GroundSweepHitbox/CollisionShape2D)
	
func _on_UpCutCharge_animation_finished():
	start_attack($UpperCutHitbox/CollisionShape2D)
	
func _on_UpCharge_animation_finished():
	start_attack($AboveHitBox/CollisionShape2D)
	
func _on_GroundSweepHitbox_body_entered(body):
	if body == player_node:
		damage_player(ground_sweep_damage, side_knockback, 150)

func _on_UpperCutHitbox_body_entered(body):
	if body == player_node:
		damage_player(uppercut_damage, 0, up_swing_knockback * 1.5)

func _on_AboveHitBox_body_entered(body):
	if body == player_node:
		damage_player(up_swing_damage, 0, up_swing_knockback)


