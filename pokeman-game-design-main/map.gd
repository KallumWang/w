extends Node2D

@onready var player = $Player

func _ready():
	# If we have a saved position, move the player there immediately
	if Global.player_map_position != Vector2.ZERO:
		player.global_position = Global.player_map_position
		# Reset the position in Global so we don't teleport next time we open the game
		Global.player_map_position = Vector2.ZERO
