extends KinematicBody2D



export (float) var invuln_flicker_time = 0.1
export (float) var invuln_time = 3.0
var invulnerable = false
export (int) var health = 0
export (int) var max_health = 100
const FLOOR_NORMAL: = Vector2.UP

var isDead = false

var active_damage = 0
var InvulnTimer = Timer.new()
var InvulnFlickerTimer = Timer.new()

func _ready():
	#Setting up flicker timers programatically
	InvulnTimer.set_one_shot(true)
	InvulnTimer.set_wait_time(invuln_time)
	InvulnFlickerTimer.set_wait_time(invuln_flicker_time)
	
	InvulnTimer.set_timer_process_mode(1)
	InvulnFlickerTimer.set_timer_process_mode(1)
	
	InvulnFlickerTimer.set_one_shot(false)
	InvulnTimer.connect("timeout", self, "_on_InvulnTimer_timeout")
	InvulnFlickerTimer.connect("timeout", self, "_on_InvulnFlickerTime_timeout")
	add_child(InvulnTimer)
	add_child(InvulnFlickerTimer)
	
func take_damage(damage):
	if invulnerable or damage == 0:
		return
	
	health = max(health - damage, 0)
	
	emit_signal("health",health,max_health)
	
	if health == 0:
		die()
		return
	
	invulnerable = true
	InvulnTimer.start(invuln_time)
	InvulnFlickerTimer.start(invuln_flicker_time)

func die():
	pass
		
func _on_InvulnTimer_timeout():
	InvulnFlickerTimer.stop()
	invulnerable = false
	#$EnemyDetector/HeadCollisionShape.disabled = false
	#$EnemyDetector/BodyCollisionShape.disabled = false
	show()
	take_damage(active_damage)

func _on_InvulnFlickerTime_timeout():
	if visible:
		hide()
	else:
		show()
