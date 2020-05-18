extends KinematicBody2D

signal smash_land
signal win
signal health

export (PackedScene) var Bullet

# Cosmetic-related options.
export (int) var invuln_flicker_time = 0.1

# Physics-related options.
export (bool) var may_move = true
export (bool) var obey_physics = true
export (int) var max_run_speed = 250
export (float) var run_speed_increment_fraction = 1.0 / 10.0
export (int) var jump_speed = 800
export (int) var smash_speed = 1200
export (float) var jump_bonus = 0.15
export (float) var gravity = 2
export (float) var friction = 0.2
export (float) var air_resistance = 0.05

# Gameplay-related options.
export (int) var max_health = 100
export (float) var invuln_time = 2
export (int) var smash_damage = 50
export (int) var bullet_damage = 10

const LEFT = 0
const RIGHT = 1

var velocity = Vector2()
var direction = RIGHT
var jumping = false
var just_jumped = false
var smashing = false
var firing_chest = false
var health = max_health
var active_damage = 0
var invulnerable = false

# If the list of persisted props continues to grow, perhaps we can store it in
# an inner class instead, as a way of containing all persisted values.
var did_persisted_props_change = false
var xp = 0
var spawn_xp = 0
var checkpoint = -1
var spawn_location = Vector2()

#How much damage enemies do to do player
export var basic_enemy_damage = 15

func _ready():
	spawn_location = position
	_show_anim($StandAnimation)
	emit_signal("health",max_health,max_health)

func _stop_all_anim():
	$StandAnimation.visible = false
	$StandAnimation.stop()
	$WalkAnimation.visible = false
	$WalkAnimation.stop()
	$JumpAnimation.visible = false
	$JumpAnimation.stop()
	$CrouchAnimation.visible = false
	$CrouchAnimation.stop()
	$FireChestAnimation.visible = false
	$FireChestAnimation.stop()

func _show_anim(anim):
	if anim.visible:
		# No need to show it again.
		return
	
	_stop_all_anim()
	
	anim.visible = true
	anim.frame = 0
	anim.play()

func calculate_velocity(delta):
	var fire_chest = may_move and Input.is_action_just_pressed("fire_chest")
	firing_chest = firing_chest or fire_chest
	
	var freeze = (not may_move) or firing_chest
	var right = not freeze and Input.is_action_pressed('ui_right')
	var left = not freeze and Input.is_action_pressed('ui_left')
	var jump = not freeze and (Input.is_action_just_pressed('ui_select') or Input.is_action_just_pressed('ui_up'))
	var crouch = not freeze and Input.is_action_pressed('ui_down')
	var fire = not freeze and Input.is_action_just_pressed("fire")
	var walking = left != right

	if fire:
		var instance = Bullet.instance()
		get_parent().add_child(instance)
		instance.position = $RegularFirePoint.global_position
		instance.look_at(get_global_mouse_position())	
		instance.linear_velocity = Vector2(1000, 0).rotated(instance.rotation)
		instance.damage = bullet_damage		
		instance.connect("kill_obtained", self, "on_kill")	
			
	if crouch:
		if jumping and not smashing:
			smashing = true
			velocity.y = smash_speed
	if jump and is_on_floor():
		jumping = true
		just_jumped = true
		velocity.y = -jump_speed - jump_bonus * abs(velocity.x)
	if right and not left:
		velocity.x += run_speed_increment_fraction * max_run_speed * delta * 60
		velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
		if direction != RIGHT:
			direction = RIGHT
			scale.x = -1
	if left and not right:
		velocity.x -= run_speed_increment_fraction * max_run_speed * delta * 60
		velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
		if direction != LEFT:
			direction = LEFT
			scale.x = -1
	
	if obey_physics:
		if not walking:
			velocity.x *= (1 - (friction if is_on_floor() else air_resistance)) * delta * 60
		
		velocity.y += gravity * delta * 1000
	else:
		velocity.x = 0
		velocity.y = 0
	
	if fire_chest:
		_show_anim($FireChestAnimation)
	elif not freeze:
		if crouch:
			_show_anim($CrouchAnimation)
		elif jumping:
			_show_anim($JumpAnimation)
		elif walking:
			_show_anim($WalkAnimation)
		else:
			_show_anim($StandAnimation)

func _physics_process(delta):
		
	calculate_velocity(delta)
	if smashing and is_on_floor():
		smashing = false
		emit_signal("smash_land")
	if jumping and not just_jumped and is_on_floor():
		jumping = false
	if just_jumped:
		just_jumped = false
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	
func obtain_checkpoint(id, new_spawn_location):
	# Mark if we have something to save.
	if checkpoint != id or spawn_location != new_spawn_location:
		did_persisted_props_change = true
	
	checkpoint = id
	spawn_location = new_spawn_location
	
	health = max_health
	spawn_xp = xp

func obtain_goal(next_scene, freeze = false, hide_mouse = true):
	invulnerable = true
	may_move = false
	obey_physics = not freeze
	emit_signal("win", next_scene, hide_mouse)

func begin_damage(damage):
	if smashing:
		return smash_damage
	
	active_damage += damage
	take_damage(active_damage)
	return 0

func end_damage(damage):
	if active_damage <= 0:
		return
	
	active_damage -= damage

func take_damage(damage):
	if invulnerable or damage == 0:
		return
	
	health = max(health - damage, 0)
	
	emit_signal("health",health,max_health)
	
	if health == 0:
		die()
		return
	
	invulnerable = true
	$InvulnTimer.start(invuln_time)
	$InvulnFlickerTimer.start(invuln_flicker_time)

func on_kill(reward):
	if reward == 0:
		return
	xp += reward
	did_persisted_props_change = true
	
func _on_InvulnTimer_timeout():
	$InvulnFlickerTimer.stop()
	invulnerable = false
	show()
	take_damage(active_damage)

func _on_InvulnFlickerTimer_timeout():
	if visible:
		hide()
	else:
		show()

func die():
	respawn()

func respawn():
	Root.reset_layout()
	
	health = max_health
	emit_signal("health",health,max_health)
	
	xp = spawn_xp
	
	position.x = spawn_location.x
	position.y = spawn_location.y
	velocity.x = 0
	velocity.y = 0

func should_persist():
	return did_persisted_props_change

func persist():
	did_persisted_props_change = false
	
	return {
		"checkpoint": checkpoint,
		"spawn_x": spawn_location.x,
		"spawn_y": spawn_location.y,
		"spawn_xp": xp,
		"max_health": max_health
	}

func restore(data):
	checkpoint = data.checkpoint
	spawn_location.x = data.spawn_x
	spawn_location.y = data.spawn_y
	spawn_xp = data.spawn_xp
	max_health = data.max_health
	
	respawn()


func _on_FireChestAnimation_animation_finished():
	firing_chest = false
	
#This happens when an object of type enemy touches the player
func _on_EnemyDetector_body_entered(body):
	if "BasicEnemy" in body.name and body.isDead == false:
		take_damage(basic_enemy_damage)
