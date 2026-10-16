# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Stickier Buns of SPLORR!!" is a small LÖVE2D (Lua, LÖVE 11.5, LuaJIT) game: an isometric 8x8 chess-board roguelike. You are a Knight that moves only in knight-L jumps, eating Buns (food), checking Buttholes (random loot/trap), killing Pawns/Bishops for XP, and buying upgrades at a Shoppe. The project is planned to be **ported to an Odin/WASM stack**, so the Lua source is effectively the reference spec for behaviour.

All game code lives in `src/` (this is the LÖVE game root; `assets/` at the repo root holds only source/template art, runtime images are in `src/assets/`). There is no test suite, linter, or build script.

## Commands

Run from the repo root (LÖVE must be installed):

```bash
love src
```

- Debug (VS Code `lua-local` debugger, see `src/.vscode/launch.json`): launches with the extra arg `debug`, which makes `main.lua` call `require("lldebugger").start()`. The launch config hardcodes a Windows path to `love.exe`.
- Package: `7z a -tzip -r ..\stickier.love *` run inside `src/` (noted in `main.lua`). `stickier.love` and `index.html` are gitignored build outputs.
- Window is fixed 1280x720, non-resizable (`src/conf.lua`).

## Architecture

Plain Lua modules (`local M = {}` ... `return M`), loaded with `require("name")` relative to `src/`. No classes/OOP library; "instances" are tables with closures (`statemachine.create()`, `button.create(...)`).

**Single global game state** lives in `board.lua`: `board.getWorld()` returns `world = {board[x][y], avatar, messages}`. `board.initialize()` resets it (used for restart). All game rules (movement, `attemptMove`, damage/armour, hunger via `starve`, XP/levelling, butthole outcomes, teleport, lotion) are in `board.lua`; `itemmanager.lua` handles shop prices/purchases and mutates `world.avatar` directly. Rendering code reads `world` but never owns it.

**Data-driven "ID + manager" pattern** — repeated across the codebase:
- `sprites.lua`, `tokens.lua`, `buttons.lua`, `items.lua`, `fonts.lua`, `states.lua` are pure string-constant ID tables.
- `spritemanager`, `tokenmanager`, `buttonmanager`, `itemmanager`, `fontmanager` each have `load()` (called from `love.load` in `main.lua`) that fills a private `repository` keyed by ID, and `getX(id)` accessors. To add a new entity type you touch the ID file plus the matching manager `load()` (e.g. a new token needs an entry in `tokens.lua`, `tokenmanager.load`, a sprite in `sprites.lua` + `spritemanager.load`, and the PNG in `src/assets/images/`).
- `buttonmanager.lua` registers each button with parallel tables of tooltip/enabler/handler functions keyed by button ID; layout positions come from `constants.lua`.

**Isometric coordinate pipeline** (important when porting):
- `uimanager.plotXY(x,y)` converts board cell -> screen via the iso formula `((x-y)*TILE_W/2, (x+y)*TILE_H/2)` then `scroller.toScreen` (centres the board; `scroller.fromScreen` is the inverse).
- Mouse -> cell: `uimanager.mapXY` -> `mousemap.mapXY` un-scrolls the pixel, computes the coarse diamond cell, then looks up the pixel's colour in `assets/images/mousemap.png` (corner colours = UL/UR/LL/LR vs. centre) to adjust the cell by one. The mousemap image is loaded as ImageData at startup and is load-bearing — a port must reproduce this lookup (or the equivalent geometry).
- Sprites have per-sprite draw offsets (`spritemanager.load`) since token art is taller than a tile.

**Input/draw flow**: `main.lua` defines the LÖVE callbacks and all HUD drawing (`drawBoard`, `drawStats`, `drawMessages`, tooltip, buttons, "Yer Dead!"). `love.mousepressed` first lets `buttonmanager.handleClick` consume the click, otherwise calls `board.attemptMove(cursor)`. A `statemachine`/`inplaystate` skeleton exists but only has the one `IN_PLAY` state with empty handlers; the real logic is still in `main.lua`/`board.lua`.

**Game-rule notes**: moves are only legal onto highlighted cells (knight deltas, `board.lua`); each move costs a bun, and at 0 buns costs health instead. The previous cell gets a `CANCEL` token for one turn (can't move back). Killing the last Pawn spawns a Bishop; killing a Bishop respawns pawns and a Shoppe; `world.avatar.shoppe` flips the UI into shop mode (board input blocked, blur overlay, shop buttons enabled). Butthole outcomes use weighted random tables in `butthole.lua`. Randomness uses `love.math.random` throughout.
