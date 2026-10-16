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
}

ctx: runtime.Context
mouse_x, mouse_y: f32

main :: proc() {
	ctx = context
	rand.reset(u64(time.now()._nsec))
	js.add_event_listener("screen", .Mouse_Move, nil, on_mouse_move)
}

on_mouse_move :: proc(e: js.Event) {
	context = ctx
	scale := f32(game.SCREEN_WIDTH) / css_width()
	mouse_x = f32(e.mouse.offset.x) * scale
	mouse_y = f32(e.mouse.offset.y) * scale
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

@(export)
step :: proc(dt: f64, c: runtime.Context) -> bool {
	context = ctx
	fill_rect(0, 0, game.SCREEN_WIDTH, game.SCREEN_HEIGHT, 0x14052e)
	if !assets_ready() {
		return true
	}
	// Step 2 smoke test: every sprite, plus both fonts. Replaced by the real renderer in step 5.
	for id in game.Sprite_Id {
		i := f32(id)
		draw_sprite(id, 8 + f32(int(i) % 10) * 124, 60 + f32(int(i) / 10) * 110)
	}
	print(.Statistics, "Buns: 15/15", 8, 8, 0xa800a8)
	print(.Message, "Antiquity 12px message font", 8, 40, 0xffffff)
	fill_rect(mouse_x - 4, mouse_y - 4, 8, 8, 0xffffff)
	return true
}
