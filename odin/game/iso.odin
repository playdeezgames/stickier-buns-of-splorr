package game

import "core:math"

// Board <-> screen coordinates (scroller.lua, uimanager.plotXY, mousemap.lua).

// Baked from assets/images/mousemap.png by tools/gen_mousemap.py. A variable (not a constant)
// so it can be indexed at runtime.
MOUSEMAP_DATA := #load("mousemap.bin")

MOUSEMAP_WIDTH :: TILE_WIDTH
MOUSEMAP_HEIGHT :: TILE_HEIGHT

Mousemap_Corner :: enum u8 {
	Center,
	Upper_Left,
	Upper_Right,
	Lower_Left,
	Lower_Right,
}

scroll_to_screen :: proc(x, y: int) -> (int, int) {
	return -(TILE_WIDTH / 2) + SCREEN_WIDTH / 2 + x, y + TILE_HEIGHT - 8
}

scroll_from_screen :: proc(x, y: int) -> (int, int) {
	return (TILE_WIDTH / 2) - SCREEN_WIDTH / 2 + x, y - TILE_HEIGHT + 8
}

// Top-left of a board cell's tile on the screen.
plot_xy :: proc(x, y: int) -> (int, int) {
	return scroll_to_screen((x - y) * (TILE_WIDTH / 2), (x + y) * (TILE_HEIGHT / 2))
}

// The board cell under a screen pixel, clamped to the board.
map_xy :: proc(screen_x, screen_y: int) -> (int, int) {
	x, y := scroll_from_screen(screen_x, screen_y)
	grid_x := math.floor_div(x, TILE_WIDTH)
	grid_y := math.floor_div(y, TILE_HEIGHT)
	remainder_x := math.floor_mod(x, TILE_WIDTH)
	remainder_y := math.floor_mod(y, TILE_HEIGHT)
	map_x := grid_y + grid_x
	map_y := grid_y - grid_x
	corner := Mousemap_Corner(MOUSEMAP_DATA[remainder_y * MOUSEMAP_WIDTH + remainder_x])
	switch corner {
	case .Center:
	case .Upper_Left:
		map_x -= 1
	case .Upper_Right:
		map_y -= 1
	case .Lower_Left:
		map_y += 1
	case .Lower_Right:
		map_x += 1
	}
	return clamp(map_x, 0, BOARD_WIDTH - 1), clamp(map_y, 0, BOARD_HEIGHT - 1)
}
