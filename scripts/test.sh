#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/home/alejandro/godot/Godot_v4.7.2-stable_linux.x86_64}"

if [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot binary not found or not executable: $GODOT_BIN" >&2
  echo "Set GODOT_BIN to the Godot 4.7.2 binary path." >&2
  exit 127
fi

cd "$ROOT"

echo "==> Importing Godot project"
"$GODOT_BIN" --headless --path "$ROOT" --import

echo "==> Running GUT test suite (headless)"
GUT_LOG="$(mktemp)"
trap 'rm -f "$GUT_LOG"' EXIT

set +e
"$GODOT_BIN" --headless --path "$ROOT" \
  -s addons/gut/gut_cmdln.gd \
  -gdir=res://tests -ginclude_subdirs -gexit 2>&1 | tee "$GUT_LOG"
GUT_STATUS=${PIPESTATUS[0]}
set -e

if [[ $GUT_STATUS -ne 0 ]]; then
  echo "GUT failed with exit code $GUT_STATUS" >&2
  exit "$GUT_STATUS"
fi

if grep -qE "SCRIPT ERROR|Parse Error|GUT ERROR|Nothing was run" "$GUT_LOG"; then
  echo "GUT reported script errors or did not run any tests" >&2
  exit 1
fi

echo "==> Validating OpenSpec artifacts (strict)"
openspec validate --all --strict

echo "==> All checks passed"
