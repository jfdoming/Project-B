extends Sprite

export (float) var smoothing = 0.1

func smooth(delta = 0.01):
	var mouse_pos = get_global_mouse_position()
	position += smoothing * 100 * delta * (mouse_pos - position)

func _ready():
	position = get_global_mouse_position()

func _process(delta):
	smooth(delta)
