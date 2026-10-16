#+build js
package main

import "core:fmt"
import game "sb:game"

// Draws a frame from the world (main.lua's love.draw). Order matters: it matches the Lua.
render :: proc(w: ^game.World, ui: ^game.UI) {
	fill_rect(0, 0, game.SCREEN_WIDTH, game.SCREEN_HEIGHT, 0x000000)
	draw_board(w, ui)
	if w.avatar.shoppe {
		draw_sprite(.Blur, 0, 0)
	}
	draw_stats(w)
	draw_messages(w)
	draw_tooltip(ui)
	draw_buttons(w, ui)
	draw_dead(w)
}

draw_board :: proc(w: ^game.World, ui: ^game.UI) {
	for x in 0 ..< game.BOARD_WIDTH {
		for y in 0 ..< game.BOARD_HEIGHT {
			cell := w.cells[x][y]
			tile: game.Sprite_Id
			switch {
			case cell.light && cell.hilite:
				tile = .Light_Hilite
			case cell.light:
				tile = .Light
			case cell.hilite:
				tile = .Dark_Hilite
			case:
				tile = .Dark
			}
			px, py := game.plot_xy(x, y)
			fx, fy := f32(px), f32(py)
			draw_sprite(tile, fx, fy)
			if !w.avatar.shoppe && x == ui.cursor_x && y == ui.cursor_y {
				draw_sprite(.Cursor, fx, fy)
			}
			info := game.token_table[cell.token]
			if info.has_sprite {
				draw_sprite(info.sprite, fx, fy)
			}
		}
	}
}


draw_stats :: proc(w: ^game.World) {
	a := &w.avatar
	buf: [64]u8
	y := f32(0)
	line :: proc(buf: []u8, y: ^f32, rgb: u32, format: string, args: ..any) {
		print(.Statistics, fmt.bprintf(buf, format, ..args), 0, y^, rgb)
		y^ += game.LINE_HEIGHT
	}
	// Colours from main.lua's drawStats (0.66 -> 0xA8, 0.33 -> 0x54).
	line(buf[:], &y, 0xA800A8, "Buns: %d/%d", a.buns, a.maximum_buns)
	line(buf[:], &y, 0xFF5454, "Health: %d/%d", a.health, a.maximum_health)
	line(buf[:], &y, 0x54FF00, "Jools: %d", a.jools)
	line(buf[:], &y, 0xFFFF54, "Armour: %d", a.armour)
	line(buf[:], &y, 0x00A8A8, "Floggers: %d", a.floggers)
	line(buf[:], &y, 0xA8A8A8, "Lotions: %d", a.lotions)
	line(buf[:], &y, 0x0000A8, "Trap Sprays: %d", a.sprays)
	line(buf[:], &y, 0xFFFFFF, "XP: %d/%d", a.xp, a.xp_goal)
	line(buf[:], &y, 0xFFFFFF, "Level: %d", a.xp_level)
}

draw_messages :: proc(w: ^game.World) {
	y := f32(game.SCREEN_HEIGHT - game.MESSAGE_LINE_HEIGHT)
	for i in 0 ..< w.message_count {
		print(.Message, game.message_text(w, i), 0, y, 0xFFFFFF)
		y -= game.MESSAGE_LINE_HEIGHT
	}
}

draw_tooltip :: proc(ui: ^game.UI) {
	text := game.ui_tooltip(ui)
	print(.Message, text, f32(game.SCREEN_WIDTH) - measure(.Message, text), 0, 0xFFFFFF)
}

draw_buttons :: proc(w: ^game.World, ui: ^game.UI) {
	for id in game.Button_Id {
		if !game.button_enabled(w, id) {
			continue
		}
		b := game.button_table[id]
		sprite := b.hover_sprite if ui.hover[id] else b.sprite
		draw_sprite(sprite, f32(b.x), f32(b.y))
	}
}

draw_dead :: proc(w: ^game.World) {
	if w.avatar.health > 0 {
		return
	}
	text := "Yer Dead!"
	x := (f32(game.SCREEN_WIDTH) - measure(.Statistics, text)) / 2
	y := (f32(game.SCREEN_HEIGHT) - font_height(game.font_sizes[.Statistics])) / 2
	print(.Statistics, text, x, y, 0xFF0000)
}
