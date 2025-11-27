#!/usr/bin/env bash
set -euo pipefail

# Runs the GUT test suite headlessly.
# Usage: scripts/run_tests.sh

PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

resolve_godot() {
	if [[ -n "${GODOT_BIN:-}" ]]; then
		echo "$GODOT_BIN"
		return
	fi
	if command -v godot4 >/dev/null 2>&1; then
		echo "godot4"
		return
	fi
	if command -v godot >/dev/null 2>&1; then
		echo "godot"
		return
	fi
	# Common macOS path for the official app bundle
	if [[ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]]; then
		echo "/Applications/Godot.app/Contents/MacOS/Godot"
		return
	fi
	echo "Error: Godot binary not found. Set GODOT_BIN to your Godot executable." >&2
	exit 1
}

GODOT_BIN_RESOLVED="$(resolve_godot)"

"$GODOT_BIN_RESOLVED" --headless --path "$PROJECT_PATH" -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit "$@"
