extends Label

func _process(delta):
	text = "Checkpoint: " + str($"../../Player".checkpoint)
