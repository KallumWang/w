extends Node

var player_map_position: Vector2 = Vector2.ZERO
var current_map_path: String = ""

func save_player_state(pos: Vector2, map_path: String):
	player_map_position = pos
	current_map_path = map_path
