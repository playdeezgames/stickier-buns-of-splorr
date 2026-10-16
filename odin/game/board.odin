package game

knight_deltas := [8][2]int{{-2, -1}, {-2, 1}, {2, -1}, {2, 1}, {-1, -2}, {-1, 2}, {1, -2}, {1, 2}}

in_bounds :: proc(x, y: int) -> bool {
	return x >= 0 && y >= 0 && x < BOARD_WIDTH && y < BOARD_HEIGHT
}

place_token :: proc(w: ^World, x, y: int, token: Token) {
	w.cells[x][y].token = token
}

get_token :: proc(w: ^World, x, y: int) -> Token {
	return w.cells[x][y].token
}

// Puts the token on a random empty cell. After SPAWN_ATTEMPTS misses it takes the first empty
// cell, and reports false only when the board is full.
spawn_token :: proc(w: ^World, token: Token) -> (x, y: int, ok: bool) {
	for _ in 0 ..< SPAWN_ATTEMPTS {
		tx := roll(w, 0, BOARD_WIDTH - 1)
		ty := roll(w, 0, BOARD_HEIGHT - 1)
		if get_token(w, tx, ty) == .None {
			place_token(w, tx, ty, token)
			return tx, ty, true
		}
	}
	for cx in 0 ..< BOARD_WIDTH {
		for cy in 0 ..< BOARD_HEIGHT {
			if get_token(w, cx, cy) == .None {
				place_token(w, cx, cy, token)
				return cx, cy, true
			}
		}
	}
	return 0, 0, false
}

unhilite :: proc(w: ^World) {
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			w.cells[x][y].hilite = false
		}
	}
}

hilite :: proc(w: ^World) {
	unhilite(w)
	if w.avatar.health > 0 {
		for d in knight_deltas {
			x := w.avatar.x + d.x
			y := w.avatar.y + d.y
			if in_bounds(x, y) {
				w.cells[x][y].hilite = true
			}
		}
	}
}

spawn_pawns :: proc(w: ^World) {
	for _ in 0 ..< PAWN_COUNT {
		spawn_token(w, .Pawn)
	}
}

place_avatar :: proc(w: ^World) {
	place_token(w, w.avatar.x, w.avatar.y, .Knight)
}

// random may be nil, in which case the previous one (or the default) is kept.
world_init :: proc(w: ^World, random: Random_Proc = nil) {
	r := random if random != nil else w.random
	if r == nil {
		r = default_random
	}
	w^ = {}
	w.random = r
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			w.cells[x][y].light = (x + y) % 2 == 1
		}
	}
	w.avatar = Avatar {
		x              = roll(w, 0, BOARD_WIDTH - 1),
		y              = roll(w, 0, BOARD_HEIGHT - 1),
		buns           = 15,
		maximum_buns   = 15,
		health         = 3,
		maximum_health = 3,
		armour         = 5,
		xp_goal        = 5,
	}
	place_avatar(w)
	hilite(w)
	spawn_token(w, .Bun)
	spawn_token(w, .Butthole)
	spawn_pawns(w)
}

uncancel :: proc(w: ^World) {
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			if get_token(w, x, y) == .Cancel {
				place_token(w, x, y, .None)
			}
		}
	}
}

change_buns :: proc(w: ^World, delta: int) {
	w.avatar.buns = clamp(w.avatar.buns + delta, 0, w.avatar.maximum_buns)
}

change_health :: proc(w: ^World, delta: int) {
	w.avatar.health = clamp(w.avatar.health + delta, 0, w.avatar.maximum_health)
}

starve :: proc(w: ^World) {
	if w.avatar.buns > 0 {
		change_buns(w, -1)
	} else {
		change_health(w, -1)
	}
}

teleport :: proc(w: ^World) {
	place_token(w, w.avatar.x, w.avatar.y, .None)
	unhilite(w)
	x, y, ok := spawn_token(w, .Knight)
	if !ok { 	// cannot happen (we just freed a cell); keep the knight where it was
		place_avatar(w)
	} else {
		w.avatar.x, w.avatar.y = x, y
	}
	hilite(w)
	add_message(w, "You teleported!")
}

take_damage :: proc(w: ^World, damage: int) {
	add_message(w, "You take %d damage!", damage)
	remaining := damage
	armour_cost := min(remaining, w.avatar.armour)
	w.avatar.armour -= armour_cost
	remaining -= armour_cost
	health_cost := min(remaining, w.avatar.health)
	w.avatar.health -= health_cost
	if armour_cost > 0 {
		add_message(w, "-%d armour!", armour_cost)
	}
	if health_cost > 0 {
		add_message(w, "-%d health!", health_cost)
	}
	if w.avatar.health <= 0 {
		unhilite(w)
	}
}

trap :: proc(w: ^World) {
	add_message(w, "You trigger a trap!")
	if w.avatar.sprays > 0 {
		add_message(w, "-1 Trap Spray")
		w.avatar.sprays -= 1
	} else {
		take_damage(w, 1)
	}
}

apply_butthole_result :: proc(w: ^World, result: Butthole_Result) {
	switch result {
	case .Nothing:
	case .Jools:
		jools := 3 + roll(w, 1, 3) + roll(w, 1, 3)
		w.avatar.jools += jools
		add_message(w, "+%d Jools!", jools)
	case .Trap:
		trap(w)
	case .Teleport:
		teleport(w)
	case .Armour:
		w.avatar.armour += 1
		add_message(w, "+1 Armour!")
	case .Flogger:
		w.avatar.floggers += 1
		add_message(w, "+1 Flogger!")
	case .Lotion:
		w.avatar.lotions += 1
		add_message(w, "+1 lotion!")
	}
}

check_butthole :: proc(w: ^World) {
	add_message(w, "Checking butthole...")
	total := weights_total(butthole_weights)
	apply_butthole_result(w, pick_weighted(butthole_weights, roll(w, 0, total - 1)))
}

pawn_count :: proc(w: ^World) -> int {
	count := 0
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			if get_token(w, x, y) == .Pawn {
				count += 1
			}
		}
	}
	return count
}

add_xp :: proc(w: ^World, xp: int) {
	a := &w.avatar
	a.xp += xp
	add_message(w, "+%d XP", xp)
	level := a.xp_level
	for a.xp >= a.xp_goal {
		a.xp -= a.xp_goal
		a.xp_goal *= 2
		a.xp_level += 1
		a.maximum_health += 1
	}
	if a.xp_level > level {
		add_message(w, "Yer now level %d", a.xp_level)
	}
}

attack_pawn :: proc(w: ^World) {
	take_damage(w, 1)
	add_xp(w, 1)
	if pawn_count(w) == 0 {
		spawn_token(w, .Bishop)
	}
}

attack_bishop :: proc(w: ^World) {
	if w.avatar.floggers > 0 {
		add_message(w, "-1 flogger!")
		w.avatar.floggers -= 1
	} else {
		take_damage(w, 3)
	}
	add_xp(w, 3)
	spawn_pawns(w)
	spawn_token(w, .Shoppe)
}

attempt_move :: proc(w: ^World, x, y: int) {
	if w.avatar.shoppe || !in_bounds(x, y) || !w.cells[x][y].hilite {
		return
	}
	starve(w)
	uncancel(w)
	cancel_x, cancel_y := w.avatar.x, w.avatar.y
	place_token(w, cancel_x, cancel_y, .Cancel)
	token := get_token(w, x, y)
	w.avatar.x, w.avatar.y = x, y
	place_avatar(w)
	hilite(w)
	w.cells[cancel_x][cancel_y].hilite = false
	#partial switch token {
	case .Bun:
		add_message(w, "+5 buns")
		spawn_token(w, .Bun)
		change_buns(w, 5)
	case .Butthole:
		check_butthole(w)
		spawn_token(w, .Butthole)
	case .Pawn:
		attack_pawn(w)
	case .Bishop:
		attack_bishop(w)
	case .Shoppe:
		w.avatar.shoppe = true
	}
}

use_lotion :: proc(w: ^World) {
	if w.avatar.lotions <= 0 {
		return
	}
	w.avatar.lotions -= 1
	healing := w.avatar.maximum_health - w.avatar.health
	w.avatar.health = w.avatar.maximum_health
	add_message(w, "-1 lotion")
	add_message(w, "+%d health", healing)
}
