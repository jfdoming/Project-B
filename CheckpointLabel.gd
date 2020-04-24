extends Label

func _process(_delta):
	text = "Checkpoint: " + str($"../../Player".checkpoint)
