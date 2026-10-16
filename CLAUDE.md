# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Stickier Buns of SPLORR!!" is a small isometric 8x8 chess-board roguelike: you are a Knight that moves only in knight-L jumps, eating Buns (food), checking Buttholes (random loot/trap), killing Pawns/Bishops for XP, and buying upgrades at a Shoppe.

The game is being **ported from LÖVE2D (Lua) to Odin compiled to WebAssembly**. The port is playable and rule-for-rule identical to the Lua (verified by a differential test). Two trees coexist:

- `odin/` + `web/` — the port (the future). Work here.
- `src/` — the original LÖVE 11.5 game, kept as the behavioural reference and as the source of the test oracles. Run it with `love src`. Don't add features to it.

Port plan and status: `PORT_PLAN.md` (steps 1-8 done; step 7 was folded into 6; remaining: ship prep and retiring the Lua). The author's recipes live in the vault at `/home/yermom/git/bok-of-splorr/splorr` (`Tech/Odin wasm recipe.md`, `Tech/Release standard.md`, `Gotchas.md`); this port follows the "pure rules package + thin web layer" variant.

Itch page: https://thegrumpygamedev.itch.io/stickier-buns-of-splorr (slug `stickier-buns-of-splorr`; new pages use channel `html`). Never run `butler push` or `git push` unless the user says to; if "push" is ambiguous, ask which.

## Commands

Odin is at `/home/yermom/ODIN/odin` (nightly `dev-2026-07-nightly`); scripts honour `$ODIN`.

```bash
tools/test.sh    # native tests (-o:speed, single thread) + `odin check` of both packages for js_wasm32
tools/build.sh   # builds build/web (game.wasm, odin.js, index.html, assets/) — what gets shipped
```

Run a single test: `odin test odin/game -collection:sb=odin -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_NAMES=game.test_lotion`

Serve for manual play: `python3 -m http.server <port> --bind 127.0.0.1 -d build/web` (must be http, not `file://`). Other sessions may be using ports — check with `ss -ltn` first, and kill only the server you started (by pid; `pkill -f` kills your own shell).

Regenerating oracles (only when the Lua or art changes): `python3 tools/gen_mousemap.py` (needs Pillow; writes `odin/game/mousemap.bin`), `tools/gen_lua_reference.sh` (runs the Lua under headless `love`, writes `testdata/iso_reference.txt`), `lua5.4 tools/lua_trace.lua > odin/game/testdata/lua_trace.txt` (from repo root).

## Architecture (Odin port)

Always build with `-collection:sb=odin` so `odin/web` imports `sb:game`.

- `odin/game` (package `game`): **pure rules, no platform imports**, so it tests natively. Never import `core:os` here or in anything compiled for wasm (it panics at startup on `js_wasm32`); platform code goes in `#+build js` files and the test file is `#+build !js`.
  - `world.odin`: `World` (cells, avatar, message log newest-first, injectable `random` proc), `Token` enum + `token_table` (tooltips/sprites).
  - `board.odin`: all rules (`world_init`, `attempt_move`, damage, XP, butthole effects, teleport, lotion). `items.odin`: shop prices/`buy`. `butthole.odin`: weights + generic `pick_weighted` (fixed enum order).
  - `iso.odin`: board↔screen math and `map_xy` (mouse → cell), which looks pixels up in `mousemap.bin`, a baked copy of `mousemap.png` classifying pixels as centre/UL/UR/LL/LR corner.
  - `buttons.odin`: button layout/enable rules/tooltips/actions (Play restarts via `world_init`). `ui.odin`: hover/cursor/tooltip state and `ui_mouse_pressed` (a button click never also moves the knight — a deliberate fix of a Lua bug).
  - `sprites.odin`: `Sprite_Id`/`sprite_table` (file + draw offsets) and fonts. **Order of `Sprite_Id` is load-bearing**: the page loads images by index via exported `image_count/image_path_ptr/image_path_len`.
- `odin/web` (package `main`, `#+build js`): `web.odin` has the shim imports (`foreign import canvas "canvas"`), mouse listeners, exported `step` frame loop; `render.odin` draws a frame from `World` in the same order as the Lua `love.draw`.
- `web/index.html`: the 2D-canvas shim (draw image/text, text metrics), asset preloading (images + Antiquity font; the game waits on `assets_ready`), `odin.runWasm("game.wasm", null, imports, memory)`. Canvas is a fixed 1280x720 logical screen, CSS-scaled; mouse coordinates are rescaled in `logical_xy`. `web/assets/` holds the runtime images/font.
- Randomness: `core:math/rand`, seeded in `main`. All "find a free tile" loops are capped (`SPAWN_ATTEMPTS`), because an unbounded loop freezes the whole browser tab. `int` is 32-bit on wasm.

## Tests

`odin/game/game_test.odin` has unit tests, two soak tests (the "immortal" one tops up health/armour/buns so the knight reaches bishops and the shop), and two oracle tests that must stay green:
- `test_iso_matches_lua`: `plot_xy`/`map_xy` against 4,320 answers recorded from the real Lua.
- `test_parity_with_lua_trace`: replays a scripted policy with identical LCG random streams through both implementations and compares full-state checksums (avatar, board, highlights, button enable flags, messages) — a rule change in Odin that isn't mirrored in the Lua (or vice versa) fails here at a named seed/step. The Lua side swaps `pairs` iteration in `butthole.check` for a fixed order so the two line up.

Rendering is not covered by tests; check it by eye in the browser pane (its screenshots lag one step — take a second one).

## Original Lua game (`src/`) — reference

LÖVE module layout, same ID+manager pattern the Odin enums replaced: `board.lua` holds the single `world` and all rules; `spritemanager/tokenmanager/buttonmanager/itemmanager/fontmanager` fill private repositories from ID files in `load()`; `mousemap.lua` + `uimanager.lua` + `scroller.lua` do the isometric mapping; `main.lua` has the callbacks and HUD drawing; `statemachine/inplaystate` are an unused one-state stub. `src/.vscode/launch.json` hardcodes a Windows `love.exe` path. `assets/` at the repo root is source/template art only.
