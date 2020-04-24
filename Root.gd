# Many thanks to the Godot step-by-step documentation for the ideas behind
# the code below.

extends Node

signal load_progress

var loader
var wait_frames
var time_max = 100
var current_scene

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
	# Don't stop responding to requests, even when paused.
	self.set_pause_mode(PAUSE_MODE_PROCESS)

func reset_layout():
	get_tree().call_group("ResetOnRespawn", "reset")

func save_game(filename = "default"):
	var save_game = File.new()
	var persisted_nodes = get_tree().get_nodes_in_group("Persist")
	
	var should_persist = false
	for persisted_node in persisted_nodes:
		if not persisted_node.has_method("should_persist") or persisted_node.should_persist():
			should_persist = true
	
	if not should_persist:
		return
	
	print("Saving...")
	var path = "user://saves/" + filename + ".save"
	var flags = File.READ_WRITE if save_game.file_exists(path) else File.WRITE
	save_game.open(path, flags)
	
	for persisted_node in persisted_nodes:
		if !persisted_node.has_method("persist"):
			save_game.get_line() # Skip this line
			print("Persisted node '%s' is missing a persist() function, skipping..." % persisted_node.name)
			continue
		
		var data = persisted_node.call("persist")
		save_game.store_line(to_json(data))
	save_game.close()

func load_game(filename = "default"):
	var save_game = File.new()
	if not save_game.file_exists("user://saves/" + filename + ".save"):
		return
	
	var persisted_nodes = get_tree().get_nodes_in_group("Persist")
	var index = 0
	
	save_game.open("user://saves/" + filename + ".save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var persisted_node = persisted_nodes[index]
		index += 1
		
		var node_data = parse_json(save_game.get_line())
		if !persisted_node.has_method("restore"):
			print("Persisted node '%s' is missing a restore() function, skipping..." % persisted_node.name)
			continue

		persisted_node.restore(node_data)
	save_game.close()

func delete_game(filename = "default"):
	var save_game = Directory.new()
	save_game.remove("user://saves/" + filename + ".save")

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	loader = ResourceLoader.load_interactive("res://scenes/" + path + ".tscn")
	if loader == null:
		printerr("Failed to load scene: ", path)
		return
	set_process(true)

	current_scene.queue_free()
	get_tree().paused = false

	wait_frames = 1
	emit_signal("load_progress", 0)

func _process(_time):
	if loader == null:
		set_process(false)
		return

	if wait_frames > 0:
		wait_frames -= 1
		return

	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()

		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			printerr("Failed to load scene.")
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	emit_signal("load_progress", progress)

func set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
	emit_signal("load_progress", 1)
