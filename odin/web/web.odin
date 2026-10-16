#+build js
package main

import "base:runtime"
import "core:sys/wasm/js"
import "core:math/rand"
import "core:time"
import game "sb:game"

foreign import canvas "canvas"
@(default_calling_convention = "contextless")
foreign canvas {
	fill_rect    :: proc(x, y, w, h: f32, rgb: u32) ---
	css_width    :: proc() -> f32 ---
	assets_ready :: proc() -> bool ---
	draw_image   :: proc(sprite: i32, x, y: f32) ---
	draw_text    :: proc(size: i32, text: [^]u8, length: i32, x, y: f32, rgb: u32) ---
	text_width   :: proc(size: i32, text: [^]u8, length: i32) -> f32 ---
	font_height  :: proc(size: i32) -> f32 ---
}

ctx: runtime.Context
world: game.World
ui: game.UI

main :: proc() {
	ctx = context
	rand.reset(u64(time.now()._nsec))
	game.world_init(&world)
	js.add_event_listener("screen", .Mouse_Move, nil, on_mouse_move)
	js.add_event_listener("screen", .Mouse_Down, nil, on_mouse_down)
}

// Pointer position in the 1280x720 logical screen.
logical_xy :: proc(e: js.Event) -> (int, int) {
	scale := f32(game.SCREEN_WIDTH) / css_width()
	return int(f32(e.mouse.offset.x) * scale), int(f32(e.mouse.offset.y) * scale)
}

on_mouse_move :: proc(e: js.Event) {
	context = ctx
	x, y := logical_xy(e)
	game.ui_mouse_moved(&ui, &world, x, y)
}

on_mouse_down :: proc(e: js.Event) {
	context = ctx
	x, y := logical_xy(e)
	game.ui_mouse_pressed(&ui, &world, x, y)
}

// The page reads the image list through these, so the table lives only in Odin.
@(export)
image_count :: proc "c" () -> i32 {
	return i32(len(game.Sprite_Id))
}

@(export)
image_path_ptr :: proc "c" (i: i32) -> [^]u8 {
	return raw_data(game.sprite_table[game.Sprite_Id(i)].file)
}

@(export)
image_path_len :: proc "c" (i: i32) -> i32 {
	return i32(len(game.sprite_table[game.Sprite_Id(i)].file))
}

draw_sprite :: proc(id: game.Sprite_Id, x, y: f32) {
	info := game.sprite_table[id]
	draw_image(i32(id), x + f32(info.offset_x), y + f32(info.offset_y))
}

print :: proc(font: game.Font_Id, s: string, x, y: f32, rgb: u32) {
	text := s
	draw_text(game.font_sizes[font], raw_data(text), i32(len(text)), x, y, rgb)
}

measure :: proc(font: game.Font_Id, s: string) -> f32 {
	text := s
	return text_width(game.font_sizes[font], raw_data(text), i32(len(text)))
}

@(export)
step :: proc(dt: f64, c: runtime.Context) -> bool {
	context = ctx
	if !assets_ready() {
		fill_rect(0, 0, game.SCREEN_WIDTH, game.SCREEN_HEIGHT, 0x000000)
		return true
	}
	game.ui_update_tooltip(&ui, &world)
	render(&world, &ui)
	return true
}
