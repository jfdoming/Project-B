extends Control

onready var update_tween = $UpdateTween
onready var health_over = $HealthBarOver
onready var health_under = $HealthBarUnder
	
#Health of player is updated.
# health may be 0, or amount may be 0.
func _on_Player_health(setHealth,maxHealth):
	var percentage_health = health_bar_value_Update(setHealth,maxHealth) #Sets value
	health_bar_color_Update() #Sets color
	update_tween.interpolate_property(health_under,"value",
	health_under.value,percentage_health,0.4,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
	update_tween.start()
	

#Sets health bar value so it represents a percentage
func health_bar_value_Update(setHealth,maxHealth) -> int:
	var percentage_health = int((float(setHealth) / maxHealth)*100)
	health_over.value = percentage_health
	return percentage_health
	
#Precondition: health bar has a value that's between 0-100. 
# This represents percentages.
func health_bar_color_Update():
	if health_over.value >= 60:
		health_over.set_tint_progress("14e114") #green
	elif health_over.value <=60 and health_over.value>25:
		health_over.set_tint_progress("e1be32") #orange
	else:
		health_over.set_tint_progress("e11e1e") #red	
