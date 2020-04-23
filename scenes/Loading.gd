extends CanvasLayer

var progress
var may_finish

func _ready():
	Root.connect("load_progress", self, "_on_load_progress")

func start_loading():
	$LoadingContainer.show()
	$MinTimer.start(0.5)
	may_finish = false

func finish_loading():
	$LoadingContainer.hide()
	$MinTimer.stop()

func _on_load_progress(new_progress):
	progress = new_progress
	
	if progress == 0:
		start_loading()
		return
	
	if progress == 1 and may_finish:
		finish_loading()
		return
	
	$LoadingContainer/LoadingProgress.value = progress * 100


func _on_MinTimer_timeout():
	may_finish = true
	if progress == 1:
		finish_loading()
