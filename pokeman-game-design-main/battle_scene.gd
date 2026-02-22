extends Node2D

# --- DATA ---
var player_hp = 150
var enemy_hp = 500
var lucky_multiplier: float = 2.0
var lucky_move_index: int = -1

# Enemy Move Data
var enemy_moves = [
	{"name": "Cheese", "damage": 15},
	{"name": "Hollow purple", "damage": 30},
	{"name": "Diddle", "damage": 10},
	{"name": "Divergent fist", "damage": 15}
]


# --- NODES ---
@onready var player_spawn = $PlayerSpawn
@onready var enemy_spawn = $EnemySpawn
@onready var move_menu = $BattleUI/Control/MarginContainer/VBoxContainer
@onready var battle_log = $BattleUI/RichTextLabel 
@onready var player_hp_bar = $BattleUI/PlayerHPBar
@onready var enemy_hp_bar = $BattleUI/EnemyHPBar

# --- SPRITES ---
var player_sprite = Sprite2D.new()
var enemy_sprite = Sprite2D.new()

# --- STATE ---
var is_player_turn = true

func _ready():
	randomize() 
	setup_sprites()
	pick_lucky_move()
	
	# Initialize bars
	player_hp_bar.max_value = player_hp
	player_hp_bar.value = player_hp
	enemy_hp_bar.max_value = enemy_hp
	enemy_hp_bar.value = enemy_hp
	
	update_log("A wild enemy appears!")

func setup_sprites():
	player_spawn.add_child(player_sprite)
	enemy_spawn.add_child(enemy_sprite)
	
	player_sprite.texture = load("res://icon.svg")
	enemy_sprite.texture = load("res://icon.svg")
	player_sprite.scale = Vector2(0.5, 0.5) 
	enemy_sprite.scale = Vector2(0.5, 0.5)
	
	player_sprite.global_position = player_spawn.global_position + Vector2(-600, 0)
	enemy_sprite.global_position = enemy_spawn.global_position + Vector2(600, 0)
	
	var intro_tween = create_tween().set_parallel(true)
	intro_tween.tween_property(player_sprite, "position", Vector2.ZERO, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	intro_tween.tween_property(enemy_sprite, "position", Vector2.ZERO, 1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func pick_lucky_move():
	lucky_move_index = randi() % 4
	var move_names = ["Tackle", "Fireball", "Kidnap", "PhotoChad"]
	print("DEBUG: The lucky move for this fight is: ", move_names[lucky_move_index])

func update_log(new_text: String):
	battle_log.text = new_text
	battle_log.visible_ratio = 0.0
	var tween = create_tween()
	tween.tween_property(battle_log, "visible_ratio", 1.0, 0.4)

func execute_player_move(move_id: int, move_name: String, base_damage: int):
	is_player_turn = false
	move_menu.hide() # ANTI-SPAM: Hide immediately
	
	var final_damage = base_damage
	update_log("Player used " + move_name + "!")
	
	await get_tree().create_timer(0.5).timeout
	
	if move_id == lucky_move_index:
		final_damage = int(base_damage * lucky_multiplier)
		update_log("LUCKY HIT! " + move_name + " was super effective!")
		spawn_damage_number(final_damage, enemy_spawn.global_position, Color.YELLOW)
		flash_sprite(enemy_sprite, Color.YELLOW)
	else:
		spawn_damage_number(final_damage, enemy_spawn.global_position, Color.WHITE)
		flash_sprite(enemy_sprite, Color.RED)
	
	enemy_hp -= final_damage
	enemy_hp = max(0, enemy_hp)
	check_battle_status("enemy")

func enemy_turn():
	update_log("Enemy is thinking...")
	await get_tree().create_timer(1.5).timeout
	
	# AI: Pick a random move from the list
	var random_index = randi() % enemy_moves.size()
	var move = enemy_moves[random_index]
	
	update_log("Enemy used " + move["name"] + "!")
	
	player_hp -= move["damage"]
	player_hp = max(0, player_hp)
	
	spawn_damage_number(move["damage"], player_spawn.global_position, Color.WHITE)
	flash_sprite(player_sprite, Color.RED)
	check_battle_status("player")

func check_battle_status(last_target: String):
	var hp_tween = create_tween().set_parallel(true)
	hp_tween.tween_property(player_hp_bar, "value", player_hp, 0.4)
	hp_tween.tween_property(enemy_hp_bar, "value", enemy_hp, 0.4)
	
	await hp_tween.finished
	
	if enemy_hp <= 0:
		update_log("ENEMY FAINTED! YOU WIN!")
		victory_animation(enemy_sprite)
	elif player_hp <= 0:
		update_log("YOU WERE DEFEATED...")
		victory_animation(player_sprite)
	else:
		if last_target == "enemy":
			enemy_turn()
		else:
			is_player_turn = true
			move_menu.show() # Bring menu back only when it's your turn

# --- VISUAL HELPERS ---

func flash_sprite(sprite: Sprite2D, color: Color):
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", color, 0.1)
	tween.parallel().tween_property(sprite, "offset", Vector2(10, 0), 0.05)
	tween.tween_property(sprite, "offset", Vector2(-10, 0), 0.05)
	tween.tween_property(sprite, "offset", Vector2(0, 0), 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func victory_animation(defeated_sprite: Sprite2D):
	var tween = create_tween()
	tween.parallel().tween_property(defeated_sprite, "modulate:a", 0, 0.5)
	tween.parallel().tween_property(defeated_sprite, "position:y", 100, 0.5)
	move_menu.hide()

func spawn_damage_number(amount: int, target_position: Vector2, color: Color):
	var label = Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", 32)
	label.modulate = color
	label.global_position = target_position + Vector2(-20, -50)
	add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 100, 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0, 0.7)
	tween.tween_callback(label.queue_free)

# --- BUTTON CONNECTIONS ---

func _on_move_1_pressed() -> void:
	if is_player_turn:
		execute_player_move(0, "Toe Mass", 30)

func _on_move_2_pressed() -> void:
	if is_player_turn:
		execute_player_move(1, "Fireball", 30)

func _on_move_3_pressed() -> void:
	if is_player_turn:
		execute_player_move(2, "Kidnap", 30)

func _on_move_4_pressed() -> void:
	if is_player_turn:
		execute_player_move(3, "Oil Up", 30)
