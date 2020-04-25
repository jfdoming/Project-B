extends Area2D

export (String) var next_map

func _on_Goal_body_entered(body):
	body.obtain_goal(next_map, true)
	Root.save_game()
