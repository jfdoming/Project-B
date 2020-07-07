extends Label

func _process(_delta):
	text = "XP: " + str($"../../Player".xp)
