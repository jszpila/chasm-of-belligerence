extends Node2D

@export var cell_size: int = 12
@export var max_dark: float = 0.8
@export var inner_tiles: int = 5
@export var outer_tiles: int = 14

var grid_size: Vector2i = Vector2i.ZERO
var vis_map: Array[bool] = []        # visibility per tile
var dist_tiles: Array[float] = []    # distance per tile (in tiles)

func set_grid(grid: Vector2i) -> void:
	grid_size = grid
	var total: int = grid_size.x * grid_size.y
	vis_map.resize(total)
	dist_tiles.resize(total)
	for i in range(total):
		vis_map[i] = false
		dist_tiles[i] = 1e9
	queue_redraw()

func update_fov(_visible: Array[bool], _dist_tiles: Array[float], _inner_tiles: int, _outer_tiles: int, _max_dark: float) -> void:
	# Copy references (assumed sized correctly)
	vis_map = _visible
	dist_tiles = _dist_tiles
	inner_tiles = _inner_tiles
	outer_tiles = _outer_tiles
	max_dark = _max_dark
	queue_redraw()

func _draw() -> void:
	if grid_size == Vector2i.ZERO:
		return
	var total: int = grid_size.x * grid_size.y
	if vis_map.size() != total:
		return
	# Draw visibility inside the playable grid
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var idx: int = y * grid_size.x + x
			var alpha: float
			if vis_map[idx]:
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
			if alpha <= 0.001:
				continue
			var pos: Vector2 = Vector2(float(x * cell_size), float(y * cell_size))
			draw_rect(Rect2(pos, Vector2(float(cell_size), float(cell_size))), Color(0, 0, 0, alpha), true)
	# Hard clip light outside the grid so braziers and other sources don't bleed past walls.
	var world_w: float = float(grid_size.x * cell_size)
	var world_h: float = float(grid_size.y * cell_size)
	var pad: float = float(cell_size * 8)
	var clip_color := Color(0, 0, 0, 1.0)
	draw_rect(Rect2(Vector2(-pad, -pad), Vector2(world_w + pad * 2.0, pad)), clip_color, true)
	draw_rect(Rect2(Vector2(-pad, world_h), Vector2(world_w + pad * 2.0, pad)), clip_color, true)
	draw_rect(Rect2(Vector2(-pad, 0), Vector2(pad, world_h)), clip_color, true)
	draw_rect(Rect2(Vector2(world_w, 0), Vector2(pad, world_h)), clip_color, true)
