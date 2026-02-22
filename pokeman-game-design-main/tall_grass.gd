extends Node2D

@onready var anim_player = $AnimationPlayer

# 1 in 10 chance (0.1) - make this smaller (e.g., 0.05) to make encounters rarer
var encounter_chance = 0.9 

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Play the rustle animation
	anim_player.play("Stepped")
	
	# Check if the thing that entered is the player
	if body is CharacterBody2D:
		roll_for_encounter()

func roll_for_encounter():
	if randf() < encounter_chance:
		print("Encounter triggered!")
		# Change the scene immediately to avoid Tween errors
		get_tree().change_scene_to_file("res://battle_scene.tscn")
