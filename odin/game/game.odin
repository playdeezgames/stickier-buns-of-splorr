// Pure rules for Stickier Buns of SPLORR!! — no platform imports, so it tests natively.
package game

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720
TILE_WIDTH :: 160
TILE_HEIGHT :: 80
BOARD_WIDTH :: 8
BOARD_HEIGHT :: 8
PAWN_COUNT :: 8
LINE_HEIGHT :: 36
MESSAGE_LINE_HEIGHT :: 18

// A retry cap, not a loop-until: an unbounded "find a free tile" loop freezes the browser tab.
SPAWN_ATTEMPTS :: 1000
