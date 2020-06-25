extends Node

#the global singleton dealing with the stage engine 

var are_levels_complete = {}
var levels = []

func _ready():
	for i in levels:
		if File.new().file_exists("res://scenes/" + i + ".tscn"):
			are_levels_complete[i] = false

