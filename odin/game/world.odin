package game

import "core:fmt"
import "core:math/rand"

Token :: enum u8 {
	None,
	Knight,
	Bun,
	Butthole,
	Cancel,
	Pawn,
	Bishop,
	Shoppe,
}

Cell :: struct {
	light:  bool,
	hilite: bool,
	token:  Token,
}

Avatar :: struct {
	x, y:                       int,
	buns, maximum_buns:         int,
	health, maximum_health:     int,
	armour:                     int,
	jools:                      int,
	floggers, sprays, lotions:  int,
	shoppe:                     bool,
	xp, xp_goal, xp_level:      int,
}

MESSAGE_CAPACITY :: 15
MESSAGE_LENGTH :: 64

Message :: struct {
	text:   [MESSAGE_LENGTH]u8,
	length: int,
}

// Inclusive range [lo, hi]. Tests replace it to force outcomes.
Random_Proc :: proc(lo, hi: int) -> int

World :: struct {
	cells:         [BOARD_WIDTH][BOARD_HEIGHT]Cell,
	avatar:        Avatar,
	messages:      [MESSAGE_CAPACITY]Message, // newest first
	message_count: int,
	random:        Random_Proc,
}

default_random :: proc(lo, hi: int) -> int {
	return lo + rand.int_max(hi - lo + 1)
}

roll :: proc(w: ^World, lo, hi: int) -> int {
	return w.random(lo, hi)
}

add_message :: proc(w: ^World, format: string, args: ..any) {
	copy(w.messages[1:], w.messages[:MESSAGE_CAPACITY - 1])
	m := &w.messages[0]
	text := fmt.bprintf(m.text[:], format, ..args)
	m.length = len(text)
	w.message_count = min(w.message_count + 1, MESSAGE_CAPACITY)
}

message_text :: proc(w: ^World, index: int) -> string {
	m := &w.messages[index]
	return string(m.text[:m.length])
}

// Token art and tooltips (tokenmanager.lua).
Token_Info :: struct {
	tooltip:   string,
	sprite:    Sprite_Id,
	has_sprite: bool,
}

token_table := [Token]Token_Info {
	.None     = {},
	.Knight   = {"Knight (you)", .Knight, true},
	.Bun      = {"Stickier Buns", .Bun, true},
	.Butthole = {"Butthole (for checking)", .Butthole, true},
	.Cancel   = {"YOU! SHALL NOT! PASS!", .Cancel, true},
	.Pawn     = {"Pawn (enemy)", .Pawn, true},
	.Bishop   = {"Bishop (enemy, for flogging)", .Bishop, true},
	.Shoppe   = {"Shoppe (buy stuff!)", .Shoppe, true},
}
