# Itch.io page text

Page: https://thegrumpygamedev.itch.io/stickier-buns-of-splorr
Pasted in by hand; nothing here is published by the repo.

## Short description

A knight, a chessboard, and a dangerous appetite for stickier buns.

## Paste this as the page description

Yer a KNIGHT, and yer hungry. The board is crawling with PAWNS, and somewhere on it are STICKIER BUNS.

**How to play**

Click a lit-up square to jump there. Knights move in an L, so that is the only way ye can go (and ye can't step straight back where ye just came from; the red mark says no). Hover over anything to see what it is.

Every jump costs a bun. Run out of buns and every jump costs health instead, so eat! Stickier Buns give ye 5 more.

**What's on the board**

- **Stickier Buns**: food.
- **Buttholes**: check them for JOOLS, ARMOUR, FLOGGERS or LOTIONS... or a TRAP, or a TELEPORT, or nothing at all. Ye take the chance.
- **Pawns**: they hit ye for 1 (armour soaks it up first), and give ye XP when ye take them.
- **The Bishop**: take the last pawn and a BISHOP turns up. It hits for 3 unless ye flog it with a FLOGGER. Beat it and the pawns come back, and so does...
- **The Shoppe**: spend yer JOOLS on more buns, lotion, floggers, armour and trap spray.

Lotion heals ye all the way. Every level up gives ye another point of health. When ye finally fall, hit Play Again.

**Controls:** mouse only. Click a lit square to move, click the buttons for lotion and the shop.

**Saving:** there isn't any. Close the tab and the run is gone.

**Credits**

Code by TheGrumpyGameDev. Originally made with LÖVE (Lua), rebuilt in Odin for the browser in 2026; the Odin port was written with Claude Code (generative AI).

Icons from [game-icons.net](https://game-icons.net), used under CC BY 3.0: chess knight, bishop and pawn by Skoll; flake and cancel by sbed; dumpling bao by Caro Asercion; flanged mace, liquid soap, exit door and armor upgrade by Delapouite; play button by Guard13007. Font: Antiquity Print by ninjikin (https://ninjikin.itch.io/font-antiquity-script).

## Notes (not for the page)

- Channel `html` via `shippit.sh` (a wrapper for `tools/ship.sh`; pushes only with `--push`). On the page's Edit game screen set "Kind of project" to HTML, tick "This file will be played in the browser", and make the embed 1280 by 720 (it scales).
- The cover is `assets/cover.png` (630 by 500, `tools/make_cover.py`, built from a screenshot, so a regenerated cover has a different random board). Screenshots are in `assets/screenshots/` (`tools/make_screenshots.sh`; they use the `?scene=N` QA hook).
- The icon credits were taken from the source comments in `src/main.lua`; the Game Icons licence is CC BY 3.0, which needs the attribution above. I have not checked the font's licence terms; please confirm.
- The page text discloses that the port was written with Claude Code; remove or reword if you'd rather not. If the edit screen has a generative-AI disclosure field, fill it in to match.
