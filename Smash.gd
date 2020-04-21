extends AnimatedSprite

func _on_Player_smash_land():
	show()
	frame = 0
	play()


func _on_Smash_animation_finished():
	hide()
