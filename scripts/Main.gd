extends Node2D

const GRID_W := 40 # unused; kept for reference
const GRID_H := 25 # unused; kept for reference

const TILE_FLOOR := Vector2i(0, 0)
const TILE_WALL := Vector2i(0, 0)
const SOURCES_FLOOR := [0, 1, 2, 3]
const SOURCES_WALL := [4, 5, 6, 7]
const FIXED_GRID_W := 48
const FIXED_GRID_H := 36
const BONE_TEXTURES: Array[Texture2D] = [
	preload("res://assets/bones-1.png"),
	preload("res://assets/bones-2.png"),
	preload("res://assets/bones-3.png"),
]
const DOOR_TEX_1: Texture2D = preload("res://assets/door-1.png")
const DOOR_TEX_2: Texture2D = preload("res://assets/door-2.png")
const DOOR_TEX_3: Texture2D = preload("res://assets/door-3.png")
const PLAYER_TEX_1: Texture2D = preload("res://assets/player-1.png")
const PLAYER_TEX_2: Texture2D = preload("res://assets/player-2.png")
const PLAYER_TEX_3: Texture2D = preload("res://assets/player-3.png")
const PLAYER_TEX_4: Texture2D = preload("res://assets/player-4.png")
const HEART_TEX: Texture2D = preload("res://assets/heart.png")
const DEAD_GOBLIN_TEX: Texture2D = preload("res://assets/goblin-2.png")
const ZOMBIE_TEX_1: Texture2D = preload("res://assets/zombie-1.png")
const ZOMBIE_TEX_2: Texture2D = preload("res://assets/zombie-2.png")
const MINO_TEX_1: Texture2D = preload("res://assets/minotaur-1.png")
const MINO_TEX_2: Texture2D = preload("res://assets/minotaur-2.png")
const SFX_PICKUP1: AudioStream = preload("res://assets/pickup-1.wav")
const SFX_PICKUP2: AudioStream = preload("res://assets/pickup-2.wav")
const SFX_HURT1: AudioStream = preload("res://assets/hurt-1.wav")
const SFX_HURT2: AudioStream = preload("res://assets/hurt-2.wav")
const SFX_HURT3: AudioStream = preload("res://assets/hurt-3.wav")
const SFX_DOOR_OPEN: AudioStream = preload("res://assets/door-open.wav")
const SFX_START: AudioStream = preload("res://assets/start.wav")
const SIGHT_INNER_TILES := 5
const SIGHT_OUTER_TILES := 10
const SIGHT_MAX_DARK := 0.8

@onready var floor_map: TileMap = $Floor
@onready var walls_map: TileMap = $Walls
@onready var player: Node2D = $Player
@onready var _player_sprite: Sprite2D = $Player/Sprite2D
@onready var _hud_hearts: HBoxContainer = $HUD/Hearts
@onready var _hud_icon_key: TextureRect = $HUD/HUDKeyIcon
@onready var _hud_icon_sword: TextureRect = $HUD/HUDSwordIcon
@onready var _hud_icon_shield: TextureRect = $HUD/HUDShieldIcon
@onready var _hud_icon_codex: TextureRect = $HUD/HUDCodexIcon
@onready var _hud_icon_rune1: TextureRect = $HUD/HUDRune1Icon
@onready var _hud_icon_rune2: TextureRect = $HUD/HUDRune2Icon
@onready var _fade: ColorRect = $HUD/Fade
@onready var _key_node: Node2D = $Key
@onready var _sword_node: Node2D = $Sword
@onready var _shield_node: Node2D = $Shield
@onready var _potion_node: Node2D = $Potion
@onready var _codex_node: Node2D = $Codex
@onready var _goblin_node: Node2D = $Goblin
@onready var _decor: Node2D = $Decor
@onready var _title_layer: CanvasLayer = $Title
@onready var _title_label: Label = $Title/TitleLabel
@onready var _over_layer: CanvasLayer = $GameOver
@onready var _over_label: Label = $GameOver/OverLabel
@onready var _title_bg: TextureRect = $Title/TitleBG
@onready var _over_bg_win: TextureRect = $GameOver/OverBGWin
@onready var _over_bg_lose: TextureRect = $GameOver/OverBGLose
@onready var _door_node: Node2D = $Door
@onready var _door_sprite: Sprite2D = $Door/Sprite2D
var _fov_overlay: Node2D
var _fov_visible: Array[bool] = []
var _fov_dist: Array[float] = []

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _key_cell: Vector2i = Vector2i.ZERO
var _sword_cell: Vector2i = Vector2i.ZERO
var _shield_cell: Vector2i = Vector2i.ZERO
var _potion_cell: Vector2i = Vector2i.ZERO
var _potion2_cell: Vector2i = Vector2i.ZERO
var _rune1_cell: Vector2i = Vector2i.ZERO
var _rune2_cell: Vector2i = Vector2i.ZERO
var _codex_cell: Vector2i = Vector2i.ZERO
var _key_collected: bool = false
var _sword_collected: bool = false
var _shield_collected: bool = false
var _potion_collected: bool = false
var _potion2_collected: bool = false
var _rune1_collected: bool = false
var _rune2_collected: bool = false
var _codex_collected: bool = false
var _grid_size: Vector2i = Vector2i.ZERO
var _game_over: bool = false
var _won: bool = false
var _goblin_nodes: Array[Node2D] = []
var _goblin_cells: Array[Vector2i] = []
var _goblin_alive: Array[bool] = []
var _zombie_nodes: Array[Node2D] = []
var _zombie_cells: Array[Vector2i] = []
var _zombie_alive: Array[bool] = []
var _zombie_hp: Array[int] = []
var _minotaur_nodes: Array[Node2D] = []
var _minotaur_cells: Array[Vector2i] = []
var _minotaur_alive: Array[bool] = []
var _minotaur_hp: Array[int] = []
var _potion2_node: Node2D
var _rune1_node: Node2D
var _rune2_node: Node2D
var _door_cell: Vector2i = Vector2i.ZERO
var _hp_max: int = 3
var _hp_current: int = 3
var _door_is_open: bool = false
var _level: int = 1
var _crown_collected: bool = false
var _is_transitioning: bool = false

const STATE_TITLE := 0
const STATE_PLAYING := 1
const STATE_GAME_OVER := 2
var _state: int = STATE_TITLE

func _ready() -> void:
	_setup_input()
	_rng.randomize()
	# Start at title screen
	_state = STATE_TITLE
	_show_title(true)
	_set_world_visible(false)
	# Disable player controls until game starts
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	print("Main scene ready 🚀")

func _process(_delta: float) -> void:
	# Title state: wait for Enter to start
	if _state == STATE_TITLE:
		if Input.is_action_just_pressed("start"):
			_start_game()
		return
	# Game over screen: allow Enter/Space to restart regardless
	if _state == STATE_GAME_OVER:
		if Input.is_action_just_pressed("restart") or Input.is_action_just_pressed("start"):
			_restart_game()
		return
	# FOV overlay updates only when player moves or world changes
	var wp := Vector2i(round(player.global_position.x), round(player.global_position.y))
	var cp := Grid.world_to_cell(player.global_position)
	if _game_over:
		# Game over state; show overlay and wait for Enter to restart
		if _state != STATE_GAME_OVER:
			_state = STATE_GAME_OVER
			_show_game_over(_won)
			_set_world_visible(false)
		return
	# proceed with gameplay checks
	# Simple collision checks on grid
	if not _key_collected and cp == _key_cell:
		_key_collected = true
		print("GOT KEY")
		if _key_node:
			_key_node.visible = false
		_update_door_texture()
		_update_hud_icons()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)
		_check_win()
	if not _sword_collected and cp == _sword_cell:
		_sword_collected = true
		print("GOT SWORD")
		if _sword_node:
			_sword_node.visible = false
		_update_player_sprite_appearance()
		_update_hud_icons()
		_play_sfx(SFX_PICKUP1)
		_blink_node(player)
		# Potions (supports two on level 2+); only pick up if below max HP
		var consumed := false
		if cp == _potion_cell and not _potion_collected:
			if _hp_current < _hp_max:
				print("[DEBUG] On potion1 cell. hp=", _hp_current, "/", _hp_max)
				_potion_collected = true
				if _potion_node:
					_potion_node.visible = false
				consumed = true
			else:
				print("[DEBUG] On potion1 but at max HP; not consuming")
		elif _level >= 2 and cp == _potion2_cell and not _potion2_collected:
			if _hp_current < _hp_max:
				print("[DEBUG] On potion2 cell. hp=", _hp_current, "/", _hp_max)
				_potion2_collected = true
				if _potion2_node:
					_potion2_node.visible = false
				consumed = true
			else:
				print("[DEBUG] On potion2 but at max HP; not consuming")
		if consumed:
			_hp_current = min(_hp_max, _hp_current + 1)
			print("GOT POTION (+1 HP)")
			_update_hud_hearts()
			_play_sfx(SFX_PICKUP1)
			_blink_node(player)
	# Level-specific special pickup (codex on L1, crown on L2)
	if _level == 1:
		if not _codex_collected and cp == _codex_cell:
			_codex_collected = true
			print("GOT CODEX")
			if _codex_node:
				_codex_node.visible = false
			_update_hud_icons()
			_update_door_texture()
			_play_sfx(SFX_PICKUP2)
			_blink_node(player)
			_check_win()
	else:
		if not _crown_collected and cp == _codex_cell:
			_crown_collected = true
			print("GOT CROWN")
			if _codex_node:
				_codex_node.visible = false
			_update_hud_icons()
			_update_door_texture()
			_play_sfx(SFX_PICKUP2)
			_blink_node(player)
	if not _shield_collected and cp == _shield_cell:
		_shield_collected = true
		print("GOT SHIELD")
		if _shield_node:
			_shield_node.visible = false
		_update_player_sprite_appearance()
		_update_hud_icons()
		_play_sfx(SFX_PICKUP1)
		_blink_node(player)

	if not _game_over:
		for i in range(_goblin_cells.size()):
			if _goblin_alive.size() > i and _goblin_alive[i] and cp == _goblin_cells[i]:
				_resolve_combat(i)
				break
		# Check zombie contact
		for zi in range(_zombie_cells.size()):
			if _zombie_alive.size() > zi and _zombie_alive[zi] and cp == _zombie_cells[zi]:
				_combat_round_zombie(zi)
				break
		# Check minotaur contact
		for mi in range(_minotaur_cells.size()):
			if _minotaur_alive.size() > mi and _minotaur_alive[mi] and cp == _minotaur_cells[mi]:
				_combat_round_minotaur(mi)
				break
	# Rune pickups: rune-1 (+1 attack) and rune-2 (+1 defense i.e., -1 goblin roll)
	if not _rune1_collected and cp == _rune1_cell:
		_rune1_collected = true
		print("GOT RUNE-1 (+1 ATK)")
		if _rune1_node:
			_rune1_node.visible = false
		_update_hud_icons()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)
	if not _rune2_collected and cp == _rune2_cell:
		_rune2_collected = true
		print("GOT RUNE-2 (+1 DEF)")
		if _rune2_node:
			_rune2_node.visible = false
		_update_hud_icons()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)
	# Check win condition each frame after movement/collisions
	_check_win()
	# Restart on SPACE/ENTER when game over
	if _game_over and Input.is_action_just_pressed("restart"):
		_restart_game()

func _on_player_moved(new_cell: Vector2i) -> void:
	# 75% chance each goblin attempts to move 1 step in a random dir
	print("[DEBUG] moved=", new_cell, " potion1=", _potion_cell, " p1col=", _potion_collected, 
		" potion2=", _potion2_cell, " p2col=", _potion2_collected)
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for i in range(_goblin_cells.size()):
		if _goblin_alive.size() <= i or not _goblin_alive[i]:
			continue
		if _rng.randf() <= 0.75:
			var d: Vector2i = dirs[_rng.randi_range(0, dirs.size() - 1)]
			_move_goblin(i, d)
	# Move zombie (one per level) with low accuracy towards player, less accurate at distance
	if _zombie_cells.size() > 0:
		for i in range(_zombie_cells.size()):
			if _zombie_alive.size() <= i or not _zombie_alive[i]:
				continue
			_move_homing_enemy("zombie", i)
	# Move minotaur (zero on L1, one on L2) with higher accuracy towards player
	if _minotaur_cells.size() > 0:
		for i in range(_minotaur_cells.size()):
			if _minotaur_alive.size() <= i or not _minotaur_alive[i]:
				continue
			_move_homing_enemy("minotaur", i)
	_update_fov()
	# Ensure item pickups trigger reliably on the exact moved cell (especially potions)
	if not _potion_collected and new_cell == _potion_cell:
		if _hp_current < _hp_max:
			print("[DEBUG] On potion1 cell via moved. hp=", _hp_current, "/", _hp_max)
			_potion_collected = true
			if _potion_node:
				_potion_node.visible = false
			_hp_current = min(_hp_max, _hp_current + 1)
			_update_hud_hearts()
			_play_sfx(SFX_PICKUP1)
			_blink_node(player)
		else:
			print("[DEBUG] On potion1 via moved but at max HP; not consuming")
	elif _level >= 2 and not _potion2_collected and new_cell == _potion2_cell:
		if _hp_current < _hp_max:
			print("[DEBUG] On potion2 cell via moved. hp=", _hp_current, "/", _hp_max)
			_potion2_collected = true
			if _potion2_node:
				_potion2_node.visible = false
			_hp_current = min(_hp_max, _hp_current + 1)
			_update_hud_hearts()
			_play_sfx(SFX_PICKUP1)
			_blink_node(player)
		else:
			print("[DEBUG] On potion2 via moved but at max HP; not consuming")

func _move_goblin(index: int, dir: Vector2i) -> void:
	var dest := _goblin_cells[index] + dir
	if not _in_interior(dest):
		return
	if _is_wall(dest):
		return
	var player_cell := Grid.world_to_cell(player.global_position)
	# If goblin would move onto player, do one combat round and don't move into that cell
	if dest == player_cell and _goblin_alive.size() > index and _goblin_alive[index] and not _game_over:
		_combat_round(index)
		return
	_goblin_cells[index] = dest
	if _goblin_nodes.size() > index and _goblin_nodes[index]:
		_goblin_nodes[index].global_position = Grid.cell_to_world(_goblin_cells[index])

func _move_homing_enemy(kind: String, index: int) -> void:
	var ecell := _zombie_cells[index] if kind == "zombie" else _minotaur_cells[index]
	var player_cell := Grid.world_to_cell(player.global_position)
	var delta: Vector2i = player_cell - ecell
	var dist: int = abs(delta.x) + abs(delta.y)
	# Determine desired direction towards player
	var cand: Array[Vector2i] = []
	if delta.x != 0:
		cand.append(Vector2i(1 if delta.x > 0 else -1, 0))
	if delta.y != 0:
		cand.append(Vector2i(0, 1 if delta.y > 0 else -1))
	# Accuracy: minotaur more accurate; zombie less, and decreases with distance
	var p_towards := 0.7
	if kind == "zombie":
		p_towards = clamp(0.8 - 0.05 * float(dist), 0.2, 0.8)
	else:
		p_towards = clamp(0.95 - 0.02 * float(dist), 0.5, 0.95)
	var dir := Vector2i.ZERO
	if _rng.randf() < p_towards and cand.size() > 0:
		dir = cand[_rng.randi_range(0, cand.size() - 1)]
	else:
		# Pick a random direction; slight bias away from player
		var dirs: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
		dirs.shuffle()
		for d in dirs:
			var newd := ecell + d
			if abs((player_cell - newd).x) + abs((player_cell - newd).y) > dist:
				dir = d
				break
		if dir == Vector2i.ZERO:
			dir = dirs[0]
	var dest := ecell + dir
	if not _in_interior(dest) or _is_wall(dest):
		return
	# If moving onto player, do one combat round and don't step
	if dest == player_cell and not _game_over:
		if kind == "zombie":
			_combat_round_zombie(index)
		else:
			_combat_round_minotaur(index)
		return
	# Move
	if kind == "zombie":
		_zombie_cells[index] = dest
		if _zombie_nodes.size() > index and _zombie_nodes[index]:
			_zombie_nodes[index].global_position = Grid.cell_to_world(dest)
	else:
		_minotaur_cells[index] = dest
		if _minotaur_nodes.size() > index and _minotaur_nodes[index]:
			_minotaur_nodes[index].global_position = Grid.cell_to_world(dest)


func _build_test_map(grid_size: Vector2i) -> void:
	var ts: TileSet = floor_map.tile_set
	if ts == null:
		push_warning("TileSet missing on Floor TileMap")
		return
	# Use the first atlas source explicitly (id 0)
	# Ensure tiles exist in both atlas sources (Godot 4 requires explicit tiles)
	for sid in SOURCES_FLOOR:
		var srcf: TileSetAtlasSource = ts.get_source(sid)
		if srcf != null and not srcf.has_tile(TILE_FLOOR):
			srcf.create_tile(TILE_FLOOR)
	for sid in SOURCES_WALL:
		var srcw: TileSetAtlasSource = ts.get_source(sid)
		if srcw != null and not srcw.has_tile(TILE_WALL):
			srcw.create_tile(TILE_WALL)
	# Fill floor to cover the entire viewport (ceil)
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var fsid: int = SOURCES_FLOOR[_rng.randi_range(0, SOURCES_FLOOR.size() - 1)]
			var c := Vector2i(x, y)
			floor_map.set_cell(0, c, fsid, TILE_FLOOR)
			_randomize_floor_wall_transform(floor_map, c)
	# Outline walls on border
	for x in range(grid_size.x):
		var wsid_top: int = SOURCES_WALL[_rng.randi_range(0, SOURCES_WALL.size() - 1)]
		var wsid_bottom: int = SOURCES_WALL[_rng.randi_range(0, SOURCES_WALL.size() - 1)]
		var ctop := Vector2i(x, 0)
		var cbottom := Vector2i(x, grid_size.y - 1)
		walls_map.set_cell(0, ctop, wsid_top, TILE_WALL)
		_randomize_floor_wall_transform(walls_map, ctop)
		walls_map.set_cell(0, cbottom, wsid_bottom, TILE_WALL)
		_randomize_floor_wall_transform(walls_map, cbottom)
	for y in range(grid_size.y):
		var wsid_left: int = SOURCES_WALL[_rng.randi_range(0, SOURCES_WALL.size() - 1)]
		var wsid_right: int = SOURCES_WALL[_rng.randi_range(0, SOURCES_WALL.size() - 1)]
		var cleft := Vector2i(0, y)
		var cright := Vector2i(grid_size.x - 1, y)
		walls_map.set_cell(0, cleft, wsid_left, TILE_WALL)
		_randomize_floor_wall_transform(walls_map, cleft)
		walls_map.set_cell(0, cright, wsid_right, TILE_WALL)
		_randomize_floor_wall_transform(walls_map, cright)

func _get_grid_size() -> Vector2i:
	# Use a fixed world size (in tiles)
	return Vector2i(FIXED_GRID_W, FIXED_GRID_H)

func _random_interior_cell(grid_size: Vector2i) -> Vector2i:
	# Avoid walls by choosing from the interior
	var x := _rng.randi_range(1, grid_size.x - 2)
	var y := _rng.randi_range(1, grid_size.y - 2)
	return Vector2i(x, y)

func _pick_free_interior_cell(grid_size: Vector2i, exclude: Array[Vector2i], require_neighbor: bool = true) -> Vector2i:
	# Gather all eligible interior cells, excluding provided list
	var pool: Array[Vector2i] = []
	for y in range(1, grid_size.y - 1):
		for x in range(1, grid_size.x - 1):
			var c := Vector2i(x, y)
			if exclude.has(c):
				continue
			if not _is_free(c):
				continue
			if require_neighbor and not _has_free_neighbor(c):
				continue
			pool.append(c)
	# Fallbacks if too constrained
	if pool.is_empty() and require_neighbor:
		return _pick_free_interior_cell(grid_size, exclude, false)
	if pool.is_empty():
		# As a last resort, pick any interior cell not in exclude
		for y in range(1, grid_size.y - 1):
			for x in range(1, grid_size.x - 1):
				var c2 := Vector2i(x, y)
				if exclude.has(c2):
					continue
				pool.append(c2)
	if pool.is_empty():
		return Vector2i(1, 1)
	return pool[_rng.randi_range(0, pool.size() - 1)]

func _place_random_entities(grid_size: Vector2i) -> void:
	var player_cell := Grid.world_to_cell(player.global_position)
	# Place key
	_key_cell = _pick_free_interior_cell(grid_size, [player_cell])
	if _key_node:
		_key_node.global_position = Grid.cell_to_world(_key_cell)
	# Place sword
	if not _sword_collected:
		_sword_cell = _pick_free_interior_cell(grid_size, [player_cell, _key_cell])
		if _sword_node:
			_sword_node.global_position = Grid.cell_to_world(_sword_cell)
	elif _sword_node:
		_sword_node.visible = false
	# Place shield
	if not _shield_collected:
		_shield_cell = _pick_free_interior_cell(grid_size, [player_cell, _key_cell, _sword_cell])
		if _shield_node:
			_shield_node.global_position = Grid.cell_to_world(_shield_cell)
	elif _shield_node:
		_shield_node.visible = false
	# Place potion(s)
	_potion_cell = _pick_free_interior_cell(grid_size, [player_cell, _key_cell, _sword_cell, _shield_cell])
	if _potion_node:
		_potion_node.global_position = Grid.cell_to_world(_potion_cell)
	# On level 2+, add a second potion at a distinct free cell
	if _level >= 2:
		var exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell]
		_potion2_cell = _pick_free_interior_cell(grid_size, exclude)
		if _potion2_node == null and _potion_node != null:
			_potion2_node = _potion_node.duplicate()
			_potion2_node.name = "PotionExtra"
			add_child(_potion2_node)
		if _potion2_node != null:
			_potion2_node.global_position = Grid.cell_to_world(_potion2_cell)
			_potion2_node.visible = true
	# Place codex (or crown on L2) avoiding potions
	var codex_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell]
	if _level >= 2:
		codex_exclude.append(_potion2_cell)
	_codex_cell = _pick_free_interior_cell(grid_size, codex_exclude)
	if _codex_node:
		_codex_node.global_position = Grid.cell_to_world(_codex_cell)
	# Place runes (only on level 2+, if not already collected)
	if _level >= 2:
		var base_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell, _codex_cell]
		base_exclude.append(_potion2_cell)
		if not _rune1_collected:
			_rune1_cell = _pick_free_interior_cell(grid_size, base_exclude)
			base_exclude.append(_rune1_cell)
			if _rune1_node == null:
				_rune1_node = Node2D.new()
				_rune1_node.name = "Rune1"
				var s := Sprite2D.new()
				s.centered = false
				s.texture = _try_load_tex("res://assets/rune-1.png")
				s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				s.z_index = 1
				_rune1_node.add_child(s)
				add_child(_rune1_node)
			_rune1_node.global_position = Grid.cell_to_world(_rune1_cell)
			_rune1_node.visible = true
		else:
			if _rune1_node:
				_rune1_node.visible = false
		if not _rune2_collected:
			_rune2_cell = _pick_free_interior_cell(grid_size, base_exclude)
			if _rune2_node == null:
				_rune2_node = Node2D.new()
				_rune2_node.name = "Rune2"
				var s2 := Sprite2D.new()
				s2.centered = false
				s2.texture = _try_load_tex("res://assets/rune-2.png")
				s2.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				s2.z_index = 1
				_rune2_node.add_child(s2)
				add_child(_rune2_node)
			_rune2_node.global_position = Grid.cell_to_world(_rune2_cell)
			_rune2_node.visible = true
		else:
			if _rune2_node:
				_rune2_node.visible = false
	else:
		# Hide runes entirely on level 1
		if _rune1_node:
			_rune1_node.visible = false
		if _rune2_node:
			_rune2_node.visible = false
	# Debug placement dump
	print("[DEBUG] L", _level, " placements:")
	print("  key=", _key_cell, " sword=", _sword_cell, " shield=", _shield_cell)
	print("  potion1=", _potion_cell, " potion2=", (_potion2_cell if _level >= 2 else Vector2i(-1, -1)))
	print("  special(cell)=", _codex_cell, " collected L1? ", _codex_collected, " crown L2+? ", _crown_collected)
	# Reset goblin lists and remove any existing extras
	_clear_extra_goblins()
	_goblin_nodes.clear()
	_goblin_cells.clear()
	_goblin_alive.clear()
	# Reset zombie/minotaur
	for child in get_children():
		if child is Node2D and (child.name.begins_with("Zombie") or child.name.begins_with("Minotaur")):
			child.queue_free()
	_zombie_nodes.clear()
	_zombie_cells.clear()
	_zombie_alive.clear()
	_zombie_hp.clear()
	_minotaur_nodes.clear()
	_minotaur_cells.clear()
	_minotaur_alive.clear()
	_minotaur_hp.clear()
	# Decide total goblins: base + 0-3 extra
	var total := 1 + _rng.randi_range(0, 3)
	var attempts := 0
	for i in range(total):
		attempts = 0
		var gcell := Vector2i.ZERO
		while attempts < 2000:
			attempts += 1
			gcell = _random_interior_cell(grid_size)
			if gcell == player_cell or gcell == _key_cell:
				continue
			var clash := false
			for j in range(_goblin_cells.size()):
				if gcell == _goblin_cells[j]:
					clash = true
					break
			if clash:
				continue
			if not _is_free(gcell):
				continue
			if not _has_free_neighbor(gcell):
				continue
			break
		_spawn_goblin_at(gcell)

	# Spawn exactly one zombie per level
	var zcell := _pick_free_interior_cell(grid_size, [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell, _codex_cell])
	_spawn_zombie_at(zcell)
	# Spawn minotaur only on level 2, exactly one
	if _level >= 2:
		var mcell := _pick_free_interior_cell(grid_size, [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell, _codex_cell, zcell])
		_spawn_minotaur_at(mcell)

func _restart_game() -> void:
	# Fade to black
	if _is_transitioning:
		return
	_is_transitioning = true
	var tw1 := get_tree().create_tween()
	tw1.tween_property(_fade, "modulate:a", 1.0, 0.4)
	await tw1.finished
	# Reset flags
	_game_over = false
	_key_collected = false
	_sword_collected = false
	_shield_collected = false
	_rune1_collected = false
	_rune2_collected = false
	_potion_collected = false
	_potion2_collected = false
	_codex_collected = false
	_crown_collected = false
	_codex_collected = false
	_hp_current = _hp_max
	_level = 1
	_goblin_nodes.clear()
	_goblin_cells.clear()
	_goblin_alive.clear()
	# Clear maps
	floor_map.clear()
	walls_map.clear()
	# Rebuild
	var grid_size := _get_grid_size()
	_grid_size = grid_size
	_build_test_map(grid_size)
	_ensure_fov_overlay()
	_place_player(Vector2i(int(grid_size.x / 2), int(grid_size.y / 2)))
	_place_random_inner_walls(grid_size)
	_place_random_entities(grid_size)
	_set_level_item_textures()
	_clear_bones()
	_place_bones(grid_size)
	_place_door(grid_size)
	_update_fov()
	# Show entities
	if _key_node:
		_key_node.visible = true
	if _sword_node:
		_sword_node.visible = not _sword_collected
	if _shield_node:
		_shield_node.visible = not _shield_collected
	if _potion_node:
		_potion_node.visible = true
	if _potion2_node:
		_potion2_node.visible = _level >= 2
	if _codex_node:
		_codex_node.visible = true
	# Re-enable player controls
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_update_player_sprite_appearance()
	_update_hud_icons()
	_update_hud_hearts()
	# Hide game over overlay and mark state
	_over_layer.visible = false
	_state = STATE_PLAYING
	_set_world_visible(true)
	_play_sfx(SFX_START)
	# Fade back in
	var tw2 := get_tree().create_tween()
	tw2.tween_property(_fade, "modulate:a", 0.0, 0.4)
	await tw2.finished
	_is_transitioning = false

func _resolve_combat(gidx: int) -> void:
	# Roll d20 for player and goblin until there's a winner
	while true:
		var player_roll: int = _rng.randi_range(1, 20)
		var goblin_roll: int = _rng.randi_range(1, 20)
		# Apply equipment modifiers
		if _sword_collected:
			player_roll += 1
		if _rune1_collected:
			player_roll += 1
		if _shield_collected:
			goblin_roll -= 1
		if _rune2_collected:
			goblin_roll -= 1
		print("Player rolls ", player_roll, ", Goblin rolls ", goblin_roll)
		if player_roll == goblin_roll:
			continue
		if player_roll > goblin_roll:
			# Player wins: goblin disappears
			_play_sfx(SFX_HURT1)
			_goblin_alive[gidx] = false
			_goblin_nodes[gidx].visible = false
			_leave_goblin_corpse(_goblin_cells[gidx])
			_play_sfx(SFX_HURT3)
			_check_win()
			break

func _combat_round(gidx: int) -> void:
	if _game_over:
		return
	var player_roll: int = _rng.randi_range(1, 20)
	var goblin_roll: int = _rng.randi_range(1, 20)
	if _sword_collected:
		player_roll += 1
	if _rune1_collected:
		player_roll += 1
	if _shield_collected:
		goblin_roll -= 1
	if _rune2_collected:
		goblin_roll -= 1
	print("Player rolls ", player_roll, ", Goblin rolls ", goblin_roll)
	if player_roll == goblin_roll:
		return
	if player_roll > goblin_roll:
		_play_sfx(SFX_HURT1)
		_blink_node(_goblin_nodes[gidx])
		_goblin_alive[gidx] = false
		_goblin_nodes[gidx].visible = false
		_leave_goblin_corpse(_goblin_cells[gidx])
		_play_sfx(SFX_HURT3)
		_check_win()
	else:
		_hp_current -= 1
		print("Player loses 1 HP. HP now:", _hp_current)
		_update_hud_hearts()
		_play_sfx(SFX_HURT2)
		_blink_node(player)
		if _hp_current <= 0:
			_game_over = true
			_won = false
			if player.has_method("set_control_enabled"):
				player.set_control_enabled(false)

func _combat_round_zombie(zidx: int) -> void:
	if _game_over or _zombie_alive.size() <= zidx or not _zombie_alive[zidx]:
		return
	var player_roll: int = _rng.randi_range(1, 20)
	var z_roll: int = _rng.randi_range(1, 20)
	if _sword_collected:
		player_roll += 1
	if _rune1_collected:
		player_roll += 1
	if _shield_collected:
		z_roll -= 1
	if _rune2_collected:
		z_roll -= 1
	print("Player rolls ", player_roll, ", Zombie rolls ", z_roll)
	if player_roll == z_roll:
		return
	if player_roll > z_roll:
		_play_sfx(SFX_HURT1)
		_blink_node(_zombie_nodes[zidx])
		_zombie_hp[zidx] -= 1
		if _zombie_hp[zidx] <= 0:
			_zombie_alive[zidx] = false
			_zombie_nodes[zidx].visible = false
			_leave_zombie_corpse(_zombie_cells[zidx])
			_play_sfx(SFX_HURT3)
	else:
		_hp_current -= 1
		print("Player loses 1 HP. HP now:", _hp_current)
		_update_hud_hearts()
		_play_sfx(SFX_HURT2)
		_blink_node(player)
		if _hp_current <= 0:
			_game_over = true
			_won = false
			if player.has_method("set_control_enabled"):
				player.set_control_enabled(false)

func _combat_round_minotaur(midx: int) -> void:
	if _game_over or _minotaur_alive.size() <= midx or not _minotaur_alive[midx]:
		return
	var player_roll: int = _rng.randi_range(1, 20)
	var m_roll: int = _rng.randi_range(1, 20)
	if _sword_collected:
		player_roll += 1
	if _rune1_collected:
		player_roll += 1
	if _shield_collected:
		m_roll -= 1
	if _rune2_collected:
		m_roll -= 1
	print("Player rolls ", player_roll, ", Minotaur rolls ", m_roll)
	if player_roll == m_roll:
		return
	if player_roll > m_roll:
		_play_sfx(SFX_HURT1)
		_blink_node(_minotaur_nodes[midx])
		_minotaur_hp[midx] -= 1
		if _minotaur_hp[midx] <= 0:
			_minotaur_alive[midx] = false
			_minotaur_nodes[midx].visible = false
			_leave_minotaur_corpse(_minotaur_cells[midx])
			_play_sfx(SFX_HURT3)
	else:
		_hp_current -= 1
		print("Player loses 1 HP. HP now:", _hp_current)
		_update_hud_hearts()
		_play_sfx(SFX_HURT2)
		_blink_node(player)
		if _hp_current <= 0:
			_game_over = true
			_won = false
			if player.has_method("set_control_enabled"):
				player.set_control_enabled(false)



func _check_win() -> void:
	if _game_over:
		return
	# Prevent re-entrant loads while transitioning
	if _is_transitioning:
		return
	# Require key plus level-appropriate special item
	var special_ok := (_level == 1 and _codex_collected) or (_level >= 2 and _crown_collected)
	if not _key_collected or not special_ok:
		return
	# Player must be standing on the door cell and the door must be open (door-2)
	var cp := Grid.world_to_cell(player.global_position)
	if cp == _door_cell and _door_sprite != null and _door_sprite.texture == DOOR_TEX_2:
		if _level == 1:
			_is_transitioning = true
			_load_next_level()
			return
		# Level 2+: show win screen
		_won = true
		_game_over = true
		if player.has_method("set_control_enabled"):
			player.set_control_enabled(false)

func _start_game() -> void:
	# Hide title, show HUD, reset fade
	_title_layer.visible = false
	_over_layer.visible = false
	_fade.modulate.a = 0.0
	# Reset flags/state
	_state = STATE_PLAYING
	_is_transitioning = false
	_game_over = false
	_won = false
	_level = 1
	_key_collected = false
	_potion_collected = false
	_potion2_collected = false
	_sword_collected = false
	_shield_collected = false
	_hp_current = _hp_max
	_goblin_nodes.clear()
	_goblin_cells.clear()
	_goblin_alive.clear()
	# Build board fresh
	_clear_extra_goblins()
	floor_map.clear()
	walls_map.clear()
	var grid_size := _get_grid_size()
	_grid_size = grid_size
	_build_test_map(grid_size)
	_ensure_fov_overlay()
	_place_player(Vector2i(int(grid_size.x / 2), int(grid_size.y / 2)))
	_place_random_inner_walls(grid_size)
	_place_random_entities(grid_size)
	_set_level_item_textures()
	_clear_bones()
	_place_bones(grid_size)
	_place_door(grid_size)
	_update_fov()
	# Enable controls
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_set_world_visible(true)
	_update_player_sprite_appearance()
	_update_hud_icons()
	_update_hud_hearts()
	# React to player movement for goblin AI
	if player.has_signal("moved") and not player.moved.is_connected(_on_player_moved):
		player.moved.connect(_on_player_moved)
	_play_sfx(SFX_START)

func _show_title(visible: bool) -> void:
	_title_layer.visible = visible
	_over_layer.visible = false
	_title_label.add_theme_font_size_override("font_size", 48)

func _show_game_over(won: bool) -> void:
	_over_layer.visible = true
	_over_bg_win.visible = won
	_over_bg_lose.visible = not won
	_over_label.add_theme_font_size_override("font_size", 48)
	_over_label.text = "Press Enter to restart"

func _set_world_visible(visible: bool) -> void:
	floor_map.visible = visible
	walls_map.visible = visible
	player.visible = visible
	if _fov_overlay:
		_fov_overlay.visible = visible
	if _key_node:
		_key_node.visible = visible and not _key_collected
	if _sword_node:
		_sword_node.visible = visible and not _sword_collected
	if _shield_node:
		_shield_node.visible = visible and not _shield_collected
	if _potion_node:
		_potion_node.visible = visible and not _potion_collected
	if _potion2_node:
		_potion2_node.visible = visible and _level >= 2 and not _potion2_collected
	if _codex_node:
			# Only show special item if not collected for the current level
			var special_uncollected := (_level == 1 and not _codex_collected) or (_level >= 2 and not _crown_collected)
			_codex_node.visible = visible and special_uncollected
	for i in range(_goblin_nodes.size()):
		_goblin_nodes[i].visible = visible and _goblin_alive[i]
	for i in range(_zombie_nodes.size()):
		_zombie_nodes[i].visible = visible and _zombie_alive[i]
	for i in range(_minotaur_nodes.size()):
		_minotaur_nodes[i].visible = visible and _minotaur_alive[i]
	if _hud_hearts:
		_hud_hearts.visible = visible
	_decor.visible = visible
	if _door_node:
		_door_node.visible = visible
	if _potion_node:
		_potion_node.visible = visible and not _potion_collected
	if _rune1_node:
		_rune1_node.visible = visible and _level >= 2 and not _rune1_collected
	if _rune2_node:
		_rune2_node.visible = visible and _level >= 2 and not _rune2_collected
	_update_hud_icons()

func _ensure_fov_overlay() -> void:
	if _fov_overlay == null:
		var fov := preload("res://scripts/FOVOverlay.gd").new()
		fov.name = "FOVOverlay"
		fov.z_index = 100
		fov.z_as_relative = false
		fov.cell_size = Grid.CELL_SIZE
		add_child(fov)
		_fov_overlay = fov
	# size arrays and overlay to grid
	var total: int = _grid_size.x * _grid_size.y
	_fov_visible.resize(total)
	_fov_dist.resize(total)
	for i in range(total):
		_fov_visible[i] = false
		_fov_dist[i] = 1e9
		(_fov_overlay as Node).call("set_grid", _grid_size)
	_update_fov()

func _update_fov() -> void:
	if _grid_size == Vector2i.ZERO:
		return
	var total: int = _grid_size.x * _grid_size.y
	if _fov_visible.size() != total:
		_fov_visible.resize(total)
		_fov_dist.resize(total)
	for i in range(total):
		_fov_visible[i] = false
		_fov_dist[i] = 1e9
	var center: Vector2i = Grid.world_to_cell(player.global_position)
	var radius: int = SIGHT_OUTER_TILES
	if _in_bounds(center):
		var center_idx: int = center.y * _grid_size.x + center.x
		_fov_visible[center_idx] = true
		_fov_dist[center_idx] = 0.0
	var xmin: int = max(0, center.x - radius)
	var xmax: int = min(_grid_size.x - 1, center.x + radius)
	var ymin: int = max(0, center.y - radius)
	var ymax: int = min(_grid_size.y - 1, center.y + radius)
	for y in range(ymin, ymax + 1):
		for x in range(xmin, xmax + 1):
			var c: Vector2i = Vector2i(x, y)
			var dtiles: float = float(max(abs(c.x - center.x), abs(c.y - center.y)))
			if dtiles > float(radius):
				continue
			var line: Array[Vector2i] = _bresenham(center, c)
			for p in line:
				if not _in_bounds(p):
					break
				var i: int = p.y * _grid_size.x + p.x
				var dist: float = sqrt(pow(float(p.x - center.x), 2.0) + pow(float(p.y - center.y), 2.0))
				_fov_visible[i] = true
				_fov_dist[i] = min(_fov_dist[i], dist)
				if _is_wall(p) and p != center:
					break
	if _fov_overlay:
		(_fov_overlay as Node).call_deferred("update_fov", _fov_visible, _fov_dist, SIGHT_INNER_TILES, SIGHT_OUTER_TILES, SIGHT_MAX_DARK)

func _in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < _grid_size.x and cell.y < _grid_size.y

func _bresenham(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var points: Array[Vector2i] = []
	var x0: int = a.x
	var y0: int = a.y
	var x1: int = b.x
	var y1: int = b.y
	var dx: int = abs(x1 - x0)
	var sx: int = (1 if x0 < x1 else -1)
	var dy: int = -abs(y1 - y0)
	var sy: int = (1 if y0 < y1 else -1)
	var err: int = dx + dy
	while true:
		points.append(Vector2i(x0, y0))
		if x0 == x1 and y0 == y1:
			break
		var e2: int = 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy
	return points

func _spawn_goblin_at(cell: Vector2i) -> void:
	var node: Node2D
	if _goblin_nodes.size() == 0:
		node = _goblin_node
	else:
		node = _goblin_node.duplicate()
		node.name = "GoblinExtra%d" % _goblin_nodes.size()
		add_child(node)
	_goblin_nodes.append(node)
	_goblin_cells.append(cell)
	_goblin_alive.append(true)
	node.visible = true
	node.global_position = Grid.cell_to_world(cell)

func _spawn_zombie_at(cell: Vector2i) -> void:
	var node := Node2D.new()
	node.name = "Zombie"
	var s := Sprite2D.new()
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture = ZOMBIE_TEX_1
	node.add_child(s)
	add_child(node)
	_zombie_nodes.append(node)
	_zombie_cells.append(cell)
	_zombie_alive.append(true)
	_zombie_hp.append(1)
	node.visible = true
	node.global_position = Grid.cell_to_world(cell)

func _spawn_minotaur_at(cell: Vector2i) -> void:
	var node := Node2D.new()
	node.name = "Minotaur"
	var s := Sprite2D.new()
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.texture = MINO_TEX_1
	node.add_child(s)
	add_child(node)
	_minotaur_nodes.append(node)
	_minotaur_cells.append(cell)
	_minotaur_alive.append(true)
	_minotaur_hp.append(2)
	node.visible = true
	node.global_position = Grid.cell_to_world(cell)

func _clear_extra_goblins() -> void:
	for child in get_children():
		if child is Node2D and child.name.begins_with("GoblinExtra"):
			child.queue_free()

func _clear_bones() -> void:
	for child in _decor.get_children():
		child.queue_free()

func _place_bones(grid_size: Vector2i) -> void:
	var count := _rng.randi_range(5, 30)
	var used := {}
	var player_cell := Grid.world_to_cell(player.global_position)
	for i in range(count):
		var attempts := 0
		while attempts < 2000:
			attempts += 1
			var c := _random_interior_cell(grid_size)
			var key := "%d,%d" % [c.x, c.y]
			if used.has(key):
				continue
			if not _is_free(c):
				continue
			if c == player_cell or c == _key_cell or c == _sword_cell or c == _shield_cell or c == _potion_cell or c == _codex_cell:
				continue
			var clash := false
			for j in range(_goblin_cells.size()):
				if c == _goblin_cells[j]:
					clash = true
					break
			if clash:
				continue
			# Place a bones sprite
			var s := Sprite2D.new()
			s.texture = BONE_TEXTURES[_rng.randi_range(0, BONE_TEXTURES.size() - 1)]
			s.centered = false
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.modulate = Color(1, 1, 1, 0.75)
			# bones: 50% chance to flip horizontally
			s.flip_h = (_rng.randi_range(0, 1) == 1)
			s.global_position = Grid.cell_to_world(c)
			_decor.add_child(s)
			used[key] = true
			break

func _place_entrance_marker(start_cell: Vector2i) -> void:
	# Find a wall adjacent to the start cell and place a decorative door sprite there.
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	dirs.shuffle()
	var wall_cell := Vector2i(-1, -1)
	for d in dirs:
		var n := start_cell + d
		if _is_wall(n):
			wall_cell = n
			break
	if wall_cell.x == -1:
		return
	var s := Sprite2D.new()
	s.texture = DOOR_TEX_3
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = Grid.cell_to_world(wall_cell)
	# Ensure it draws above the Walls TileMap
	s.z_as_relative = false
	s.z_index = 10
	_decor.add_child(s)

func _place_door(grid_size: Vector2i) -> void:
	# Find a random wall cell (border or inner wall)
	var attempts := 0
	var found := false
	while attempts < 5000 and not found:
		attempts += 1
		var c := Vector2i(_rng.randi_range(0, grid_size.x - 1), _rng.randi_range(0, grid_size.y - 1))
		if _is_wall(c):
			# Ensure door is reachable: at least one adjacent free cell
			var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
			var reachable := false
			for d: Vector2i in dirs:
				var n := c + d
				if _is_free(n):
					reachable = true
					break
			if reachable:
				_door_cell = c
				found = true
	if not found:
		_door_cell = Vector2i(0, 0)
	if _door_node:
		_door_node.global_position = Grid.cell_to_world(_door_cell)
	_update_door_texture()

func _update_door_texture() -> void:
	if _door_sprite == null:
		return
	# Door opens when the level's required items are collected
	var special_ok := (_level == 1 and _codex_collected) or (_level >= 2 and _crown_collected)
	var open := _key_collected and special_ok
	_door_sprite.texture = DOOR_TEX_2 if open else DOOR_TEX_1
	if open and not _door_is_open:
		_play_sfx(SFX_DOOR_OPEN)
		_door_is_open = true
	elif not open:
		_door_is_open = false

func _load_next_level() -> void:
	# Transition to the next level instead of ending the game
	_is_transitioning = true
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	var tw := get_tree().create_tween()
	tw.tween_property(_fade, "modulate:a", 1.0, 0.3)
	await tw.finished
	_level += 1
	# Reset level-specific flags
	_key_collected = false
	_potion_collected = false
	_potion2_collected = false
	_codex_collected = false
	_crown_collected = false
	_door_is_open = false
	# Clear and rebuild world
	_clear_extra_goblins()
	floor_map.clear()
	walls_map.clear()
	var grid_size := _get_grid_size()
	_grid_size = grid_size
	_build_test_map(grid_size)
	_ensure_fov_overlay()
	_place_random_inner_walls(grid_size)
	# Start near a wall for variety and to avoid center artifacts
	var start_cell := _pick_free_cell_next_to_wall(grid_size)
	_place_player(start_cell)
	# Place entities after choosing the start to avoid overlaps
	_place_random_entities(grid_size)
	_set_level_item_textures()
	_clear_bones()
	# Mark the entrance on an adjacent wall near the player's start
	_place_entrance_marker(start_cell)
	_place_bones(grid_size)
	_place_door(grid_size)
	_update_door_texture()
	# Ensure world/entities are visible for the new level
	if _key_node:
		_key_node.visible = true
	if _sword_node:
		_sword_node.visible = not _sword_collected
	if _shield_node:
		_shield_node.visible = not _shield_collected
	if _potion_node:
		_potion_node.visible = true
	if _potion2_node:
		_potion2_node.visible = _level >= 2
	if _codex_node:
		var special_uncollected := (_level == 1 and not _codex_collected) or (_level >= 2 and not _crown_collected)
		_codex_node.visible = special_uncollected
	_update_hud_icons()
	_update_hud_hearts()
	_update_fov()
	_set_world_visible(true)
	var tw2 := get_tree().create_tween()
	tw2.tween_property(_fade, "modulate:a", 0.0, 0.3)
	await tw2.finished
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_is_transitioning = false

func _update_player_sprite_appearance() -> void:
	if _player_sprite == null:
		return
	var both := _sword_collected and _shield_collected
	if both:
		_player_sprite.texture = PLAYER_TEX_4
	elif _sword_collected:
		_player_sprite.texture = PLAYER_TEX_3
	elif _shield_collected:
		_player_sprite.texture = PLAYER_TEX_2
	else:
		_player_sprite.texture = PLAYER_TEX_1

func _update_hud_icons() -> void:
	# Icons appear only during gameplay and when items collected
	var show := (_state == STATE_PLAYING)
	if _hud_icon_key:
		_hud_icon_key.visible = show and _key_collected
	if _hud_icon_sword:
		_hud_icon_sword.visible = show and _sword_collected
	if _hud_icon_shield:
		_hud_icon_shield.visible = show and _shield_collected
	if _hud_icon_codex:
		_hud_icon_codex.visible = show and ((_level == 1 and _codex_collected) or (_level >= 2 and _crown_collected))
	if _hud_icon_rune1:
		_hud_icon_rune1.visible = show and _rune1_collected
	if _hud_icon_rune2:
		_hud_icon_rune2.visible = show and _rune2_collected

func _update_hud_hearts() -> void:
	if _hud_hearts == null:
		return
	for c in _hud_hearts.get_children():
		c.queue_free()
	for i in range(_hp_current):
		var tr := TextureRect.new()
		tr.texture = HEART_TEX
		tr.custom_minimum_size = Vector2(24, 24)
		tr.stretch_mode = TextureRect.STRETCH_KEEP
		_hud_hearts.add_child(tr)

func _leave_goblin_corpse(cell: Vector2i) -> void:
	if _decor == null:
		return
	var s := Sprite2D.new()
	s.texture = DEAD_GOBLIN_TEX
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = Grid.cell_to_world(cell)
	_decor.add_child(s)

func _leave_zombie_corpse(cell: Vector2i) -> void:
	if _decor == null:
		return
	var s := Sprite2D.new()
	s.texture = ZOMBIE_TEX_2
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = Grid.cell_to_world(cell)
	_decor.add_child(s)

func _leave_minotaur_corpse(cell: Vector2i) -> void:
	if _decor == null:
		return
	var s := Sprite2D.new()
	s.texture = MINO_TEX_2
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = Grid.cell_to_world(cell)
	_decor.add_child(s)

func _randomize_floor_wall_transform(tm: TileMap, cell: Vector2i) -> void:
	# Random transform for floor/wall: identity, 90, 180, 270 rotation or horizontal/vertical flip
	var choice := _rng.randi_range(0, 5)
	var flip_h := false
	var flip_v := false
	var transpose := false
	match choice:
		0:
			pass # identity
		1:
			# rotate 90 deg
			transpose = true
			flip_h = true
		2:
			# rotate 180 deg
			flip_h = true
			flip_v = true
		3:
			# rotate 270 deg
			transpose = true
			flip_v = true
		4:
			# flip horizontally
			flip_h = true
		5:
			# flip vertically
			flip_v = true
	var td := tm.get_cell_tile_data(0, cell)
	if td != null:
		td.flip_h = flip_h
		td.flip_v = flip_v
		td.transpose = transpose

func _blink_node(ci: CanvasItem) -> void:
	if ci == null:
		return
	var t := get_tree().create_tween()
	for i in range(3):
		t.tween_property(ci, "modulate:a", 0.2, 0.06)
		t.tween_property(ci, "modulate:a", 1.0, 0.06)

func _play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = stream
	add_child(p)
	p.finished.connect(func(): p.queue_free())
	p.play()

func _set_level_item_textures() -> void:
	# Adjust item visuals per level; fall back gracefully if assets are missing
	var key_tex: Texture2D
	var special_tex: Texture2D
	if _level == 1:
		key_tex = _try_load_tex("res://assets/key-1.png")
		special_tex = _try_load_tex("res://assets/codex.png")
	else:
		key_tex = _try_load_tex("res://assets/key-2.png", "res://assets/key-1.png")
		special_tex = _try_load_tex("res://assets/crown.png", "res://assets/codex.png")
	if _key_node and _key_node.get_node_or_null("Sprite2D") is Sprite2D:
		var s1 := _key_node.get_node("Sprite2D") as Sprite2D
		s1.texture = key_tex if key_tex != null else s1.texture
		s1.z_index = 1
	if _codex_node and _codex_node.get_node_or_null("Sprite2D") is Sprite2D:
		var s2 := _codex_node.get_node("Sprite2D") as Sprite2D
		s2.texture = special_tex if special_tex != null else s2.texture
		s2.z_index = 1
	# Also ensure sword/shield/potions render above tiles
	if _sword_node and _sword_node.get_node_or_null("Sprite2D") is Sprite2D:
		(_sword_node.get_node("Sprite2D") as Sprite2D).z_index = 1
	if _shield_node and _shield_node.get_node_or_null("Sprite2D") is Sprite2D:
		(_shield_node.get_node("Sprite2D") as Sprite2D).z_index = 1
	if _potion_node and _potion_node.get_node_or_null("Sprite2D") is Sprite2D:
		(_potion_node.get_node("Sprite2D") as Sprite2D).z_index = 1
	if _potion2_node and _potion2_node.get_node_or_null("Sprite2D") is Sprite2D:
		(_potion2_node.get_node("Sprite2D") as Sprite2D).z_index = 1
	# HUD icons match the same textures
	if _hud_icon_key:
		_hud_icon_key.texture = key_tex if key_tex != null else _hud_icon_key.texture
	if _hud_icon_codex:
		_hud_icon_codex.texture = special_tex if special_tex != null else _hud_icon_codex.texture

func _try_load_tex(p1: String, p2: String = "", p3: String = "") -> Texture2D:
	var t := load(p1)
	if t is Texture2D:
		return t
	if p2 != "":
		t = load(p2)
		if t is Texture2D:
			return t
	if p3 != "":
		t = load(p3)
		if t is Texture2D:
			return t
	return null

func is_passable(cell: Vector2i) -> bool:
	# Allow stepping onto the door cell so the player can win
	return cell == _door_cell

func _place_random_inner_walls(grid_size: Vector2i) -> void:
	var count := _rng.randi_range(50, 250)
	var placed := 0
	var attempts := 0
	var player_cell := Grid.world_to_cell(player.global_position)
	while placed < count and attempts < count * 20:
		attempts += 1
		var c := _random_interior_cell(grid_size)
		var blocked := (c == player_cell or c == _key_cell or c == _sword_cell or c == _shield_cell or c == _potion_cell)
		for j in range(_goblin_cells.size()):
			if c == _goblin_cells[j]:
				blocked = true
				break
		if blocked:
			continue
		if _is_wall(c):
			continue
		var wsid: int = SOURCES_WALL[_rng.randi_range(0, SOURCES_WALL.size() - 1)]
		walls_map.set_cell(0, c, wsid, TILE_WALL)
		placed += 1

func _is_wall(cell: Vector2i) -> bool:
	return walls_map.get_cell_source_id(0, cell) != -1

func _in_interior(cell: Vector2i) -> bool:
	return cell.x >= 1 and cell.y >= 1 and cell.x < _grid_size.x - 1 and cell.y < _grid_size.y - 1

func _is_free(cell: Vector2i) -> bool:
	return _in_interior(cell) and not _is_wall(cell)

func _has_free_neighbor(cell: Vector2i) -> bool:
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for d: Vector2i in dirs:
		var n: Vector2i = cell + d
		if _is_free(n):
			return true
	return false

func _place_player(cell: Vector2i) -> void:
	if player.has_method("teleport_to_cell"):
		player.teleport_to_cell(cell)
	else:
		player.global_position = Grid.cell_to_world(cell)


func _pick_free_cell_next_to_wall(grid_size: Vector2i) -> Vector2i:
	# Prefer cells that are free and adjacent to a wall, but pick randomly from all candidates
	var pool: Array[Vector2i] = []
	for y in range(1, grid_size.y - 1):
		for x in range(1, grid_size.x - 1):
			var c := Vector2i(x, y)
			if not _is_free(c):
				continue
			var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
			for d in dirs:
				if _is_wall(c + d):
					pool.append(c)
					break
	if pool.size() > 0:
		return pool[_rng.randi_range(0, pool.size() - 1)]
	# Fallback to center if none found (shouldn't happen)
	return Vector2i(int(grid_size.x / 2), int(grid_size.y / 2))

func _setup_input() -> void:
	var mapping: Array = [
		["move_up", [Key.KEY_UP, Key.KEY_W]],
		["move_down", [Key.KEY_DOWN, Key.KEY_S]],
		["move_left", [Key.KEY_LEFT, Key.KEY_A]],
		["move_right", [Key.KEY_RIGHT, Key.KEY_D]],
		["toggle_zoom", [Key.KEY_Z]],
		["restart", [Key.KEY_SPACE, Key.KEY_ENTER]],
		["start", [Key.KEY_ENTER]],
	]
	for pair in mapping:
		var name: String = pair[0]
		var keys: Array = pair[1]
		if not InputMap.has_action(name):
			InputMap.add_action(name)
		for key_code in keys:
			var ev := InputEventKey.new()
			ev.physical_keycode = key_code
			InputMap.action_add_event(name, ev)
func _get_goblin_index_at(cell: Vector2i) -> int:
	for i in range(_goblin_cells.size()):
		if _goblin_alive.size() > i and _goblin_alive[i] and _goblin_cells[i] == cell:
			return i
	return -1

func _get_zombie_index_at(cell: Vector2i) -> int:
	for i in range(_zombie_cells.size()):
		if _zombie_alive.size() > i and _zombie_alive[i] and _zombie_cells[i] == cell:
			return i
	return -1

func _get_minotaur_index_at(cell: Vector2i) -> int:
	for i in range(_minotaur_cells.size()):
		if _minotaur_alive.size() > i and _minotaur_alive[i] and _minotaur_cells[i] == cell:
			return i
	return -1
