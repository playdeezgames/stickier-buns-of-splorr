# Odin / WASM Port Plan

Goal: reproduce the LÖVE game (`src/`, ~1250 lines of Lua) as Odin compiled to `js_wasm32`, running in a browser with identical rules and look (1280x720, isometric 8x8 board).

The stack follows the vault's `Tech/Odin wasm recipe.md` (in `/home/yermom/git/bok-of-splorr/splorr`), specifically the **Roomba Rights / Turn Left at the Cow** variant: a pure rules package plus a thin `#+build js` web layer drawing through a 2D-canvas shim. Also relevant: `Tech/Release standard.md` and `Gotchas.md`.

## Stack decisions (settled by the recipe)

- Target `js_wasm32` with Odin's own `core/sys/wasm/js/odin.js`. **No emscripten, no raylib, no WebGL** (WebGL doesn't work on this machine's Chrome or the in-app browser pane).
- Toolchain: Odin at `/home/yermom/ODIN/odin` (`dev-2026-07-nightly`). Build: `odin build odin/web -target:js_wasm32 -out:build/web/game.wasm -o:speed`, then copy `odin.js` from `$(odin root)/core/sys/wasm/js/`. Serve with `python3 -m http.server -d build/web <port>` (not `file://`; pick a port the user isn't using).
- Drawing: a 2D canvas with `imageSmoothingEnabled = false`. Odin imports a few shim procs (`foreign import canvas "canvas"`, key in the third arg of `odin.runWasm`), e.g. `clear(r,g,b)`, `draw_image(sprite_id, x, y)`, `draw_text(font, ptr, len, x, y, r,g,b)`, `text_width(font, ptr, len) -> f32`, `fill_rect`.
- Frame loop: exported `step :: proc(dt: f64, c: runtime.Context) -> bool`; setup in `main`. Mouse via `js.add_window_event_listener(.Mouse_Move / .Mouse_Down, ...)`; every callback sets `context = ctx` first. The recipe's examples use keyboard, so mouse coordinates (`e.mouse.offset`, scaled to the canvas's 1280x720 logical size when CSS-stretched) need checking early.
- Randomness: `rand.reset(u64(time.now()._nsec))` in `main`; **cap every retry loop** (the Lua `spawnToken` is `repeat ... until empty`; the Gotchas note says an unbounded loop freezes the whole tab — use 1000 tries).
- Weighted picks: generic `pick_weighted :: proc(weights: [$E]int, roll: int) -> E` over an enum-indexed array (fixes the Lua `pairs`-order dependence in `butthole.lua`).
- `int` is 32 bits on wasm; nothing here is large, but run the wasm build as well as native tests.
- Constant arrays can't be indexed at runtime: use `:=` not `::` for tables. `raw_data` needs a non-constant string.

## Layout

Keep the Lua in `src/` untouched until the port reaches parity (it is the spec); port in a new tree:

```
odin/game/      package game — rules only, no platform imports (tests run natively)
odin/web/       package main, #+build js — shim imports, input, step loop, HUD drawing
web/index.html  canvas shim: image/font loading, draw procs, runWasm call
assets/         (root assets/ already holds template art; runtime sprites copied to web/assets/)
tools/          build.sh, test.sh, ship.sh, gen_mousemap.py
build.sh, shippit.sh (wrapper), ITCH_DESCRIPTION.md, assets/cover.png (630x500)
```

Compile with `-collection:sb=odin` so `web` imports `sb:game`. Tests: `odin test odin/game -collection:sb=odin -define:ODIN_TEST_THREADS=1`, test file `#+build !js` (`core:testing` pulls in `core:os`, which panics on wasm). `tools/test.sh` should also `odin check` both packages for `js_wasm32`.

## Lua → Odin mapping

| Lua | Odin |
|---|---|
| ID-constant files (`sprites`, `tokens`, `buttons`, `items`, `fonts`, `states`) | `enum`s |
| `*manager` repositories keyed by ID | enum-indexed arrays: `[Sprite_Id]Sprite_Info`, `[Token]Token_Info{tooltip, sprite}` |
| `board.lua` `world` | `World` struct: `cells: [8][8]Cell`, `avatar: Avatar`, `messages` fixed ring (15, newest first) |
| `cell.token` nil/id | `Token` enum, zero value `None` |
| buttons (tooltip/enabler/handler closures) | `[Button_Id]` table of procs taking `^World` (or a `switch`) |
| `statemachine`/`inplaystate` stub | drop (single state); add a `Screen`/state enum only if a title/restart screen is added |
| `love.math.random` | `core:math/rand`; in the logic package take the roll/rng as a parameter so tests can force outcomes |
| `love.graphics.draw(image, x+ox, y+oy)` | `draw_image(id, x+ox, y+oy)`; offsets from `spritemanager.load` (tokens 40,-30; bun 40,-20; butthole/cancel 40,20; rest 0,0) |

## Steps

1. **Skeleton** — `odin/web` `main` + `step` that clears the canvas; `web/index.html` with the canvas shim; `tools/build.sh`; serve and confirm in the browser pane (screenshots lag one step — take two).
2. **Assets** — copy `src/assets/images/*.png` and `antiquity-print.ttf` into `web/assets/`. Image list lives in one Odin table (`IMAGE_FILES`) indexed by `Sprite_Id`; the page reads it or a test pins the order against the page's table. Load the font with `@font-face`/`FontFace` and wait for it, plus all images, before the first frame.
3. **Rules package** — port `board.lua`, `butthole.lua`, `itemmanager.lua` into `odin/game`: `init`, `attempt_move`, knight highlighting, `starve`, `take_damage` (armour then health), `add_xp` (goal doubles, +1 max health per level), butthole outcomes, teleport, `use_lotion`, shop prices (bun upgrade = max buns, lotion 10, flogger 25, armour = armour+1, spray 1), pawn/bishop/shoppe spawning, CANCEL token. Native tests for each, plus a soak test (many random legal moves, no crash, invariants hold) with bounded loops.
4. **Iso math + mouse map** — port `plotXY` and `scroller` (x offset `SCREEN_WIDTH/2 - TILE_WIDTH/2`, y offset `TILE_HEIGHT - 8`). Bake `mousemap.png` (160x80, 4-bit palette: classify each pixel as UL/UR/LL/LR/centre by matching the four corner pixels' colours) with `tools/gen_mousemap.py` into a generated `mousemap_data.odin` (`:=` array). Test: cell results for a grid of screen points against values computed from the Lua version (dump a table by running the Lua mousemap once under `love`).
5. **Drawing** — `web` package renders from `World`: board tiles (light/dark × hilite), cursor (hidden in shoppe), token sprites, stats panel (8 coloured lines, 36px spacing, 24px font), message log (bottom-up, 12px font, 18px lines), right-aligned tooltip (`text_width`), blur overlay in shoppe, centred red "Yer Dead!" at health ≤ 0, buttons (hover sprite; only drawn when enabled). Use `fmt.bprintf` into stack buffers for HUD text.
6. **Input + buttons** — mouse move → hover/cursor/tooltip (button tooltip wins, then token tooltip, blank in shoppe); mouse down → button click else `attempt_move`. **Fix the Lua quirk**: `handleClick` returns nothing, so a button click also triggers a board move; make it return whether it handled the click. Per-frame button enable rules as in `buttonmanager` (lotion: not in shoppe, lotions>0, alive; shop buttons: in shoppe and affordable; leave: in shoppe).
7. **Restart** — Lua HEAD has `PLAY` button/sprite constants and `board.initialize()` (commit "i can restart the game!"). Read the rest of `buttonmanager.lua`'s PLAY wiring and replicate (likely: PLAY enabled when dead, calls `init`).
8. **Parity pass** — play Lua (`love src`) and wasm side by side: messages text, prices, spawn rules (last pawn → bishop; bishop → 8 pawns + shoppe), CANCEL blocks the previous square for a turn, death behaviour. Optionally add the node parity harness from the recipe (`tools/wasm_parity.js` driving exported `proc "c"` functions) if a native-vs-wasm discrepancy shows up.
9. **Ship prep (per Release standard)** — `ITCH_DESCRIPTION.md`, `assets/cover.png` 630x500 (existing `ss/cover.png` should move there; check size), `assets/screenshots/`, `tools/ship.sh` (test → `-o:size` build → zip with `index.html` at root → `butler push` **only with `--push`**), `shippit.sh` wrapper. Use the `html` channel; namespace any `localStorage` key (`sb:...`) since all itch games share an origin. Never run `--push` or `git push` without the user saying so, and ask which one if "push" is ambiguous.
10. **Retire the Lua** — once parity is signed off, decide whether to delete `src/` (history keeps it) and update `CLAUDE.md` with the new build/test/run commands.

## Open questions for the user

- Mouse-only is the Lua behaviour; add keyboard or touch input? (Recipe has touch patterns; default: mouse only, matching the original.)
- Keep the Lua in `src/` alongside `odin/` until parity, or replace in place? (Plan assumes alongside.)
- Itch page slug / target for `ship.sh` (needed only at step 9).
- Fixing the click-through-button bug and the unbounded spawn loop: plan assumes yes.
