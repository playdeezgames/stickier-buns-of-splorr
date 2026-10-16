#!/usr/bin/env bash
# Builds the web game into build/web (what gets shipped).
set -euo pipefail
cd "$(dirname "$0")/.."
ODIN="${ODIN:-/home/yermom/ODIN/odin}"
mkdir -p build/web
"$ODIN" build odin/web -collection:sb=odin -target:js_wasm32 -out:build/web/game.wasm -o:speed -vet-shadowing -vet-unused
cp "$("$ODIN" root)/core/sys/wasm/js/odin.js" build/web/
cp web/index.html build/web/
cp -r web/assets build/web/
echo "built build/web"
