extends GutTest

var _main_script: Script = preload("res://scripts/Main.gd")

func _fresh_main() -> Node:
	return _main_script.new()

func test_rune_plans_stay_within_bounds() -> void:
	var main: Node = _fresh_main()
	main._rng.seed = 1
	main._prepare_run_layout()
	assert_true(main._rune1_plan.size() > 0, "Rune1 plan should not be empty")
	assert_true(main._rune2_plan.size() > 0, "Rune2 plan should not be empty")
	assert_true(main._rune3_plan.size() > 0, "Rune3 plan should not be empty")
	for plan in [main._rune1_plan, main._rune2_plan, main._rune3_plan]:
		for level_key in plan.keys():
			assert_true(level_key >= 1 and level_key <= main._max_level, "Rune plan key should be within level bounds")
	main.queue_free()

func test_hud_labels_update_with_rune_counts() -> void:
	var main: Node = _fresh_main()
	main._state = main.STATE_PLAYING
	main._hud_atk_label = Label.new()
	main._hud_def_label = Label.new()
	main._hud_level = Label.new()
	main._attack_level_bonus = 0
	main._defense_level_bonus = 0
	main._sword_collected = false
	main._shield_collected = false
	main._rune1_collected_count = 2
	main._rune2_collected_count = 1
	main._update_hud_icons()
	assert_eq(main._hud_atk_label.text, "ATK: 2", "ATK label should reflect rune attack bonus")
	assert_eq(main._hud_def_label.text, "DEF: 1", "DEF label should reflect rune defense bonus")
	main.queue_free()

func _weighted_sample(rng: RandomNumberGenerator, max_level: int, weight: int) -> int:
	var pool: Array[int] = []
	for lvl in range(1, max_level + 1):
		pool.append(lvl)
		if lvl <= 3 and max_level > 1:
			for _i in range(weight - 1):
				pool.append(lvl)
	return pool[rng.randi_range(0, pool.size() - 1)]

func test_weighted_selection_prefers_early_levels() -> void:
	var main: Node = _fresh_main()
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var early := 0
	var late := 0
	for _i in range(200):
		var lvl: int = _weighted_sample(rng, 10, main.EARLY_LEVEL_WEIGHT)
		if lvl <= 3:
			early += 1
		else:
			late += 1
	assert_true(early > late, "Early levels should be sampled more frequently than later levels")
	main.queue_free()
