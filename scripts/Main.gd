extends Node2D

const LevelBuilder := preload("res://scripts/LevelBuilder.gd")
const Enemy := preload("res://scripts/Enemy.gd")
const Goblin := preload("res://scripts/Goblin.gd")
const Zombie := preload("res://scripts/Zombie.gd")
const Minotaur := preload("res://scripts/Minotaur.gd")
const Mouse := preload("res://scripts/Mouse.gd")
const Skeleton := preload("res://scripts/Skeleton.gd")
const Trap := preload("res://scripts/Trap.gd")
const Item := preload("res://scripts/Item.gd")
const GOBLIN_SCENE: PackedScene = preload("res://scenes/Goblin.tscn")
const ZOMBIE_SCENE: PackedScene = preload("res://scenes/Zombie.tscn")
const MINOTAUR_SCENE: PackedScene = preload("res://scenes/Minotaur.tscn")
const SKELETON_SCENE: PackedScene = preload("res://scenes/Skeleton.tscn")
const MOUSE_SCENE: PackedScene = preload("res://scenes/Mouse.tscn")
const TRAP_SCENE: PackedScene = preload("res://scenes/Trap.tscn")
const SPRITESHEET_PATH := "res://assets/spritesheet.png"
const SHEET_CELL := 13
const SHEET_SPRITE_SIZE := Vector2i(12, 12)
const GRID_W := 40 # unused; kept for reference
const GRID_H := 25 # unused; kept for reference

const TILE_FLOOR: Vector2i = Vector2i(0, 0)
const TILE_WALL: Vector2i = Vector2i(0, 0)
const SOURCES_FLOOR: Array[int] = [0, 1, 2, 3]
const SOURCES_WALL: Array[int] = [4, 5, 6, 7, 8]
const FIXED_GRID_W := 48
const FIXED_GRID_H := 36

const SFX_PICKUP1: AudioStream = preload("res://assets/pickup-1.wav")
const SFX_PICKUP2: AudioStream = preload("res://assets/pickup-2.wav")
const SFX_HURT1: AudioStream = preload("res://assets/hurt-1.wav")
const SFX_HURT2: AudioStream = preload("res://assets/hurt-2.wav")
const SFX_HURT3: AudioStream = preload("res://assets/hurt-3.wav")
const SFX_LEVEL_UP: AudioStream = preload("res://assets/level-up.wav")
const SFX_MR_BONES: AudioStream = preload("res://assets/mr-bones.wav")
const SFX_DOOR_OPEN: AudioStream = preload("res://assets/door-open.wav")
const SFX_START: AudioStream = preload("res://assets/start.wav")
const SIGHT_INNER_TILES := 5
const SIGHT_OUTER_TILES := 10
const SIGHT_MAX_DARK := 0.8
const FLOOR_ALPHA_MIN := 1.0
const FLOOR_ALPHA_MAX := 1.0
const BONE_ALPHA_MIN := 1.0
const BONE_ALPHA_MAX := 1.0
const ARMOR_MAX := 3
const LEVEL_UP_SCORE_STEP := 10
const HP_MAX_LIMIT := 10
var PLAYER_TEX_1: Texture2D
var PLAYER_TEX_2: Texture2D
var PLAYER_TEX_3: Texture2D
var PLAYER_TEX_4: Texture2D
var HEART_TEX: Texture2D
var GOBLIN_TEX_1: Texture2D
var DEAD_GOBLIN_TEX: Texture2D
var ZOMBIE_TEX_1: Texture2D
var ZOMBIE_TEX_2: Texture2D
var MINO_TEX_1: Texture2D
var MINO_TEX_2: Texture2D
var SKELETON_TEX_1: Texture2D
var SKELETON_TEX_2: Texture2D
var DOOR_TEX_1: Texture2D
var DOOR_TEX_2: Texture2D
var DOOR_TEX_3: Texture2D
var KEY_TEX_1: Texture2D
var KEY_TEX_2: Texture2D
var KEY_TEX_3: Texture2D
var SWORD_TEX: Texture2D
var SHIELD_TEX: Texture2D
var ARMOR_TEX: Texture2D
var POTION_TEX: Texture2D
var CODEX_TEX: Texture2D
var CROWN_TEX: Texture2D
var RUNE1_TEX: Texture2D
var RUNE2_TEX: Texture2D
var RUNE3_TEX: Texture2D
var TORCH_TEX: Texture2D
var RING_TEX: Texture2D
var ARMOR_ICON_TEX: Texture2D
var TRAP_TEX_A: Texture2D
var TRAP_TEX_B: Texture2D
var TRAP_WEB_TEX: Texture2D
var BRAZIER_TEX: Texture2D
var BONE_TEXTURES: Array[Texture2D] = []
var SPIDERWEB_TEXTURES := {}
var FLOOR_TEXTURES: Array[Texture2D] = []
var WALL_TEXTURES: Array[Texture2D] = []
var _sheet_image: Image
var _sheet_tex_cache := {}

@onready var floor_map: TileMap = $Floor
@onready var walls_map: TileMap = $Walls
@onready var player: Node2D = $Player
@onready var _player_sprite: Sprite2D = $Player/Sprite2D
@onready var _hud_hearts: HBoxContainer = $HUD/HUDBar/HUDVitals/HeartsBorder/Hearts
@onready var _hud_items: HBoxContainer = $HUD/HUDBar/HUDItems/HUDItemsContainer
@onready var _hud_icon_key1: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDKey1Icon
@onready var _hud_icon_key2: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDKey2Icon
@onready var _hud_icon_key3: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDKey3Icon
@onready var _hud_icon_sword: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDSwordIcon
@onready var _hud_icon_shield: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDShieldIcon
@onready var _hud_icon_codex: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDCodexIcon
@onready var _hud_icon_crown: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDCrownIcon
@onready var _hud_icon_rune1: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDRune1Icon
@onready var _hud_icon_rune2: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDRune2Icon
@onready var _hud_icon_rune3: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDRune3Icon
@onready var _hud_icon_torch: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDTorchIcon
@onready var _hud_icon_ring: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDRingIcon
@onready var _hud_icon_potion: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDPotionIcon
@onready var _hud_armor: HBoxContainer = $HUD/HUDBar/HUDVitals/ArmorBorder/Armor
@onready var _hud_atk_label: Label = $HUD/HUDBar/HUDStats/HUDATKLabel
@onready var _hud_def_label: Label = $HUD/HUDBar/HUDStats/HUDDEFLabel
@onready var _hud_score: Label = $HUD/HUDBar/HUDScore
@onready var _fade: ColorRect = $HUD/Fade
@onready var _key_node: Item = $Key
@onready var _sword_node: Item = $Sword
@onready var _shield_node: Item = $Shield
@onready var _potion_node: Item = $Potion
@onready var _codex_node: Item = $Codex
@onready var _decor: Node2D = $Decor
@onready var _title_layer: CanvasLayer = $Title
@onready var _title_label: Label = $Title/TitleLabel
@onready var _over_layer: CanvasLayer = $GameOver
@onready var _over_label: Label = $GameOver/OverLabel
@onready var _over_score: Label = $GameOver/OverScore
@onready var _title_bg: TextureRect = $Title/TitleBG
@onready var _over_bg_win: TextureRect = $GameOver/OverBGWin
@onready var _over_bg_lose: TextureRect = $GameOver/OverBGLose
@onready var _door_node: Node2D = $Door
@onready var _door_sprite: Sprite2D = $Door/Sprite2D
@onready var _entrance_door_node: Node2D = $EntranceDoor
@onready var _entrance_door_sprite: Sprite2D = $EntranceDoor/Sprite2D
@onready var _hud_level: Label = $HUD/HUDBar/HUDLevel
@export var level_fade_out_time: float = 0.5
@export var level_fade_in_time: float = 0.5
@export var level_fade_alpha: float = 0.95
var _tileset: TileSet
var _fov_overlay: Node2D
var _fov_visible: Array[bool] = []
var _fov_dist: Array[float] = []

func _sheet() -> Image:
	if _sheet_image == null:
		var tex: Texture2D = load(SPRITESHEET_PATH)
		if tex == null:
			push_error("Spritesheet not found at %s" % SPRITESHEET_PATH)
			return Image.new()
		_sheet_image = tex.get_image()
	return _sheet_image

func _sheet_tex(key: StringName, pos: Vector2i, mask_black: bool) -> Texture2D:
	if _sheet_tex_cache.has(key):
		return _sheet_tex_cache[key]
	var region := Rect2i(pos + Vector2i.ONE, SHEET_SPRITE_SIZE)
	var img := _sheet().get_region(region)
	if mask_black:
		img.convert(Image.FORMAT_RGBA8)
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var c := img.get_pixel(x, y)
				if c.r <= 0.01 and c.g <= 0.01 and c.b <= 0.01:
					c.a = 0.0
					img.set_pixel(x, y, c)
	var tex := ImageTexture.create_from_image(img)
	_sheet_tex_cache[key] = tex
	return tex

func _make_tile_source(tex: Texture2D) -> TileSetAtlasSource:
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = SHEET_SPRITE_SIZE
	return src

func _set_sprite_tex(node: Node, tex: Texture2D) -> void:
	if node == null or tex == null:
		return
	var s := node.get_node_or_null("Sprite2D") as Sprite2D
	if s:
		s.texture = tex
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _load_spritesheet_textures() -> void:
	PLAYER_TEX_1 = _sheet_tex(&"player1", Vector2i(1352, 0), true)
	PLAYER_TEX_2 = _sheet_tex(&"player2", Vector2i(1456, 0), true)
	PLAYER_TEX_3 = _sheet_tex(&"player3", Vector2i(1937, 0), true)
	PLAYER_TEX_4 = _sheet_tex(&"player4", Vector2i(1989, 0), true)
	HEART_TEX = _sheet_tex(&"heart", Vector2i(1014, 481), true)
	GOBLIN_TEX_1 = _sheet_tex(&"goblin1", Vector2i(1352, 52), true)
	DEAD_GOBLIN_TEX = _sheet_tex(&"goblin_dead", Vector2i(2613, 52), true)
	ZOMBIE_TEX_1 = _sheet_tex(&"zombie1", Vector2i(1352, 117), true)
	ZOMBIE_TEX_2 = _sheet_tex(&"zombie2", Vector2i(2613, 117), true)
	MINO_TEX_1 = _sheet_tex(&"mino1", Vector2i(1352, 208), true)
	MINO_TEX_2 = _sheet_tex(&"mino2", Vector2i(2613, 208), true)
	SKELETON_TEX_1 = _sheet_tex(&"skeleton1", Vector2i(1352, 130), true)
	SKELETON_TEX_2 = _sheet_tex(&"skeleton_dead", Vector2i(2613, 130), true)
	var mouse_tex := _sheet_tex(&"mouse", Vector2i(39, 182), true)
	DOOR_TEX_1 = _sheet_tex(&"door1", Vector2i(156, 13), false)
	DOOR_TEX_2 = _sheet_tex(&"door2", Vector2i(143, 13), false)
	DOOR_TEX_3 = _sheet_tex(&"door3", Vector2i(260, 26), false)
	KEY_TEX_1 = _sheet_tex(&"key1", Vector2i(117, 585), true)
	KEY_TEX_2 = _sheet_tex(&"key2", Vector2i(13, 585), true)
	KEY_TEX_3 = _sheet_tex(&"key3", Vector2i(39, 585), true)
	SWORD_TEX = _sheet_tex(&"sword", Vector2i(351, 78), true)
	SHIELD_TEX = _sheet_tex(&"shield", Vector2i(364, 156), true)
	ARMOR_TEX = _sheet_tex(&"armor", Vector2i(351, 143), true)
	POTION_TEX = _sheet_tex(&"potion", Vector2i(481, 52), true)
	CODEX_TEX = _sheet_tex(&"codex", Vector2i(91, 481), true)
	CROWN_TEX = _sheet_tex(&"crown", Vector2i(351, 299), true)
	RUNE1_TEX = _sheet_tex(&"rune1", Vector2i(338, 221), true)
	RUNE2_TEX = _sheet_tex(&"rune2", Vector2i(351, 221), true)
	RUNE3_TEX = _sheet_tex(&"rune3", Vector2i(364, 221), true)
	TORCH_TEX = _sheet_tex(&"torch", Vector2i(52, 546), true)
	RING_TEX = _sheet_tex(&"ring", Vector2i(156, 559), true)
	ARMOR_ICON_TEX = _sheet_tex(&"armor_icon", Vector2i(338, 156), true)
	TRAP_TEX_A = _sheet_tex(&"trap_a", Vector2i(364, 273), true)
	TRAP_TEX_B = _sheet_tex(&"trap_b", Vector2i(390, 273), true)
	TRAP_WEB_TEX = _sheet_tex(&"trap_web", Vector2i(52, 507), true)
	BRAZIER_TEX = _sheet_tex(&"brazier", Vector2i(351, 286), true)
	BONE_TEXTURES = [
		_sheet_tex(&"bone1", Vector2i(0, 494), true),
		_sheet_tex(&"bone2", Vector2i(13, 494), true),
		_sheet_tex(&"bone3", Vector2i(26, 494), true),
	]
	SPIDERWEB_TEXTURES = {
		&"top_left": _sheet_tex(&"spiderweb_top_left", Vector2i(0, 507), true),
		&"top_right": _sheet_tex(&"spiderweb_top_right", Vector2i(13, 507), true),
		&"bottom_left": _sheet_tex(&"spiderweb_bottom_left", Vector2i(26, 507), true),
		&"bottom_right": _sheet_tex(&"spiderweb_bottom_right", Vector2i(39, 507), true),
	}
	FLOOR_TEXTURES = [
		_sheet_tex(&"floor1", Vector2i(130, 65), false),
		_sheet_tex(&"floor2", Vector2i(143, 65), false),
		_sheet_tex(&"floor3", Vector2i(156, 65), false),
		_sheet_tex(&"floor4", Vector2i(117, 65), false),
	]
	WALL_TEXTURES = [
		_sheet_tex(&"wall1", Vector2i(0, 26), false),
		_sheet_tex(&"wall2", Vector2i(13, 26), false),
		_sheet_tex(&"wall3", Vector2i(65, 26), false),
		_sheet_tex(&"wall4", Vector2i(78, 26), false),
		_sheet_tex(&"wall5", Vector2i(91, 26), false),
	]
	_sheet_tex_cache[&"mouse_tex"] = mouse_tex
	_set_sprite_tex(_door_node, DOOR_TEX_1)
	_set_sprite_tex(_key_node, KEY_TEX_1)
	_set_sprite_tex(_sword_node, SWORD_TEX)
	_set_sprite_tex(_shield_node, SHIELD_TEX)
	_set_sprite_tex(_potion_node, POTION_TEX)
	_set_sprite_tex(_codex_node, CODEX_TEX)
	_set_sprite_tex(_player_sprite, PLAYER_TEX_1)

func _build_tileset_from_sheet() -> void:
	_tileset = TileSet.new()
	_tileset.tile_size = Vector2i(12, 12)
	for i in range(FLOOR_TEXTURES.size()):
		var src := _make_tile_source(FLOOR_TEXTURES[i])
		_tileset.add_source(src, i)
	for i in range(WALL_TEXTURES.size()):
		var src2 := _make_tile_source(WALL_TEXTURES[i])
		_tileset.add_source(src2, SOURCES_WALL[0] + i)
	floor_map.tile_set = _tileset
	walls_map.tile_set = _tileset

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _level_builder: LevelBuilder
var _key_cell: Vector2i = Vector2i.ZERO
var _sword_cell: Vector2i = Vector2i.ZERO
var _shield_cell: Vector2i = Vector2i.ZERO
var _potion_cell: Vector2i = Vector2i.ZERO
var _potion2_cell: Vector2i = Vector2i.ZERO
var _armor_cells: Array[Vector2i] = []
var _rune1_cells: Array[Vector2i] = []
var _rune2_cells: Array[Vector2i] = []
var _rune3_cells: Array[Vector2i] = []
var _torch_cell: Vector2i = Vector2i.ZERO
var _ring_cell: Vector2i = Vector2i.ZERO
var _codex_cell: Vector2i = Vector2i.ZERO
var _key_collected: bool = false
var _key_on_level: bool = false
var _entrance_cell: Vector2i = Vector2i.ZERO
var _sword_collected: bool = false
var _shield_collected: bool = false
var _potion_collected: bool = false
var _potion2_collected: bool = false
var _armor_current: int = 0
var _rune1_collected_count: int = 0
var _rune2_collected_count: int = 0
var _rune3_collected_count: int = 0
var _torch_collected: bool = false
var _ring_collected: bool = false
var _codex_collected: bool = false
var _crown_collected: bool = false
var _key1_icon_persistent: bool = false
var _key2_icon_persistent: bool = false
var _key3_icon_persistent: bool = false
var _key1_collected: bool = false
var _key2_collected: bool = false
var _key3_collected: bool = false
var _codex_icon_persistent: bool = false
var _crown_icon_persistent: bool = false
var _entrance_rearm: bool = false
var _exit_rearm: bool = false
var _grid_size: Vector2i = Vector2i.ZERO
var _game_over: bool = false
var _won: bool = false
var _score: int = 0
var _next_level_score: int = LEVEL_UP_SCORE_STEP
var _attack_level_bonus: int = 0
var _defense_level_bonus: int = 0
var _carried_potion: bool = false
var _goblins: Array[Goblin] = []
var _zombies: Array[Zombie] = []
var _minotaurs: Array[Minotaur] = []
var _skeletons: Array[Skeleton] = []
var _mice: Array[Mouse] = []
var _traps: Array[Trap] = []
var _potion2_node: Item
var _armor_nodes: Array[Item] = []
var _rune1_nodes: Array[Item] = []
var _rune2_nodes: Array[Item] = []
var _rune3_nodes: Array[Item] = []
var _torch_node: Item
var _ring_node: Item
var _door_cell: Vector2i = Vector2i.ZERO
var _hp_max: int = 3
var _hp_current: int = 3
var _door_is_open: bool = false
var _level: int = 1
var _max_level: int = 2
var _is_transitioning: bool = false
var _torch_target_level: int = 1
var _last_trap_cell: Vector2i = Vector2i(-1, -1)
var _bone_cells := {}
var _bone_spawn_outcomes := {}
var _web_stuck_turns: int = 0
var _spiderweb_nodes: Array[Sprite2D] = []
var _brazier_cells: Array[Vector2i] = []
var _brazier_nodes: Array[Node2D] = []
var _level_special_map := {} # level -> special type
var _special_levels := {} # special type -> level
var _level_key_map := {} # level -> key type
var _armor_plan := {} # level -> count
var _rune1_plan := {} # level -> count
var _rune2_plan := {}
var _rune3_plan := {}
var _level_states := {}

const STATE_TITLE := 0
const STATE_PLAYING := 1
const STATE_GAME_OVER := 2
var _state: int = STATE_TITLE

func _ready() -> void:
	_setup_input()
	_load_spritesheet_textures()
	_build_tileset_from_sheet()
	_rng.randomize()
	_level_builder = LevelBuilder.new(_rng)
	# Start at title screen
	_state = STATE_TITLE
	_show_title(true)
	_set_world_visible(false)
	# Disable player controls until game starts
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	if _fade:
		# Use opaque black color; modulate controls the visible alpha
		_fade.color = Color(0, 0, 0, 1)
		_fade.modulate.a = 0.0
		_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_fade.show_behind_parent = false
		_fade.z_as_relative = false
		_fade.z_index = 1000
		_update_fade_rect()
		if get_tree().root and not get_tree().root.size_changed.is_connected(_update_fade_rect):
			get_tree().root.size_changed.connect(_update_fade_rect)
	_update_hud_icons()
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
	if Input.is_action_just_pressed("use_potion"):
		_try_use_potion()
	# proceed with gameplay checks
	# Simple collision checks on grid
	var on_entrance := (_level > 1 and cp == _entrance_cell)
	if on_entrance and _entrance_rearm:
		print("[DEBUG] Entrance travel trigger: level=", _level, " cp=", cp, " entrance_cell=", _entrance_cell)
		_travel_to_level(_level - 1, false)
		return
	if not on_entrance and _level > 1:
		_entrance_rearm = true
	var on_exit := (cp == _door_cell)
	if on_exit and _exit_rearm and (not _key_on_level or _key_collected):
		if _level < _max_level:
			_travel_to_level(_level + 1, true)
			return
		else:
			_won = true
			_game_over = true
			if player.has_method("set_control_enabled"):
				player.set_control_enabled(false)
	# re-arm exit once player leaves tile
	if not on_exit:
		_exit_rearm = true
	if not _key_collected and cp == _key_cell:
		_key_collected = true
		var ktype := _current_key_type()
		if ktype == &"key1":
			_key1_collected = true
			_key1_icon_persistent = true
		elif ktype == &"key2":
			_key2_collected = true
			_key2_icon_persistent = true
		elif ktype == &"key3":
			_key3_collected = true
			_key3_icon_persistent = true
		print("GOT KEY")
		if _key_node:
			_key_node.collect()
		_play_sfx(SFX_DOOR_OPEN)
		_add_score(1)
		_update_door_texture()
		_blink_node(player)
		_check_win()
	if not _sword_collected and cp == _sword_cell:
		_sword_collected = true
		print("GOT SWORD")
		if _sword_node:
			_sword_node.collect()
			_add_score(1)
			_update_player_sprite_appearance()
			_play_sfx(SFX_PICKUP1)
			_blink_node(player)
	# Potions (supports two on level 2+); collect into inventory if available and not already carrying one
		_pickup_potion_if_available(cp)
	# Special pickups (codex, crown, ring)
	var st := _current_level_special_type()
	if st == &"codex" and not _codex_collected and cp == _codex_cell:
		_codex_collected = true
		_codex_icon_persistent = true
		print("GOT CODEX")
		if _codex_node:
			_codex_node.collect()
		_add_score(1)
		_update_door_texture()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)
		_check_win()
	elif st == &"crown" and not _crown_collected and cp == _codex_cell:
		_crown_collected = true
		_crown_icon_persistent = true
		print("GOT CROWN")
		if _codex_node:
			_codex_node.collect()
		_add_score(1)
		_update_door_texture()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)
	if not _shield_collected and cp == _shield_cell:
		_shield_collected = true
		print("GOT SHIELD")
		if _shield_node:
			_shield_node.collect()
			_add_score(1)
			_update_player_sprite_appearance()
			_play_sfx(SFX_PICKUP1)
			_blink_node(player)
	# Torch pickup: extends FOV by +4 for the rest of the run
	if not _torch_collected and cp == _torch_cell:
		_torch_collected = true
		print("GOT TORCH (+4 SIGHT)")
		if _torch_node:
			_torch_node.collect()
		_update_fov()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)
		_add_score(1)
	if not _ring_collected and _current_level_special_type() == &"ring" and cp == _ring_cell:
		_ring_collected = true
		print("GOT RING")
		if _ring_node:
			_ring_node.collect()
		_play_sfx(SFX_PICKUP1)
		_blink_node(player)
		_add_score(1)
		_ring_cell = Vector2i(-1, -1)

	if not _game_over:
		var enemy: Enemy = _get_enemy_at(cp)
		if enemy != null:
			var force_resolve := enemy is Goblin
			_combat_round_enemy(enemy, force_resolve)
		else:
			var trap := _trap_at(cp)
			if trap != null:
				if trap.trap_type == &"spiderweb" or cp != _last_trap_cell:
					_handle_trap_trigger(trap, cp)
			else:
				_last_trap_cell = Vector2i(-1, -1)
		# Rune pickups: rune-1 (+1 attack) and rune-2 (+1 defense i.e., -1 goblin roll)
		for r1 in _rune1_nodes:
			if r1 != null and not r1.collected and cp == r1.grid_cell:
				_rune1_collected_count += 1
				print("GOT RUNE-1 (+1 ATK)")
				r1.collect()
				_play_sfx(SFX_PICKUP2)
				_blink_node(player)
				_add_score(1)
				break
		for r2 in _rune2_nodes:
			if r2 != null and not r2.collected and cp == r2.grid_cell:
				_rune2_collected_count += 1
				print("GOT RUNE-2 (+1 DEF)")
				r2.collect()
				_play_sfx(SFX_PICKUP2)
				_blink_node(player)
				_add_score(1)
				break
		for r3 in _rune3_nodes:
			if r3 != null and not r3.collected and cp == r3.grid_cell:
				_rune3_collected_count += 1
				print("GOT RUNE-3 (+1 MAX HP)")
				_hp_max = min(HP_MAX_LIMIT, _hp_max + 1)
				if _hp_current < _hp_max:
					_hp_current = min(_hp_max, _hp_current + 1)
				_update_hud_hearts()
				r3.collect()
				_play_sfx(SFX_PICKUP2)
				_blink_node(player)
				_add_score(1)
				break
		for ar in _armor_nodes:
			if ar != null and not ar.collected and cp == ar.grid_cell:
				_armor_current = min(ARMOR_MAX, _armor_current + 1)
				print("GOT ARMOR (+1 ARMOR)")
				_update_hud_armor()
				ar.collect()
				_play_sfx(SFX_PICKUP2)
				_blink_node(player)
				_add_score(1)
				break
	# Check win condition each frame after movement/collisions
	_check_win()
	# Restart on SPACE/ENTER when game over
	if _game_over and Input.is_action_just_pressed("restart"):
		_restart_game()

func _on_player_moved(new_cell: Vector2i) -> void:
	var skeleton_count_before := _skeletons.size()
	_maybe_spawn_skeleton_from_bones(new_cell)
	_advance_enemies_and_update(skeleton_count_before)
	# Ensure item pickups trigger reliably on the exact moved cell (especially potions)
	_pickup_potion_if_available(new_cell)

func _on_player_attempt_move() -> bool:
	if _web_stuck_turns > 0:
		_web_stuck_turns = max(0, _web_stuck_turns - 1)
		_advance_enemies_and_update(_skeletons.size())
		return false
	return true

func _advance_enemies_and_update(skip_skeletons_from: int) -> void:
	# 75% chance each goblin attempts to move 1 step in a random dir
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for goblin: Goblin in _goblins:
		if goblin.alive and _rng.randf() <= 0.75:
			var d: Vector2i = dirs[_rng.randi_range(0, dirs.size() - 1)]
			_move_goblin(goblin, d)
	for mouse: Mouse in _mice:
		if mouse.alive and _rng.randf() <= 0.75:
			var d2: Vector2i = dirs[_rng.randi_range(0, dirs.size() - 1)]
			_move_mouse(mouse, d2)
	# Move zombie (one per level) with low accuracy towards player, less accurate at distance
	for zombie: Zombie in _zombies:
		if zombie.alive:
			_move_homing_enemy(zombie)
	for i in range(_skeletons.size()):
		var skeleton := _skeletons[i]
		if i >= skip_skeletons_from:
			continue
		if skeleton.alive:
			_move_homing_enemy(skeleton)
	# Move minotaur (zero on L1, one on L2) with higher accuracy towards player
	for mino: Minotaur in _minotaurs:
		if mino.alive:
			_move_homing_enemy(mino)
	_update_fov()

func _move_goblin(goblin: Goblin, dir: Vector2i) -> void:
	var dest: Vector2i = goblin.grid_cell + dir
	if not _can_enemy_step(dest, goblin):
		return
	var player_cell := Grid.world_to_cell(player.global_position)
	# If goblin would move onto player, do one combat round and don't move into that cell
	if dest == player_cell and goblin.alive and not _game_over:
		_combat_round_enemy(goblin)
		return
	goblin.set_cell(dest)
	var trap := _trap_at(dest)
	if trap != null:
		_handle_enemy_hit_by_trap(goblin, trap)

func _move_mouse(mouse: Mouse, dir: Vector2i) -> void:
	var dest: Vector2i = mouse.grid_cell + dir
	if not _in_interior(dest) or _is_wall(dest):
		return
	# avoid stacking on hostile enemies or other mice
	if _get_enemy_at(dest) != null:
		return
	for m in _mice:
		if m != mouse and m.alive and m.grid_cell == dest:
			return
	var trap := _trap_at(dest)
	if trap != null:
		# mice are immune
		return
	mouse.set_cell(dest)

func _move_homing_enemy(enemy: Enemy) -> void:
	var ecell := enemy.grid_cell
	var player_cell := Grid.world_to_cell(player.global_position)
	var delta: Vector2i = player_cell - ecell
	var dist: int = abs(delta.x) + abs(delta.y)
	# Determine desired direction towards player
	var cand: Array[Vector2i] = []
	if delta.x != 0:
		cand.append(Vector2i(1 if delta.x > 0 else -1, 0))
	if delta.y != 0:
		cand.append(Vector2i(0, 1 if delta.y > 0 else -1))
	# Accuracy: minotaur more accurate; zombie/skeleton less, and decreases with distance
	var p_towards := 0.7
	if enemy.enemy_type == &"zombie" or enemy.enemy_type == &"skeleton":
		# Make zombies/skeletons track more aggressively, but still below minotaur accuracy
		p_towards = clamp(0.88 - 0.035 * float(dist), 0.35, 0.9)
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
	var dest: Vector2i = ecell + dir
	if not _can_enemy_step(dest, enemy):
		return
	# If moving onto player, do one combat round and don't step
	if dest == player_cell and not _game_over:
		var trap := _trap_at(dest)
		if trap != null:
			_handle_enemy_hit_by_trap(enemy, trap)
			return
		_combat_round_enemy(enemy)
		return
	# Move
	enemy.set_cell(dest)
	var trap2 := _trap_at(dest)
	if trap2 != null:
		_handle_enemy_hit_by_trap(enemy, trap2)


func _get_grid_size() -> Vector2i:
	# Use a fixed world size (in tiles)
	return Vector2i(FIXED_GRID_W, FIXED_GRID_H)

func _build_maps(grid_size: Vector2i) -> void:
	_level_builder.build_test_map(
		floor_map,
		walls_map,
		grid_size,
		SOURCES_FLOOR,
		SOURCES_WALL,
		TILE_FLOOR,
		TILE_WALL,
		FLOOR_ALPHA_MIN,
		FLOOR_ALPHA_MAX
	)

func _place_random_entities(grid_size: Vector2i) -> void:
	var player_cell := Grid.world_to_cell(player.global_position)
	var is_free := Callable(self, "_is_free")
	var has_free_neighbor := Callable(self, "_has_free_neighbor")
	_clear_enemies()
	_clear_mice()
	_clear_runes()
	_clear_armor_items()
	_clear_bones()
	_potion_collected = false
	_potion2_collected = false
	_reset_items_visibility()
	# Place key (may be absent on some levels)
	var key_type := _current_key_type()
	_key_on_level = false
	if key_type != StringName():
		if _is_key_type_collected(key_type):
			_key_cell = Vector2i(-1, -1)
			_key_collected = true
			if key_type == &"key1":
				_key1_collected = true
				_key1_icon_persistent = true
			elif key_type == &"key2":
				_key2_collected = true
				_key2_icon_persistent = true
			elif key_type == &"key3":
				_key3_collected = true
				_key3_icon_persistent = true
			if _key_node:
				_key_node.visible = false
		else:
			_key_on_level = true
			_key_collected = false
			_key_cell = _level_builder.pick_free_interior_cell(grid_size, [player_cell], is_free, has_free_neighbor)
			if _key_node:
				_set_sprite_tex(_key_node, _key_texture_for_type(key_type))
				_key_node.place(_key_cell)
	else:
		_key_cell = Vector2i(-1, -1)
		if _key_node:
			_key_node.visible = false
			_key_node.collected = true
	if not _key_on_level:
		_key_collected = true
		if key_type == &"key1":
			_key1_collected = true
		elif key_type == &"key2":
			_key2_collected = true
		elif key_type == &"key3":
			_key3_collected = true
	# Place sword/shield only on first level
	if _level == 1 and not _sword_collected:
		_sword_cell = _level_builder.pick_free_interior_cell(grid_size, [player_cell, _key_cell], is_free, has_free_neighbor)
		if _sword_node:
			_sword_node.place(_sword_cell)
	elif _sword_node:
		_sword_node.visible = false
	if _level == 1 and not _shield_collected:
		_shield_cell = _level_builder.pick_free_interior_cell(
			grid_size,
			[player_cell, _key_cell, _sword_cell],
			is_free,
			has_free_neighbor
		)
		if _shield_node:
			_shield_node.place(_shield_cell)
	elif _shield_node:
		_shield_node.visible = false
	# Place potion(s): between 0-2 per level
	var potion_count := _rng.randi_range(0, 2)
	if potion_count > 0:
		_potion_cell = _level_builder.pick_free_interior_cell(
			grid_size,
			[player_cell, _key_cell, _sword_cell, _shield_cell],
			is_free,
			has_free_neighbor
		)
		if _potion_node:
			_potion_node.place(_potion_cell)
	else:
		_potion_cell = Vector2i(-1, -1)
		_potion_collected = true
		if _potion_node:
			_potion_node.visible = false
	if potion_count > 1:
		var exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell]
		_potion2_cell = _level_builder.pick_free_interior_cell(grid_size, exclude, is_free, has_free_neighbor)
		if _potion2_node == null and _potion_node != null:
			_potion2_node = _potion_node.duplicate() as Item
			_potion2_node.name = "PotionExtra"
			add_child(_potion2_node)
			_set_sprite_tex(_potion2_node, POTION_TEX)
		if _potion2_node != null:
			_potion2_node.place(_potion2_cell)
			_potion2_node.visible = true
	else:
		_potion2_cell = Vector2i(-1, -1)
		_potion2_collected = true
		if _potion2_node:
			_potion2_node.visible = false
	# Place braziers as decor (same count logic as potions)
	_clear_braziers()
	var brazier_count := _rng.randi_range(0, 2)
	if brazier_count > 0:
		var b_exclude: Array[Vector2i] = [
			player_cell,
			_key_cell,
			_sword_cell,
			_shield_cell
		]
		if _potion_cell != Vector2i(-1, -1):
			b_exclude.append(_potion_cell)
		if _potion2_cell != Vector2i(-1, -1):
			b_exclude.append(_potion2_cell)
		for i_b in range(brazier_count):
			var b_cell := _level_builder.pick_free_interior_cell(grid_size, b_exclude, is_free, has_free_neighbor)
			b_exclude.append(b_cell)
			_brazier_cells.append(b_cell)
			_spawn_brazier(b_cell)
	else:
		_brazier_cells.clear()
	# Place special (codex/crown/ring) avoiding potions
	var special_type := _current_level_special_type()
	var special_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell]
	if _potion_cell != Vector2i(-1, -1):
		special_exclude.append(_potion_cell)
	if _potion2_cell != Vector2i(-1, -1):
		special_exclude.append(_potion2_cell)
	if special_type == &"codex" or special_type == &"crown":
		if (special_type == &"codex" and _codex_collected) or (special_type == &"crown" and _crown_collected):
			_codex_cell = Vector2i(-1, -1)
			if _codex_node:
				_codex_node.visible = false
		else:
			_codex_cell = _level_builder.pick_free_interior_cell(grid_size, special_exclude, is_free, has_free_neighbor)
			if _codex_node:
				_codex_node.place(_codex_cell)
	elif special_type == &"ring":
		if _ring_collected:
			_ring_cell = Vector2i(-1, -1)
			if _ring_node:
				_ring_node.visible = false
		else:
			_ring_cell = _level_builder.pick_free_interior_cell(grid_size, special_exclude, is_free, has_free_neighbor)
			if _ring_node == null:
				_ring_node = _make_item_node("Ring", RING_TEX)
				add_child(_ring_node)
			_ring_node.place(_ring_cell)
			_ring_node.visible = true
	else:
		_codex_cell = Vector2i(-1, -1)
		_ring_cell = Vector2i(-1, -1)
		if _codex_node:
			_codex_node.visible = false
		if _ring_node and special_type != &"ring":
			_ring_node.visible = false
	# Place runes according to run-level plan
	var base_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell]
	if _potion_cell != Vector2i(-1, -1):
		base_exclude.append(_potion_cell)
	if _potion2_cell != Vector2i(-1, -1):
		base_exclude.append(_potion2_cell)
	if _brazier_cells.size() > 0:
		base_exclude.append_array(_brazier_cells)
	if _codex_cell != Vector2i.ZERO:
		base_exclude.append(_codex_cell)
	if special_type == &"ring" and _ring_cell != Vector2i.ZERO:
		base_exclude.append(_ring_cell)
	var armor_to_place: int = int(_armor_plan.get(_level, 0))
	var rune1_to_place: int = int(_rune1_plan.get(_level, 0))
	var rune2_to_place: int = int(_rune2_plan.get(_level, 0))
	var rune3_to_place: int = int(_rune3_plan.get(_level, 0))
	for i_a in range(armor_to_place):
		var a_cell := _level_builder.pick_free_interior_cell(grid_size, base_exclude, is_free, has_free_neighbor)
		base_exclude.append(a_cell)
		_armor_cells.append(a_cell)
		var a_node := _make_item_node("Armor%d" % i_a, ARMOR_TEX)
		add_child(a_node)
		a_node.place(a_cell)
		_armor_nodes.append(a_node)
	for i_r1 in range(rune1_to_place):
		var cell1 := _level_builder.pick_free_interior_cell(grid_size, base_exclude, is_free, has_free_neighbor)
		base_exclude.append(cell1)
		_rune1_cells.append(cell1)
		var node1 := _make_item_node("Rune1%d" % i_r1, RUNE1_TEX)
		add_child(node1)
		node1.place(cell1)
		_rune1_nodes.append(node1)
	for i_r2 in range(rune2_to_place):
		var cell2 := _level_builder.pick_free_interior_cell(grid_size, base_exclude, is_free, has_free_neighbor)
		base_exclude.append(cell2)
		_rune2_cells.append(cell2)
		var node2: Item = _make_item_node("Rune2%d" % i_r2, RUNE2_TEX)
		add_child(node2)
		node2.place(cell2)
		_rune2_nodes.append(node2)
	for i_r3 in range(rune3_to_place):
		var cell3 := _level_builder.pick_free_interior_cell(grid_size, base_exclude, is_free, has_free_neighbor)
		base_exclude.append(cell3)
		_rune3_cells.append(cell3)
		var node3: Item = _make_item_node("Rune3%d" % i_r3, RUNE3_TEX)
		add_child(node3)
		node3.place(cell3)
		_rune3_nodes.append(node3)
	# Torch placement: only once per run
	if not _torch_collected and _level == _torch_target_level:
		var exclude2: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell]
		if _potion_cell != Vector2i(-1, -1):
			exclude2.append(_potion_cell)
		if _potion2_cell != Vector2i(-1, -1):
			exclude2.append(_potion2_cell)
		for c1 in _rune1_cells:
			exclude2.append(c1)
		for c2 in _rune2_cells:
			exclude2.append(c2)
		for a_cell in _armor_cells:
			exclude2.append(a_cell)
		for c3 in _rune3_cells:
			exclude2.append(c3)
		if special_type == &"ring" and _ring_cell != Vector2i.ZERO:
			exclude2.append(_ring_cell)
		if _codex_cell != Vector2i.ZERO:
			exclude2.append(_codex_cell)
		_torch_cell = _level_builder.pick_free_interior_cell(grid_size, exclude2, is_free, has_free_neighbor)
		if _torch_node == null:
			_torch_node = _make_item_node("Torch", TORCH_TEX)
			add_child(_torch_node)
		_torch_node.place(_torch_cell)
		_torch_node.visible = true
	else:
		if _torch_node and _level != _torch_target_level:
			_torch_node.visible = false
	# Debug placement dump
	print("[DEBUG] L", _level, " of ", _max_level ," placements:")
	print("  key=", _key_cell, " sword=", _sword_cell, " shield=", _shield_cell)
	print("  potion1=", _potion_cell, " potion2=", (_potion2_cell if _level >= 2 else Vector2i(-1, -1)))
	print("  special=", _current_level_special_type(), " codex? ", _codex_collected, " crown? ", _crown_collected, " ring? ", _ring_collected)
	print(
		"  torch=",
		(_torch_cell if _level == _torch_target_level and not _torch_collected else Vector2i(-1, -1)),
		" ring=",
		(_ring_cell if _current_level_special_type() == &"ring" and not _ring_collected else Vector2i(-1, -1))
	)
	# Decide total goblins scaled by level
	var total := 1 + int(max(0, _level - 1)) + _rng.randi_range(0, 2)
	var attempts := 0
	for i in range(total):
		attempts = 0
		var gcell := Vector2i.ZERO
		while attempts < 2000:
			attempts += 1
			gcell = _level_builder.random_interior_cell(grid_size)
			if gcell == player_cell or gcell == _key_cell:
				continue
			if _get_enemy_at(gcell) != null:
				continue
			if not _is_free(gcell):
				continue
			if not _has_free_neighbor(gcell):
				continue
			break
		_spawn_goblin_at(gcell)

	# Spawn zombies scaled modestly
	var zombie_count: int = 1 + int((_level - 1) / 3)
	var zcells: Array[Vector2i] = []
	for i2 in range(zombie_count):
		var z_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell, _codex_cell]
		z_exclude.append_array(zcells)
		var zcell := _level_builder.pick_free_interior_cell(
			grid_size,
			z_exclude,
			is_free,
			has_free_neighbor
		)
		zcells.append(zcell)
		_spawn_zombie_at(zcell)
	# Spawn minotaurs scaled slowly
	var mino_count: int = int(1 + (_level - 3) / 4) if _level >= 3 else 0
	for i3 in range(mino_count):
		var m_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell, _codex_cell]
		m_exclude.append_array(zcells)
		var mcell := _level_builder.pick_free_interior_cell(grid_size, m_exclude, is_free, has_free_neighbor)
		_spawn_minotaur_at(mcell)
	# Spawn 0-3 mice per level as non-hostile wanderers
	var mice_count: int = _rng.randi_range(0, 3)
	for i in range(mice_count):
		var attempts_mouse := 0
		var mcell2 := Vector2i.ZERO
		while attempts_mouse < 2000:
			attempts_mouse += 1
			mcell2 = _level_builder.random_interior_cell(grid_size)
			if mcell2 == player_cell:
				continue
			if not _is_free(mcell2):
				continue
			if _mouse_at(mcell2) != null:
				continue
			break
		_spawn_mouse_at(mcell2)
	# Spawn traps scaling with level
	var traps_total: int = int(clamp(_rng.randi_range(0, 2) + (_level - 1), 0, 6))
	for i in range(traps_total):
		var t_exclude: Array[Vector2i] = [
			player_cell,
			_key_cell,
			_sword_cell,
			_shield_cell,
			_potion_cell,
			_potion2_cell,
			_codex_cell,
			_torch_cell,
			_ring_cell
		]
		t_exclude.append_array(_rune1_cells)
		t_exclude.append_array(_rune2_cells)
		t_exclude.append_array(_armor_cells)
		t_exclude.append_array(_rune3_cells)
		if not zcells.is_empty():
			t_exclude.append(zcells[0])
		var tcell := _level_builder.pick_free_interior_cell(grid_size, t_exclude, is_free, has_free_neighbor)
		_spawn_trap_at(tcell)

func _restart_game() -> void:
	# Fade to black
	if _is_transitioning:
		return
	_is_transitioning = true
	await _fade_to(level_fade_alpha, level_fade_out_time)
	# Reset flags
	_game_over = false
	_key_collected = false
	_key_on_level = false
	_key1_collected = false
	_key2_collected = false
	_key3_collected = false
	_sword_collected = false
	_shield_collected = false
	_potion_collected = false
	_potion2_collected = false
	_armor_current = 0
	_codex_collected = false
	_crown_collected = false
	_codex_collected = false
	_ring_collected = false
	_rune1_collected_count = 0
	_rune2_collected_count = 0
	_rune3_collected_count = 0
	_ring_cell = Vector2i.ZERO
	_rune1_cells.clear()
	_rune2_cells.clear()
	_rune3_cells.clear()
	_armor_cells.clear()
	_key1_icon_persistent = false
	_key2_icon_persistent = false
	_key3_icon_persistent = false
	_codex_icon_persistent = false
	_crown_icon_persistent = false
	_carried_potion = false
	_entrance_rearm = false
	_score = 0
	_next_level_score = LEVEL_UP_SCORE_STEP
	_attack_level_bonus = 0
	_defense_level_bonus = 0
	_door_is_open = false
	_hp_max = 3
	_hp_current = _hp_max
	_level = 1
	_prepare_run_layout()
	_level_states.clear()
	_torch_collected = false
	_torch_target_level = _rng.randi_range(1, _max_level)
	_ring_collected = false
	_ring_cell = Vector2i.ZERO
	_rune1_cells.clear()
	_rune2_cells.clear()
	_rune3_cells.clear()
	_armor_cells.clear()
	_last_trap_cell = Vector2i(-1, -1)
	_web_stuck_turns = 0
	_brazier_cells.clear()
	_clear_braziers()
	_clear_enemies()
	_clear_runes()
	_clear_armor_items()
	# Clear maps
	floor_map.clear()
	walls_map.clear()
	# Rebuild
	var grid_size := _get_grid_size()
	_grid_size = grid_size
	_build_maps(grid_size)
	_ensure_fov_overlay()
	_place_player(Vector2i(int(grid_size.x / 2), int(grid_size.y / 2)))
	_place_random_inner_walls(grid_size)
	_place_random_entities(grid_size)
	_set_level_item_textures()
	_clear_bones()
	_place_bones(grid_size)
	_place_spiderwebs(grid_size)
	_place_door(grid_size)
	_update_fov()
	# Show entities
	if _key_node:
		_key_node.place(_key_cell)
	if _sword_node:
		if _sword_collected:
			_sword_node.collect()
		else:
			_sword_node.place(_sword_cell)
	if _shield_node:
		if _shield_collected:
			_shield_node.collect()
		else:
			_shield_node.place(_shield_cell)
	if _potion_node:
		_potion_node.place(_potion_cell)
	if _potion2_node:
		_potion2_node.visible = _level >= 2
	if _codex_node:
		_codex_node.place(_codex_cell)
	# Re-enable player controls
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_update_player_sprite_appearance()
	_update_hud_icons()
	_update_hud_hearts()
	_update_hud_armor()
	# Hide game over overlay and mark state
	_over_layer.visible = false
	_state = STATE_PLAYING
	_set_world_visible(true)
	_play_sfx(SFX_START)
	# Fade back in
	await _fade_to(0.0, level_fade_in_time)
	_is_transitioning = false

func _fade_to(alpha: float, duration: float) -> void:
	if _fade == null:
		return
	_fade.visible = true
	var tw := get_tree().create_tween()
	tw.tween_property(_fade, "modulate:a", alpha, duration)
	await tw.finished

func _set_icon_visible(icon: TextureRect, should_show: bool) -> void:
	if icon == null:
		return
	if should_show and not icon.visible and _hud_items:
		var last_idx := _hud_items.get_child_count() - 1
		_hud_items.move_child(icon, max(0, last_idx))
	icon.visible = should_show

func _update_fade_rect() -> void:
	if _fade == null:
		return
	_fade.position = Vector2.ZERO
	_fade.size = get_viewport_rect().size

func _combat_round_enemy(enemy: Enemy, force_outcome: bool = false) -> void:
	if _game_over or enemy == null or not enemy.alive:
		return
	# Trap collision check before combat
	var trap := _trap_at(enemy.grid_cell)
	if trap != null:
		_handle_enemy_hit_by_trap(enemy, trap)
		if not enemy.alive:
			return
	while true:
		var player_roll: int = _rng.randi_range(1, 20)
		var enemy_roll: int = _rng.randi_range(1, 20)
		player_roll += _attack_bonus()
		enemy_roll -= _defense_bonus()
		print("Player rolls ", player_roll, ", ", enemy.enemy_type, " rolls ", enemy_roll)
		if player_roll == enemy_roll:
			if force_outcome:
				continue
			return
		if player_roll > enemy_roll:
			_play_sfx(SFX_HURT1)
			_blink_node(enemy)
			enemy.apply_damage(1)
			if not enemy.alive:
				_handle_enemy_death(enemy)
			_check_win()
		else:
			_handle_player_hit()
		break

func _handle_enemy_death(enemy: Enemy) -> void:
	if enemy == null:
		return
	enemy.visible = false
	_leave_enemy_corpse(enemy)
	_play_sfx(SFX_HURT3)
	_add_score(_enemy_score_value(enemy))

func _enemy_score_value(enemy: Enemy) -> int:
	if enemy == null:
		return 0
	if enemy.enemy_type == &"minotaur":
		return 2
	return 1

func _add_score(amount: int) -> void:
	_score += amount
	_maybe_level_up()
	_update_hud_icons()

func _maybe_level_up() -> void:
	while _score >= _next_level_score:
		_apply_level_up_reward()
		_next_level_score += LEVEL_UP_SCORE_STEP

func _apply_level_up_reward() -> void:
	var roll := _rng.randf()
	if roll < 0.4:
		_attack_level_bonus += 1
		print("LEVEL UP: +1 ATK (bonus=", _attack_level_bonus, ")")
	elif roll < 0.8:
		_defense_level_bonus += 1
		print("LEVEL UP: +1 DEF (bonus=", _defense_level_bonus, ")")
	else:
		if _hp_max < HP_MAX_LIMIT:
			_hp_max = min(HP_MAX_LIMIT, _hp_max + 1)
		print("LEVEL UP: +1 MAX HP (max=", _hp_max, ")")
	if _hp_current < _hp_max:
		_hp_current = min(_hp_max, _hp_current + 1)
	_update_hud_hearts()
	_update_hud_icons()
	_play_sfx(SFX_LEVEL_UP)
	_blink_node_colored(player, Color(0.776, 0.624, 0.153))

func _leave_enemy_corpse(enemy: Enemy) -> void:
	if _decor == null or enemy == null:
		return
	var corpse_tex := enemy.corpse_texture
	if corpse_tex == null:
		if enemy.enemy_type == &"goblin":
			corpse_tex = DEAD_GOBLIN_TEX
		elif enemy.enemy_type == &"zombie":
			corpse_tex = ZOMBIE_TEX_2
		elif enemy.enemy_type == &"minotaur":
			corpse_tex = MINO_TEX_2
	if corpse_tex == null:
		return
	var s := Sprite2D.new()
	s.texture = corpse_tex
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = Grid.cell_to_world(enemy.grid_cell)
	_decor.add_child(s)

func _handle_player_hit() -> void:
	_apply_player_damage(1)

func _apply_player_damage(amount: int) -> void:
	if _game_over or amount <= 0:
		return
	var remaining := amount
	if _armor_current > 0:
		var absorbed: int = min(_armor_current, remaining)
		_armor_current -= absorbed
		remaining -= absorbed
		_update_hud_armor()
	if remaining > 0:
		_hp_current = max(0, _hp_current - remaining)
		_update_hud_hearts()
	else:
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
	# Require key plus special requirements
	var key_needed := _key_on_level
	if key_needed and not _key_collected:
		return
	var specials_collected := _codex_collected and _crown_collected and _ring_collected
	if _level >= _max_level and not specials_collected:
		return
	# Player must be standing on the door cell and the door must be open (door-2)
	var cp := Grid.world_to_cell(player.global_position)
	if cp == _door_cell:
		print(
			"[DEBUG] Door check: level=",
			_level,
			"/",
			_max_level,
			" cp=",
			cp,
			" door_cell=",
			_door_cell,
			" key_on_level=",
			_key_on_level,
			" key_collected=",
			_key_collected,
			" door_is_open=",
			_door_is_open,
			" specials_final=",
			specials_collected,
			" transitioning=",
			_is_transitioning
		)
	if cp == _door_cell and (not _key_on_level or _key_collected) and _exit_rearm:
		if _level < _max_level:
			_travel_to_level(_level + 1, true)
			return
		# Final level: show win screen
		_won = true
		_game_over = true
		if player.has_method("set_control_enabled"):
			player.set_control_enabled(false)

func _current_level_special_required() -> bool:
	return _level_special_map.has(_level)

func _current_level_special_type() -> StringName:
	if _level_special_map.has(_level):
		return _level_special_map[_level]
	return StringName()

func _level_special_collected() -> bool:
	var t := _current_level_special_type()
	if t == &"codex":
		return _codex_collected
	if t == &"crown":
		return _crown_collected
	if t == &"ring":
		return _ring_collected
	return false

func _current_key_type() -> StringName:
	if _level_key_map.has(_level):
		return _level_key_map[_level]
	return StringName()

func _key_texture_for_type(key_type: StringName) -> Texture2D:
	if key_type == &"key1":
		return KEY_TEX_1
	if key_type == &"key2":
		return KEY_TEX_2
	if key_type == &"key3":
		return KEY_TEX_3
	return null

func _is_key_type_collected(key_type: StringName) -> bool:
	if key_type == &"key1":
		return _key1_collected
	if key_type == &"key2":
		return _key2_collected
	if key_type == &"key3":
		return _key3_collected
	return false

func _has_rune1() -> bool:
	return _rune1_collected_count > 0

func _has_rune2() -> bool:
	return _rune2_collected_count > 0

func _has_rune3() -> bool:
	return _rune3_collected_count > 0

func _attack_bonus() -> int:
	var bonus := 0
	if _sword_collected:
		bonus += 1
	if _has_rune1():
		bonus += 1
	bonus += _attack_level_bonus
	return bonus

func _defense_bonus() -> int:
	var bonus := 0
	if _shield_collected:
		bonus += 1
	if _has_rune2():
		bonus += 1
	bonus += _defense_level_bonus
	return bonus

func _apply_restored_items() -> void:
	if _key_node:
		if _key_on_level and not _key_collected:
			_key_node.place(_key_cell)
			_key_node.visible = true
		else:
			_key_node.visible = false
			_key_node.collected = true
	if _sword_node:
		if not _sword_collected and _level == 1:
			_sword_node.place(_sword_cell)
			_sword_node.visible = true
		else:
			_sword_node.visible = false
	if _shield_node:
		if not _shield_collected and _level == 1:
			_shield_node.place(_shield_cell)
			_shield_node.visible = true
		else:
			_shield_node.visible = false
	if _potion_node:
		if not _potion_collected and _potion_cell != Vector2i(-1, -1):
			_potion_node.place(_potion_cell)
			_potion_node.visible = true
		else:
			_potion_node.visible = false
	if _potion2_node:
		if not _potion2_collected and _potion2_cell != Vector2i(-1, -1):
			_potion2_node.place(_potion2_cell)
			_potion2_node.visible = true
		else:
			_potion2_node.visible = false
	var st := _current_level_special_type()
	if _codex_node:
		if (st == &"codex" and not _codex_collected) or (st == &"crown" and not _crown_collected):
			_codex_node.place(_codex_cell)
			_codex_node.visible = true
		else:
			_codex_node.visible = false
	if _ring_node:
		if st == &"ring" and not _ring_collected:
			_ring_node.place(_ring_cell)
			_ring_node.visible = true
		else:
			_ring_node.visible = false
	if _torch_node:
		if _level == _torch_target_level and not _torch_collected:
			_torch_node.place(_torch_cell)
			_torch_node.visible = true
		else:
			_torch_node.visible = false
	if _door_node:
		_door_node.global_position = Grid.cell_to_world(_door_cell)
	if _entrance_door_node:
		_entrance_door_node.global_position = Grid.cell_to_world(_entrance_cell)

func _save_level_state(level: int) -> void:
	var state := {}
	state["player_cell"] = Grid.world_to_cell(player.global_position)
	state["key_on_level"] = _key_on_level
	state["key_cell"] = _key_cell
	state["key_collected"] = _key_collected
	state["key_type"] = _current_key_type()
	state["sword_cell"] = _sword_cell
	state["sword_collected"] = _sword_collected
	state["shield_cell"] = _shield_cell
	state["shield_collected"] = _shield_collected
	state["potion_cell"] = _potion_cell
	state["potion_collected"] = _potion_collected
	state["potion2_cell"] = _potion2_cell
	state["potion2_collected"] = _potion2_collected
	state["braziers"] = _brazier_cells.duplicate()
	state["armor_cells"] = []
	state["codex_cell"] = _codex_cell
	state["codex_collected"] = _codex_collected
	state["ring_cell"] = _ring_cell
	state["ring_collected"] = _ring_collected
	state["crown_collected"] = _crown_collected
	state["torch_cell"] = _torch_cell
	state["torch_collected"] = _torch_collected
	state["rune1_cells"] = []
	state["rune2_cells"] = []
	state["rune3_cells"] = []
	for r1 in _rune1_nodes:
		if r1 != null and not r1.collected:
			state["rune1_cells"].append(r1.grid_cell)
	for r2 in _rune2_nodes:
		if r2 != null and not r2.collected:
			state["rune2_cells"].append(r2.grid_cell)
	for ar in _armor_nodes:
		if ar != null and not ar.collected:
			state["armor_cells"].append(ar.grid_cell)
	for r3 in _rune3_nodes:
		if r3 != null and not r3.collected:
			state["rune3_cells"].append(r3.grid_cell)
	state["exit_cell"] = _door_cell
	state["entrance_cell"] = _entrance_cell
	state["door_open"] = _door_is_open
	state["key_on_level"] = _key_on_level
	# Enemies/traps/mice
	var enemies: Array = []
	for g in _goblins:
		enemies.append({
			"type": "goblin",
			"cell": g.grid_cell,
			"alive": g.alive
		})
	for z in _zombies:
		enemies.append({
			"type": "zombie",
			"cell": z.grid_cell,
			"alive": z.alive
		})
	for m in _minotaurs:
		enemies.append({
			"type": "minotaur",
			"cell": m.grid_cell,
			"alive": m.alive,
			"hp": m.hp
		})
	for sk in _skeletons:
		enemies.append({
			"type": "skeleton",
			"cell": sk.grid_cell,
			"alive": sk.alive,
			"hp": sk.hp
		})
	var traps: Array = []
	for t in _traps:
		traps.append({"cell": t.grid_cell, "type": t.trap_type})
	var mice: Array = []
	for m2 in _mice:
		mice.append({
			"cell": m2.grid_cell,
			"alive": m2.alive
		})
	# Persist inner walls/blocks (skip borders)
	var walls: Array = []
	for c in walls_map.get_used_cells(0):
		if c.x <= 0 or c.y <= 0 or c.x >= _grid_size.x - 1 or c.y >= _grid_size.y - 1:
			continue
		var sid := walls_map.get_cell_source_id(0, c)
		if sid != -1:
			walls.append({"cell": c, "sid": sid})
	var corpses: Array = []
	for child in _decor.get_children():
		if child is Sprite2D:
			var spr := child as Sprite2D
			if spr.texture == DEAD_GOBLIN_TEX or spr.texture == ZOMBIE_TEX_2 or spr.texture == MINO_TEX_2 or spr.texture in BONE_TEXTURES:
				corpses.append({
					"texture": spr.texture,
					"pos": spr.global_position
				})
	state["corpses"] = corpses
	state["enemies"] = enemies
	state["traps"] = traps
	state["mice"] = mice
	state["walls"] = walls
	_level_states[level] = state

func _restore_level_state(level: int, entering_forward: bool) -> void:
	var state: Dictionary = _level_states.get(level, null)
	if state == null:
		return
	_key_on_level = state.get("key_on_level", false)
	_key_cell = state.get("key_cell", Vector2i(-1, -1))
	_key_collected = state.get("key_collected", false)
	var key_type: StringName = state.get("key_type", StringName())
	if key_type == &"key1":
		_key1_collected = _key1_collected or _key_collected
		if _key1_collected:
			_key1_icon_persistent = true
	elif key_type == &"key2":
		_key2_collected = _key2_collected or _key_collected
		if _key2_collected:
			_key2_icon_persistent = true
	elif key_type == &"key3":
		_key3_collected = _key3_collected or _key_collected
		if _key3_collected:
			_key3_icon_persistent = true
	_sword_cell = state.get("sword_cell", _sword_cell)
	_sword_collected = state.get("sword_collected", _sword_collected)
	_shield_cell = state.get("shield_cell", _shield_cell)
	_shield_collected = state.get("shield_collected", _shield_collected)
	_potion_cell = state.get("potion_cell", _potion_cell)
	_potion_collected = state.get("potion_collected", _potion_collected)
	_potion2_cell = state.get("potion2_cell", _potion2_cell)
	_potion2_collected = state.get("potion2_collected", _potion2_collected)
	_brazier_cells = state.get("braziers", [])
	var armor_state: Array = state.get("armor_cells", [])
	_codex_cell = state.get("codex_cell", _codex_cell)
	_codex_collected = state.get("codex_collected", _codex_collected)
	_ring_cell = state.get("ring_cell", _ring_cell)
	_ring_collected = state.get("ring_collected", _ring_collected)
	_crown_collected = state.get("crown_collected", _crown_collected)
	_torch_cell = state.get("torch_cell", _torch_cell)
	_torch_collected = state.get("torch_collected", _torch_collected)
	_door_cell = state.get("exit_cell", _door_cell)
	_entrance_cell = state.get("entrance_cell", _entrance_cell)
	_door_is_open = state.get("door_open", false)
	var r1_state: Array = state.get("rune1_cells", [])
	var r2_state: Array = state.get("rune2_cells", [])
	var r3_state: Array = state.get("rune3_cells", [])
	_clear_runes()
	_clear_armor_items()
	_rune1_cells = []
	_rune2_cells = []
	_rune3_cells = []
	_armor_cells = []
	for a in armor_state:
		if a is Vector2i:
			_armor_cells.append(a)
	for v in r1_state:
		if v is Vector2i:
			_rune1_cells.append(v)
	for v2 in r2_state:
		if v2 is Vector2i:
			_rune2_cells.append(v2)
	for v3 in r3_state:
		if v3 is Vector2i:
			_rune3_cells.append(v3)
	for rc1 in _rune1_cells:
		var n1 := _make_item_node("Rune1Restore", RUNE1_TEX)
		add_child(n1)
		n1.place(rc1)
		_rune1_nodes.append(n1)
	for ac in _armor_cells:
		var an := _make_item_node("ArmorRestore", ARMOR_TEX)
		add_child(an)
		an.place(ac)
		_armor_nodes.append(an)
	for rc2 in _rune2_cells:
		var n2 := _make_item_node("Rune2Restore", RUNE2_TEX)
		add_child(n2)
		n2.place(rc2)
		_rune2_nodes.append(n2)
	for rc3 in _rune3_cells:
		var n3 := _make_item_node("Rune3Restore", RUNE3_TEX)
		add_child(n3)
		n3.place(rc3)
		_rune3_nodes.append(n3)
	var spawn_cell: Vector2i = _entrance_cell
	if not entering_forward:
		spawn_cell = _door_cell
	if state.has("player_cell") and entering_forward:
		spawn_cell = state["player_cell"]
	_place_player(spawn_cell)

func _restore_entities_from_state(level: int) -> void:
	var state: Dictionary = _level_states.get(level, {})
	_clear_enemies()
	_clear_mice()
	_clear_traps()
	# Restore walls before entities if present
	_restore_walls_from_state(state)
	var enemies: Array = state.get("enemies", [])
	for e in enemies:
		var etype: String = e.get("type", "")
		var cell: Vector2i = e.get("cell", Vector2i.ZERO)
		var alive: bool = e.get("alive", true)
		if etype == "goblin":
			var gcell := cell
			_spawn_goblin_at(gcell)
			if not alive:
				_goblins.back().alive = false
				_goblins.back().visible = false
		elif etype == "zombie":
			var zcell := cell
			_spawn_zombie_at(zcell)
			if not alive:
				_zombies.back().alive = false
				_zombies.back().visible = false
		elif etype == "minotaur":
			var mcell := cell
			_spawn_minotaur_at(mcell)
			_minotaurs.back().hp = e.get("hp", _minotaurs.back().hp)
			if not alive:
				_minotaurs.back().alive = false
				_minotaurs.back().visible = false
		elif etype == "skeleton":
			var skcell := cell
			_spawn_skeleton_at(skcell)
			_skeletons.back().hp = e.get("hp", _skeletons.back().hp)
			if not alive:
				_skeletons.back().alive = false
				_skeletons.back().visible = false
	var traps: Array = state.get("traps", [])
	for t in traps:
		var tcell: Vector2i = t.get("cell", Vector2i.ZERO)
		var ttype: StringName = StringName(t.get("type", "spike"))
		_spawn_trap_at(tcell, ttype)
	_clear_braziers()
	for bc in _brazier_cells:
		_spawn_brazier(bc)
	var mice: Array = state.get("mice", [])
	for m in mice:
		var mcell: Vector2i = m.get("cell", Vector2i.ZERO)
		_spawn_mouse_at(mcell)
		if not m.get("alive", true):
			_mice.back().alive = false
			_mice.back().visible = false
	var corpses: Array = state.get("corpses", [])
	for c in corpses:
		var tex: Texture2D = c.get("texture", null)
		var pos: Vector2 = c.get("pos", Vector2.ZERO)
		if tex != null and _decor != null:
			var s := Sprite2D.new()
			s.texture = tex
			s.centered = false
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.global_position = pos
			_decor.add_child(s)

func _restore_walls_from_state(state: Dictionary) -> void:
	var walls: Array = state.get("walls", [])
	if walls.is_empty():
		return
	# Clear current inner walls (keep borders)
	for c in walls_map.get_used_cells(0):
		if c.x > 0 and c.y > 0 and c.x < _grid_size.x - 1 and c.y < _grid_size.y - 1:
			walls_map.set_cell(0, c, -1, Vector2i.ZERO)
	for w in walls:
		var cell: Vector2i = w.get("cell", Vector2i.ZERO)
		var sid: int = w.get("sid", -1)
		if sid != -1:
			walls_map.set_cell(0, cell, sid, TILE_WALL)

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
	_prepare_run_layout()
	_level_states.clear()
	_key_collected = false
	_key_on_level = false
	_key1_collected = false
	_key2_collected = false
	_key3_collected = false
	_potion_collected = false
	_potion2_collected = false
	_sword_collected = false
	_shield_collected = false
	_torch_collected = false
	_ring_collected = false
	_codex_collected = false
	_crown_collected = false
	_armor_current = 0
	_rune1_collected_count = 0
	_rune2_collected_count = 0
	_rune3_collected_count = 0
	_ring_cell = Vector2i.ZERO
	_key1_icon_persistent = false
	_key2_icon_persistent = false
	_codex_icon_persistent = false
	_crown_icon_persistent = false
	_carried_potion = false
	_entrance_rearm = false
	_exit_rearm = false
	_next_level_score = LEVEL_UP_SCORE_STEP
	_attack_level_bonus = 0
	_defense_level_bonus = 0
	_hp_max = 3
	_hp_current = _hp_max
	_torch_target_level = _rng.randi_range(1, _max_level)
	_score = 0
	_last_trap_cell = Vector2i(-1, -1)
	_web_stuck_turns = 0
	_brazier_cells.clear()
	_clear_braziers()
	_update_hud_icons()
	_clear_enemies()
	_clear_runes()
	_clear_armor_items()
	# Build board fresh
	floor_map.clear()
	walls_map.clear()
	var grid_size := _get_grid_size()
	_grid_size = grid_size
	_build_maps(grid_size)
	_ensure_fov_overlay()
	_place_player(Vector2i(int(grid_size.x / 2), int(grid_size.y / 2)))
	_place_random_inner_walls(grid_size)
	_place_random_entities(grid_size)
	_set_level_item_textures()
	_clear_bones()
	_place_bones(grid_size)
	_place_spiderwebs(grid_size)
	_place_door(grid_size)
	_update_fov()
	# Enable controls
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_set_world_visible(true)
	_update_player_sprite_appearance()
	_update_hud_icons()
	_update_hud_hearts()
	_update_hud_armor()
	# React to player movement for goblin AI
	if player.has_signal("moved") and not player.moved.is_connected(_on_player_moved):
		player.moved.connect(_on_player_moved)
	_play_sfx(SFX_START)

func _show_title(visible: bool) -> void:
	_title_layer.visible = visible
	_over_layer.visible = false
	_title_label.add_theme_font_size_override("font_size", 64)
	_title_label.offset_top = 512.0

func _show_game_over(won: bool) -> void:
	_over_layer.visible = true
	_over_bg_win.visible = won
	_over_bg_lose.visible = not won
	_over_label.add_theme_font_size_override("font_size", 48)
	_over_label.text = "Press Enter to restart"
	if _over_score:
		_over_score.add_theme_font_size_override("font_size", 36)
		_over_score.offset_top = -124.0
		_over_score.text = "Score: %d" % _score

func _set_world_visible(visible: bool) -> void:
	floor_map.visible = visible
	walls_map.visible = visible
	player.visible = visible
	if _fov_overlay:
		_fov_overlay.visible = visible
	if _key_node:
		_key_node.visible = visible and _key_on_level and not _key_collected
	if _sword_node:
		_sword_node.visible = visible and not _sword_collected
	if _shield_node:
		_shield_node.visible = visible and not _shield_collected
	if _potion_node:
		_potion_node.visible = visible and not _potion_collected
	if _potion2_node:
		_potion2_node.visible = visible and _level >= 2 and not _potion2_collected
	if _torch_node:
		_torch_node.visible = visible and not _torch_collected and _level == _torch_target_level
	if _ring_node:
		_ring_node.visible = visible and not _ring_collected and _current_level_special_type() == &"ring"
	for r1 in _rune1_nodes:
		if r1:
			r1.visible = visible and not r1.collected
	for r2 in _rune2_nodes:
		if r2:
			r2.visible = visible and not r2.collected
	for ar in _armor_nodes:
		if ar:
			ar.visible = visible and not ar.collected
	for r3 in _rune3_nodes:
		if r3:
			r3.visible = visible and not r3.collected
	if _codex_node:
		var st := _current_level_special_type()
		var special_uncollected := (st == &"codex" and not _codex_collected) or (st == &"crown" and not _crown_collected)
		_codex_node.visible = visible and special_uncollected
	for g in _goblins:
		g.visible = visible and g.alive
	for z in _zombies:
		z.visible = visible and z.alive
	for m in _minotaurs:
		m.visible = visible and m.alive
	for sk in _skeletons:
		sk.visible = visible and sk.alive
	for t in _traps:
		t.visible = visible
	for mouse in _mice:
		mouse.visible = visible and mouse.alive
	_decor.visible = visible
	if _door_node:
		_door_node.visible = visible
	if _entrance_door_node:
		_entrance_door_node.visible = visible and _level > 1
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
	var bonus: int = (4 if _torch_collected else 0)
	_apply_light_source(center, SIGHT_OUTER_TILES + bonus)
	for bc in _brazier_cells:
		_apply_light_source(bc, 3)
	if _fov_overlay:
		(_fov_overlay as Node).call_deferred("update_fov", _fov_visible, _fov_dist, SIGHT_INNER_TILES + bonus, SIGHT_OUTER_TILES + bonus, SIGHT_MAX_DARK)

func _apply_light_source(center: Vector2i, radius: int) -> void:
	if not _in_bounds(center):
		return
	var center_idx: int = center.y * _grid_size.x + center.x
	_fov_visible[center_idx] = true
	_fov_dist[center_idx] = min(_fov_dist[center_idx], 0.0)
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
	var node: Goblin = GOBLIN_SCENE.instantiate() as Goblin
	node.setup(cell, GOBLIN_TEX_1, DEAD_GOBLIN_TEX)
	add_child(node)
	_goblins.append(node)

func _spawn_zombie_at(cell: Vector2i) -> void:
	var node: Zombie = ZOMBIE_SCENE.instantiate() as Zombie
	node.setup(cell, ZOMBIE_TEX_1, ZOMBIE_TEX_2)
	add_child(node)
	_zombies.append(node)

func _spawn_minotaur_at(cell: Vector2i) -> void:
	var node: Minotaur = MINOTAUR_SCENE.instantiate() as Minotaur
	node.setup(cell, MINO_TEX_1, MINO_TEX_2)
	add_child(node)
	_minotaurs.append(node)

func _spawn_mouse_at(cell: Vector2i) -> void:
	var node: Mouse = MOUSE_SCENE.instantiate() as Mouse
	var tex: Texture2D = _sheet_tex_cache.get(&"mouse_tex", null)
	node.setup(cell, tex)
	add_child(node)
	_mice.append(node)

func _spawn_trap_at(cell: Vector2i, trap_type: StringName = StringName()) -> void:
	var node: Trap = TRAP_SCENE.instantiate() as Trap
	var resolved_type := trap_type
	if resolved_type == StringName():
		var is_web := _rng.randf() < 0.33 and TRAP_WEB_TEX != null
		resolved_type = (&"spiderweb" if is_web else &"spike")
	var tex: Texture2D = null
	if resolved_type == &"spiderweb":
		tex = TRAP_WEB_TEX
	else:
		tex = (TRAP_TEX_A if _rng.randf() < 0.5 else TRAP_TEX_B)
	node.setup(cell, tex, resolved_type)
	add_child(node)
	_traps.append(node)

func _spawn_skeleton_at(cell: Vector2i) -> void:
	var node: Skeleton = SKELETON_SCENE.instantiate() as Skeleton
	node.setup(cell, SKELETON_TEX_1, SKELETON_TEX_2)
	add_child(node)
	_skeletons.append(node)

func _clear_enemies() -> void:
	for child: Goblin in _goblins:
		child.queue_free()
	for child: Zombie in _zombies:
		child.queue_free()
	for child: Minotaur in _minotaurs:
		child.queue_free()
	for child: Skeleton in _skeletons:
		child.queue_free()
	_goblins.clear()
	_zombies.clear()
	_minotaurs.clear()
	_skeletons.clear()
	_clear_mice()
	_clear_traps()

func _clear_mice() -> void:
	for m in _mice:
		m.queue_free()
	_mice.clear()

func _clear_traps() -> void:
	for t in _traps:
		t.queue_free()
	_traps.clear()

func _clear_armor_items() -> void:
	for a in _armor_nodes:
		a.queue_free()
	_armor_nodes.clear()
	_armor_cells.clear()

func _clear_runes() -> void:
	for r in _rune1_nodes:
		r.queue_free()
	for r in _rune2_nodes:
		r.queue_free()
	for r in _rune3_nodes:
		r.queue_free()
	_rune1_nodes.clear()
	_rune2_nodes.clear()
	_rune3_nodes.clear()
	_rune1_cells.clear()
	_rune2_cells.clear()
	_rune3_cells.clear()

func _reset_items_visibility() -> void:
	var key_type := _current_key_type()
	if _key_node:
		_key_node.collected = _key_collected or key_type == StringName()
		_key_node.visible = key_type != StringName() and not _key_collected
	if _sword_node:
		_sword_node.collected = _sword_collected
		_sword_node.visible = not _sword_collected and _level == 1
	if _shield_node:
		_shield_node.collected = _shield_collected
		_shield_node.visible = not _shield_collected and _level == 1
	if _potion_node:
		_potion_node.collected = _potion_collected
		_potion_node.visible = not _potion_collected and _potion_cell != Vector2i(-1, -1)
	if _potion2_node:
		_potion2_node.collected = _potion2_collected
		_potion2_node.visible = not _potion2_collected and _potion2_cell != Vector2i(-1, -1)
	if _codex_node:
		var st := _current_level_special_type()
		var needs_special := st == &"codex" or st == &"crown"
		var special_uncollected := needs_special and not _level_special_collected()
		_codex_node.collected = not special_uncollected
		_codex_node.visible = special_uncollected
	if _torch_node:
		_torch_node.collected = _torch_collected
		_torch_node.visible = (_level == _torch_target_level) and not _torch_collected
	for r1 in _rune1_nodes:
		if r1:
			r1.collected = r1.collected
			r1.visible = not r1.collected
	for r2 in _rune2_nodes:
		if r2:
			r2.collected = r2.collected
			r2.visible = not r2.collected
	for ar in _armor_nodes:
		if ar:
			ar.collected = ar.collected
			ar.visible = not ar.collected
	for r3 in _rune3_nodes:
		if r3:
			r3.collected = r3.collected
			r3.visible = not r3.collected
	if _ring_node:
		_ring_node.collected = _ring_collected
		_ring_node.visible = _current_level_special_type() == &"ring" and not _ring_collected

func _clear_bones() -> void:
	for bone in _bone_cells.values():
		if bone:
			bone.queue_free()
	_bone_cells.clear()
	_bone_spawn_outcomes.clear()
	_clear_spiderwebs()

func _place_bones(grid_size: Vector2i) -> void:
	var count := _rng.randi_range(5, 30)
	var used := {}
	var player_cell := Grid.world_to_cell(player.global_position)
	# Skeleton chance: starts at 15% and climbs 5% per level (and falls if level decreases)
	var spawn_chance: float = clamp(0.15 + 0.05 * float(_level - 1), 0.15, 0.7)
	for i in range(count):
		var attempts := 0
		while attempts < 2000:
			attempts += 1
			var c := _level_builder.random_interior_cell(grid_size)
			var key := "%d,%d" % [c.x, c.y]
			if used.has(key):
				continue
			if not _is_free(c):
				continue
			if c == player_cell or c == _key_cell or c == _sword_cell or c == _shield_cell or c == _potion_cell or c == _codex_cell or c == _ring_cell or _rune1_cells.has(c) or _rune2_cells.has(c) or _rune3_cells.has(c) or _armor_cells.has(c):
				continue
			if _get_enemy_at(c) != null:
				continue
			# Place a bones sprite
			var s := Sprite2D.new()
			s.texture = BONE_TEXTURES[_rng.randi_range(0, BONE_TEXTURES.size() - 1)]
			s.centered = false
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var bone_alpha := _rng.randf_range(BONE_ALPHA_MIN, BONE_ALPHA_MAX)
			s.modulate = Color(1, 1, 1, bone_alpha)
			# bones: 50% chance to flip horizontally
			s.flip_h = (_rng.randi_range(0, 1) == 1)
			s.global_position = Grid.cell_to_world(c)
			_decor.add_child(s)
			_bone_cells[c] = s
			# Lock in skeleton spawn chance now to avoid re-rolling on each step.
			_bone_spawn_outcomes[c] = (_rng.randf() <= spawn_chance)
			used[key] = true
			break

func _clear_braziers() -> void:
	for b in _brazier_nodes:
		if b:
			b.queue_free()
	_brazier_nodes.clear()
	_brazier_cells.clear()

func _clear_spiderwebs() -> void:
	for s in _spiderweb_nodes:
		if s:
			s.queue_free()
	_spiderweb_nodes.clear()

func _spawn_brazier(cell: Vector2i) -> void:
	if BRAZIER_TEX == null or _decor == null:
		return
	var node := Node2D.new()
	node.global_position = Grid.cell_to_world(cell)
	var spr := Sprite2D.new()
	spr.texture = BRAZIER_TEX
	spr.centered = false
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.z_index = 1
	node.add_child(spr)
	var light := PointLight2D.new()
	light.position = Vector2(6, 6)
	light.energy = 0.8
	light.texture_scale = 0.35 # approximate 3 tiles of reach
	light.shadow_enabled = false
	node.add_child(light)
	_decor.add_child(node)
	_brazier_nodes.append(node)

func _place_spiderwebs(grid_size: Vector2i) -> void:
	_clear_spiderwebs()
	var corner_defs := [
		{ "name": &"top_left", "dirs": [Vector2i.UP, Vector2i.LEFT] },
		{ "name": &"top_right", "dirs": [Vector2i.UP, Vector2i.RIGHT] },
		{ "name": &"bottom_left", "dirs": [Vector2i.DOWN, Vector2i.RIGHT] },
		{ "name": &"bottom_right", "dirs": [Vector2i.DOWN, Vector2i.LEFT] },
	]
	var used := {}
	var player_cell := Grid.world_to_cell(player.global_position)
	for corner in corner_defs:
		var candidates: Array[Vector2i] = []
		var dirs: Array = corner["dirs"]
		for y in range(1, grid_size.y - 1):
			for x in range(1, grid_size.x - 1):
				var c := Vector2i(x, y)
				var key := "%d,%d" % [c.x, c.y]
				if used.has(key):
					continue
				if not _is_free(c):
					continue
				if c == player_cell or c == _key_cell or c == _sword_cell or c == _shield_cell or c == _potion_cell or c == _potion2_cell or c == _codex_cell or c == _ring_cell or _rune1_cells.has(c) or _rune2_cells.has(c) or _rune3_cells.has(c) or _armor_cells.has(c):
					continue
				if _bone_cells.has(c):
					continue
				var dir1: Vector2i = dirs[0]
				var dir2: Vector2i = dirs[1]
				if _is_wall(c + dir1) and _is_wall(c + dir2):
					candidates.append(c)
		if candidates.is_empty():
			continue
		candidates.shuffle()
		var place_count: int = min(candidates.size(), _rng.randi_range(3, 12))
		for i in range(place_count):
			var cell: Vector2i = candidates[i]
			var key2 := "%d,%d" % [cell.x, cell.y]
			used[key2] = true
			var s := Sprite2D.new()
			var tex: Texture2D = SPIDERWEB_TEXTURES.get(corner["name"], null)
			if tex == null:
				continue
			s.texture = tex
			s.centered = false
			s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s.global_position = Grid.cell_to_world(cell)
			_decor.add_child(s)
			_spiderweb_nodes.append(s)

func _maybe_spawn_skeleton_from_bones(cell: Vector2i) -> void:
	if _level <= 1:
		return
	if not _bone_cells.has(cell):
		return
	if not _bone_spawn_outcomes.has(cell):
		return
	var should_spawn: bool = _bone_spawn_outcomes[cell]
	_bone_spawn_outcomes.erase(cell)
	if not should_spawn:
		return
	var bone_sprite := _bone_cells[cell] as Sprite2D
	_bone_cells.erase(cell)
	if bone_sprite:
		bone_sprite.queue_free()
	var dirs: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var options: Array[Vector2i] = []
	for d in dirs:
		var target := cell + d
		if _can_enemy_step(target, null):
			options.append(target)
	if options.is_empty():
		return
	var spawn_cell := options[_rng.randi_range(0, options.size() - 1)]
	_play_sfx(SFX_MR_BONES)
	_spawn_skeleton_at(spawn_cell)

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
				# Avoid placing where decorative door (door-3) already exists
				var existing := false
				for child in _decor.get_children():
					if child is Sprite2D and (child as Sprite2D).texture == DOOR_TEX_3 and Grid.world_to_cell(child.global_position) == c:
						existing = true
						break
				if existing:
					continue
				_door_cell = c
				found = true
	if not found:
		_door_cell = Vector2i(0, 0)
	if _door_node:
		_door_node.global_position = Grid.cell_to_world(_door_cell)
	_update_door_texture()

func _place_entrance_door(grid_size: Vector2i) -> void:
	# Place entrance adjacent to player start for backtracking
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	dirs.shuffle()
	for d in dirs:
		var c := _entrance_cell + d
		if _is_wall(c):
			_entrance_cell = _entrance_cell + d * 0 # keep original
			if _entrance_door_node:
				_entrance_door_node.global_position = Grid.cell_to_world(c)
			return
	# fallback: place entrance door on player's cell wall side if none found
	if _entrance_door_node:
		_entrance_door_node.global_position = Grid.cell_to_world(_entrance_cell)

func _update_door_texture() -> void:
	if _door_sprite == null:
		return
	# Door opens when the level's required items are collected (or if no key spawns this level)
	var key_needed := _key_on_level
	var open := (not key_needed or _key_collected)
	_door_sprite.texture = DOOR_TEX_2 if open else DOOR_TEX_1
	_door_is_open = open
	if _entrance_door_sprite:
		_entrance_door_sprite.texture = DOOR_TEX_3 if DOOR_TEX_3 != null else DOOR_TEX_2
	print("[DEBUG] Door texture update: level=", _level, " key_on_level=", _key_on_level, " key_collected=", _key_collected, " open=", open, " door_cell=", _door_cell)

func _travel_to_level(target_level: int, entering_forward: bool) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_save_level_state(_level)
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	await _fade_to(level_fade_alpha, level_fade_out_time)
	_level = target_level
	_key_collected = false
	_key_on_level = false
	_door_is_open = false
	_last_trap_cell = Vector2i(-1, -1)
	_web_stuck_turns = 0
	_clear_enemies()
	_clear_runes()
	_clear_armor_items()
	_clear_bones()
	floor_map.clear()
	walls_map.clear()
	var grid_size := _get_grid_size()
	_grid_size = grid_size
	_build_maps(grid_size)
	_ensure_fov_overlay()
	if _level_states.has(_level):
		_restore_level_state(_level, entering_forward)
		_apply_restored_items()
		_restore_entities_from_state(_level)
	else:
		_place_random_inner_walls(grid_size)
		var start_cell := _pick_free_cell_next_to_wall(grid_size)
		_entrance_cell = start_cell
		_place_player(start_cell)
		_place_random_entities(grid_size)
		_set_level_item_textures()
		_clear_bones()
		_place_bones(grid_size)
		_place_door(grid_size)
		_place_entrance_door(grid_size)
		_update_door_texture()
		_reset_items_visibility()
		_save_level_state(_level)
	# Ensure entrance/exit door nodes positioned
	if _door_node:
		_door_node.global_position = Grid.cell_to_world(_door_cell)
	if _entrance_door_node:
		_entrance_door_node.global_position = Grid.cell_to_world(_entrance_cell)
	_entrance_rearm = false
	_exit_rearm = false
	_update_door_texture()
	_update_hud_icons()
	_update_hud_hearts()
	_update_hud_armor()
	if _hud_level:
		_hud_level.text = "Level: %d" % _level
	_update_fov()
	_set_world_visible(true)
	print("[DEBUG] Travel complete -> level ", _level, " key_on_level=", _key_on_level, " key_collected=", _key_collected, " door_cell=", _door_cell, " entrance_cell=", _entrance_cell)
	await _fade_to(0.0, level_fade_in_time)
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_is_transitioning = false
	_exit_rearm = false

func _load_next_level() -> void:
	_travel_to_level(_level + 1, true)

func _update_player_sprite_appearance() -> void:
	if _player_sprite == null:
		return
	_player_sprite.z_index = 5
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
	if _hud_level:
		_hud_level.visible = show
		_hud_level.text = "Level: %d" % _level
	if _hud_hearts:
		_hud_hearts.visible = show
	if _hud_icon_key1 and KEY_TEX_1:
		_hud_icon_key1.texture = KEY_TEX_1
	if _hud_icon_key2 and KEY_TEX_2:
		_hud_icon_key2.texture = KEY_TEX_2
	if _hud_icon_key3 and KEY_TEX_3:
		_hud_icon_key3.texture = KEY_TEX_3
	_set_icon_visible(_hud_icon_key1, show and _key1_collected)
	_set_icon_visible(_hud_icon_key2, show and _key2_collected)
	_set_icon_visible(_hud_icon_key3, show and _key3_collected)
	_set_icon_visible(_hud_icon_sword, show and _sword_collected)
	_set_icon_visible(_hud_icon_shield, show and _shield_collected)
	var st := _current_level_special_type()
	_set_icon_visible(_hud_icon_codex, show and _codex_collected)
	_set_icon_visible(_hud_icon_crown, show and _crown_collected)
	_set_icon_visible(_hud_icon_rune1, show and _has_rune1())
	_set_icon_visible(_hud_icon_rune2, show and _has_rune2())
	_set_icon_visible(_hud_icon_rune3, show and _has_rune3())
	_set_icon_visible(_hud_icon_torch, show and _torch_collected)
	if _hud_icon_ring and RING_TEX:
		_hud_icon_ring.texture = RING_TEX
	_set_icon_visible(_hud_icon_ring, show and _ring_collected)
	if _hud_icon_potion and POTION_TEX:
		_hud_icon_potion.texture = POTION_TEX
	_set_icon_visible(_hud_icon_potion, show and _carried_potion)
	if _hud_atk_label:
		_hud_atk_label.visible = show
		_hud_atk_label.text = "ATK: %d" % _attack_bonus()
	if _hud_def_label:
		_hud_def_label.visible = show
		_hud_def_label.text = "DEF: %d" % _defense_bonus()
	if _hud_score:
		_hud_score.visible = show
		_hud_score.text = "Score: %d" % _score
	if _hud_armor:
		_hud_armor.visible = show

func _pickup_potion_if_available(cell: Vector2i) -> void:
	if _carried_potion:
		return
	var picked := false
	if cell == _potion_cell and not _potion_collected:
		_potion_collected = true
		picked = true
		if _potion_node:
			_potion_node.collect()
	if _level >= 2 and cell == _potion2_cell and not _potion2_collected:
		_potion2_collected = true
		picked = true
		if _potion2_node:
			_potion2_node.collect()
	if picked:
		_carried_potion = true
		_play_sfx(SFX_PICKUP1)
		_blink_node(player)
		_update_hud_icons()

func _try_use_potion() -> void:
	if not _carried_potion:
		return
	if _hp_current >= _hp_max:
		return
	_carried_potion = false
	_hp_current = min(_hp_max, _hp_current + 1)
	_update_hud_hearts()
	_update_hud_icons()
	_play_sfx(SFX_PICKUP1)
	_blink_node(player)

func _apply_trap_damage() -> void:
	if _game_over:
		return
	_apply_player_damage(1)

func _handle_trap_trigger(trap: Trap, cell: Vector2i) -> void:
	if trap == null:
		return
	if trap.trap_type == &"spiderweb":
		_web_stuck_turns = _rng.randi_range(1, 3)
		_traps.erase(trap)
		trap.queue_free()
		_last_trap_cell = Vector2i(-1, -1)
		return
	_apply_trap_damage()
	_last_trap_cell = cell

func _handle_enemy_hit_by_trap(enemy: Enemy, trap: Trap) -> void:
	if enemy == null or not enemy.alive:
		return
	if trap.trap_type == &"spiderweb":
		return
	enemy.apply_damage(1)
	if not enemy.alive:
		enemy.visible = false
		_leave_enemy_corpse(enemy)

func _update_hud_hearts() -> void:
	if _hud_hearts == null:
		return
	for c in _hud_hearts.get_children():
		c.queue_free()
	for i in range(_hp_current):
		var tr := TextureRect.new()
		tr.texture = HEART_TEX
		tr.custom_minimum_size = Vector2(24, 24)
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_hud_hearts.add_child(tr)
	_update_hud_armor()

func _update_hud_armor() -> void:
	if _hud_armor == null:
		return
	for c in _hud_armor.get_children():
		c.queue_free()
	for i in range(_armor_current):
		var tr := TextureRect.new()
		tr.texture = ARMOR_ICON_TEX
		tr.custom_minimum_size = Vector2(24, 24)
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_hud_armor.add_child(tr)

func _blink_node(ci: CanvasItem) -> void:
	_blink_node_colored(ci, Color(1, 1, 1, 1))

func _blink_node_colored(ci: CanvasItem, color: Color) -> void:
	if ci == null:
		return
	ci.modulate = Color(color.r, color.g, color.b, 1.0)
	var t := get_tree().create_tween()
	for i in range(3):
		t.tween_property(ci, "modulate:a", 0.2, 0.06)
		t.tween_property(ci, "modulate:a", 1.0, 0.06)
	t.finished.connect(func(): ci.modulate = Color(1, 1, 1, 1))

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
	var key_tex: Texture2D = _key_texture_for_type(_current_key_type())
	var st := _current_level_special_type()
	var special_tex: Texture2D = CODEX_TEX
	if st == &"crown":
		special_tex = CROWN_TEX
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
	if _hud_icon_key1 and KEY_TEX_1:
		_hud_icon_key1.texture = KEY_TEX_1
	if _hud_icon_key2 and KEY_TEX_2:
		_hud_icon_key2.texture = KEY_TEX_2
	if _hud_icon_key3 and KEY_TEX_3:
		_hud_icon_key3.texture = KEY_TEX_3
	if _hud_icon_key3 and KEY_TEX_3:
		_hud_icon_key3.texture = KEY_TEX_3
	if _hud_icon_codex and CODEX_TEX:
		_hud_icon_codex.texture = CODEX_TEX
	if _hud_icon_crown and CROWN_TEX:
		_hud_icon_crown.texture = CROWN_TEX
	if _hud_icon_sword and SWORD_TEX:
		_hud_icon_sword.texture = SWORD_TEX
	if _hud_icon_shield and SHIELD_TEX:
		_hud_icon_shield.texture = SHIELD_TEX
	if _hud_icon_rune1 and RUNE1_TEX:
		_hud_icon_rune1.texture = RUNE1_TEX
	if _hud_icon_rune2 and RUNE2_TEX:
		_hud_icon_rune2.texture = RUNE2_TEX
	if _hud_icon_rune3 and RUNE3_TEX:
		_hud_icon_rune3.texture = RUNE3_TEX
	if _hud_icon_torch and TORCH_TEX:
		_hud_icon_torch.texture = TORCH_TEX
	if _hud_icon_ring and RING_TEX:
		_hud_icon_ring.texture = RING_TEX
	if _hud_icon_potion and POTION_TEX:
		_hud_icon_potion.texture = POTION_TEX

func is_passable(cell: Vector2i) -> bool:
	# Allow stepping onto the door cell only when it is actually open
	return _door_is_open and cell == _door_cell

func is_in_bounds(cell: Vector2i) -> bool:
	return _in_bounds(cell)

func _place_random_inner_walls(grid_size: Vector2i) -> void:
	var player_cell := Grid.world_to_cell(player.global_position)
	var is_blocked := func(c: Vector2i) -> bool:
		if c == player_cell or c == _key_cell or c == _sword_cell or c == _shield_cell or c == _potion_cell:
			return true
		if _get_enemy_at(c) != null:
			return true
		return false
	_level_builder.place_random_inner_walls(grid_size, walls_map, SOURCES_WALL, TILE_WALL, is_blocked)

func _is_wall(cell: Vector2i) -> bool:
	return walls_map.get_cell_source_id(0, cell) != -1

func _in_interior(cell: Vector2i) -> bool:
	return cell.x >= 1 and cell.y >= 1 and cell.x < _grid_size.x - 1 and cell.y < _grid_size.y - 1

func _is_free(cell: Vector2i) -> bool:
	if not _in_interior(cell) or _is_wall(cell):
		return false
	if _get_enemy_at(cell) != null:
		return false
	if _trap_at(cell) != null:
		return false
	return true

func _can_enemy_step(cell: Vector2i, mover: Enemy) -> bool:
	if not _in_interior(cell) or _is_wall(cell):
		return false
	var occupant := _get_enemy_at(cell)
	if occupant != null and occupant != mover:
		return false
	var mouse := _mouse_at(cell)
	if mouse != null and mouse != mover:
		return false
	return true

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

func _make_item_node(item_name: String, tex: Texture2D) -> Item:
	var item := Item.new()
	item.name = item_name
	item.item_type = item_name
	var s := Sprite2D.new()
	s.centered = false
	s.texture = tex
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.z_index = 1
	item.add_child(s)
	return item


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
		["use_potion", [Key.KEY_Q]],
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

func _prepare_run_layout() -> void:
	_max_level = _rng.randi_range(3, 10)
	_level_special_map.clear()
	_special_levels.clear()
	_level_key_map.clear()
	_armor_plan.clear()
	_rune1_plan.clear()
	_rune2_plan.clear()
	_rune3_plan.clear()
	var levels: Array[int] = []
	for i in range(1, _max_level + 1):
		levels.append(i)
	levels.shuffle()
	var specials: Array[StringName] = [&"codex", &"crown", &"ring"]
	for s in specials:
		if levels.is_empty():
			break
		var lvl: int = levels.pop_back()
		_special_levels[s] = lvl
		_level_special_map[lvl] = s
	var key_levels: Array[int] = []
	for i2 in range(1, _max_level + 1):
		key_levels.append(i2)
	key_levels.shuffle()
	var key_types: Array[StringName] = [&"key1", &"key2", &"key3"]
	for k in key_types:
		if key_levels.is_empty():
			break
		var kl: int = key_levels.pop_back()
		_level_key_map[kl] = k
	var armor_total: int = _rng.randi_range(1, 3)
	var rune1_total: int = _rng.randi_range(1, 3)
	var rune2_total: int = _rng.randi_range(1, 3)
	var rune3_total: int = _rng.randi_range(1, 3)
	for i_a in range(armor_total):
		var al: int = _rng.randi_range(1, _max_level)
		_armor_plan[al] = _armor_plan.get(al, 0) + 1
	for i3 in range(rune1_total):
		var rl: int = _rng.randi_range(1, _max_level)
		_rune1_plan[rl] = _rune1_plan.get(rl, 0) + 1
	for i4 in range(rune2_total):
		var rl2: int = _rng.randi_range(1, _max_level)
		_rune2_plan[rl2] = _rune2_plan.get(rl2, 0) + 1
	for i5 in range(rune3_total):
		var rl3: int = _rng.randi_range(1, _max_level)
		_rune3_plan[rl3] = _rune3_plan.get(rl3, 0) + 1

func _get_enemy_at(cell: Vector2i) -> Enemy:
	for g: Goblin in _goblins:
		if g.alive and g.grid_cell == cell:
			return g
	for z: Zombie in _zombies:
		if z.alive and z.grid_cell == cell:
			return z
	for m: Minotaur in _minotaurs:
		if m.alive and m.grid_cell == cell:
			return m
	for sk: Skeleton in _skeletons:
		if sk.alive and sk.grid_cell == cell:
			return sk
	return null

func _mouse_at(cell: Vector2i) -> Mouse:
	for m in _mice:
		if m.alive and m.grid_cell == cell:
			return m
	return null

func _trap_at(cell: Vector2i) -> Trap:
	for t in _traps:
		if t.grid_cell == cell:
			return t
	return null
