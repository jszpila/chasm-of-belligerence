# Repository Guidelines

## Project Structure & Module Organization
- `project.godot`: Godot 4.5 project settings and main scene.
- `scenes/`: Godot scenes (`Main.tscn`, `Player.tscn`). One scene per feature where possible.
- `scripts/`: GDScript sources (`*.gd`) matching scene names (e.g., `Main.gd`).
- `assets/`: Art/audio and export settings (`export_presets.cfg`, `icon.svg`, sprites, sounds). Do not store built exports here.
- `tiles/`: Tile resources (e.g., `Sprites.tileset.tres`).
- `.godot/`: Editor cache; excluded from version control.
- `index-template.html`: Custom HTML shell used by the Web export preset.

## Build, Test, and Development Commands
- Run in editor: `godot4 -e --path .` (binary may be `godot` on your system).
- Play locally: `godot4 --path .` launches the main scene (`res://scenes/Main.tscn`).
- Export Web (release): `godot4 --headless --path . --export-release "Web"` → outputs to `codexquestweb/index.html` per `assets/export_presets.cfg`.
- Clean caches: remove `.godot/` and `*.import` artifacts if imports misbehave (Godot will regenerate).

## Coding Style & Naming Conventions
- Language: GDScript 2 (Godot 4). Indentation: 4 spaces; UTF‑8 (see `.editorconfig`).
- Files: scenes `PascalCase.tscn`, scripts `PascalCase.gd`, assets lowercase with hyphens (e.g., `player-1.png`).
- Names: classes `PascalCase`, functions/variables `snake_case`, constants `UPPER_SNAKE_CASE`, signals `snake_case`.
- Structure: keep scene ↔ script pairing; prefer small, focused nodes and scripts. Avoid global singletons unless necessary.

## Testing Guidelines
- No test framework is committed yet. Recommended: GUT.
- If added, place tests in `tests/` mirroring `scripts/` and name `test_*.gd`.
- Example (when GUT installed): `godot4 --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests`.

## Commit & Pull Request Guidelines
- Commits: use imperative, descriptive messages. Prefer Conventional Commits, e.g., `feat: add goblin AI`, `fix: snap player to grid`.
- PRs: include summary, rationale, before/after notes, and a short clip/screenshot for gameplay changes. Link related issues. Keep diffs focused; avoid committing exports or large binaries not needed for runtime.

## Security & Configuration Tips
- Do not commit credentials (`export_credentials.cfg`) or local exports. Respect asset licenses for third‑party art/audio.
- Exports are configured via `assets/export_presets.cfg`; change paths or HTML shell (`index-template.html`) there.
