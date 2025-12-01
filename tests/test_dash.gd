extends GutTest

var _main_script: Script = preload("res://scripts/Main.gd")
var _enemy_script: Script = preload("res://scripts/Enemy.gd")

class FakePlayer:
	extends Node2D

	func teleport_to_cell(cell: Vector2i) -> void:
		global_position = Grid.cell_to_world(cell)

func _empty_tilemap() -> TileMap:
	var tm := TileMap.new()
	var ts := TileSet.new()
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	var tex := ImageTexture.create_from_image(img)
	var src := TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(1, 1)
	ts.add_source(src, 0)
	tm.tile_set = ts
	return tm

func _fresh_dash_ready_main() -> Node:
	var main: Node = _main_script.new()
	main._grid_size = Vector2i(10, 10)
	main._setup_input()
	main._state = main.STATE_PLAYING
	main._is_transitioning = false
	main._rune4_collected_count = 1
	main.walls_map = _empty_tilemap()
	main._decor = Node2D.new()
	main.add_child(main._decor)
	var player := FakePlayer.new()
	player.teleport_to_cell(Vector2i(2, 2))
	main.player = player
	return main

func test_dash_kills_enemy_and_moves_into_cell() -> void:
	var main: Node = _fresh_dash_ready_main()
	var enemy: Enemy = _enemy_script.new()
	enemy.configure(Vector2i(5, 2), 1, null)
	main._register_enemy(enemy)
	var success: bool = main._on_player_dash_attempt(Vector2i(1, 0))
	assert_true(success, "Dash should succeed when enemy is in range")
	assert_false(enemy.alive, "Enemy should be defeated by dash strike")
	assert_eq(Grid.world_to_cell(main.player.global_position), Vector2i(5, 2), "Player should land on defeated enemy cell")
	assert_eq(main._rune4_dash_cooldown, main.RUNE4_DASH_COOLDOWN_MOVES, "Dash should set cooldown after resolving movement")
	enemy.queue_free()
	main.queue_free()

func test_dash_stops_before_surviving_enemy() -> void:
	var main: Node = _fresh_dash_ready_main()
	var enemy: Enemy = _enemy_script.new()
	enemy.configure(Vector2i(5, 2), 2, null)
	main._register_enemy(enemy)
	var success: bool = main._on_player_dash_attempt(Vector2i(1, 0))
	assert_true(success, "Dash should attempt even if enemy survives")
	assert_true(enemy.alive, "Enemy should survive with remaining HP")
	assert_eq(enemy.hp, 1, "Enemy HP should decrease by 1")
	assert_eq(Grid.world_to_cell(main.player.global_position), Vector2i(4, 2), "Player should stop before surviving enemy")
	assert_eq(main._rune4_dash_cooldown, main.RUNE4_DASH_COOLDOWN_MOVES, "Cooldown should still start when dash resolves")
	enemy.queue_free()
	main.queue_free()
