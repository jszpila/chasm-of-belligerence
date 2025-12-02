extends Node2D

@export var cell_size: int = 12
@export var max_dark: float = 0.8
@export var inner_tiles: int = 5
@export var outer_tiles: int = 14

var grid_size: Vector2i = Vector2i.ZERO
var vis_map: Array[bool] = []        # visibility per tile
var dist_tiles: Array[float] = []    # distance per tile (in tiles)
var _cell_rects: Array[ColorRect] = []  # Cached ColorRect nodes for each cell
var _clip_rects: Array[ColorRect] = []  # Border clipping rects
var _last_alpha: Array[float] = []   # Track last alpha to avoid unnecessary updates
var _wall_cache: Array[bool] = []    # Cache of wall positions to exclude from darkening

func set_wall_cache(wall_cache: Array[bool]) -> void:
	_wall_cache = wall_cache
	# Re-initialize darkening with wall information
	if grid_size != Vector2i.ZERO:
		_initialize_all_dark()

func set_grid(grid: Vector2i) -> void:
	grid_size = grid
	var total: int = grid_size.x * grid_size.y
	vis_map.resize(total)
	dist_tiles.resize(total)
	_last_alpha.resize(total)
	for i in range(total):
		vis_map[i] = false
		dist_tiles[i] = 1e9
		_last_alpha[i] = -1.0
	_clear_cell_rects()
	_create_cell_rects()
	_create_clip_rects()
	# Initialize all cells to max dark (fully dark) until FOV is calculated
	_initialize_all_dark()

func _clear_cell_rects() -> void:
	for rect in _cell_rects:
		if is_instance_valid(rect):
			rect.queue_free()
	_cell_rects.clear()
	for rect in _clip_rects:
		if is_instance_valid(rect):
			rect.queue_free()
	_clip_rects.clear()

func _create_cell_rects() -> void:
	if grid_size == Vector2i.ZERO:
		return
	var total: int = grid_size.x * grid_size.y
	_cell_rects.resize(total)
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var idx: int = y * grid_size.x + x
			var rect := ColorRect.new()
			rect.color = Color(0, 0, 0, 0)  # Start transparent, will be set by _initialize_all_dark
			rect.position = Vector2(float(x * cell_size), float(y * cell_size))
			rect.size = Vector2(float(cell_size), float(cell_size))
			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			rect.visible = true
			add_child(rect)
			_cell_rects[idx] = rect

func _initialize_all_dark() -> void:
	# Initialize all cells to max dark (fully dark) until FOV is calculated
	# But exclude walls - they should remain visible
	if grid_size == Vector2i.ZERO:
		return
	var total: int = grid_size.x * grid_size.y
	for idx in range(total):
		if _cell_rects[idx] != null:
			# Check if this is a wall - if so, don't darken it
			var is_wall: bool = false
			if _wall_cache.size() > idx:
				is_wall = _wall_cache[idx]
			
			if is_wall:
				_cell_rects[idx].color = Color(0, 0, 0, 0)
				_last_alpha[idx] = 0.0
			else:
				_cell_rects[idx].color = Color(0, 0, 0, max_dark)
				_last_alpha[idx] = max_dark

func _create_clip_rects() -> void:
	if grid_size == Vector2i.ZERO:
		return
	var world_w: float = float(grid_size.x * cell_size)
	var world_h: float = float(grid_size.y * cell_size)
	var pad: float = float(cell_size * 8)
	var clip_color := Color(0, 0, 0, 1.0)
	
	# Top
	var top := ColorRect.new()
	top.color = clip_color
	top.position = Vector2(-pad, -pad)
	top.size = Vector2(world_w + pad * 2.0, pad)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)
	_clip_rects.append(top)
	
	# Bottom
	var bottom := ColorRect.new()
	bottom.color = clip_color
	bottom.position = Vector2(-pad, world_h)
	bottom.size = Vector2(world_w + pad * 2.0, pad)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bottom)
	_clip_rects.append(bottom)
	
	# Left
	var left := ColorRect.new()
	left.color = clip_color
	left.position = Vector2(-pad, 0)
	left.size = Vector2(pad, world_h)
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(left)
	_clip_rects.append(left)
	
	# Right
	var right := ColorRect.new()
	right.color = clip_color
	right.position = Vector2(world_w, 0)
	right.size = Vector2(pad, world_h)
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(right)
	_clip_rects.append(right)

func update_fov(_visible: Array[bool], _dist_tiles: Array[float], _inner_tiles: int, _outer_tiles: int, _max_dark: float, wall_cache: Array[bool] = []) -> void:
	# Copy references (assumed sized correctly)
	vis_map = _visible
	dist_tiles = _dist_tiles
	inner_tiles = _inner_tiles
	outer_tiles = _outer_tiles
	max_dark = _max_dark
	# Store wall cache to exclude walls from darkening
	_wall_cache = wall_cache
	_update_cell_alphas()

func _update_cell_alphas() -> void:
	if grid_size == Vector2i.ZERO:
		return
	var total: int = grid_size.x * grid_size.y
	if vis_map.size() != total or _cell_rects.size() != total:
		return
	
	# Only update cells that have changed alpha
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var idx: int = y * grid_size.x + x
			# Skip darkening wall cells - they should remain fully visible
			var is_wall: bool = false
			if _wall_cache.size() > idx:
				is_wall = _wall_cache[idx]
			
			var alpha: float
			if is_wall:
				# Walls are never darkened - set alpha to 0 (transparent overlay)
				alpha = 0.0
			elif vis_map[idx]:
				var d: float = float(dist_tiles[idx])
				var denom: float = float(outer_tiles - inner_tiles)
				if denom < 0.001:
					denom = 0.001
				var t: float = clampf((d - float(inner_tiles)) / denom, 0.0, 1.0)
				# Smooth falloff
				t = smoothstep(0.0, 1.0, t)
				alpha = t * max_dark
			else:
				alpha = max_dark
			
			# Only update if alpha changed (avoid unnecessary property updates)
			if abs(_last_alpha[idx] - alpha) > 0.001:
				_last_alpha[idx] = alpha
				if _cell_rects[idx] != null:
					_cell_rects[idx].color = Color(0, 0, 0, alpha)
					_cell_rects[idx].visible = (alpha > 0.001)
