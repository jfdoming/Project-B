extends KinematicBody2D

signal smash_land

export (PackedScene) var Bullet

export (bool) var may_move = true
export (int) var max_run_speed = 700
export (float) var run_speed_increment_fraction = 1.0 / 20.0
export (int) var jump_speed = 800
export (int) var smash_speed = 1200
export (float) var jump_bonus = 0.15
export (float) var gravity = 2
export (float) var friction = 0.2
export (float) var air_resistance = 0.05

var velocity = Vector2()
var jumping = false
var just_jumped = false
var smashing = false
var alive = true

func get_input(delta):
	var right = may_move and Input.is_action_pressed('ui_right')
	var left = may_move and Input.is_action_pressed('ui_left')
	var jump = may_move and (Input.is_action_just_pressed('ui_select') or Input.is_action_just_pressed('ui_up'))
	var smash = may_move and Input.is_action_just_pressed('ui_down')
	var fire = may_move and Input.is_action_just_pressed("fire")

	if fire:
		var instance = Bullet.instance()
		add_child(instance)
		
		instance.look_at(get_global_mouse_position())
		instance.linear_velocity = Vector2(100, 0).rotated(instance.rotation)
	if smash and jumping and not smashing:
		smashing = true
		velocity.y = smash_speed
	if jump and is_on_floor():
		jumping = true
		just_jumped = true
		velocity.y = -jump_speed - jump_bonus * abs(velocity.x)
	if right:
		velocity.x += run_speed_increment_fraction * max_run_speed * delta * 60
		velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
	if left:
		velocity.x -= run_speed_increment_fraction * max_run_speed * delta * 60
		velocity.x = clamp(velocity.x, -max_run_speed, max_run_speed)
	if not right and not left:
		velocity.x *= (1 - (friction if is_on_floor() else air_resistance)) * delta * 60

func _physics_process(delta):
	get_input(delta)
	velocity.y += gravity * delta * 1000
	if smashing and is_on_floor():
		smashing = false
		emit_signal("smash_land")
	if jumping and not just_jumped and is_on_floor():
		jumping = false
	if just_jumped:
		just_jumped = false
	velocity = move_and_slide(velocity, Vector2(0, -1))


func respawn():
	alive = false
	position.x = 536
	position.y = 240
	velocity.x = 0
	velocity.y = 0
