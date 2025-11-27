extends SceneTree

# Lightweight test runner (no external deps). Run with:
# godot4 --headless --path . --script res://tests/run_tests.gd

var _failures: Array[String] = []

func _init() -> void:
	_run()
	quit(0 if _failures.is_empty() else 1)

func _run() -> void:
	_test_grid_round_trip()
	_test_weighted_floor_sources()
	_test_enemy_registry()
	_test_bresenham_line()
	if not _failures.is_empty():
		for f in _failures:
			printerr(f)
	else:
		print("All tests passed (%d)" % 4)

func _assert_true(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)

func _assert_eq(a, b, msg: String) -> void:
	if a != b:
		_failures.append("%s (expected=%s actual=%s)" % [msg, str(b), str(a)])

func _test_grid_round_trip() -> void:
	var cell := Vector2i(5, 7)
	var world := Grid.cell_to_world(cell)
	var back := Grid.world_to_cell(world)
	_assert_eq(back, cell, "Grid round-trip should return original cell")

func _test_weighted_floor_sources() -> void:
	var main_script := load("res://scripts/Main.gd")
	var main := main_script.new()
	var base := [1, 2]
	var shared := [3]
	var weighted: Array = main._build_weighted_floor_sources(base, shared, 0.25)
	_assert_eq(weighted.size(), 100, "Weighted floor sources should have 100 buckets")
	var shared_count := 0
	for id in weighted:
		if id == 3:
			shared_count += 1
	_assert_true(shared_count >= 20 and shared_count <= 30, "Shared bucket count should be near 25% (got %d)" % shared_count)

func _test_enemy_registry() -> void:
	var main_script := load("res://scripts/Main.gd")
	var goblin_script := load("res://scripts/Goblin.gd")
	var main := main_script.new()
	var goblin := goblin_script.new()
	goblin.grid_cell = Vector2i(1, 1)
	main._register_enemy(goblin)
	_assert_eq(main._get_enemy_at(Vector2i(1, 1)), goblin, "Enemy should be retrievable after register")
	main._set_enemy_cell(goblin, Vector2i(2, 2))
	_assert_true(main._get_enemy_at(Vector2i(1, 1)) == null, "Old enemy cell should be cleared after move")
	_assert_eq(main._get_enemy_at(Vector2i(2, 2)), goblin, "Enemy should move in registry with set")
	main._remove_enemy_from_map(goblin)
	_assert_true(main._get_enemy_at(Vector2i(2, 2)) == null, "Enemy should be removed from registry")

func _test_bresenham_line() -> void:
	var main_script := load("res://scripts/Main.gd")
	var main := main_script.new()
	var pts: Array = main._bresenham(Vector2i.ZERO, Vector2i(3, 3))
	_assert_eq(pts.front(), Vector2i.ZERO, "Bresenham should start at origin")
	_assert_eq(pts.back(), Vector2i(3, 3), "Bresenham should end at destination")
	for i in range(1, pts.size()):
		var step := pts[i] - pts[i - 1]
		_assert_true(abs(step.x) <= 1 and abs(step.y) <= 1, "Bresenham steps should move at most 1 per axis")
