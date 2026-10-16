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
	fill_rect :: proc(x, y, w, h: f32, rgb: u32) ---
	css_width :: proc() -> f32 ---
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

@(export)
step :: proc(dt: f64, c: runtime.Context) -> bool {
	context = ctx
	fill_rect(0, 0, game.SCREEN_WIDTH, game.SCREEN_HEIGHT, 0x14052e)
	fill_rect(mouse_x - 8, mouse_y - 8, 16, 16, 0xffffff)
	return true
}
