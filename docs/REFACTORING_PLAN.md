# Main.gd Refactoring Plan

## Current State
- **File Size**: ~4,750 lines
- **Functions**: ~99 functions
- **Variables**: ~200+ variables
- **Responsibilities**: Too many (violates Single Responsibility Principle)

## Identified Functional Areas

### 1. **AssetManager** (~300 lines)
**Responsibilities:**
- Spritesheet loading and caching
- Texture creation and management
- Tileset building
- Floor/wall texture arrays

**Functions to Extract:**
- `_sheet()`, `_sheet_tex()`, `_load_spritesheet_textures()`
- `_build_tileset_from_sheet()`, `_make_tile_source()`
- `_set_sprite_tex()`, `_normalize_item_node()`

**Suggested File:** `scripts/managers/AssetManager.gd`

---

### 2. **EnemyManager** (~600 lines)
**Responsibilities:**
- Enemy spawning (all types)
- Enemy movement and AI
- Enemy registry (`_enemy_map`)
- Enemy lifecycle (spawn, move, death)

**Functions to Extract:**
- `_spawn_*_at()` (goblin, zombie, minotaur, imp, skeleton, mouse, trap)
- `_advance_enemies_and_update()`, `_move_*()`
- `_register_enemy()`, `_set_enemy_cell()`, `_remove_enemy_from_map()`, `_get_enemy_at()`
- `_enemy_can_act()`, `_can_enemy_step()`
- `_clear_enemies()`, `_handle_enemy_death()`, `_leave_enemy_corpse()`

**Suggested File:** `scripts/managers/EnemyManager.gd`

---

### 3. **CombatManager** (~250 lines)
**Responsibilities:**
- Combat rounds
- Player damage
- Enemy damage
- Scoring and level-ups

**Functions to Extract:**
- `_combat_round_enemy()`, `_apply_player_damage()`, `_handle_player_hit()`
- `_add_score()`, `_maybe_level_up()`, `_apply_level_up_reward()`
- `_enemy_score_value()`, `_attack_bonus()`, `_defense_bonus()`
- `_handle_enemy_hit_by_trap()`

**Suggested File:** `scripts/managers/CombatManager.gd`

---

### 4. **ItemManager** (~400 lines)
**Responsibilities:**
- Item spawning and placement
- Item pickups
- Item visibility management
- Item state tracking

**Functions to Extract:**
- `_make_item_node()`, `_add_debug_item()`, `_clear_debug_items()`
- `_pickup_*_if_available()` (potion, arrows, etc.)
- `_reset_items_visibility()`, `_set_level_item_textures()`
- `_try_give_cheese()`, `_enforce_melee_first_level_only()`

**Suggested File:** `scripts/managers/ItemManager.gd`

---

### 5. **LevelManager** (~700 lines)
**Responsibilities:**
- Level building and generation
- Level state saving/loading
- Level transitions
- Wall/floor placement

**Functions to Extract:**
- `_build_maps()`, `_place_random_entities()`, `_place_random_inner_walls()`
- `_save_level_state()`, `_restore_level_state()`, `_restore_entities_from_state()`
- `_restore_walls_from_state()`, `_travel_to_level()`
- `_get_grid_size()`, `_set_current_tileset_for_level()`
- `_build_weighted_floor_sources()`, `_prepare_run_layout()`

**Suggested File:** `scripts/managers/LevelManager.gd`

---

### 6. **FOVManager** (~200 lines)
**Responsibilities:**
- Field of view calculations
- Light source application
- Bresenham line algorithm
- FOV overlay management

**Functions to Extract:**
- `_update_fov()`, `_apply_light_source()`, `_ensure_fov_overlay()`
- `_bresenham()`, `_bresenham_to_buffer()`, `_in_bounds()`
- `_rebuild_wall_cache()`, `_is_wall()` (wall cache related)

**Suggested File:** `scripts/managers/FOVManager.gd`

---

### 7. **HUDManager** (~350 lines)
**Responsibilities:**
- HUD updates (hearts, armor, icons, text)
- Action log management
- HUD visibility control

**Functions to Extract:**
- `_update_hud_*()` (hearts, armor, icons, score, etc.)
- `_log_action()`, `_refresh_action_log()`, `_clear_action_log()`
- `_init_action_log_labels()`, `_set_hud_layer_visible()`
- `_set_icon_visible()`, `_apply_ranged_highlight()`

**Suggested File:** `scripts/managers/HUDManager.gd`

---

### 8. **GameStateManager** (~400 lines)
**Responsibilities:**
- Title screen
- Game over screen
- State transitions
- Game initialization

**Functions to Extract:**
- `_start_game()`, `_restart_game()`, `_show_title()`, `_show_game_over()`
- `_fade_to()`, `_set_world_visible()`
- `_death_cause_text()`, `_position_game_over_labels()`
- `_on_viewport_resized()`, `_resize_fullscreen_art()`

**Suggested File:** `scripts/managers/GameStateManager.gd`

---

### 9. **GridUtilities** (~150 lines)
**Responsibilities:**
- Grid-related helper functions
- Pathfinding utilities
- Cell validation

**Functions to Extract:**
- `_is_free()`, `_in_interior()`, `_is_wall()` (basic version)
- `_pick_free_cell_next_to_wall()`, `_has_free_neighbor()`
- Grid helper functions

**Suggested File:** `scripts/utils/GridUtilities.gd` (static utility class)

---

### 10. **VisualEffectsManager** (~200 lines)
**Responsibilities:**
- Projectiles
- Dash trails
- Visual blinks/effects
- Debug outlines

**Functions to Extract:**
- `_fire_ranged()`, `_show_dash_trail()`, `_blink_node()`, `_blink_node_colored()`
- `_draw_debug_outline()`, `_clear_debug_outlines()`, `_update_debug_ranged_outlines()`
- Projectile pool management

**Suggested File:** `scripts/managers/VisualEffectsManager.gd`

---

## Refactoring Strategy

### Phase 1: Extract Utility Classes (Low Risk)
1. Create `GridUtilities.gd` as a static utility class
2. Move grid helper functions
3. Update Main.gd to use static calls

### Phase 2: Extract Managers (Medium Risk)
1. Create manager classes as Node children or autoloads
2. Move related functions and variables
3. Use composition - Main.gd holds references to managers
4. Update function calls to go through managers

### Phase 3: Refactor Main.gd (High Risk)
1. Main.gd becomes a coordinator/orchestrator
2. Delegates to managers
3. Handles high-level game flow
4. Manages manager lifecycle

## Implementation Approach

### Option A: Composition (Recommended)
- Managers are Node children or separate Node instances
- Main.gd holds references: `@onready var enemy_manager: EnemyManager = $EnemyManager`
- Managers can access Main via `get_parent()` or passed references
- **Pros**: Clear ownership, easy to test, follows Godot patterns
- **Cons**: Requires scene structure changes

### Option B: Autoloads
- Managers as autoload singletons
- **Pros**: Global access, no scene changes needed
- **Cons**: Harder to test, tight coupling, not ideal for game-specific managers

### Option C: Static Classes
- Managers as static utility classes
- **Pros**: No scene changes, simple
- **Cons**: Can't hold state easily, less flexible

## Recommended Structure

```
Main.gd (orchestrator, ~500-800 lines)
├── AssetManager (handles all textures/assets)
├── EnemyManager (handles all enemy logic)
├── CombatManager (handles combat/scoring)
├── ItemManager (handles items/pickups)
├── LevelManager (handles level generation/transitions)
├── FOVManager (handles FOV calculations)
├── HUDManager (handles UI updates)
├── GameStateManager (handles game flow)
└── VisualEffectsManager (handles visual effects)
```

## Migration Steps

1. **Start with utilities** - Extract `GridUtilities` first (lowest risk)
2. **Extract one manager at a time** - Start with `EnemyManager` or `AssetManager`
3. **Test after each extraction** - Ensure game still works
4. **Update tests** - Modify tests to work with new structure
5. **Iterate** - Continue until Main.gd is manageable

## Benefits

- **Readability**: Each file has a single, clear purpose
- **Maintainability**: Changes isolated to relevant manager
- **Testability**: Managers can be tested independently
- **Reusability**: Managers could be reused in other projects
- **Collaboration**: Multiple developers can work on different managers

## Considerations

- **Performance**: Minimal impact - same code, just organized differently
- **Breaking Changes**: Need to update all function calls
- **Testing**: Existing tests will need updates
- **Scene Structure**: May need to add manager nodes to scene

