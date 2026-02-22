extends Node2D

@onready var anim_player = $AnimationPlayer


func _on_area_2d_body_entered(_body: Node2D) -> void:
	anim_player.play("Stepped")
	
	pass # Replace with function body.
