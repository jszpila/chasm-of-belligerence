class_name Enemy
extends Node2D

var enemy_type: StringName = &"enemy"
var grid_cell: Vector2i = Vector2i.ZERO
var hp: int = 1
var max_hp: int = 1
var corpse_texture: Texture2D
var alive: bool = true
var web_stuck_turns: int = 0

func configure(cell: Vector2i, hp_value: int, corpse_tex: Texture2D) -> void:
	enemy_type = enemy_type if enemy_type != StringName() else &"enemy"
	grid_cell = cell
	max_hp = hp_value
	hp = hp_value
	corpse_texture = corpse_tex
	alive = true
	visible = true
	global_position = Grid.cell_to_world(grid_cell)

func set_cell(cell: Vector2i) -> void:
	grid_cell = cell
	global_position = Grid.cell_to_world(grid_cell)

func apply_damage(amount: int) -> bool:
	if not alive:
		return false
	var prev_hp := hp
	hp = max(0, hp - amount)
	if hp < prev_hp:
		_on_damaged(amount)
	if hp <= 0:
		alive = false
		visible = false
		return true
	return false

func _on_damaged(_amount: int) -> void:
	# Overridden by specific enemies to react to damage (e.g., tint, particles).
	pass

func take_turn(player_cell: Vector2i, rng: RandomNumberGenerator, can_step: Callable) -> void:
	# To be overridden per enemy type.
	pass
