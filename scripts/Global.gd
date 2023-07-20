extends Node2D

#TODO: Add Global.get_type() https://docs.godotengine.org/en/latest/classes/class_@globalscope.html
#^Why?

var player_data

func _ready():
	player_data = get_json("res://data/player.json")

func get_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())
