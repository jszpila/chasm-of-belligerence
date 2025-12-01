extends Node2D

const LevelBuilder := preload("res://scripts/LevelBuilder.gd")
const Enemy := preload("res://scripts/Enemy.gd")
const Goblin := preload("res://scripts/Goblin.gd")
const Zombie := preload("res://scripts/Zombie.gd")
const Minotaur := preload("res://scripts/Minotaur.gd")
const Imp := preload("res://scripts/Imp.gd")
const Mouse := preload("res://scripts/Mouse.gd")
const Skeleton := preload("res://scripts/Skeleton.gd")
const Trap := preload("res://scripts/Trap.gd")
const Item := preload("res://scripts/Item.gd")
const GOBLIN_SCENE: PackedScene = preload("res://scenes/Goblin.tscn")
const ZOMBIE_SCENE: PackedScene = preload("res://scenes/Zombie.tscn")
const MINOTAUR_SCENE: PackedScene = preload("res://scenes/Minotaur.tscn")
const IMP_SCENE: PackedScene = preload("res://scenes/Imp.tscn")
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
const TILESET_A := &"tile_set_a"
const TILESET_B := &"tile_set_b"
const TILESET_C := &"tile_set_c"
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
const SFX_BOW: AudioStream = preload("res://assets/bow.wav")
const SFX_WAND: AudioStream = preload("res://assets/wand.wav")
const SIGHT_INNER_TILES := 5
const SIGHT_OUTER_TILES := 10
const SIGHT_MAX_DARK := 0.8
const FLOOR_ALPHA_MIN := 1.0
const FLOOR_ALPHA_MAX := 1.0
const BONE_ALPHA_MIN := 1.0
const BONE_ALPHA_MAX := 1.0
const ARMOR_MAX := 3
const LEVEL_UP_SCORE_STEP := 10
const HP_MAX_LIMIT := 5
const RANGED_WAND := &"wand"
const RANGED_BOW := &"bow"
const RANGED_NONE := &"none"
const ARROWS_PER_PICKUP := 3
const RUNE4_DASH_RANGE := 5
const RUNE4_DASH_COOLDOWN_MOVES := 20
const SHARED_FLOOR_WEIGHT := 0.15
const DEBUG_FORCE_RANGED := false
const DEBUG_SPAWN_ALL_ITEMS := false
const DEBUG_SPAWN_CHEESE := false
const RANGED_INPUT_LOCK := 0.12
const EARLY_LEVEL_WEIGHT := 3
const ACTION_LOG_MAX := 5
const ACTION_LOG_OPACITIES := [1.0, 0.8, 0.6, 0.4, 0.2]
const ACTION_LOG_FONT_SIZE := 28
const FINAL_DOOR_PULSE_SCALE := 0.06
const FINAL_DOOR_PULSE_TIME := 0.6
var PLAYER_TEX_1: Texture2D
var PLAYER_TEX_2: Texture2D
var PLAYER_TEX_3: Texture2D
var PLAYER_TEX_4: Texture2D
var PLAYER_TEX_WAND: Texture2D
var PLAYER_TEX_BOW: Texture2D
var PLAYER_TEX_TORCH: Texture2D
var PLAYER_TEX_DEAD: Texture2D
var HEART_TEX: Texture2D
var GOBLIN_TEX_1: Texture2D
var DEAD_GOBLIN_TEX: Texture2D
var ZOMBIE_TEX_1: Texture2D
var ZOMBIE_TEX_2: Texture2D
var MINO_TEX_1: Texture2D
var MINO_TEX_2: Texture2D
var IMP_TEX: Texture2D
var IMP_DEAD_TEX: Texture2D
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
var RUNE4_TEX: Texture2D
var TORCH_TEX: Texture2D
var RING_TEX: Texture2D
var CHEESE_TEX: Texture2D
var ARMOR_ICON_TEX: Texture2D
var TRAP_TEX_A: Texture2D
var TRAP_TEX_B: Texture2D
var TRAP_WEB_TEX: Texture2D
var BRAZIER_TEX: Texture2D
var WAND_TEX: Texture2D
var BOW_TEX: Texture2D
var ARROW_TEX: Texture2D
var BONE_TEXTURES: Array[Texture2D] = []
var SPIDERWEB_TEXTURES := {}
var FLOOR_TEXTURES_A: Array[Texture2D] = []
var FLOOR_TEXTURES_B: Array[Texture2D] = []
var FLOOR_TEXTURES_C: Array[Texture2D] = []
var FLOOR_TEXTURES_SHARED: Array[Texture2D] = []
var WALL_TEXTURES_A: Array[Texture2D] = []
var WALL_TEXTURES_B: Array[Texture2D] = []
var WALL_TEXTURES_C: Array[Texture2D] = []
var _floor_sources_by_set := {}
var _wall_sources_by_set := {}
var _shared_floor_sources: Array[int] = []
var _current_floor_sources_base: Array[int] = []
var _current_floor_sources: Array[int] = []
var _current_wall_sources: Array[int] = []
var _tileset_plan := {}
var _tileset_choices: Array[StringName] = [TILESET_A, TILESET_B, TILESET_C]
var _sheet_image: Image
var _sheet_tex_cache := {}
var _ranged_highlight: StyleBoxFlat
var _ranged_inactive: StyleBoxFlat
var _debug_bow_outline: Line2D
var _debug_wand_outline: Line2D
var _projectile_pool: Array[Line2D] = []
var _projectile_active: Array[Line2D] = []
var _dash_trail_pool: Array[Line2D] = []
var _dash_trail_active: Array[Line2D] = []
var _title_textures: Array[Texture2D] = []
var _win_textures: Array[Texture2D] = []
var _lose_textures: Array[Texture2D] = []
var _audio_pool: Array[AudioStreamPlayer] = []
var _debug_items: Array[Item] = []
var _action_log: Array[String] = []
@onready var _loading_label: Label = $HUD/LoadingLabel

@onready var floor_map: TileMap = $Floor
@onready var walls_map: TileMap = $Walls
@onready var player: Node2D = $Player
@onready var _player_sprite: Sprite2D = $Player/Sprite2D
@onready var _hud_hearts: HBoxContainer = $HUD/HUDBar/HUDVitals/HeartsBorder/Hearts
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
@onready var _hud_icon_rune4: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDRune4Icon
@onready var _hud_icon_torch: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDTorchIcon
@onready var _hud_icon_ring: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDRingIcon
@onready var _hud_icon_potion: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDPotionIcon
@onready var _hud_icon_cheese: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDCheeseIcon
@onready var _hud_icon_bow: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDBowSlot/HUDBowIcon
@onready var _hud_icon_wand: TextureRect = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDWandSlot/HUDWandIcon
@onready var _hud_bow_panel: PanelContainer = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDBowSlot
@onready var _hud_wand_panel: PanelContainer = $HUD/HUDBar/HUDItems/HUDItemsContainer/HUDWandSlot
@onready var _hud_arrow_label: Label = $HUD/HUDBar/HUDTextGroup/HUDTextGrid/HUDArrows
@onready var _action_log_box: VBoxContainer = $ActionLogLayer/ActionLog
var _hud_action_lines: Array[Label] = []
const ACTION_LOG_FONT := preload("res://assets/m5x7.ttf")
@onready var _hud_armor: HBoxContainer = $HUD/HUDBar/HUDVitals/ArmorBorder/Armor
@onready var _hud_player_level: Label = $HUD/HUDBar/HUDTextGroup/HUDTextGrid/HUDPlayerLevel
@onready var _hud_atk_label: Label = $HUD/HUDBar/HUDTextGroup/HUDTextGrid/HUDATKLabel
@onready var _hud_def_label: Label = $HUD/HUDBar/HUDTextGroup/HUDTextGrid/HUDDEFLabel
@onready var _hud_score: Label = $HUD/HUDBar/HUDTextGroup/HUDTextGrid/HUDScore
@onready var _fade: ColorRect = $HUD/Fade
@onready var _key_node: Item = $Key
@onready var _sword_node: Item = $Sword
@onready var _shield_node: Item = $Shield
@onready var _potion_node: Item = $Potion
@onready var _codex_node: Item = $Codex
@onready var _bow_node: Item = $Bow
@onready var _wand_node: Item = $Wand
@onready var _arrow_base_node: Item = $ArrowPickup
@onready var _decor: Node2D = $Decor
@onready var _title_layer: CanvasLayer = $Title
@onready var _title_label: Label = $Title/TitleLabel
@onready var _title_build_label: Label = $Title/VersionLabel
@onready var _over_layer: CanvasLayer = $GameOver
@onready var _over_label: Label = $GameOver/OverLabel
@onready var _over_result: Label = $GameOver/OverResult
@onready var _over_score: Label = $GameOver/OverScore
@onready var _over_cause: Label = $GameOver/OverCause
@onready var _title_bg: TextureRect = $Title/TitleBG
@onready var _over_bg_win: TextureRect = $GameOver/OverBGWin
@onready var _over_bg_lose: TextureRect = $GameOver/OverBGLose
@onready var _door_node: Node2D = $Door
@onready var _door_sprite: Sprite2D = $Door/Sprite2D
@onready var _entrance_door_node: Node2D = $EntranceDoor
@onready var _entrance_door_sprite: Sprite2D = $EntranceDoor/Sprite2D
@onready var _hud_level: Label = $HUD/HUDBar/HUDTextGroup/HUDTextGrid/HUDLevel
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
		s.modulate = Color(1, 1, 1, 1)
		s.visible = true
		s.z_index = 50
		s.z_as_relative = false
		s.position = Vector2.ZERO

func _normalize_item_node(item: Item, tex: Texture2D) -> void:
	if item == null:
		return
	item.collected = false
	item.visible = true
	item.modulate = Color(1, 1, 1, 1)
	item.z_index = 10
	item.z_as_relative = false
	item.global_position = Grid.cell_to_world(item.grid_cell)
	_set_sprite_tex(item, tex)

func _load_spritesheet_textures() -> void:
	PLAYER_TEX_1 = _sheet_tex(&"player1", Vector2i(1352, 0), true)
	PLAYER_TEX_2 = _sheet_tex(&"player2", Vector2i(1456, 0), true)
	PLAYER_TEX_3 = _sheet_tex(&"player3", Vector2i(1937, 0), true)
	PLAYER_TEX_4 = _sheet_tex(&"player4", Vector2i(1989, 0), true)
	PLAYER_TEX_WAND = _sheet_tex(&"player_wand", Vector2i(1625, 0), true)
	PLAYER_TEX_BOW = _sheet_tex(&"player_bow", Vector2i(2028, 0), true)
	PLAYER_TEX_TORCH = _sheet_tex(&"player_torch", Vector2i(1898, 0), true)
	PLAYER_TEX_DEAD = _sheet_tex(&"player_dead", Vector2i(2613, 0), true)
	HEART_TEX = _sheet_tex(&"heart", Vector2i(1014, 481), true)
	GOBLIN_TEX_1 = _sheet_tex(&"goblin1", Vector2i(1352, 52), true)
	DEAD_GOBLIN_TEX = _sheet_tex(&"goblin_dead", Vector2i(2613, 52), true)
	ZOMBIE_TEX_1 = _sheet_tex(&"zombie1", Vector2i(2626, 117), true)
	ZOMBIE_TEX_2 = _sheet_tex(&"zombie2", Vector2i(2613, 117), true)
	MINO_TEX_1 = _sheet_tex(&"mino1", Vector2i(1352, 208), true)
	MINO_TEX_2 = _sheet_tex(&"mino2", Vector2i(2613, 208), true)
	IMP_TEX = _sheet_tex(&"imp", Vector2i(2028, 260), true)
	IMP_DEAD_TEX = _sheet_tex(&"imp_dead", Vector2i(2613, 260), true)
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
	RUNE4_TEX = _sheet_tex(&"rune4", Vector2i(455, 221), true)
	TORCH_TEX = _sheet_tex(&"torch", Vector2i(52, 546), true)
	RING_TEX = _sheet_tex(&"ring", Vector2i(156, 559), true)
	CHEESE_TEX = _sheet_tex(&"cheese", Vector2i(91, 221), true)
	ARMOR_ICON_TEX = _sheet_tex(&"armor_icon", Vector2i(338, 156), true)
	TRAP_TEX_A = _sheet_tex(&"trap_a", Vector2i(364, 273), true)
	TRAP_TEX_B = _sheet_tex(&"trap_b", Vector2i(390, 273), true)
	TRAP_WEB_TEX = _sheet_tex(&"trap_web", Vector2i(52, 507), true)
	BRAZIER_TEX = _sheet_tex(&"brazier", Vector2i(351, 286), true)
	WAND_TEX = _sheet_tex(&"wand", Vector2i(544, 169), true)
	BOW_TEX = _sheet_tex(&"bow", Vector2i(351, 130), true)
	ARROW_TEX = _sheet_tex(&"arrow", Vector2i(429, 130), true)
	_title_textures = [
		load("res://assets/CoB-title.png"),
		load("res://assets/cob-title-mb.png"),
		load("res://assets/cob-title-comic.png")
	]
	_win_textures = [
		load("res://assets/codex-quest-win.png"),
		load("res://assets/win-mb.png"),
		load("res://assets/win-comic.png")
	]
	_lose_textures = [
		load("res://assets/codex-quest-lose.png"),
		load("res://assets/lose-mb.png"),
		load("res://assets/lose-comic.png")
	]
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
	FLOOR_TEXTURES_A = [
		_sheet_tex(&"tile_set_a_floor_1", Vector2i(130, 65), false),
		_sheet_tex(&"tile_set_a_floor_2", Vector2i(143, 65), false),
		_sheet_tex(&"tile_set_a_floor_3", Vector2i(156, 65), false),
		_sheet_tex(&"tile_set_a_floor_4", Vector2i(117, 65), false),
	]
	WALL_TEXTURES_A = [
		_sheet_tex(&"tile_set_a_wall_1", Vector2i(0, 26), false),
		_sheet_tex(&"tile_set_a_wall_2", Vector2i(13, 26), false),
		_sheet_tex(&"tile_set_a_wall_3", Vector2i(65, 26), false),
		_sheet_tex(&"tile_set_a_wall_4", Vector2i(78, 26), false),
		_sheet_tex(&"tile_set_a_wall_5", Vector2i(91, 26), false),
	]
	FLOOR_TEXTURES_B = [
		_sheet_tex(&"tile_set_b_floor_1", Vector2i(52, 65), false),
		_sheet_tex(&"tile_set_b_floor_2", Vector2i(65, 65), false),
		_sheet_tex(&"tile_set_b_floor_3", Vector2i(78, 65), false),
		_sheet_tex(&"tile_set_b_floor_4", Vector2i(91, 65), false),
	]
	WALL_TEXTURES_B = [
		_sheet_tex(&"tile_set_b_wall_1", Vector2i(39, 0), false),
		_sheet_tex(&"tile_set_b_wall_2", Vector2i(52, 0), false),
		_sheet_tex(&"tile_set_b_wall_3", Vector2i(65, 0), false),
		_sheet_tex(&"tile_set_b_wall_4", Vector2i(78, 0), false),
	]
	FLOOR_TEXTURES_C = [
		_sheet_tex(&"tile_set_c_floor_1", Vector2i(78, 78), false),
		_sheet_tex(&"tile_set_c_floor_2", Vector2i(91, 78), false),
		_sheet_tex(&"tile_set_c_floor_3", Vector2i(130, 78), false),
		_sheet_tex(&"tile_set_c_floor_4", Vector2i(143, 78), false),
	]
	WALL_TEXTURES_C = [
		_sheet_tex(&"tile_set_c_wall_1", Vector2i(0, 39), false),
		_sheet_tex(&"tile_set_c_wall_2", Vector2i(13, 39), false),
		_sheet_tex(&"tile_set_c_wall_3", Vector2i(26, 39), false),
		_sheet_tex(&"tile_set_c_wall_4", Vector2i(156, 39), false),
	]
	FLOOR_TEXTURES_SHARED = [
		_sheet_tex(&"old_bones_floor_1", Vector2i(0, 91), false),
		_sheet_tex(&"old_bones_floor_2", Vector2i(13, 91), false),
		_sheet_tex(&"old_bones_floor_3", Vector2i(26, 91), false),
	]
	_sheet_tex_cache[&"mouse_tex"] = mouse_tex
	_set_sprite_tex(_door_node, DOOR_TEX_1)
	_set_sprite_tex(_key_node, KEY_TEX_1)
	_set_sprite_tex(_sword_node, SWORD_TEX)
	_set_sprite_tex(_shield_node, SHIELD_TEX)
	_set_sprite_tex(_potion_node, POTION_TEX)
	_set_sprite_tex(_codex_node, CODEX_TEX)
	_set_sprite_tex(_bow_node, BOW_TEX)
	_set_sprite_tex(_wand_node, WAND_TEX)
	_set_sprite_tex(_arrow_base_node, ARROW_TEX)
	_set_sprite_tex(_player_sprite, PLAYER_TEX_1)

func _build_tileset_from_sheet() -> void:
	_tileset = TileSet.new()
	_tileset.tile_size = Vector2i(12, 12)
	_floor_sources_by_set.clear()
	_wall_sources_by_set.clear()
	_shared_floor_sources.clear()
	var tilesets: Array = [
		{
			"id": TILESET_A,
			"floors": FLOOR_TEXTURES_A,
			"walls": WALL_TEXTURES_A
		},
		{
			"id": TILESET_B,
			"floors": FLOOR_TEXTURES_B,
			"walls": WALL_TEXTURES_B
		},
		{
			"id": TILESET_C,
			"floors": FLOOR_TEXTURES_C,
			"walls": WALL_TEXTURES_C
		},
	]
	var next_source_id := 0
	for ts in tilesets:
		var floor_sources: Array[int] = []
		for tex: Texture2D in ts["floors"]:
			var src := _make_tile_source(tex)
			_tileset.add_source(src, next_source_id)
			floor_sources.append(next_source_id)
			next_source_id += 1
		_floor_sources_by_set[ts["id"]] = floor_sources
		var wall_sources: Array[int] = []
		for tex2: Texture2D in ts["walls"]:
			var src2 := _make_tile_source(tex2)
			_tileset.add_source(src2, next_source_id)
			wall_sources.append(next_source_id)
			next_source_id += 1
		_wall_sources_by_set[ts["id"]] = wall_sources
	for shared_tex in FLOOR_TEXTURES_SHARED:
		var shared_src := _make_tile_source(shared_tex)
		_tileset.add_source(shared_src, next_source_id)
		_shared_floor_sources.append(next_source_id)
		next_source_id += 1
	floor_map.tile_set = _tileset
	walls_map.tile_set = _tileset

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _level_builder: LevelBuilder
var _key_cell: Vector2i = Vector2i.ZERO
var _sword_cell: Vector2i = Vector2i.ZERO
var _shield_cell: Vector2i = Vector2i.ZERO
var _potion_cell: Vector2i = Vector2i.ZERO
var _potion2_cell: Vector2i = Vector2i.ZERO
var _wand_cell: Vector2i = Vector2i.ZERO
var _bow_cell: Vector2i = Vector2i.ZERO
var _arrow_cells: Array[Vector2i] = []
var _armor_cells: Array[Vector2i] = []
var _rune1_cells: Array[Vector2i] = []
var _rune2_cells: Array[Vector2i] = []
var _rune3_cells: Array[Vector2i] = []
var _rune4_cells: Array[Vector2i] = []
var _torch_cell: Vector2i = Vector2i.ZERO
var _ring_cell: Vector2i = Vector2i.ZERO
var _codex_cell: Vector2i = Vector2i.ZERO
var _cheese_cell: Vector2i = Vector2i.ZERO
var _key_collected: bool = false
var _key_on_level: bool = false
var _entrance_cell: Vector2i = Vector2i.ZERO
var _sword_collected: bool = false
var _shield_collected: bool = false
var _potion_collected: bool = false
var _potion2_collected: bool = false
var _wand_collected: bool = false
var _bow_collected: bool = false
var _armor_current: int = 0
var _rune1_collected_count: int = 0
var _rune2_collected_count: int = 0
var _rune3_collected_count: int = 0
var _rune4_collected_count: int = 0
var _torch_collected: bool = false
var _ring_collected: bool = false
var _codex_collected: bool = false
var _crown_collected: bool = false
var _cheese_collected: bool = false
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
var _imps: Array[Imp] = []
var _skeletons: Array[Skeleton] = []
var _mice: Array[Mouse] = []
var _traps: Array[Trap] = []
var _enemy_map: Dictionary = {}
var _potion2_node: Item
var _arrow_nodes: Array[Item] = []
var _armor_nodes: Array[Item] = []
var _rune1_nodes: Array[Item] = []
var _rune2_nodes: Array[Item] = []
var _rune3_nodes: Array[Item] = []
var _rune4_nodes: Array[Item] = []
var _torch_node: Item
var _ring_node: Item
var _cheese_node: Item
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
var _corpse_nodes: Array[Sprite2D] = []
var _brazier_cells: Array[Vector2i] = []
var _brazier_nodes: Array[Node2D] = []
var _door_glow: PointLight2D
var _door_pulse_tween: Tween
var _level_special_map := {} # level -> special type
var _special_levels := {} # special type -> level
var _level_key_map := {} # level -> key type
var _armor_plan := {} # level -> count
var _rune1_plan := {} # level -> count
var _rune2_plan := {}
var _rune3_plan := {}
var _rune4_plan := {}
var _arrow_plan := {} # level -> 0/1 arrow pickup
var _level_states := {}
var _wand_level: int = 1
var _bow_level: int = 1
var _arrow_count: int = 0
var _active_ranged_weapon: StringName = RANGED_NONE
var _player_level: int = 0
var _rune4_dash_cooldown: int = 0
var _last_death_cause: StringName = StringName()
var _ranged_fire_lock: float = 0.0
var _cheese_given: bool = false
var _cheese_level: int = -1

const STATE_TITLE := 0
const STATE_PLAYING := 1
const STATE_GAME_OVER := 2
var _state: int = STATE_TITLE

func _ready() -> void:
	_setup_input()
	_load_spritesheet_textures()
	_build_tileset_from_sheet()
	_rng.randomize()
	_ranged_highlight = StyleBoxFlat.new()
	_ranged_highlight.draw_center = false
	_ranged_highlight.border_color = Color(1, 1, 1, 1)
	_ranged_highlight.border_width_top = 1
	_ranged_highlight.border_width_bottom = 1
	_ranged_highlight.border_width_left = 1
	_ranged_highlight.border_width_right = 1
	_ranged_inactive = StyleBoxFlat.new()
	_ranged_inactive.draw_center = false
	_ranged_inactive.border_color = Color(1, 1, 1, 0)
	_ranged_inactive.border_width_top = 1
	_ranged_inactive.border_width_bottom = 1
	_ranged_inactive.border_width_left = 1
	_ranged_inactive.border_width_right = 1
	if _hud_bow_panel:
		_hud_bow_panel.add_theme_stylebox_override("panel", _ranged_inactive)
	if _hud_wand_panel:
		_hud_wand_panel.add_theme_stylebox_override("panel", _ranged_inactive)
	_clear_debug_outlines()
	_level_builder = LevelBuilder.new(_rng)
	if not get_viewport().size_changed.is_connected(_on_viewport_resized):
		get_viewport().size_changed.connect(_on_viewport_resized)
	_resize_fullscreen_art()
	_init_action_log_labels()
	# Start at title screen
	_state = STATE_TITLE
	_show_title(true)
	_set_world_visible(false)
	# Disable player controls until game starts
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(false)
	_update_title_build_label()
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

func _show_loading(text: String = "Loading...") -> void:
	if _loading_label:
		_loading_label.text = text
		_loading_label.visible = true
		_loading_label.z_index = 10000
		_loading_label.z_as_relative = false

func _hide_loading() -> void:
	if _loading_label:
		_loading_label.visible = false

func _process(_delta: float) -> void:
	# Title state: wait for Enter to start
	_ranged_fire_lock = max(0.0, _ranged_fire_lock - _delta)
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
	if Input.is_action_just_pressed("switch_ranged"):
		_cycle_ranged_weapon()
	var ranged_dir := _ranged_dir_from_input()
	if ranged_dir != Vector2i.ZERO and _ranged_fire_lock <= 0.0:
		if _fire_ranged(ranged_dir):
			_ranged_fire_lock = RANGED_INPUT_LOCK
			return
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
			_log_action("Picked up Gold Key")
		elif ktype == &"key2":
			_key2_collected = true
			_key2_icon_persistent = true
			_log_action("Picked up Bronze Key")
		elif ktype == &"key3":
			_key3_collected = true
			_key3_icon_persistent = true
			_log_action("Picked up Silver Key")
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
			_log_action("Picked up Sword")
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
		_log_action("Picked up Codex")
		_check_win()
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
		_log_action("Picked up Crown")
	_debug_check_special_pickups(cp)
	if not _shield_collected and cp == _shield_cell:
		_shield_collected = true
		print("GOT SHIELD")
		if _shield_node:
			_shield_node.collect()
			_add_score(1)
			_update_player_sprite_appearance()
			_play_sfx(SFX_PICKUP1)
			_blink_node(player)
			_log_action("Picked up Shield")
	if not _wand_collected and cp == _wand_cell:
		_wand_collected = true
		_wand_cell = Vector2i(-1, -1)
		_active_ranged_weapon = RANGED_WAND
		print("GOT WAND")
		if _wand_node:
			_wand_node.collect()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)
		_add_score(1)
		_update_player_sprite_appearance()
		_update_hud_icons()
		_log_action("Picked up Wand")
	if not _bow_collected and cp == _bow_cell:
		_bow_collected = true
		_bow_cell = Vector2i(-1, -1)
		_active_ranged_weapon = _active_ranged_weapon if _active_ranged_weapon != RANGED_NONE else RANGED_BOW
		print("GOT BOW")
		if _bow_node:
			_bow_node.collect()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)
		_add_score(1)
		_update_player_sprite_appearance()
		_update_hud_icons()
		_log_action("Picked up Bow")
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
		_update_player_sprite_appearance()
		_log_action("Picked up Torch")
	if not _cheese_collected and not _cheese_given and cp == _cheese_cell:
		_cheese_collected = true
		_cheese_cell = Vector2i(-1, -1)
		print("GOT CHEESE")
		if _cheese_node:
			_cheese_node.collect()
		_play_sfx(SFX_PICKUP1)
		_blink_node(player)
		_add_score(1)
		_update_hud_icons()
		_log_action("Picked up Cheese")
	if not _ring_collected and _current_level_special_type() == &"ring" and cp == _ring_cell:
		_ring_collected = true
		print("GOT RING")
		if _ring_node:
			_ring_node.collect()
		_play_sfx(SFX_PICKUP1)
		_blink_node(player)
		_add_score(1)
		_ring_cell = Vector2i(-1, -1)
		_log_action("Picked up Ring")

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
				_log_action("Got Rune-1 (+1 ATK)")
				break
		for r2 in _rune2_nodes:
			if r2 != null and not r2.collected and cp == r2.grid_cell:
				_rune2_collected_count += 1
				print("GOT RUNE-2 (+1 DEF)")
				r2.collect()
				_play_sfx(SFX_PICKUP2)
				_blink_node(player)
				_add_score(1)
				_log_action("Got Rune-2 (+1 DEF)")
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
				_log_action("Got Rune-3 (+1 MAX HP)")
				break
		for r4 in _rune4_nodes:
			if r4 != null and not r4.collected and cp == r4.grid_cell:
				_rune4_collected_count += 1
				print("GOT RUNE-4 (Dash Attack)")
				r4.collect()
				_play_sfx(SFX_PICKUP2)
				_blink_node(player)
				_add_score(1)
				_log_action("Got Rune-4 (Dash Attack)")
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
				_log_action("Picked up Armor")
				break
		_try_give_cheese(cp)
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
	_pickup_arrows_if_available(new_cell)

func _on_player_attempt_move() -> bool:
	if _web_stuck_turns > 0:
		_web_stuck_turns = max(0, _web_stuck_turns - 1)
		_advance_enemies_and_update(_skeletons.size())
		return false
	return true

func _on_player_dash_attempt(dir: Vector2i) -> bool:
	if dir == Vector2i.ZERO or _state != STATE_PLAYING or _is_transitioning:
		return false
	if not _has_rune4():
		return false
	if _rune4_dash_cooldown > 0:
		return false
	var step_dir := Vector2i(sign(dir.x), sign(dir.y))
	if step_dir == Vector2i.ZERO:
		return false
	var origin := Grid.world_to_cell(player.global_position)
	var path: Array[Vector2i] = [origin]
	var target: Enemy = null
	var target_cell := origin
	for i in range(1, RUNE4_DASH_RANGE + 1):
		var c := origin + step_dir * i
		if not _in_interior(c) or _is_wall(c):
			break
		target_cell = c
		var enemy := _get_enemy_at(c)
		if enemy != null:
			target = enemy
			break
		path.append(c)
	if target == null:
		return false
	_play_sfx(SFX_HURT1)
	_log_action("Dash strike!")
	_blink_node(target)
	target.apply_damage(1)
	var enemy_died := not target.alive
	if not target.alive:
		_handle_enemy_death(target)
		_check_win()
	_rune4_dash_cooldown = RUNE4_DASH_COOLDOWN_MOVES + 1
	var landing_cell := target_cell if enemy_died else (path[-1] if path.size() > 1 else origin)
	var trail_cells: Array[Vector2i] = [origin]
	for cell in path:
		if trail_cells[-1] != cell:
			trail_cells.append(cell)
	if trail_cells[-1] != landing_cell:
		trail_cells.append(landing_cell)
	if landing_cell == origin and target_cell != landing_cell and trail_cells[-1] != target_cell:
		trail_cells.append(target_cell)
	_show_dash_trail(trail_cells)
	player.teleport_to_cell(landing_cell)
	if landing_cell != origin:
		_on_player_moved(landing_cell)
	else:
		_advance_enemies_and_update(_skeletons.size())
	return true

func _enemy_can_act(enemy: Enemy) -> bool:
	if enemy == null:
		return false
	if enemy.web_stuck_turns > 0:
		enemy.web_stuck_turns = max(0, enemy.web_stuck_turns - 1)
		return false
	return true

func _advance_enemies_and_update(skip_skeletons_from: int) -> void:
	var prev_dash_cd := _rune4_dash_cooldown
	# 75% chance each goblin attempts to move 1 step in a random dir
	var dirs: Array[Vector2i] = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
	for goblin: Goblin in _goblins:
		if goblin.alive and _enemy_can_act(goblin) and _rng.randf() <= 0.75:
			var d: Vector2i = dirs[_rng.randi_range(0, dirs.size() - 1)]
			_move_goblin(goblin, d)
	for mouse: Mouse in _mice:
		if mouse.alive and _enemy_can_act(mouse) and _rng.randf() <= 0.75:
			var d2: Vector2i = dirs[_rng.randi_range(0, dirs.size() - 1)]
			_move_mouse(mouse, d2)
	# Move zombie (one per level) with low accuracy towards player, less accurate at distance
	for zombie: Zombie in _zombies:
		if zombie.alive and _enemy_can_act(zombie):
			_move_homing_enemy(zombie)
			_update_facing_to_player(zombie)
	for i in range(_skeletons.size()):
		var skeleton := _skeletons[i]
		if i >= skip_skeletons_from:
			continue
		if skeleton.alive and _enemy_can_act(skeleton):
			_move_homing_enemy(skeleton)
	# Move minotaur (zero on L1, one on L2) with higher accuracy towards player
	for mino: Minotaur in _minotaurs:
		if mino.alive and _enemy_can_act(mino):
			_move_homing_enemy(mino)
	for imp: Imp in _imps:
		if imp.alive and _enemy_can_act(imp):
			_imp_take_turn(imp)
	_update_fov()
	if _rune4_dash_cooldown > 0:
		_rune4_dash_cooldown = max(0, _rune4_dash_cooldown - 1)
	if prev_dash_cd != _rune4_dash_cooldown:
		_update_hud_icons()

func _move_goblin(goblin: Goblin, dir: Vector2i) -> void:
	var dest: Vector2i = goblin.grid_cell + dir
	if not _can_enemy_step(dest, goblin):
		return
	var player_cell := Grid.world_to_cell(player.global_position)
	# If goblin would move onto player, do one combat round and don't move into that cell
	if dest == player_cell and goblin.alive and not _game_over:
		_combat_round_enemy(goblin)
		return
	_set_enemy_cell(goblin, dest)
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
	_set_enemy_cell(enemy, dest)
	var trap2 := _trap_at(dest)
	if trap2 != null:
		_handle_enemy_hit_by_trap(enemy, trap2)

func _update_facing_to_player(enemy: Enemy) -> void:
	if enemy == null:
		return
	var player_cell := Grid.world_to_cell(player.global_position)
	var spr := enemy.get_node_or_null("Sprite2D") as Sprite2D
	if spr == null:
		return
	spr.flip_h = player_cell.x > enemy.grid_cell.x

func _move_enemy_away_from_player(enemy: Enemy) -> void:
	var player_cell := Grid.world_to_cell(player.global_position)
	var start_dist: int = abs(enemy.grid_cell.x - player_cell.x) + abs(enemy.grid_cell.y - player_cell.y)
	var dirs: Array[Vector2i] = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	var best: Array[Vector2i] = []
	var best_dist: int = start_dist
	for d in dirs:
		var dest := enemy.grid_cell + d
		if not _can_enemy_step(dest, enemy):
			continue
		var trap := _trap_at(dest)
		if trap != null:
			# Running away: don't intentionally step into traps
			continue
		var dist: int = abs(dest.x - player_cell.x) + abs(dest.y - player_cell.y)
		if dist > best_dist:
			best_dist = dist
			best = [dest]
		elif dist == best_dist:
			best.append(dest)
	if best.is_empty():
		_move_homing_enemy(enemy)
		return
	var pick := best[_rng.randi_range(0, best.size() - 1)]
	_set_enemy_cell(enemy, pick)

func _imp_targeting_data(origin: Vector2i, target: Vector2i) -> Dictionary:
	var dx := target.x - origin.x
	var dy := target.y - origin.y
	var dist: int = max(abs(dx), abs(dy))
	if dist < 1 or dist > 4:
		return {}
	var dir := Vector2i(sign(dx), sign(dy))
	var aligned: bool = (dx == 0 or dy == 0 or abs(dx) == abs(dy))
	if not aligned or dir == Vector2i.ZERO:
		return {}
	return {"dir": dir, "dist": dist}

func _imp_line_clear(origin: Vector2i, dir: Vector2i, dist: int) -> bool:
	for i in range(1, dist + 1):
		var cell := origin + dir * i
		if not _in_interior(cell):
			return false
		if _is_wall(cell):
			return false
		if i < dist:
			if _get_enemy_at(cell) != null:
				return false
			if _trap_at(cell) != null:
				return false
	return true

func _imp_miss_chance(dist: int) -> float:
	return clampf(0.15 * float(max(0, dist - 1)), 0.0, 0.6)

func _imp_fire_shot(imp: Imp, dir: Vector2i, dist: int, player_cell: Vector2i) -> void:
	if imp == null or not imp.alive:
		return
	var origin := imp.grid_cell
	var end_cell := origin + dir * dist
	_fire_projectile(origin, end_cell, Color(0.9, 0.2, 0.2, 1))
	imp.arrows = max(0, imp.arrows - 1)
	imp.cooldown = 2
	if _rng.randf() < _imp_miss_chance(dist):
		_log_action("That was close!")
		return
	_set_death_cause_enemy(&"imp")
	_apply_player_damage(1)
	_log_action("Imp hits you!")

func _imp_take_turn(imp: Imp) -> void:
	if imp == null or not imp.alive:
		return
	imp.cooldown = max(0, imp.cooldown - 1)
	var player_cell := Grid.world_to_cell(player.global_position)
	var targeting := _imp_targeting_data(imp.grid_cell, player_cell)
	if imp.arrows > 0 and imp.cooldown == 0 and not targeting.is_empty():
		var dir: Vector2i = targeting["dir"]
		var dist: int = targeting["dist"]
		if _imp_line_clear(imp.grid_cell, dir, dist):
			_imp_fire_shot(imp, dir, dist, player_cell)
			return
	if imp.arrows <= 0:
		_move_enemy_away_from_player(imp)
	else:
		_move_homing_enemy(imp)

func _get_grid_size() -> Vector2i:
	# Use a fixed world size (in tiles)
	return Vector2i(FIXED_GRID_W, FIXED_GRID_H)

func _set_current_tileset_for_level(level: int) -> void:
	if _tileset_choices.is_empty():
		_tileset_choices = [TILESET_A]
	if not _tileset_plan.has(level):
		var choice: StringName = _tileset_choices[_rng.randi_range(0, _tileset_choices.size() - 1)]
		_tileset_plan[level] = choice
	var ts_choice: StringName = _tileset_plan[level]
	var base_floor_sources: Array = _floor_sources_by_set.get(ts_choice, [])
	if base_floor_sources.is_empty() and _floor_sources_by_set.has(TILESET_A):
		base_floor_sources = _floor_sources_by_set[TILESET_A]
	_current_floor_sources_base = base_floor_sources.duplicate()
	_current_floor_sources = _build_weighted_floor_sources(_current_floor_sources_base, _shared_floor_sources, SHARED_FLOOR_WEIGHT)
	var base_wall_sources: Array = _wall_sources_by_set.get(ts_choice, [])
	if base_wall_sources.is_empty() and _wall_sources_by_set.has(TILESET_A):
		base_wall_sources = _wall_sources_by_set[TILESET_A]
	_current_wall_sources = base_wall_sources.duplicate()

func _build_weighted_floor_sources(base_sources: Array, shared_sources: Array, shared_ratio: float) -> Array[int]:
	if shared_sources.is_empty():
		return base_sources.duplicate()
	if base_sources.is_empty():
		return shared_sources.duplicate()
	var total_buckets := 100
	var shared_bucket_count := clampi(int(round(float(total_buckets) * shared_ratio)), 1, total_buckets - 1)
	var base_bucket_count := total_buckets - shared_bucket_count
	var weighted: Array[int] = []
	for i in range(base_bucket_count):
		weighted.append(base_sources[i % base_sources.size()])
	for j in range(shared_bucket_count):
		weighted.append(shared_sources[j % shared_sources.size()])
	return weighted

func _build_maps(grid_size: Vector2i) -> void:
	_set_current_tileset_for_level(_level)
	_level_builder.build_test_map(
		floor_map,
		walls_map,
		grid_size,
		_current_floor_sources,
		_current_wall_sources,
		TILE_FLOOR,
		TILE_WALL,
		FLOOR_ALPHA_MIN,
		FLOOR_ALPHA_MAX
	)

func _place_random_entities(grid_size: Vector2i) -> void:
	var player_cell := Grid.world_to_cell(player.global_position)
	var is_free := Callable(self, "_is_free")
	var has_free_neighbor := Callable(self, "_has_free_neighbor")
	_enforce_melee_first_level_only()
	_clear_enemies()
	_clear_mice()
	_clear_runes()
	_clear_armor_items()
	_clear_bones()
	_clear_debug_items()
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
	# Place ranged weapons
	if _level == _wand_level and not _wand_collected:
		var wand_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell]
		_wand_cell = _level_builder.pick_free_interior_cell(grid_size, wand_exclude, is_free, has_free_neighbor)
		if _wand_node:
			_wand_node.place(_wand_cell)
			_normalize_item_node(_wand_node, WAND_TEX)
			_ensure_ranged_pickups_ready()
			_update_debug_ranged_outlines()
	else:
		_wand_cell = Vector2i(-1, -1)
		if _wand_node:
			_wand_node.visible = false
	if _level == _bow_level and not _bow_collected:
		var bow_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _wand_cell]
		_bow_cell = _level_builder.pick_free_interior_cell(grid_size, bow_exclude, is_free, has_free_neighbor)
		if _bow_node:
			_bow_node.place(_bow_cell)
			_normalize_item_node(_bow_node, BOW_TEX)
			_ensure_ranged_pickups_ready()
		_update_debug_ranged_outlines()
	else:
		_bow_cell = Vector2i(-1, -1)
		if _bow_node:
			_bow_node.visible = false
	# Place potion(s): between 0-2 per level
	var potion_count := _rng.randi_range(0, 2)
	if DEBUG_SPAWN_ALL_ITEMS and _level == 1:
		potion_count = max(1, potion_count)
	if potion_count > 0:
		_potion_cell = _level_builder.pick_free_interior_cell(
			grid_size,
			[player_cell, _key_cell, _sword_cell, _shield_cell, _wand_cell, _bow_cell],
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
		var exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell, _wand_cell, _bow_cell]
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
	# Place cheese (max once per run)
	if _cheese_level == _level and not _cheese_collected and not _cheese_given:
		if _cheese_node == null:
			_cheese_node = _make_item_node("Cheese", CHEESE_TEX)
			add_child(_cheese_node)
		var cheese_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell, _potion2_cell, _wand_cell, _bow_cell]
		_cheese_cell = _level_builder.pick_free_interior_cell(grid_size, cheese_exclude, is_free, has_free_neighbor)
		_cheese_node.place(_cheese_cell)
		_normalize_item_node(_cheese_node, CHEESE_TEX)
		_cheese_node.visible = true
	else:
		_cheese_cell = Vector2i(-1, -1)
		if _cheese_node:
			_cheese_node.visible = false
	# Place arrows (planned: max 1 per level, min 1/max 3 per game)
	_arrow_cells.clear()
	var arrow_pickups := int(_arrow_plan.get(_level, 0))
	if arrow_pickups > 0:
		_ensure_arrow_nodes(arrow_pickups)
		var arrow_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _wand_cell, _bow_cell]
		if _potion_cell != Vector2i(-1, -1):
			arrow_exclude.append(_potion_cell)
		if _potion2_cell != Vector2i(-1, -1):
			arrow_exclude.append(_potion2_cell)
		if _cheese_cell != Vector2i(-1, -1):
			arrow_exclude.append(_cheese_cell)
		for i_a in range(arrow_pickups):
			var acell := _level_builder.pick_free_interior_cell(grid_size, arrow_exclude, is_free, has_free_neighbor)
			arrow_exclude.append(acell)
			_arrow_cells.append(acell)
			var anode := _arrow_nodes[i_a]
			if anode:
				anode.place(acell)
				anode.visible = true
				anode.collected = false
	else:
		for anode in _arrow_nodes:
			if anode:
				anode.visible = false
				anode.collected = true
	# Place braziers as decor (same count logic as potions)
	_clear_braziers()
	var brazier_count := _rng.randi_range(0, 2)
	if brazier_count > 0:
		var b_exclude: Array[Vector2i] = [
			player_cell,
			_key_cell,
			_sword_cell,
			_shield_cell,
			_wand_cell,
			_bow_cell
		]
		if _potion_cell != Vector2i(-1, -1):
			b_exclude.append(_potion_cell)
		if _potion2_cell != Vector2i(-1, -1):
			b_exclude.append(_potion2_cell)
		if _cheese_cell != Vector2i(-1, -1):
			b_exclude.append(_cheese_cell)
		for ac in _arrow_cells:
			b_exclude.append(ac)
		for i_b in range(brazier_count):
			var b_cell := _level_builder.pick_free_interior_cell(grid_size, b_exclude, is_free, has_free_neighbor)
			b_exclude.append(b_cell)
			_brazier_cells.append(b_cell)
			_spawn_brazier(b_cell)
	else:
		_brazier_cells.clear()
	# Place special (codex/crown/ring) avoiding potions
	var special_type := _current_level_special_type()
	var special_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _wand_cell, _bow_cell]
	if _potion_cell != Vector2i(-1, -1):
		special_exclude.append(_potion_cell)
	if _potion2_cell != Vector2i(-1, -1):
		special_exclude.append(_potion2_cell)
	for ac2 in _arrow_cells:
		special_exclude.append(ac2)
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
	var base_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _wand_cell, _bow_cell]
	if _potion_cell != Vector2i(-1, -1):
		base_exclude.append(_potion_cell)
	if _potion2_cell != Vector2i(-1, -1):
		base_exclude.append(_potion2_cell)
	base_exclude.append_array(_rune1_cells)
	base_exclude.append_array(_rune2_cells)
	base_exclude.append_array(_rune3_cells)
	base_exclude.append_array(_rune4_cells)
	for ac3 in _arrow_cells:
		base_exclude.append(ac3)
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
	var rune4_to_place: int = int(_rune4_plan.get(_level, 0))
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
	for i_r4 in range(rune4_to_place):
		var cell4 := _level_builder.pick_free_interior_cell(grid_size, base_exclude, is_free, has_free_neighbor)
		base_exclude.append(cell4)
		_rune4_cells.append(cell4)
		var node4: Item = _make_item_node("Rune4%d" % i_r4, RUNE4_TEX)
		add_child(node4)
		node4.place(cell4)
		_rune4_nodes.append(node4)
	# Torch placement: only once per run
	if not _torch_collected and _level == _torch_target_level:
		var exclude2: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _wand_cell, _bow_cell]
		if _potion_cell != Vector2i(-1, -1):
			exclude2.append(_potion_cell)
		if _potion2_cell != Vector2i(-1, -1):
			exclude2.append(_potion2_cell)
		for ac4 in _arrow_cells:
			exclude2.append(ac4)
		for c1 in _rune1_cells:
			exclude2.append(c1)
		for c2 in _rune2_cells:
			exclude2.append(c2)
		for a_cell in _armor_cells:
			exclude2.append(a_cell)
		for c3 in _rune3_cells:
			exclude2.append(c3)
		for c4 in _rune4_cells:
			exclude2.append(c4)
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
	# Spawn imps at about the same rate as minotaurs (ranged threat)
	var imp_count: int = mino_count
	for i_imp in range(imp_count):
		var i_exclude: Array[Vector2i] = [player_cell, _key_cell, _sword_cell, _shield_cell, _potion_cell, _codex_cell]
		i_exclude.append_array(zcells)
		var icell := _level_builder.pick_free_interior_cell(grid_size, i_exclude, is_free, has_free_neighbor)
		_spawn_imp_at(icell)
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
			_ring_cell,
			_cheese_cell
		]
		t_exclude.append_array(_rune1_cells)
		t_exclude.append_array(_rune2_cells)
		t_exclude.append_array(_armor_cells)
		t_exclude.append_array(_rune3_cells)
		t_exclude.append_array(_rune4_cells)
		if not zcells.is_empty():
			t_exclude.append(zcells[0])
		var tcell := _level_builder.pick_free_interior_cell(grid_size, t_exclude, is_free, has_free_neighbor)
		_spawn_trap_at(tcell)
	_spawn_debug_items_level1(grid_size)

func _restart_game() -> void:
	# Fade to black
	if _is_transitioning:
		return
	_is_transitioning = true
	_show_loading("Loading...")
	await get_tree().process_frame
	await _fade_to(level_fade_alpha, level_fade_out_time)
	_hide_loading()
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
	_wand_collected = false
	_bow_collected = false
	_armor_current = 0
	_codex_collected = false
	_crown_collected = false
	_codex_collected = false
	_ring_collected = false
	_rune1_collected_count = 0
	_rune2_collected_count = 0
	_rune3_collected_count = 0
	_rune4_collected_count = 0
	_ring_cell = Vector2i.ZERO
	_rune1_cells.clear()
	_rune2_cells.clear()
	_rune3_cells.clear()
	_rune4_cells.clear()
	_armor_cells.clear()
	_wand_cell = Vector2i.ZERO
	_bow_cell = Vector2i.ZERO
	_arrow_cells.clear()
	_player_level = 0
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
	if DEBUG_SPAWN_ALL_ITEMS:
		_torch_target_level = 1
	_ring_collected = false
	_ring_cell = Vector2i.ZERO
	_rune1_cells.clear()
	_rune2_cells.clear()
	_rune3_cells.clear()
	_rune4_cells.clear()
	_armor_cells.clear()
	_last_trap_cell = Vector2i(-1, -1)
	_web_stuck_turns = 0
	_arrow_count = 0
	_rune4_dash_cooldown = 0
	_active_ranged_weapon = RANGED_NONE
	for anode in _arrow_nodes:
		if anode:
			anode.visible = false
			anode.collected = true
	_brazier_cells.clear()
	_clear_braziers()
	_clear_action_log()
	_clear_corpses()
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

func _set_icon_visible(icon: Control, should_show: bool) -> void:
	if icon == null:
		return
	icon.visible = true
	icon.modulate.a = (1.0 if should_show else 0.0)

func _init_action_log_labels() -> void:
	_hud_action_lines.clear()
	if _action_log_box == null:
		return
	for child in _action_log_box.get_children():
		if child is Label:
			var lbl := child as Label
			_hud_action_lines.append(lbl)
			lbl.add_theme_font_override("font", ACTION_LOG_FONT)
			lbl.add_theme_font_size_override("font_size", ACTION_LOG_FONT_SIZE)
	_refresh_action_log()

func _refresh_action_log() -> void:
	if _hud_action_lines.is_empty():
		return
	for i in range(_hud_action_lines.size()):
		var line: Label = _hud_action_lines[i]
		if line == null:
			continue
		var text := ""
		if i < _action_log.size():
			text = _action_log[i]
		line.text = text
		var alpha: float = ACTION_LOG_OPACITIES[i] if i < ACTION_LOG_OPACITIES.size() else ACTION_LOG_OPACITIES.back()
		line.modulate = Color(1, 1, 1, alpha if text != "" else 0.0)

func _log_action(text: String) -> void:
	if text.is_empty():
		return
	_action_log.insert(0, text)
	while _action_log.size() > ACTION_LOG_MAX:
		_action_log.pop_back()
	_refresh_action_log()

func _clear_action_log() -> void:
	_action_log.clear()
	_refresh_action_log()

func _apply_ranged_highlight() -> void:
	if _hud_bow_panel:
		_hud_bow_panel.add_theme_stylebox_override(
			"panel",
			(_ranged_highlight if _active_ranged_weapon == RANGED_BOW else _ranged_inactive)
		)
	if _hud_wand_panel:
		_hud_wand_panel.add_theme_stylebox_override(
			"panel",
			(_ranged_highlight if _active_ranged_weapon == RANGED_WAND else _ranged_inactive)
		)

func _clear_debug_outline(line) -> void:
	if line and is_instance_valid(line):
		line.queue_free()

func _clear_debug_outlines() -> void:
	_clear_debug_outline(_debug_bow_outline)
	_clear_debug_outline(_debug_wand_outline)
	_debug_bow_outline = null
	_debug_wand_outline = null

func _draw_debug_outline(cell: Vector2i, color: Color) -> Line2D:
	var line := Line2D.new()
	line.width = 1
	line.default_color = color
	line.z_index = 200
	line.z_as_relative = false
	var size := Vector2(float(Grid.CELL_SIZE), float(Grid.CELL_SIZE))
	line.add_point(Vector2.ZERO)
	line.add_point(Vector2(size.x, 0))
	line.add_point(Vector2(size.x, size.y))
	line.add_point(Vector2(0, size.y))
	line.add_point(Vector2.ZERO)
	line.position = Grid.cell_to_world(cell)
	_decor.add_child(line)
	return line

func _update_debug_ranged_outlines() -> void:
	if not DEBUG_FORCE_RANGED:
		_clear_debug_outline(_debug_bow_outline)
		_clear_debug_outline(_debug_wand_outline)
		_debug_bow_outline = null
		_debug_wand_outline = null
		return
	_clear_debug_outline(_debug_bow_outline)
	_clear_debug_outline(_debug_wand_outline)
	if not _bow_collected and _bow_cell != Vector2i(-1, -1):
		_debug_bow_outline = _draw_debug_outline(_bow_cell, Color(0.2, 0.4, 1, 1))
	if not _wand_collected and _wand_cell != Vector2i(-1, -1):
		_debug_wand_outline = _draw_debug_outline(_wand_cell, Color(1, 0.9, 0.2, 1))

func _ensure_ranged_pickups_ready() -> void:
	if _wand_node:
		_wand_node.collected = false if DEBUG_FORCE_RANGED else _wand_node.collected
		if _wand_node.visible:
			_set_sprite_tex(_wand_node, WAND_TEX)
	if _bow_node:
		_bow_node.collected = false if DEBUG_FORCE_RANGED else _bow_node.collected
		if _bow_node.visible:
			_set_sprite_tex(_bow_node, BOW_TEX)

func _spawn_debug_items_level1(grid_size: Vector2i) -> void:
	if not DEBUG_SPAWN_ALL_ITEMS or _level != 1:
		return
	_clear_debug_items()
	var player_cell := Grid.world_to_cell(player.global_position)
	var exclude: Array[Vector2i] = [
		player_cell,
		_key_cell,
		_sword_cell,
		_shield_cell,
		_potion_cell,
		_potion2_cell,
		_codex_cell,
		_ring_cell,
		_torch_cell,
		_wand_cell,
		_bow_cell
	]
	exclude.append_array(_arrow_cells)
	exclude.append_array(_rune1_cells)
	exclude.append_array(_rune2_cells)
	exclude.append_array(_rune3_cells)
	exclude.append_array(_rune4_cells)
	exclude.append_array(_armor_cells)
	var pick_cell := func() -> Vector2i:
		var c := _level_builder.pick_free_interior_cell(
			grid_size,
			exclude,
			Callable(self, "_is_free"),
			Callable(self, "_has_free_neighbor")
		)
		exclude.append(c)
		return c
	_torch_target_level = 1
	if _torch_node and not _torch_collected:
		_torch_cell = pick_cell.call()
		_torch_node.place(_torch_cell)
	if _potion2_node:
		_potion2_collected = false
		_potion2_cell = pick_cell.call()
		_potion2_node.place(_potion2_cell)
	if _wand_node and not _wand_collected:
		_wand_level = 1
		_wand_cell = pick_cell.call()
		_wand_node.place(_wand_cell)
		_normalize_item_node(_wand_node, WAND_TEX)
	if _bow_node and not _bow_collected:
		_bow_level = 1
		_bow_cell = pick_cell.call()
		_bow_node.place(_bow_cell)
		_normalize_item_node(_bow_node, BOW_TEX)
	if _ring_node and not _ring_collected:
		_ring_cell = pick_cell.call()
		_ring_node.place(_ring_cell)
		_normalize_item_node(_ring_node, RING_TEX)
	if _rune1_nodes.is_empty():
		var c1: Vector2i = pick_cell.call()
		var n1: Item = _make_item_node("DebugRune1", RUNE1_TEX)
		add_child(n1)
		n1.place(c1)
		_rune1_cells.append(c1)
		_rune1_nodes.append(n1)
	if _rune2_nodes.is_empty():
		var c2: Vector2i = pick_cell.call()
		var n2: Item = _make_item_node("DebugRune2", RUNE2_TEX)
		add_child(n2)
		n2.place(c2)
		_rune2_cells.append(c2)
		_rune2_nodes.append(n2)
	if _rune3_nodes.is_empty():
		var c3: Vector2i = pick_cell.call()
		var n3: Item = _make_item_node("DebugRune3", RUNE3_TEX)
		add_child(n3)
		n3.place(c3)
		_rune3_cells.append(c3)
		_rune3_nodes.append(n3)
	if _rune4_nodes.is_empty():
		var c4: Vector2i = pick_cell.call()
		var n4: Item = _make_item_node("DebugRune4", RUNE4_TEX)
		add_child(n4)
		n4.place(c4)
		_rune4_cells.append(c4)
		_rune4_nodes.append(n4)
	if _armor_nodes.is_empty():
		var ac: Vector2i = pick_cell.call()
		var an: Item = _make_item_node("DebugArmor", ARMOR_TEX)
		add_child(an)
		an.place(ac)
		_armor_cells.append(ac)
		_armor_nodes.append(an)
	if _arrow_cells.is_empty():
		var arrow_cell: Vector2i = pick_cell.call()
		_arrow_cells.append(arrow_cell)
		_ensure_arrow_nodes(1)
		var anode := _arrow_nodes[0]
		if anode:
			anode.collected = false
			anode.place(arrow_cell)
	if not _codex_collected:
		_add_debug_item("DebugCodex", CODEX_TEX, pick_cell.call())
	if not _crown_collected:
		_add_debug_item("DebugCrown", CROWN_TEX, pick_cell.call())
	if not _ring_collected:
		_add_debug_item("DebugRing", RING_TEX, pick_cell.call())

func _update_fade_rect() -> void:
	if _fade == null:
		return
	_fade.position = Vector2.ZERO
	_fade.call_deferred("set_size", get_viewport_rect().size)

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
		var p_base: int = _rng.randi_range(1, 20)
		var e_base: int = _rng.randi_range(1, 20)
		var p_bonus: int = _attack_bonus()
		var e_penalty: int = _defense_bonus()
		var player_roll: int = p_base + p_bonus
		var enemy_roll: int = e_base - e_penalty
		print("Player rolls ", player_roll, " (", p_base, " + ", p_bonus, "), ", enemy.enemy_type, " rolls ", enemy_roll, " (", e_base, " - ", e_penalty, ")")
		_log_action("Roll: Player %d (%d + %d) vs %s %d (%d - %d)" % [player_roll, p_base, p_bonus, String(enemy.enemy_type), enemy_roll, e_base, e_penalty])
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
			_set_death_cause_enemy(enemy.enemy_type)
			_handle_player_hit()
		break

func _handle_enemy_death(enemy: Enemy) -> void:
	if enemy == null:
		return
	enemy.visible = false
	_remove_enemy_from_map(enemy)
	_leave_enemy_corpse(enemy)
	_play_sfx(SFX_HURT3)
	_add_score(_enemy_score_value(enemy))

func _enemy_score_value(enemy: Enemy) -> int:
	if enemy == null:
		return 0
	if enemy.enemy_type == &"minotaur" or enemy.enemy_type == &"imp":
		return 2
	return 1

func _set_death_cause_enemy(enemy_type: StringName) -> void:
	if enemy_type != StringName():
		_last_death_cause = enemy_type

func _add_score(amount: int) -> void:
	_score += amount
	_maybe_level_up()
	_update_hud_icons()

func _maybe_level_up() -> void:
	while _score >= _next_level_score:
		_player_level += 1
		_apply_level_up_reward()
		_next_level_score += LEVEL_UP_SCORE_STEP

func _apply_level_up_reward() -> void:
	var roll := _rng.randf()
	var log_msg := "Level up:"
	if roll < 0.4:
		_attack_level_bonus += 1
		print("LEVEL UP: +1 ATK (bonus=", _attack_level_bonus, ")")
		log_msg += " +1 ATK"
	elif roll < 0.8:
		_defense_level_bonus += 1
		print("LEVEL UP: +1 DEF (bonus=", _defense_level_bonus, ")")
		log_msg += " +1 DEF"
	else:
		if _hp_max < HP_MAX_LIMIT:
			_hp_max = min(HP_MAX_LIMIT, _hp_max + 1)
			print("LEVEL UP: +1 MAX HP (max=", _hp_max, ")")
			log_msg += " +1 MAX HP"
		else:
			_attack_level_bonus += 1
			_defense_level_bonus += 1
			print("LEVEL UP: +1 ATK and +1 DEF (max HP already at limit)")
			log_msg += " +1 ATK +1 DEF"
	if _hp_current < _hp_max:
		_hp_current = min(_hp_max, _hp_current + 1)
	_update_hud_hearts()
	_update_hud_icons()
	_play_sfx(SFX_LEVEL_UP)
	_blink_node_colored(player, Color(0.776, 0.624, 0.153))
	_log_action(log_msg)

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
		elif enemy.enemy_type == &"imp":
			corpse_tex = IMP_DEAD_TEX
	if corpse_tex == null:
		return
	var s := Sprite2D.new()
	s.texture = corpse_tex
	s.centered = false
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	s.global_position = Grid.cell_to_world(enemy.grid_cell)
	s.z_index = 1
	_decor.add_child(s)
	_corpse_nodes.append(s)

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
		if _last_death_cause == StringName():
			_last_death_cause = &"enemy"
		if _player_sprite and PLAYER_TEX_DEAD:
			_player_sprite.texture = PLAYER_TEX_DEAD
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

func _has_rune4() -> bool:
	return _rune4_collected_count > 0

func _attack_bonus() -> int:
	var bonus := 0
	if _sword_collected:
		bonus += 1
	bonus += _rune1_collected_count
	bonus += _attack_level_bonus
	return bonus

func _defense_bonus() -> int:
	var bonus := 0
	if _shield_collected:
		bonus += 1
	bonus += _rune2_collected_count
	bonus += _defense_level_bonus
	return bonus

func _debug_check_special_pickups(cp: Vector2i) -> void:
	if not DEBUG_SPAWN_ALL_ITEMS:
		return
	for item in _debug_items:
		if item == null or item.collected:
			continue
		if cp != item.grid_cell:
			continue
		match String(item.item_type):
			"DebugCodex":
				_codex_collected = true
				_codex_icon_persistent = true
			"DebugCrown":
				_crown_collected = true
				_crown_icon_persistent = true
			"DebugRing":
				_ring_collected = true
		item.collect()
		_add_score(1)
		_update_door_texture()
		_play_sfx(SFX_PICKUP2)
		_blink_node(player)

func _debug_cell_blocked(cell: Vector2i) -> bool:
	if not DEBUG_SPAWN_ALL_ITEMS:
		return false
	for item in _debug_items:
		if item != null and not item.collected and item.grid_cell == cell:
			return true
	return false

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
	if _cheese_level == _level and _cheese_node == null:
		_cheese_node = _make_item_node("Cheese", CHEESE_TEX)
		add_child(_cheese_node)
	if _cheese_node:
		if _level == _cheese_level and not _cheese_collected and not _cheese_given and _cheese_cell != Vector2i(-1, -1):
			_cheese_node.place(_cheese_cell)
			_normalize_item_node(_cheese_node, CHEESE_TEX)
			_cheese_node.visible = true
		else:
			_cheese_node.visible = false
	if _wand_node:
		if _level == _wand_level and not _wand_collected and _wand_cell != Vector2i(-1, -1):
			_wand_node.place(_wand_cell)
			_normalize_item_node(_wand_node, WAND_TEX)
			_ensure_ranged_pickups_ready()
			_update_debug_ranged_outlines()
		else:
			_wand_node.visible = false
	if _bow_node:
		if _level == _bow_level and not _bow_collected and _bow_cell != Vector2i(-1, -1):
			_bow_node.place(_bow_cell)
			_normalize_item_node(_bow_node, BOW_TEX)
			_ensure_ranged_pickups_ready()
			_update_debug_ranged_outlines()
		else:
			_bow_node.visible = false
	_ensure_arrow_nodes(_arrow_cells.size())
	for i in range(_arrow_nodes.size()):
		var anode := _arrow_nodes[i]
		if anode == null:
			continue
		if i < _arrow_cells.size():
			anode.place(_arrow_cells[i])
			anode.visible = true
			anode.collected = false
		else:
			anode.visible = false
			anode.collected = true
	if _door_node:
		_door_node.global_position = Grid.cell_to_world(_door_cell)
	if _entrance_door_node:
		_entrance_door_node.global_position = Grid.cell_to_world(_entrance_cell)
	_apply_final_door_fx()

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
	state["carried_potion"] = _carried_potion
	state["wand_cell"] = _wand_cell
	state["wand_collected"] = _wand_collected
	state["bow_cell"] = _bow_cell
	state["bow_collected"] = _bow_collected
	state["arrow_cells"] = _arrow_cells.duplicate()
	state["braziers"] = _brazier_cells.duplicate()
	state["armor_cells"] = []
	state["codex_cell"] = _codex_cell
	state["codex_collected"] = _codex_collected
	state["ring_cell"] = _ring_cell
	state["ring_collected"] = _ring_collected
	state["crown_collected"] = _crown_collected
	state["torch_cell"] = _torch_cell
	state["torch_collected"] = _torch_collected
	state["cheese_cell"] = _cheese_cell
	state["cheese_collected"] = _cheese_collected
	state["cheese_given"] = _cheese_given
	state["rune1_cells"] = []
	state["rune2_cells"] = []
	state["rune3_cells"] = []
	state["rune4_cells"] = []
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
	for r4 in _rune4_nodes:
		if r4 != null and not r4.collected:
			state["rune4_cells"].append(r4.grid_cell)
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
	for imp in _imps:
		enemies.append({
			"type": "imp",
			"cell": imp.grid_cell,
			"alive": imp.alive,
			"hp": imp.hp,
			"arrows": imp.arrows,
			"cooldown": imp.cooldown
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
	_carried_potion = state.get("carried_potion", _carried_potion)
	_wand_cell = state.get("wand_cell", _wand_cell)
	_wand_collected = state.get("wand_collected", _wand_collected)
	_bow_cell = state.get("bow_cell", _bow_cell)
	_bow_collected = state.get("bow_collected", _bow_collected)
	_arrow_cells = state.get("arrow_cells", _arrow_cells).duplicate()
	_ensure_active_ranged_valid()
	_brazier_cells = state.get("braziers", [])
	var armor_state: Array = state.get("armor_cells", [])
	_codex_cell = state.get("codex_cell", _codex_cell)
	_codex_collected = state.get("codex_collected", _codex_collected)
	_ring_cell = state.get("ring_cell", _ring_cell)
	_ring_collected = state.get("ring_collected", _ring_collected)
	_crown_collected = state.get("crown_collected", _crown_collected)
	_torch_cell = state.get("torch_cell", _torch_cell)
	_torch_collected = state.get("torch_collected", _torch_collected)
	_cheese_cell = state.get("cheese_cell", _cheese_cell)
	_cheese_collected = state.get("cheese_collected", _cheese_collected)
	_cheese_given = state.get("cheese_given", _cheese_given)
	_door_cell = state.get("exit_cell", _door_cell)
	_entrance_cell = state.get("entrance_cell", _entrance_cell)
	_door_is_open = state.get("door_open", false)
	var r1_state: Array = state.get("rune1_cells", [])
	var r2_state: Array = state.get("rune2_cells", [])
	var r3_state: Array = state.get("rune3_cells", [])
	var r4_state: Array = state.get("rune4_cells", [])
	_clear_runes()
	_clear_armor_items()
	_rune1_cells = []
	_rune2_cells = []
	_rune3_cells = []
	_rune4_cells = []
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
	for v4 in r4_state:
		if v4 is Vector2i:
			_rune4_cells.append(v4)
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
	for rc4 in _rune4_cells:
		var n4 := _make_item_node("Rune4Restore", RUNE4_TEX)
		add_child(n4)
		n4.place(rc4)
		_rune4_nodes.append(n4)
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
	_clear_corpses()
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
				_remove_enemy_from_map(_goblins.back())
		elif etype == "zombie":
			var zcell := cell
			_spawn_zombie_at(zcell)
			if not alive:
				_zombies.back().alive = false
				_zombies.back().visible = false
				_remove_enemy_from_map(_zombies.back())
		elif etype == "minotaur":
			var mcell := cell
			_spawn_minotaur_at(mcell)
			_minotaurs.back().hp = e.get("hp", _minotaurs.back().hp)
			if not alive:
				_minotaurs.back().alive = false
				_minotaurs.back().visible = false
				_remove_enemy_from_map(_minotaurs.back())
		elif etype == "imp":
			var icell := cell
			_spawn_imp_at(icell)
			_imps.back().hp = e.get("hp", _imps.back().hp)
			_imps.back().arrows = e.get("arrows", _imps.back().arrows)
			_imps.back().cooldown = e.get("cooldown", _imps.back().cooldown)
			if not alive:
				_imps.back().alive = false
				_imps.back().visible = false
				_remove_enemy_from_map(_imps.back())
		elif etype == "skeleton":
			var skcell := cell
			_spawn_skeleton_at(skcell)
			_skeletons.back().hp = e.get("hp", _skeletons.back().hp)
			if not alive:
				_skeletons.back().alive = false
				_skeletons.back().visible = false
				_remove_enemy_from_map(_skeletons.back())
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
			s.z_index = 1
			_decor.add_child(s)
			_corpse_nodes.append(s)

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
	_show_loading("Loading...")
	await get_tree().process_frame
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
	_wand_collected = false
	_bow_collected = false
	_torch_collected = false
	_cheese_collected = false
	_cheese_given = false
	_ring_collected = false
	_codex_collected = false
	_crown_collected = false
	_armor_current = 0
	_rune1_collected_count = 0
	_rune2_collected_count = 0
	_rune3_collected_count = 0
	_ring_cell = Vector2i.ZERO
	_cheese_cell = Vector2i.ZERO
	_wand_cell = Vector2i.ZERO
	_bow_cell = Vector2i.ZERO
	_arrow_cells.clear()
	_player_level = 0
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
	if DEBUG_SPAWN_ALL_ITEMS:
		_torch_target_level = 1
	_score = 0
	_last_trap_cell = Vector2i(-1, -1)
	_web_stuck_turns = 0
	_arrow_count = 0
	_active_ranged_weapon = RANGED_NONE
	_brazier_cells.clear()
	_clear_braziers()
	_clear_debug_items()
	_clear_action_log()
	_update_hud_icons()
	_clear_enemies()
	_clear_runes()
	_clear_armor_items()
	for anode in _arrow_nodes:
		if anode:
			anode.visible = false
			anode.collected = true
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
	_hide_loading()

func _show_title(visible: bool) -> void:
	_title_layer.visible = visible
	_over_layer.visible = false
	_hide_loading()
	if visible and _title_bg and not _title_textures.is_empty():
		var tex: Texture2D = _random_texture(_title_textures)
		if tex:
			_title_bg.texture = tex
	_title_label.add_theme_font_size_override("font_size", 64)
	_title_label.offset_top = get_viewport_rect().size.y * 0.5

func _show_game_over(won: bool) -> void:
	var cause_text := _death_cause_text()
	var viewport_size := get_viewport_rect().size
	if _over_bg_win:
		_over_bg_win.visible = won
	if _over_bg_lose:
		_over_bg_lose.visible = not won
	if _over_layer:
		_over_layer.visible = true
	var tex_arr := _win_textures if won else _lose_textures
	var target_rect := _over_bg_win if won else _over_bg_lose
	if target_rect and not tex_arr.is_empty():
		var tex := _random_texture(tex_arr)
		if tex:
			target_rect.texture = tex
	if _over_result:
		_over_result.visible = true
		_over_result.text = "Thou hast Triumphed!" if won else "Thou hast Perished!"
		_over_result.add_theme_font_size_override("font_size", 64)
		_over_result.modulate.a = 0.0
	if _over_label:
		_over_label.visible = true
		_over_label.add_theme_font_size_override("font_size", 96)
		_over_label.text = "Press Enter to restart"
		_over_label.modulate.a = 0.0
	if _over_score:
		_over_score.add_theme_font_size_override("font_size", 80)
		_over_score.text = "EXP: %d" % _score
		_over_score.modulate.a = 0.0
	if _over_cause:
		_over_cause.visible = not won
		_over_cause.add_theme_font_size_override("font_size", 80)
		_over_cause.text = cause_text
		_over_cause.modulate.a = 0.0
	if _over_bg_win and won:
		_over_bg_win.modulate.a = 0.0
	if _over_bg_lose and not won:
		_over_bg_lose.modulate.a = 0.0
	_position_game_over_labels(viewport_size)
	_hide_loading()
	await _fade_to(level_fade_alpha, level_fade_out_time)
	var tw := get_tree().create_tween()
	tw.set_parallel(true)
	if _fade:
		tw.tween_property(_fade, "modulate:a", 0.0, level_fade_out_time)
	if _over_bg_win and won:
		tw.tween_property(_over_bg_win, "modulate:a", 1.0, level_fade_out_time)
	if _over_bg_lose and not won:
		tw.tween_property(_over_bg_lose, "modulate:a", 1.0, level_fade_out_time)
	for node in [_over_result, _over_label, _over_score, _over_cause]:
		if node and node.visible:
			tw.tween_property(node, "modulate:a", 1.0, level_fade_out_time)
	await tw.finished
	_update_title_build_label()

func _on_viewport_resized() -> void:
	_resize_fullscreen_art()

func _resize_fullscreen_art() -> void:
	var viewport_size := get_viewport_rect().size
	for rect in [_title_bg, _over_bg_win, _over_bg_lose]:
		if rect:
			rect.call_deferred("set_size", viewport_size)
			rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			rect.expand = true
	_title_label.offset_top = viewport_size.y * 0.5
	_position_game_over_labels(viewport_size)
	_update_title_build_label()

func _death_cause_text() -> String:
	if _last_death_cause == &"trap":
		return "Died of tetanus on Floor %d" % _level
	if _last_death_cause != StringName():
		return "Defeated at the hands of a %s on Floor %d" % [String(_last_death_cause), _level]
	if _enemy_map.is_empty():
		return "Defeated at the hands of a monster on Floor %d" % _level
	for e in _enemy_map.values():
		if e is Enemy and e.alive:
			return "Defeated at the hands of a %s on Floor %d" % [String(e.enemy_type), _level]
	return "Defeated at the hands of a monster on Floor %d" % _level

func _random_texture(options: Array[Texture2D]) -> Texture2D:
	if options.is_empty():
		return null
	var available: Array[Texture2D] = []
	for tex in options:
		if tex != null:
			available.append(tex)
	if available.is_empty():
		return null
	var pick := _rng.randi_range(0, available.size() - 1)
	return available[pick]

func _position_game_over_labels(viewport_size: Vector2) -> void:
	# Place result near top, then score, then restart prompt.
	var result_y := viewport_size.y * 0.22
	var cause_y := viewport_size.y * 0.33
	var score_y := viewport_size.y * 0.42
	var prompt_y := viewport_size.y * 0.52
	var result_h := 80.0
	var cause_h := 60.0
	var score_h := 60.0
	var prompt_h := 60.0
	if _over_result:
		_over_result.offset_top = result_y
		_over_result.offset_bottom = result_y + result_h - viewport_size.y
	if _over_cause:
		_over_cause.offset_top = cause_y
		_over_cause.offset_bottom = cause_y + cause_h - viewport_size.y
	if _over_score:
		_over_score.offset_top = score_y
		_over_score.offset_bottom = score_y + score_h - viewport_size.y
	if _over_label:
		_over_label.offset_top = prompt_y
		_over_label.offset_bottom = prompt_y + prompt_h - viewport_size.y

func _set_world_visible(visible: bool) -> void:
	floor_map.visible = visible
	walls_map.visible = visible
	player.visible = visible
	if _fov_overlay:
		_fov_overlay.visible = visible
	if _key_node:
		_key_node.visible = visible and _key_on_level and not _key_collected
	if _sword_node:
		_sword_node.visible = visible and not _sword_collected and _level == 1
	if _shield_node:
		_shield_node.visible = visible and not _shield_collected and _level == 1
	if _potion_node:
		_potion_node.visible = visible and not _potion_collected
	if _potion2_node:
		_potion2_node.visible = visible and _level >= 2 and not _potion2_collected
	if _cheese_node:
		_cheese_node.visible = visible and not _cheese_collected and not _cheese_given and _level == _cheese_level
	if _torch_node:
		_torch_node.visible = visible and not _torch_collected and _level == _torch_target_level
	if _ring_node:
		_ring_node.visible = visible and not _ring_collected and _current_level_special_type() == &"ring"
	if _wand_node:
		_wand_node.visible = visible and (_level == _wand_level) and not _wand_collected
		if _wand_node.visible:
			_normalize_item_node(_wand_node, WAND_TEX)
	if _bow_node:
		_bow_node.visible = visible and (_level == _bow_level) and not _bow_collected
		if _bow_node.visible:
			_normalize_item_node(_bow_node, BOW_TEX)
	for anode in _arrow_nodes:
		if anode:
			anode.visible = visible and not anode.collected and _arrow_cells.has(anode.grid_cell)
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
	for imp in _imps:
		imp.visible = visible and imp.alive
	for t in _traps:
		t.visible = visible
	for mouse in _mice:
		mouse.visible = visible and mouse.alive
	_decor.visible = visible
	for ditem in _debug_items:
		if ditem:
			ditem.visible = visible and not ditem.collected
	if _door_node:
		_door_node.visible = visible
	if _entrance_door_node:
		_entrance_door_node.visible = visible and _level > 1
	_apply_final_door_fx()
	_update_hud_icons()

func _try_give_cheese(cell: Vector2i) -> void:
	if not _cheese_collected or _cheese_given:
		return
	var mouse := _mouse_at(cell)
	if mouse == null:
		return
	_cheese_given = true
	_cheese_collected = false
	_attack_level_bonus += 1
	_defense_level_bonus += 1
	_play_sfx(SFX_PICKUP1)
	_update_hud_icons()
	_log_action("The mouse says \"Thank you!\" ( +1 ATK, +1 DEF)")

func _enforce_melee_first_level_only() -> void:
	if _level == 1:
		return
	_sword_cell = Vector2i(-1, -1)
	_shield_cell = Vector2i(-1, -1)
	if _sword_node:
		_sword_node.visible = false
	if _shield_node:
		_shield_node.visible = false

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
	_fov_visible.fill(false)
	_fov_dist.fill(1e9)
	(_fov_overlay as Node).call("set_grid", _grid_size)
	_update_fov()

func _update_fov() -> void:
	if _grid_size == Vector2i.ZERO:
		return
	var total: int = _grid_size.x * _grid_size.y
	if _fov_visible.size() != total:
		_fov_visible.resize(total)
		_fov_dist.resize(total)
	_fov_visible.fill(false)
	_fov_dist.fill(1e9)
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
					var dx: int = p.x - center.x
					var dy: int = p.y - center.y
					var dist: float = sqrt(float(dx * dx + dy * dy))
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
	_register_enemy(node)
	_goblins.append(node)

func _spawn_zombie_at(cell: Vector2i) -> void:
	var node: Zombie = ZOMBIE_SCENE.instantiate() as Zombie
	node.setup(cell, ZOMBIE_TEX_1, ZOMBIE_TEX_2)
	add_child(node)
	_register_enemy(node)
	_zombies.append(node)

func _spawn_minotaur_at(cell: Vector2i) -> void:
	var node: Minotaur = MINOTAUR_SCENE.instantiate() as Minotaur
	node.setup(cell, MINO_TEX_1, MINO_TEX_2)
	add_child(node)
	_register_enemy(node)
	_minotaurs.append(node)

func _spawn_imp_at(cell: Vector2i) -> void:
	var node: Imp = IMP_SCENE.instantiate() as Imp
	node.setup(cell, IMP_TEX, IMP_DEAD_TEX)
	add_child(node)
	_register_enemy(node)
	_imps.append(node)

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
	_register_enemy(node)
	_skeletons.append(node)
	_log_action("AHHHHH!!!!")

func _clear_enemies() -> void:
	for child: Goblin in _goblins:
		child.queue_free()
	for child: Zombie in _zombies:
		child.queue_free()
	for child: Minotaur in _minotaurs:
		child.queue_free()
	for child: Imp in _imps:
		child.queue_free()
	for child: Skeleton in _skeletons:
		child.queue_free()
	_goblins.clear()
	_zombies.clear()
	_minotaurs.clear()
	_imps.clear()
	_skeletons.clear()
	_enemy_map.clear()
	_clear_mice()
	_clear_traps()
	_clear_corpses()

func _clear_mice() -> void:
	for m in _mice:
		m.queue_free()
	_mice.clear()

func _clear_traps() -> void:
	for t in _traps:
		t.queue_free()
	_traps.clear()

func _clear_corpses() -> void:
	for c in _corpse_nodes:
		if c:
			c.queue_free()
	_corpse_nodes.clear()
	if _decor == null:
		return
	for child in _decor.get_children():
		if child is Sprite2D:
			var spr := child as Sprite2D
			if spr.texture == DEAD_GOBLIN_TEX or spr.texture == ZOMBIE_TEX_2 or spr.texture == MINO_TEX_2 or spr.texture == SKELETON_TEX_2 or BONE_TEXTURES.has(spr.texture):
				if not _corpse_nodes.has(spr):
					spr.queue_free()

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
	for r in _rune4_nodes:
		r.queue_free()
	_rune1_nodes.clear()
	_rune2_nodes.clear()
	_rune3_nodes.clear()
	_rune4_nodes.clear()
	_rune1_cells.clear()
	_rune2_cells.clear()
	_rune3_cells.clear()
	_rune4_cells.clear()

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
	if _cheese_node:
		_cheese_node.collected = _cheese_collected
		_cheese_node.visible = (_level == _cheese_level) and not _cheese_collected and not _cheese_given and _cheese_cell != Vector2i(-1, -1)
	if _codex_node:
		var st := _current_level_special_type()
		var needs_special := st == &"codex" or st == &"crown"
		var special_uncollected := needs_special and not _level_special_collected()
		_codex_node.collected = not special_uncollected
		_codex_node.visible = special_uncollected
	if _torch_node:
		_torch_node.collected = _torch_collected
		_torch_node.visible = (_level == _torch_target_level) and not _torch_collected
	if _wand_node:
		_wand_node.collected = _wand_collected
		_wand_node.visible = (_level == _wand_level) and not _wand_collected
		if _wand_node.visible:
			_wand_node.collected = false
			_set_sprite_tex(_wand_node, WAND_TEX)
	if _bow_node:
		_bow_node.collected = _bow_collected
		_bow_node.visible = (_level == _bow_level) and not _bow_collected
		if _bow_node.visible:
			_bow_node.collected = false
			_set_sprite_tex(_bow_node, BOW_TEX)
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
	for r4 in _rune4_nodes:
		if r4:
			r4.collected = r4.collected
			r4.visible = not r4.collected
	if _ring_node:
		_ring_node.collected = _ring_collected
		_ring_node.visible = _current_level_special_type() == &"ring" and not _ring_collected
	for ditem in _debug_items:
		if ditem:
			ditem.visible = not ditem.collected
	for anode in _arrow_nodes:
		if anode:
			anode.collected = anode.collected
			anode.visible = not anode.collected and _arrow_cells.has(anode.grid_cell)
	if _hud_icon_potion:
		_set_icon_visible(_hud_icon_potion, _carried_potion)

func _clear_bones() -> void:
	for bone in _bone_cells.values():
		if bone:
			bone.queue_free()
	_bone_cells.clear()
	_bone_spawn_outcomes.clear()
	_clear_spiderwebs()
	_clear_corpses()

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
			if c == player_cell or c == _key_cell or c == _sword_cell or c == _shield_cell or c == _potion_cell or c == _codex_cell or c == _ring_cell or _rune1_cells.has(c) or _rune2_cells.has(c) or _rune3_cells.has(c) or _rune4_cells.has(c) or _armor_cells.has(c) or _debug_cell_blocked(c):
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
				if c == player_cell or c == _key_cell or c == _sword_cell or c == _shield_cell or c == _potion_cell or c == _potion2_cell or c == _codex_cell or c == _ring_cell or _rune1_cells.has(c) or _rune2_cells.has(c) or _rune3_cells.has(c) or _rune4_cells.has(c) or _armor_cells.has(c):
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
	_apply_final_door_fx()
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
	_apply_final_door_fx()
	print("[DEBUG] Door texture update: level=", _level, " key_on_level=", _key_on_level, " key_collected=", _key_collected, " open=", open, " door_cell=", _door_cell)

func _stop_final_door_fx() -> void:
	if _door_pulse_tween:
		_door_pulse_tween.kill()
		_door_pulse_tween = null
	if _door_sprite:
		_door_sprite.scale = Vector2.ONE
	if _door_glow:
		_door_glow.visible = false

func _apply_final_door_fx() -> void:
	if _door_sprite == null or _door_node == null:
		return
	var is_final := (_level >= _max_level)
	if not is_final:
		_stop_final_door_fx()
		return
	if _door_glow == null:
		_door_glow = PointLight2D.new()
		_door_glow.energy = 0.9
		_door_glow.texture_scale = 0.35
		_door_glow.color = Color(1, 0.85, 0.3, 0.8)
		_door_glow.shadow_enabled = false
		_door_node.add_child(_door_glow)
		_door_glow.position = Vector2(6, 6)
	_door_glow.visible = true
	_stop_final_door_fx()
	_door_pulse_tween = get_tree().create_tween()
	_door_pulse_tween.set_loops()
	var up_scale := Vector2(1.0 + FINAL_DOOR_PULSE_SCALE, 1.0 + FINAL_DOOR_PULSE_SCALE)
	_door_pulse_tween.tween_property(_door_sprite, "scale", up_scale, FINAL_DOOR_PULSE_TIME).set_ease(Tween.EASE_IN_OUT)
	_door_pulse_tween.tween_property(_door_sprite, "scale", Vector2.ONE, FINAL_DOOR_PULSE_TIME).set_ease(Tween.EASE_IN_OUT)

func _travel_to_level(target_level: int, entering_forward: bool) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_show_loading("Loading...")
	await get_tree().process_frame
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
	_clear_corpses()
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
		_enforce_melee_first_level_only()
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
		_hud_level.text = "FLR: %d" % _level
	_log_action("Traveled to Floor %d" % _level)
	_update_fov()
	_set_world_visible(true)
	print("[DEBUG] Travel complete -> level ", _level, " key_on_level=", _key_on_level, " key_collected=", _key_collected, " door_cell=", _door_cell, " entrance_cell=", _entrance_cell)
	await _fade_to(0.0, level_fade_in_time)
	if player.has_method("set_control_enabled"):
		player.set_control_enabled(true)
	_is_transitioning = false
	_exit_rearm = false
	_hide_loading()

func _load_next_level() -> void:
	_travel_to_level(_level + 1, true)

func _update_player_sprite_appearance() -> void:
	if _player_sprite == null:
		return
	_player_sprite.z_index = 5
	var both := _sword_collected and _shield_collected
	var tex: Texture2D = null
	if both:
		tex = PLAYER_TEX_4
	elif _sword_collected:
		tex = PLAYER_TEX_3
	elif _shield_collected:
		tex = PLAYER_TEX_2
	elif _active_ranged_weapon == RANGED_WAND and _wand_collected and PLAYER_TEX_WAND:
		tex = PLAYER_TEX_WAND
	elif _active_ranged_weapon == RANGED_BOW and _bow_collected and PLAYER_TEX_BOW:
		tex = PLAYER_TEX_BOW
	elif _wand_collected and PLAYER_TEX_WAND:
		tex = PLAYER_TEX_WAND
	elif _bow_collected and PLAYER_TEX_BOW:
		tex = PLAYER_TEX_BOW
	elif _torch_collected and PLAYER_TEX_TORCH:
		tex = PLAYER_TEX_TORCH
	else:
		tex = PLAYER_TEX_1
	_player_sprite.texture = tex

func _update_hud_icons() -> void:
	# Icons appear only during gameplay and when items collected
	var show := (_state == STATE_PLAYING)
	if _hud_level:
		_hud_level.visible = show
		_hud_level.text = "FLR: %d" % _level
	if _hud_hearts:
		_hud_hearts.visible = show
	if _action_log_box:
		_action_log_box.visible = show
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
	var show_rune4 := show and _has_rune4()
	_set_icon_visible(_hud_icon_rune4, show_rune4)
	_set_icon_visible(_hud_icon_torch, show and _torch_collected)
	if _hud_icon_ring and RING_TEX:
		_hud_icon_ring.texture = RING_TEX
	_set_icon_visible(_hud_icon_ring, show and _ring_collected)
	if _hud_icon_potion and POTION_TEX:
		_hud_icon_potion.texture = POTION_TEX
	_set_icon_visible(_hud_icon_potion, show and _carried_potion)
	if _hud_icon_cheese and CHEESE_TEX:
		_hud_icon_cheese.texture = CHEESE_TEX
	_set_icon_visible(_hud_icon_cheese, show and _cheese_collected and not _cheese_given)
	if _hud_atk_label:
		_hud_atk_label.visible = show
		_hud_atk_label.text = "ATK: %d" % _attack_bonus()
	if _hud_def_label:
		_hud_def_label.visible = show
		_hud_def_label.text = "DEF: %d" % _defense_bonus()
	if _hud_score:
		_hud_score.visible = show
		_hud_score.text = "EXP: %d" % _score
	if _hud_player_level:
		_hud_player_level.visible = show
		_hud_player_level.text = "LVL: %d" % _player_level
	if _hud_armor:
		_hud_armor.visible = show
	if _hud_icon_bow and BOW_TEX:
		_hud_icon_bow.texture = BOW_TEX
	var bow_mod := Color(1, 1, 1, 1)
	if _active_ranged_weapon != RANGED_BOW:
		bow_mod = Color(0.8, 0.8, 0.8, 1)
	if _hud_icon_wand and WAND_TEX:
		_hud_icon_wand.texture = WAND_TEX
		var wand_mod := Color(1, 1, 1, 1)
		if _active_ranged_weapon != RANGED_WAND:
			wand_mod = Color(0.8, 0.8, 0.8, 1)
		_hud_icon_wand.modulate = wand_mod
	if _hud_icon_rune4 and RUNE4_TEX:
		_hud_icon_rune4.texture = RUNE4_TEX
		var rune4_mod := Color(1, 1, 1, 1)
		if _rune4_dash_cooldown > 0:
			rune4_mod = Color(0.7, 0.7, 0.7, 1)
		if not show_rune4:
			rune4_mod.a = 0.0
		_hud_icon_rune4.modulate = rune4_mod
	if _hud_icon_bow:
		_hud_icon_bow.modulate = bow_mod
	_set_icon_visible(_hud_icon_bow, show and _bow_collected)
	_set_icon_visible(_hud_icon_wand, show and _wand_collected)
	_apply_ranged_highlight()
	_update_debug_ranged_outlines()
	if _hud_arrow_label:
		_hud_arrow_label.visible = show
		_hud_arrow_label.text = "ARR: %d" % _arrow_count

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
		_log_action("Picked up Potion")

func _pickup_arrows_if_available(cell: Vector2i) -> void:
	var gained := 0
	for anode in _arrow_nodes:
		if anode != null and not anode.collected and cell == anode.grid_cell:
			anode.collect()
			gained += ARROWS_PER_PICKUP
			_arrow_cells.erase(cell)
	if gained > 0:
		_arrow_count += gained
		if _active_ranged_weapon == RANGED_NONE and _bow_collected:
			_active_ranged_weapon = RANGED_BOW
		_play_sfx(SFX_PICKUP1)
		_blink_node(player)
		_update_hud_icons()
		_log_action("Picked up Arrows (+%d)" % gained)

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
	_log_action("Healed 1 HP")

func _ranged_dir_from_input() -> Vector2i:
	# Allow combining held cardinals (e.g., J+I) to produce diagonals
	var dir := Vector2i.ZERO
	var triggered := false
	if Input.is_action_pressed("ranged_dir_left"):
		dir.x -= 1
		triggered = triggered or Input.is_action_just_pressed("ranged_dir_left")
	if Input.is_action_pressed("ranged_dir_right"):
		dir.x += 1
		triggered = triggered or Input.is_action_just_pressed("ranged_dir_right")
	if Input.is_action_pressed("ranged_dir_up"):
		dir.y -= 1
		triggered = triggered or Input.is_action_just_pressed("ranged_dir_up")
	if Input.is_action_pressed("ranged_dir_down"):
		dir.y += 1
		triggered = triggered or Input.is_action_just_pressed("ranged_dir_down")
	if triggered and dir != Vector2i.ZERO:
		return dir
	# Fall back to direct directional actions (e.g., numpad diagonals)
	var mapping: Array = [
		["ranged_dir_up_left", Vector2i(-1, -1)],
		["ranged_dir_up", Vector2i(0, -1)],
		["ranged_dir_up_right", Vector2i(1, -1)],
		["ranged_dir_left", Vector2i(-1, 0)],
		["ranged_dir_right", Vector2i(1, 0)],
		["ranged_dir_down_left", Vector2i(-1, 1)],
		["ranged_dir_down", Vector2i(0, 1)],
		["ranged_dir_down_right", Vector2i(1, 1)],
	]
	for pair in mapping:
		var action: String = pair[0]
		var dir2: Vector2i = pair[1]
		if Input.is_action_just_pressed(action):
			return dir2
	return Vector2i.ZERO

func _ensure_active_ranged_valid() -> void:
	if _active_ranged_weapon == RANGED_WAND and not _wand_collected:
		_active_ranged_weapon = RANGED_BOW if _bow_collected else RANGED_NONE
	elif _active_ranged_weapon == RANGED_BOW and not _bow_collected:
		_active_ranged_weapon = RANGED_WAND if _wand_collected else RANGED_NONE
	if _active_ranged_weapon == RANGED_NONE:
		if _wand_collected:
			_active_ranged_weapon = RANGED_WAND
		elif _bow_collected:
			_active_ranged_weapon = RANGED_BOW

func _cycle_ranged_weapon() -> void:
	var available: Array[StringName] = []
	if _wand_collected:
		available.append(RANGED_WAND)
	if _bow_collected:
		available.append(RANGED_BOW)
	if available.is_empty():
		return
	_ensure_active_ranged_valid()
	var idx := available.find(_active_ranged_weapon)
	if idx == -1:
		_active_ranged_weapon = available[0]
	else:
		_active_ranged_weapon = available[(idx + 1) % available.size()]
	_update_hud_icons()
	_update_player_sprite_appearance()

func _fire_ranged(dir: Vector2i) -> bool:
	if dir == Vector2i.ZERO or _state != STATE_PLAYING or _is_transitioning:
		return false
	_ensure_active_ranged_valid()
	if _active_ranged_weapon == RANGED_WAND and _wand_collected:
		_cast_wand(dir)
		return true
	if _active_ranged_weapon == RANGED_BOW and _bow_collected:
		return _shoot_bow(dir)
	return false

func _cone_cells(dir: Vector2i, distance: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var dx: int = sign(dir.x)
	var dy: int = sign(dir.y)
	for dist in range(1, distance + 1):
		if dx != 0 and dy == 0:
			for spread in range(-dist, dist + 1):
				cells.append(Vector2i(dx * dist, spread))
		elif dy != 0 and dx == 0:
			for spread2 in range(-dist, dist + 1):
				cells.append(Vector2i(spread2, dy * dist))
		else:
			for sx in range(0, dist + 1):
				for sy in range(0, dist + 1):
					if sx == 0 and sy == 0:
						continue
					if max(sx, sy) != dist:
						continue
					cells.append(Vector2i(dx * sx, dy * sy))
	return cells

func _cast_wand(dir: Vector2i) -> void:
	var origin := Grid.world_to_cell(player.global_position)
	var hit := false
	_play_sfx(SFX_WAND)
	_log_action("ZAP!")
	_flash_cone(dir, origin, 3, Color(0.6, 0.3, 0.8, 0.55))
	for offset in _cone_cells(dir, 3):
		var target := origin + offset
		if not _in_interior(target):
			continue
		if _is_wall(target):
			continue
		var enemy := _get_enemy_at(target)
		if enemy != null:
			hit = true
			_blink_node(enemy)
			enemy.apply_damage(1)
			if not enemy.alive:
				_handle_enemy_death(enemy)
				_check_win()
	if _wand_node:
		_wand_node.collect()
	_wand_collected = false
	_wand_cell = Vector2i(-1, -1)
	if _active_ranged_weapon == RANGED_WAND:
		_active_ranged_weapon = RANGED_BOW if _bow_collected else RANGED_NONE
	if hit:
		_play_sfx(SFX_HURT1)
		_play_sfx(SFX_PICKUP2)
	_update_hud_icons()
	_advance_enemies_and_update(_skeletons.size())

func _shoot_bow(dir: Vector2i) -> bool:
	if not _bow_collected or _arrow_count <= 0:
		return false
	_arrow_count = max(0, _arrow_count - 1)
	_play_sfx(SFX_BOW)
	var origin := Grid.world_to_cell(player.global_position)
	var path_end := origin
	for i in range(1, 8):
		var target := origin + dir * i
		if not _in_interior(target):
			path_end = origin + dir * (i - 1)
			break
		if _is_wall(target):
			path_end = origin + dir * (i - 1)
			break
		var enemy := _get_enemy_at(target)
		if enemy != null:
			path_end = target
			if _bow_missed(origin, target):
				_log_action("Whiff!")
				break
			_play_sfx(SFX_HURT1)
			_blink_node(enemy)
			enemy.apply_damage(1)
			if not enemy.alive:
				_handle_enemy_death(enemy)
				_check_win()
			_log_action("Gotcha!")
			break
		var trap := _trap_at(target)
		if trap != null:
			path_end = target
			break
		path_end = target
	_fire_projectile(origin, path_end, Color(1, 1, 1, 1))
	_update_hud_icons()
	_advance_enemies_and_update(_skeletons.size())
	return true

func _bow_missed(origin: Vector2i, target: Vector2i) -> bool:
	var dist: int = max(abs(origin.x - target.x), abs(origin.y - target.y))
	if dist <= 1:
		return false
	var miss_chance: float = clampf((dist - 1) * 0.05, 0.0, 0.25)
	return _rng.randf() < miss_chance

func _show_dash_trail(cells: Array[Vector2i]) -> void:
	if cells.size() < 2 or _decor == null:
		return
	var line: Line2D = null
	if not _dash_trail_pool.is_empty():
		line = _dash_trail_pool.pop_back()
	if line == null:
		line = Line2D.new()
		line.width = 3
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.z_index = 40
		line.z_as_relative = false
		_decor.add_child(line)
	line.clear_points()
	for cell in cells:
		var pos := Grid.cell_to_world(cell) + Vector2(Grid.CELL_SIZE / 2, Grid.CELL_SIZE / 2)
		line.add_point(pos)
	line.default_color = Color(1, 0.8, 0.4, 0.45)
	line.visible = true
	_dash_trail_active.append(line)
	var tw := get_tree().create_tween()
	tw.tween_property(line, "modulate:a", 0.0, 0.18)
	tw.finished.connect(func():
		line.visible = false
		line.modulate.a = 1.0
		_dash_trail_active.erase(line)
		_dash_trail_pool.append(line)
	)

func _fire_projectile(origin: Vector2i, end_cell: Vector2i, color: Color) -> void:
	var line: Line2D = null
	if not _projectile_pool.is_empty():
		line = _projectile_pool.pop_back()
	if line == null:
		line = Line2D.new()
		line.width = 1
		line.default_color = color
		line.begin_cap_mode = Line2D.LINE_CAP_BOX
		line.end_cap_mode = Line2D.LINE_CAP_BOX
		line.add_point(Vector2.ZERO)
		line.add_point(Vector2(6, 0))
		line.z_index = 60
		line.z_as_relative = false
		_decor.add_child(line)
	line.default_color = color
	line.visible = true
	var start_pos: Vector2 = Grid.cell_to_world(origin) + Vector2(Grid.CELL_SIZE / 2, Grid.CELL_SIZE / 2)
	var end_pos: Vector2 = Grid.cell_to_world(end_cell) + Vector2(Grid.CELL_SIZE / 2, Grid.CELL_SIZE / 2)
	var dir_vec: Vector2 = end_pos - start_pos
	line.rotation = atan2(dir_vec.y, dir_vec.x)
	line.position = start_pos
	_projectile_active.append(line)
	var dist: float = max(1.0, start_pos.distance_to(end_pos))
	var duration: float = clampf(dist / (Grid.CELL_SIZE * 18.0), 0.05, 0.18)
	var tw := get_tree().create_tween()
	tw.tween_property(line, "position", end_pos, duration)
	tw.tween_property(line, "modulate:a", 0.0, 0.1)
	tw.finished.connect(func():
		line.visible = false
		line.modulate.a = 1.0
		_projectile_active.erase(line)
		_projectile_pool.append(line)
	)

func _flash_cone(dir: Vector2i, origin: Vector2i, distance: int, color: Color) -> void:
	var cells := _cone_cells(dir, distance)
	for offset in cells:
		var target := origin + offset
		if not _in_interior(target):
			continue
		var pos := Grid.cell_to_world(target)
		var rect := ColorRect.new()
		rect.color = color
		rect.modulate.a = 0.5
		rect.size = Vector2(float(Grid.CELL_SIZE), float(Grid.CELL_SIZE))
		rect.position = pos
		rect.z_index = 55
		rect.z_as_relative = false
		_decor.add_child(rect)
		var tw := get_tree().create_tween()
		tw.tween_property(rect, "modulate:a", 0.0, 0.12)
		tw.finished.connect(func():
			rect.queue_free()
		)

func _apply_trap_damage() -> void:
	if _game_over:
		return
	_apply_player_damage(1)
	_last_death_cause = &"trap"

func _handle_trap_trigger(trap: Trap, cell: Vector2i) -> void:
	if trap == null:
		return
	if trap.trap_type == &"spiderweb":
		_web_stuck_turns = _rng.randi_range(2, 5)
		_traps.erase(trap)
		trap.queue_free()
		_last_trap_cell = Vector2i(-1, -1)
		_log_action("Stuck in a spider web")
		return
	_apply_trap_damage()
	_last_trap_cell = cell
	_log_action("Ouch!")

func _handle_enemy_hit_by_trap(enemy: Enemy, trap: Trap) -> void:
	if enemy == null or not enemy.alive:
		return
	if trap.trap_type == &"spiderweb":
		enemy.web_stuck_turns = max(enemy.web_stuck_turns, _rng.randi_range(2, 5))
		_log_action("%s got stuck in a spider web" % String(enemy.enemy_type).capitalize())
		_traps.erase(trap)
		trap.queue_free()
		return
	enemy.apply_damage(1)
	_log_action("%s stepped on a spike trap" % String(enemy.enemy_type).capitalize())
	if not enemy.alive:
		enemy.visible = false
		_remove_enemy_from_map(enemy)
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
	var player := _get_audio_player()
	if player == null:
		return
	player.stream = stream
	if player.is_inside_tree():
		player.play()

func _get_audio_player() -> AudioStreamPlayer:
	for p in _audio_pool:
		if p != null and not p.playing:
			return p
	var p := AudioStreamPlayer.new()
	add_child(p)
	_audio_pool.append(p)
	return p

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
	if _cheese_node and _cheese_node.get_node_or_null("Sprite2D") is Sprite2D:
		(_cheese_node.get_node("Sprite2D") as Sprite2D).z_index = 1
	if _wand_node and _wand_node.get_node_or_null("Sprite2D") is Sprite2D:
		var w_s := _wand_node.get_node("Sprite2D") as Sprite2D
		w_s.texture = WAND_TEX if WAND_TEX != null else w_s.texture
		w_s.z_index = 1
	if _bow_node and _bow_node.get_node_or_null("Sprite2D") is Sprite2D:
		var b_s := _bow_node.get_node("Sprite2D") as Sprite2D
		b_s.texture = BOW_TEX if BOW_TEX != null else b_s.texture
		b_s.z_index = 1
	if _arrow_base_node and _arrow_base_node.get_node_or_null("Sprite2D") is Sprite2D:
		(_arrow_base_node.get_node("Sprite2D") as Sprite2D).z_index = 1
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
	if _hud_icon_rune4 and RUNE4_TEX:
		_hud_icon_rune4.texture = RUNE4_TEX
	if _hud_icon_torch and TORCH_TEX:
		_hud_icon_torch.texture = TORCH_TEX
	if _hud_icon_ring and RING_TEX:
		_hud_icon_ring.texture = RING_TEX
	if _hud_icon_potion and POTION_TEX:
		_hud_icon_potion.texture = POTION_TEX
	if _hud_icon_bow and BOW_TEX:
		_hud_icon_bow.texture = BOW_TEX
	if _hud_icon_wand and WAND_TEX:
		_hud_icon_wand.texture = WAND_TEX

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
	_level_builder.place_random_inner_walls(grid_size, walls_map, _current_wall_sources, TILE_WALL, is_blocked)

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

func _clear_debug_items() -> void:
	for item in _debug_items:
		if item:
			item.queue_free()
	_debug_items.clear()

func _add_debug_item(item_name: String, tex: Texture2D, cell: Vector2i) -> Item:
	var item := _make_item_node(item_name, tex)
	add_child(item)
	item.place(cell)
	_debug_items.append(item)
	return item

func _ensure_arrow_nodes(count: int) -> void:
	if _arrow_nodes.is_empty() and _arrow_base_node:
		_arrow_nodes.append(_arrow_base_node)
	while _arrow_nodes.size() < count:
		var idx := _arrow_nodes.size()
		var node := _make_item_node("ArrowPickup%d" % idx, ARROW_TEX)
		add_child(node)
		_arrow_nodes.append(node)
	for i in range(_arrow_nodes.size()):
		if i >= count and _arrow_nodes[i] != null:
			_arrow_nodes[i].visible = false


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
		["switch_ranged", [Key.KEY_R]],
		["dash_attack", [Key.KEY_E]],
		["ranged_dir_up", [Key.KEY_KP_8, Key.KEY_I]],
		["ranged_dir_down", [Key.KEY_KP_2, Key.KEY_K]],
		["ranged_dir_left", [Key.KEY_KP_4, Key.KEY_J]],
		["ranged_dir_right", [Key.KEY_KP_6, Key.KEY_L]],
		["ranged_dir_up_left", [Key.KEY_KP_7, Key.KEY_U]],
		["ranged_dir_up_right", [Key.KEY_KP_9, Key.KEY_O]],
		["ranged_dir_down_left", [Key.KEY_KP_1, Key.KEY_N]],
		["ranged_dir_down_right", [Key.KEY_KP_3, Key.KEY_PERIOD]],
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
	_clear_debug_items()
	_max_level = _rng.randi_range(3, 10)
	_level_special_map.clear()
	_special_levels.clear()
	_level_key_map.clear()
	_armor_plan.clear()
	_rune1_plan.clear()
	_rune2_plan.clear()
	_rune3_plan.clear()
	_rune4_plan.clear()
	_arrow_plan.clear()
	_tileset_plan.clear()
	_cheese_level = -1
	_cheese_given = false
	_cheese_collected = false
	var levels: Array[int] = []
	for i in range(1, _max_level + 1):
		levels.append(i)
	levels.shuffle()
	var _pick_weighted_early_level := func() -> int:
		var pool: Array[int] = []
		for lvl in range(1, _max_level + 1):
			pool.append(lvl)
			if lvl <= 3 and _max_level > 1:
				for _i in range(EARLY_LEVEL_WEIGHT - 1):
					pool.append(lvl)
		return pool[_rng.randi_range(0, pool.size() - 1)]
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
	var rune3_total: int = 1
	var rune4_total: int = 1
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
	for i6 in range(rune4_total):
		var rl4: int = _rng.randi_range(1, _max_level)
		_rune4_plan[rl4] = _rune4_plan.get(rl4, 0) + 1
	var arrow_levels: Array[int] = []
	for i6 in range(1, _max_level + 1):
		arrow_levels.append(i6)
	arrow_levels.shuffle()
	var arrow_total: int = _rng.randi_range(1, min(3, _max_level))
	# Guarantee at least one arrow pickup with a bias toward early floors
	var ensured_arrow_level: int = _pick_weighted_early_level.call()
	_arrow_plan[ensured_arrow_level] = 1
	var remaining_arrows: int = max(0, arrow_total - 1)
	var attempts: int = 0
	while remaining_arrows > 0 and attempts < 100:
		attempts += 1
		var al: int = _pick_weighted_early_level.call()
		if _arrow_plan.has(al):
			continue
		_arrow_plan[al] = 1
		remaining_arrows -= 1
	_wand_level = _pick_weighted_early_level.call()
	_bow_level = _pick_weighted_early_level.call()
	if DEBUG_FORCE_RANGED:
		_wand_level = 1
		_bow_level = 1
		_arrow_plan[1] = 1
	if DEBUG_SPAWN_ALL_ITEMS:
		_level_key_map[1] = _level_key_map.get(1, &"key1")
		_armor_plan[1] = max(1, _armor_plan.get(1, 0))
		_rune1_plan[1] = max(1, _rune1_plan.get(1, 0))
		_rune2_plan[1] = max(1, _rune2_plan.get(1, 0))
		_rune3_plan[1] = max(1, _rune3_plan.get(1, 0))
		_rune4_plan[1] = max(1, _rune4_plan.get(1, 0))
		_arrow_plan[1] = max(1, _arrow_plan.get(1, 0))
		_wand_level = 1
		_bow_level = 1
		_torch_target_level = 1
		_level_special_map[1] = &"ring"
		_special_levels[&"ring"] = 1
		_cheese_level = 1
	if DEBUG_SPAWN_CHEESE:
		_cheese_level = 1
	elif _rng.randf() < 0.5:
		_cheese_level = _pick_weighted_early_level.call()

func _register_enemy(enemy: Enemy) -> void:
	if enemy == null:
		return
	_enemy_map[enemy.grid_cell] = enemy

func _set_enemy_cell(enemy: Enemy, cell: Vector2i) -> void:
	if enemy == null:
		return
	if _enemy_map.get(enemy.grid_cell, null) == enemy:
		_enemy_map.erase(enemy.grid_cell)
	enemy.set_cell(cell)
	_enemy_map[cell] = enemy

func _remove_enemy_from_map(enemy: Enemy) -> void:
	if enemy == null:
		return
	if _enemy_map.get(enemy.grid_cell, null) == enemy:
		_enemy_map.erase(enemy.grid_cell)
		if enemy.enemy_type != StringName():
			_last_death_cause = enemy.enemy_type

func _get_enemy_at(cell: Vector2i) -> Enemy:
	var enemy: Enemy = _enemy_map.get(cell, null)
	if enemy != null and enemy is Enemy and enemy.alive:
		return enemy
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

func _build_version_string() -> String:
	var version_val := str(ProjectSettings.get_setting("application/config/version", ""))
	var build_ts := str(ProjectSettings.get_setting("application/config/build_timestamp", ""))
	if version_val != "":
		return "Version: %s" % version_val
	if build_ts != "":
		return "Built: %s" % build_ts
	return "Built: %s" % Time.get_datetime_string_from_unix_time(Time.get_unix_time_from_system())

func _update_title_build_label() -> void:
	if _title_build_label == null:
		return
	_title_build_label.text = _build_version_string()
