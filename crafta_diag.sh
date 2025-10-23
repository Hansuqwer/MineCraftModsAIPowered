#!/usr/bin/env bash
set -e

ROOT="$(pwd)"
ASSET_DIR="assets/3d_preview/black_dragon"
PUBSPEC="pubspec.yaml"

echo "== Crafta 3D Preview Diagnostic =="
echo "Project: $ROOT"
echo

# 1) Check files
MISSING=0
for f in preview.html black_dragon.glb black_dragon.png; do
  if [ ! -f "$ASSET_DIR/$f" ]; then
    echo "❌ Missing: $ASSET_DIR/$f"
    MISSING=1
  else
    echo "✅ Found:   $ASSET_DIR/$f"
  fi
done
echo

# 2) Check pubspec.yaml entries
echo "== pubspec.yaml asset entries =="
grep -n "assets/3d_preview/black_dragon" "$PUBSPEC" || echo "❌ No asset lines for black_dragon in pubspec.yaml"
echo

# 3) Check Babylon CDN reachability (basic)
echo "== Checking internet for Babylon CDN =="
if command -v curl >/dev/null 2>&1; then
  curl -sI https://cdn.babylonjs.com/babylon.js | head -n 1 || true
else
  echo "⚠️ curl not installed; skipping."
fi
echo

# 4) Print tree (if available)
if command -v tree >/dev/null 2>&1; then
  echo "== Folder tree =="
  tree -a "$ASSET_DIR" || true
fi

echo
echo "== Next steps =="
if [ $MISSING -ne 0 ]; then
  echo "• Add the missing files above and re-run this script."
fi
echo "• Ensure pubspec.yaml lists the three files and run: flutter clean && flutter pub get"
echo "• Rebuild: flutter run  (or build apk) and test again."
