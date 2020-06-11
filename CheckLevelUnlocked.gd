extends Node

#the global singleton dealing with the stage engine 

var are_levels_complete = {}
var indexes = {}
var levels = []
var level_num = 0
var index = 0
var already_ran = false
var counter = 0

func _ready():
	for i in levels:
		if File.new().file_exists("res://scenes/" + i + ".tscn"):
			are_levels_complete[i] = false

func run_once():
	counter += 1
	if counter == level_num:
		already_ran = true 
	
