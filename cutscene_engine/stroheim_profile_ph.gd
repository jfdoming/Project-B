extends Sprite


var stroheim_pfp = self
onready var stroheim_tween = get_node("Tween_profile")


# Called when the node enters the scene tree for the first time.
func _ready():
	test_modulate()
	
func _process(delta):
	test_modulate()

func test_modulate():
	if Input.is_action_just_pressed("fire"):
		self.modulate = Color(0,1,0)
		


