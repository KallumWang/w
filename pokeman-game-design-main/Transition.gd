extends CanvasLayer

@onready var rect = $ColorRect

func _ready():
	# Ensure it starts invisible so it doesn't block the map
	rect.modulate.a = 0.0
	# Important: Let clicks pass through the invisible box
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE 

func fade_to_black():
	var tween = create_tween()
	# We MUST await the .finished here so the function actually 'finishes'
	await tween.tween_property(rect, "modulate:a", 1.0, 0.5).finished

func fade_from_black():
	var tween = create_tween()
	await tween.tween_property(rect, "modulate:a", 0.0, 0.5).finished
