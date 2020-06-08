extends Area2D

export (String) var next_scene
export (bool) var freeze = false
export (bool) var hide_mouse_in_next_scene = true

func _on_Goal_body_entered(body):
	if body.name=="Player":
		body.obtain_goal(next_scene, freeze, hide_mouse_in_next_scene)
		Root.save_game()
