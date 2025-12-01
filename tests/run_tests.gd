#!/usr/bin/env -S godot4 --headless --path . --script
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
	_test_player_sprite_ranged_switch()
	if not _failures.is_empty():
		for f in _failures:
			printerr(f)
	else:
		print("All tests passed (%d)" % 5)

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
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	var base: Array = [1, 2]
	var shared: Array = [3]
	var weighted: Array = main._build_weighted_floor_sources(base, shared, 0.25)
	_assert_eq(weighted.size(), 100, "Weighted floor sources should have 100 buckets")
	var shared_count := 0
	for id in weighted:
		if id == 3:
			shared_count += 1
	_assert_true(shared_count >= 20 and shared_count <= 30, "Shared bucket count should be near 25%% (got %d)" % shared_count)
	main.queue_free()

func _test_enemy_registry() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var goblin_script: Script = load("res://scripts/Goblin.gd")
	var main: Node = main_script.new()
	var goblin: Node2D = goblin_script.new()
	goblin.grid_cell = Vector2i(1, 1)
	main._register_enemy(goblin)
	_assert_eq(main._get_enemy_at(Vector2i(1, 1)), goblin, "Enemy should be retrievable after register")
	main._set_enemy_cell(goblin, Vector2i(2, 2))
	_assert_true(main._get_enemy_at(Vector2i(1, 1)) == null, "Old enemy cell should be cleared after move")
	_assert_eq(main._get_enemy_at(Vector2i(2, 2)), goblin, "Enemy should move in registry with set")
	main._remove_enemy_from_map(goblin)
	_assert_true(main._get_enemy_at(Vector2i(2, 2)) == null, "Enemy should be removed from registry")
	goblin.queue_free()
	main.queue_free()

func _test_bresenham_line() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	var pts: Array = main._bresenham(Vector2i.ZERO, Vector2i(3, 3))
	_assert_eq(pts.front(), Vector2i.ZERO, "Bresenham should start at origin")
	_assert_eq(pts.back(), Vector2i(3, 3), "Bresenham should end at destination")
	for i in range(1, pts.size()):
		var step: Vector2i = pts[i] - pts[i - 1]
		_assert_true(abs(step.x) <= 1 and abs(step.y) <= 1, "Bresenham steps should move at most 1 per axis")
	main.queue_free()

func _test_player_sprite_ranged_switch() -> void:
	var main_script: Script = load("res://scripts/Main.gd")
	var main: Node = main_script.new()
	main._player_sprite = Sprite2D.new()
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	var tex_wand := ImageTexture.create_from_image(img)
	var tex_bow := ImageTexture.create_from_image(img)
	main.PLAYER_TEX_WAND = tex_wand
	main.PLAYER_TEX_BOW = tex_bow
	main.PLAYER_TEX_1 = ImageTexture.create_from_image(img)
	main._sword_collected = false
	main._shield_collected = false
	main._wand_collected = true
	main._bow_collected = true
	main._active_ranged_weapon = main.RANGED_WAND
	main._update_player_sprite_appearance()
	_assert_eq(main._player_sprite.texture, tex_wand, "Player sprite should show wand when wand is active")
	main._active_ranged_weapon = main.RANGED_BOW
	main._update_player_sprite_appearance()
	_assert_eq(main._player_sprite.texture, tex_bow, "Player sprite should show bow when bow is active")
	main.PLAYER_TEX_WAND = null
	main.PLAYER_TEX_BOW = null
	main.PLAYER_TEX_1 = null
	main._player_sprite.queue_free()
	main.queue_free()
	main = null
