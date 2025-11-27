extends GutTest

var _main_script: Script = preload("res://scripts/Main.gd")
var _goblin_script: Script = preload("res://scripts/Goblin.gd")
var _trap_script: Script = preload("res://scripts/Trap.gd")
var _mouse_script: Script = preload("res://scripts/Mouse.gd")

func _fresh_main() -> Node:
	return _main_script.new()

func test_grid_round_trip() -> void:
	var cell := Vector2i(5, 7)
	var world := Grid.cell_to_world(cell)
	assert_eq(Grid.world_to_cell(world), cell, "Grid round-trip should return original cell")
	# No nodes created; nothing to free.

func test_weighted_floor_sources_distribution() -> void:
	var main: Node = _fresh_main()
	var base := [1, 2]
	var shared := [3]
	var weighted: Array = main.call("_build_weighted_floor_sources", base, shared, 0.25)
	assert_true(weighted != null, "_build_weighted_floor_sources should return an array")
	if weighted == null:
		main.queue_free()
		return
	assert_eq(weighted.size(), 100, "Weighted sources should produce 100 buckets")
	var shared_count := 0
	for id in weighted:
		if id == 3:
			shared_count += 1
	assert_true(shared_count >= 20 and shared_count <= 30, "Shared bucket ratio should be ~25%% (got %d)" % shared_count)
	main.queue_free()

func test_enemy_registry_register_move_remove() -> void:
	var main: Node = _fresh_main()
	var goblin: Node2D = _goblin_script.new()
	goblin.grid_cell = Vector2i(1, 1)
	main._register_enemy(goblin)
	assert_eq(main._get_enemy_at(Vector2i(1, 1)), goblin, "Enemy should be retrievable after register")
	main._set_enemy_cell(goblin, Vector2i(2, 2))
	assert_true(main._get_enemy_at(Vector2i(1, 1)) == null, "Old enemy cell should be cleared after move")
	assert_eq(main._get_enemy_at(Vector2i(2, 2)), goblin, "Enemy should be tracked at new cell")
	main._remove_enemy_from_map(goblin)
	assert_true(main._get_enemy_at(Vector2i(2, 2)) == null, "Enemy should be removed from registry")
	goblin.queue_free()
	main.queue_free()

func test_bresenham_line_continuity() -> void:
	var main: Node = _fresh_main()
	var pts: Array = main._bresenham(Vector2i.ZERO, Vector2i(3, 3))
	assert_eq(pts.front(), Vector2i.ZERO, "Line should start at origin")
	assert_eq(pts.back(), Vector2i(3, 3), "Line should end at destination")
	for i in range(1, pts.size()):
		var step: Vector2i = pts[i] - pts[i - 1]
		assert_true(abs(step.x) <= 1 and abs(step.y) <= 1, "Line steps should move at most 1 per axis (idx=%d)" % i)
	main.queue_free()

func test_ranged_dir_combined_keys_produces_diagonal() -> void:
	var main: Node = _fresh_main()
	var actions := [
		"ranged_dir_left",
		"ranged_dir_right",
		"ranged_dir_up",
		"ranged_dir_down",
		"ranged_dir_up_left",
		"ranged_dir_up_right",
		"ranged_dir_down_left",
		"ranged_dir_down_right",
	]
	for a in actions:
		_ensure_action(a)
	# Simulate holding left then pressing up to produce (-1,-1)
	Input.action_press("ranged_dir_left")
	Input.action_press("ranged_dir_up")
	var dir: Vector2i = main._ranged_dir_from_input()
	assert_eq(dir, Vector2i(-1, -1), "Combining left+up should yield a diagonal ranged dir")
	Input.action_release("ranged_dir_left")
	Input.action_release("ranged_dir_up")
	for a2 in actions:
		if InputMap.has_action(a2):
			InputMap.erase_action(a2)
	main.queue_free()

func _make_tilemap_with_wall(cell: Vector2i) -> TileMap:
	var tm := TileMap.new()
	var ts := TileSet.new()
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	var tex := ImageTexture.create_from_image(img)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(1, 1)
	ts.add_source(src, 0)
	tm.tile_set = ts
	tm.set_cell(0, cell, 0, Vector2i.ZERO)
	return tm

func _ensure_action(name: String) -> void:
	if not InputMap.has_action(name):
		InputMap.add_action(name)

func test_passability_checks_respect_walls_traps_enemies_mice() -> void:
	var main: Node = _fresh_main()
	main._grid_size = Vector2i(5, 5)
	main.walls_map = _make_tilemap_with_wall(Vector2i(2, 2))
	var trap: Trap = _trap_script.new()
	trap.grid_cell = Vector2i(3, 3)
	var traps: Array[Trap] = []
	traps.append(trap)
	main._traps = traps
	var goblin: Goblin = _goblin_script.new()
	goblin.grid_cell = Vector2i(1, 1)
	main._register_enemy(goblin)
	var mouse: Mouse = _mouse_script.new()
	mouse.grid_cell = Vector2i(1, 2)
	mouse.alive = true
	var mice: Array[Mouse] = []
	mice.append(mouse)
	main._mice = mice
	assert_false(main._is_free(Vector2i(2, 2)), "Wall should block free check")
	assert_false(main._is_free(Vector2i(3, 3)), "Trap should block free check")
	assert_false(main._is_free(Vector2i(1, 1)), "Enemy should block free check")
	assert_false(main._can_enemy_step(Vector2i(1, 2), goblin), "Mouse should block enemy step")
	assert_true(main._can_enemy_step(Vector2i(2, 1), goblin), "Open interior cell should allow step")
	goblin.queue_free()
	mouse.queue_free()
	trap.queue_free()
	if main.walls_map:
		main.walls_map.queue_free()
	main.queue_free()
