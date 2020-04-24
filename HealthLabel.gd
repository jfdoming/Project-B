extends Label

func _process(delta):
	text = "Health: " + str($"../../Player".health)
