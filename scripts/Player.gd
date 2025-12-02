extends Node2D

signal moved(new_cell: Vector2i)

@export var walls_path: NodePath = ^"../Walls"
@export var floor_path: NodePath = ^"../Floor"

var _grid_pos: Vector2i
var _can_act := true
var _move_repeat_time: float = 0.12
var _move_cooldown: float = 0.0
var _control_locked: bool = false

@onready var _walls: TileMap = get_node(walls_path)
@onready var _floor: TileMap = get_node(floor_path)
@onready var _cam: Camera2D = $Camera2D

var _zoom_levels: Array[Vector2] = [Vector2(2, 2), Vector2(3, 3), Vector2(4, 4)]
var _zoom_index: int = 2

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_grid_pos = Grid.world_to_cell(global_position)
	global_position = Grid.cell_to_world(_grid_pos)

func _unhandled_input(event: InputEvent) -> void:
	if not _can_act:
		return
	if event.is_action_pressed("toggle_zoom"):
		_cycle_zoom()
		return
	# Movement while held is handled in _process
	pass

func _process(delta: float) -> void:
	if _move_cooldown > 0.0:
		_move_cooldown -= delta
		return
	if not _can_act:
		return
	var dash_dir := _dash_dir_from_input()
	if dash_dir != Vector2i.ZERO:
		var parent := get_parent()
		if parent and parent.has_method("_on_player_dash_attempt") and parent._on_player_dash_attempt(dash_dir):
			_move_cooldown = _move_repeat_time
			return
	# Support cardinal and diagonal movement by combining axes
	var dir := Vector2i(0, 0)
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	# Opposing keys cancel out, resulting in 0 on that axis.
	if dir != Vector2i(0, 0):
		_try_move(dir)
		_move_cooldown = _move_repeat_time

func _dash_dir_from_input() -> Vector2i:
	if not Input.is_action_pressed("dash_attack"):
		return Vector2i.ZERO
	var dir := Vector2i.ZERO
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if dir == Vector2i.ZERO:
		return Vector2i.ZERO
	var dash_pressed := Input.is_action_just_pressed("dash_attack")
	var dir_just_pressed := Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_down")
	return dir if (dash_pressed or dir_just_pressed) else Vector2i.ZERO

func _try_move(delta_cell: Vector2i) -> void:
	var dest := _grid_pos + delta_cell
	var parent := get_parent()
	if parent and parent.has_method("_on_player_attempt_move"):
		var can_move: bool = parent._on_player_attempt_move()
		if not can_move:
			_end_turn()
			return
	if _is_blocked(dest):
		return
	if parent and parent.has_method("_get_enemy_at") and parent.has_method("_combat_round_enemy"):
		var enemy: Enemy = parent._get_enemy_at(dest)
		if enemy != null:
			parent._combat_round_enemy(enemy, false)
			_end_turn()
			return
	_grid_pos = dest
	global_position = Grid.cell_to_world(_grid_pos)
	emit_signal("moved", _grid_pos)
	_end_turn()

func _is_blocked(cell: Vector2i) -> bool:
	var parent := get_parent()
	# Prevent leaving the playable grid
	if parent and parent.has_method("is_in_bounds"):
		if not parent.is_in_bounds(cell):
			return true
	if parent and parent.has_method("is_cell_blocked"):
		if parent.is_cell_blocked(cell):
			return true
	# Allow parent scene to override passability (e.g., door tile)
	if parent and parent.has_method("is_passable"):
		if parent.is_passable(cell):
			return false
	# Block if there's a wall tile at the cell in the walls TileMap
	if _walls == null:
		return false
	var layer := 0
	var data := _walls.get_cell_source_id(layer, cell)
	return data != -1

func _end_turn() -> void:
	_can_act = false
	# For now, immediately allow next turn (no enemies yet)
	await get_tree().process_frame
	if _control_locked:
		return
	_can_act = true

func teleport_to_cell(cell: Vector2i) -> void:
	_grid_pos = cell
	global_position = Grid.cell_to_world(_grid_pos)

func set_control_enabled(enabled: bool) -> void:
	_control_locked = not enabled
	_can_act = enabled
	if not enabled:
		_move_cooldown = 0.0

func _cycle_zoom() -> void:
	# Find current index by nearest match; default to 2x if not matched
	var current := _cam.zoom
	var best_idx := 0
	var best_diff: float = 1.0e9
	for i in range(_zoom_levels.size()):
		var d: float = absf(_zoom_levels[i].x - current.x)
		if d < best_diff:
			best_diff = d
			best_idx = i
	_zoom_index = (best_idx + 1) % _zoom_levels.size()
	_cam.zoom = _zoom_levels[_zoom_index]
