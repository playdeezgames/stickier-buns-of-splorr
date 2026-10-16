#!/usr/bin/env bash
# Native tests for the rules package, then a wasm check of both packages.
set -euo pipefail
cd "$(dirname "$0")/.."
ODIN="${ODIN:-/home/yermom/ODIN/odin}"
FLAGS="-collection:sb=odin -vet-shadowing -vet-unused"
"$ODIN" test odin/game $FLAGS -o:speed -define:ODIN_TEST_THREADS=1
"$ODIN" check odin/game $FLAGS -target:js_wasm32 -no-entry-point
"$ODIN" check odin/web $FLAGS -target:js_wasm32
echo "tests ok"
