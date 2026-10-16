#+build !js
package game

import "core:log"
import "core:strconv"
import "core:strings"
import "core:testing"

// Empties the board except for the knight.
clear_board :: proc(w: ^World) {
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			if w.cells[x][y].token != .Knight {
				w.cells[x][y].token = .None
			}
		}
	}
}

set_avatar :: proc(w: ^World, x, y: int) {
	place_token(w, w.avatar.x, w.avatar.y, .None)
	w.avatar.x, w.avatar.y = x, y
	place_avatar(w)
	hilite(w)
}

// A world with only the knight on it, at (x, y).
bare_world :: proc(x, y: int) -> World {
	w: World
	world_init(&w)
	clear_board(&w)
	set_avatar(&w, x, y)
	return w
}

count_tokens :: proc(w: ^World, token: Token) -> int {
	n := 0
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			if w.cells[x][y].token == token {
				n += 1
			}
		}
	}
	return n
}

count_hilites :: proc(w: ^World) -> int {
	n := 0
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			if w.cells[x][y].hilite {
				n += 1
			}
		}
	}
	return n
}

@(test)
test_init_layout :: proc(t: ^testing.T) {
	for _ in 0 ..< 50 {
		w: World
		world_init(&w)
		testing.expect_value(t, count_tokens(&w, .Knight), 1)
		testing.expect_value(t, count_tokens(&w, .Bun), 1)
		testing.expect_value(t, count_tokens(&w, .Butthole), 1)
		testing.expect_value(t, count_tokens(&w, .Pawn), PAWN_COUNT)
		testing.expect_value(t, get_token(&w, w.avatar.x, w.avatar.y), Token.Knight)
		testing.expect_value(t, w.avatar.buns, 15)
		testing.expect_value(t, w.avatar.health, 3)
		testing.expect_value(t, w.avatar.armour, 5)
	}
	w: World
	world_init(&w)
	testing.expect(t, !w.cells[0][0].light)
	testing.expect(t, w.cells[1][0].light)
	testing.expect(t, w.cells[1][1].light == false)
}

@(test)
test_hilite_counts :: proc(t: ^testing.T) {
	w := bare_world(0, 0)
	testing.expect_value(t, count_hilites(&w), 2)
	testing.expect(t, w.cells[2][1].hilite)
	testing.expect(t, w.cells[1][2].hilite)
	set_avatar(&w, 3, 3)
	testing.expect_value(t, count_hilites(&w), 8)
	set_avatar(&w, 7, 7)
	testing.expect_value(t, count_hilites(&w), 2)
}

@(test)
test_illegal_move_ignored :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	attempt_move(&w, 4, 3) // not a knight move
	testing.expect_value(t, w.avatar.x, 3)
	testing.expect_value(t, w.avatar.buns, 15)
	attempt_move(&w, -1, 0)
	attempt_move(&w, 8, 8)
	testing.expect_value(t, w.avatar.x, 3)
	testing.expect_value(t, w.message_count, 0)
}

@(test)
test_move_costs_bun_then_health :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	attempt_move(&w, 5, 4)
	testing.expect_value(t, w.avatar.buns, 14)
	testing.expect_value(t, w.avatar.health, 3)
	w.avatar.buns = 0
	attempt_move(&w, 7, 5)
	testing.expect_value(t, w.avatar.health, 3 - 1)
	testing.expect_value(t, w.avatar.buns, 0)
}

@(test)
test_cancel_token :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	attempt_move(&w, 5, 4)
	testing.expect_value(t, get_token(&w, 3, 3), Token.Cancel)
	testing.expect(t, !w.cells[3][3].hilite) // can't go straight back
	testing.expect_value(t, get_token(&w, 5, 4), Token.Knight)
	attempt_move(&w, 3, 3) // ignored
	testing.expect_value(t, w.avatar.x, 5)
	attempt_move(&w, 7, 5) // a different move; the old cancel clears, a new one appears
	testing.expect_value(t, get_token(&w, 3, 3), Token.None)
	testing.expect_value(t, get_token(&w, 5, 4), Token.Cancel)
	testing.expect_value(t, count_tokens(&w, .Cancel), 1)
}

@(test)
test_eat_bun :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	place_token(&w, 5, 4, .Bun)
	w.avatar.buns = 10
	attempt_move(&w, 5, 4)
	testing.expect_value(t, w.avatar.buns, 14) // -1 for the move, +5, clamped to 15? 10-1+5 = 14
	testing.expect_value(t, count_tokens(&w, .Bun), 1) // a new one spawned
	testing.expect_value(t, message_text(&w, 0), "+5 buns")

	w.avatar.buns = 15
	place_token(&w, 7, 5, .Bun)
	attempt_move(&w, 7, 5)
	testing.expect_value(t, w.avatar.buns, 15) // clamped at maximum
}

@(test)
test_damage_armour_first :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	w.avatar.armour = 2
	take_damage(&w, 3)
	testing.expect_value(t, w.avatar.armour, 0)
	testing.expect_value(t, w.avatar.health, 2)
	testing.expect_value(t, message_text(&w, 2), "You take 3 damage!")
	testing.expect_value(t, message_text(&w, 1), "-2 armour!")
	testing.expect_value(t, message_text(&w, 0), "-1 health!")
	take_damage(&w, 10)
	testing.expect_value(t, w.avatar.health, 0)
	testing.expect_value(t, count_hilites(&w), 0) // dead: nowhere to go
}

@(test)
test_dead_cannot_move :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	w.avatar.health = 0
	hilite(&w)
	testing.expect_value(t, count_hilites(&w), 0)
	attempt_move(&w, 5, 4)
	testing.expect_value(t, w.avatar.x, 3)
}

@(test)
test_xp_levelling :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	add_xp(&w, 4)
	testing.expect_value(t, w.avatar.xp_level, 0)
	add_xp(&w, 1)
	testing.expect_value(t, w.avatar.xp_level, 1)
	testing.expect_value(t, w.avatar.xp, 0)
	testing.expect_value(t, w.avatar.xp_goal, 10)
	testing.expect_value(t, w.avatar.maximum_health, 4)
	testing.expect_value(t, message_text(&w, 0), "Yer now level 1")

	w = bare_world(3, 3)
	add_xp(&w, 15) // 15 -> 10 (goal 10) -> 0 (goal 20): two levels at once
	testing.expect_value(t, w.avatar.xp_level, 2)
	testing.expect_value(t, w.avatar.xp, 0)
	testing.expect_value(t, w.avatar.xp_goal, 20)
	testing.expect_value(t, w.avatar.maximum_health, 5)
}

@(test)
test_pawn_and_bishop :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	place_token(&w, 5, 4, .Pawn)
	place_token(&w, 7, 7, .Pawn)
	attempt_move(&w, 5, 4)
	testing.expect_value(t, w.avatar.armour, 4)
	testing.expect_value(t, w.avatar.xp, 1)
	testing.expect_value(t, count_tokens(&w, .Bishop), 0) // one pawn left

	// Kill the last pawn: a bishop appears.
	place_token(&w, 7, 5, .None)
	set_avatar(&w, 5, 4)
	place_token(&w, 7, 3, .Pawn)
	place_token(&w, 7, 7, .None)
	attempt_move(&w, 7, 3)
	testing.expect_value(t, count_tokens(&w, .Pawn), 0)
	testing.expect_value(t, count_tokens(&w, .Bishop), 1)

	// Kill the bishop with a flogger: no damage, 8 pawns and a shoppe.
	w = bare_world(3, 3)
	w.avatar.floggers = 1
	place_token(&w, 5, 4, .Bishop)
	attempt_move(&w, 5, 4)
	testing.expect_value(t, w.avatar.floggers, 0)
	testing.expect_value(t, w.avatar.armour, 5)
	testing.expect_value(t, w.avatar.xp, 3)
	testing.expect_value(t, count_tokens(&w, .Pawn), PAWN_COUNT)
	testing.expect_value(t, count_tokens(&w, .Shoppe), 1)

	// Without a flogger a bishop hits for 3.
	w = bare_world(3, 3)
	place_token(&w, 5, 4, .Bishop)
	attempt_move(&w, 5, 4)
	testing.expect_value(t, w.avatar.armour, 2)
}

@(test)
test_shoppe_blocks_moves :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	place_token(&w, 5, 4, .Shoppe)
	attempt_move(&w, 5, 4)
	testing.expect(t, w.avatar.shoppe)
	attempt_move(&w, 7, 5)
	testing.expect_value(t, w.avatar.x, 5)
	w.avatar.shoppe = false
	attempt_move(&w, 7, 5)
	testing.expect_value(t, w.avatar.x, 7)
}

@(test)
test_lotion :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	use_lotion(&w) // none owned: nothing happens
	testing.expect_value(t, w.message_count, 0)
	w.avatar.lotions = 2
	w.avatar.health = 1
	use_lotion(&w)
	testing.expect_value(t, w.avatar.health, 3)
	testing.expect_value(t, w.avatar.lotions, 1)
	testing.expect_value(t, message_text(&w, 1), "-1 lotion")
	testing.expect_value(t, message_text(&w, 0), "+2 health")
}

@(test)
test_items :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	testing.expect_value(t, item_price(&w, .Bun_Upgrade), 15)
	testing.expect_value(t, item_price(&w, .Lotion), 10)
	testing.expect_value(t, item_price(&w, .Flogger), 25)
	testing.expect_value(t, item_price(&w, .Armour), 6)
	testing.expect_value(t, item_price(&w, .Spray), 1)
	w.avatar.jools = 100
	testing.expect(t, !can_buy(&w, .Lotion)) // not in the shoppe
	w.avatar.shoppe = true
	testing.expect(t, can_buy(&w, .Lotion))
	buy(&w, .Bun_Upgrade)
	testing.expect_value(t, w.avatar.maximum_buns, 16)
	testing.expect_value(t, w.avatar.jools, 85)
	buy(&w, .Armour)
	testing.expect_value(t, w.avatar.armour, 6)
	testing.expect_value(t, item_price(&w, .Armour), 7)
	buy(&w, .Spray)
	buy(&w, .Lotion)
	buy(&w, .Flogger)
	testing.expect_value(t, w.avatar.sprays, 1)
	testing.expect_value(t, w.avatar.lotions, 1)
	testing.expect_value(t, w.avatar.floggers, 1)
	testing.expect_value(t, w.avatar.jools, 85 - 6 - 1 - 10 - 25)
	testing.expect_value(t, message_text(&w, 0), "+1 Flogger(1)")
	w.avatar.jools = 9
	testing.expect(t, !can_buy(&w, .Lotion))
}

@(test)
test_pick_weighted :: proc(t: ^testing.T) {
	total := weights_total(butthole_weights)
	testing.expect_value(t, total, 135)
	// Boundaries between consecutive outcomes, in enum order.
	testing.expect_value(t, pick_weighted(butthole_weights, 0), Butthole_Result.Nothing)
	testing.expect_value(t, pick_weighted(butthole_weights, 9), Butthole_Result.Nothing)
	testing.expect_value(t, pick_weighted(butthole_weights, 10), Butthole_Result.Jools)
	testing.expect_value(t, pick_weighted(butthole_weights, 49), Butthole_Result.Jools)
	testing.expect_value(t, pick_weighted(butthole_weights, 50), Butthole_Result.Trap)
	testing.expect_value(t, pick_weighted(butthole_weights, 70), Butthole_Result.Teleport)
	testing.expect_value(t, pick_weighted(butthole_weights, 80), Butthole_Result.Armour)
	testing.expect_value(t, pick_weighted(butthole_weights, 120), Butthole_Result.Flogger)
	testing.expect_value(t, pick_weighted(butthole_weights, 125), Butthole_Result.Lotion)
	testing.expect_value(t, pick_weighted(butthole_weights, total - 1), Butthole_Result.Lotion)
}

@(test)
test_butthole_results :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	apply_butthole_result(&w, .Nothing)
	testing.expect_value(t, w.message_count, 0)
	apply_butthole_result(&w, .Jools)
	testing.expect(t, w.avatar.jools >= 5 && w.avatar.jools <= 9)
	apply_butthole_result(&w, .Armour)
	testing.expect_value(t, w.avatar.armour, 6)
	apply_butthole_result(&w, .Flogger)
	testing.expect_value(t, w.avatar.floggers, 1)
	apply_butthole_result(&w, .Lotion)
	testing.expect_value(t, w.avatar.lotions, 1)
	w.avatar.sprays = 1
	apply_butthole_result(&w, .Trap)
	testing.expect_value(t, w.avatar.sprays, 0)
	testing.expect_value(t, w.avatar.armour, 6) // the spray took it
	apply_butthole_result(&w, .Trap)
	testing.expect_value(t, w.avatar.armour, 5)
	for _ in 0 ..< 20 {
		apply_butthole_result(&w, .Teleport)
		testing.expect_value(t, get_token(&w, w.avatar.x, w.avatar.y), Token.Knight)
		testing.expect_value(t, count_tokens(&w, .Knight), 1)
		testing.expect_value(t, count_hilites(&w) > 0, true)
	}
}

@(test)
test_messages :: proc(t: ^testing.T) {
	w: World
	world_init(&w)
	for i in 0 ..< 20 {
		add_message(&w, "message %d", i)
	}
	testing.expect_value(t, w.message_count, MESSAGE_CAPACITY)
	testing.expect_value(t, message_text(&w, 0), "message 19")
	testing.expect_value(t, message_text(&w, MESSAGE_CAPACITY - 1), "message 5")
}

@(test)
test_spawn_on_full_board_terminates :: proc(t: ^testing.T) {
	w: World
	world_init(&w)
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			if w.cells[x][y].token == .None {
				w.cells[x][y].token = .Pawn
			}
		}
	}
	_, _, ok := spawn_token(&w, .Bun)
	testing.expect(t, !ok)

	// One free cell left: it is found even though random misses it.
	w.cells[6][6].token = .None
	x, y, ok2 := spawn_token(&w, .Bun)
	testing.expect(t, ok2)
	testing.expect_value(t, x, 6)
	testing.expect_value(t, y, 6)
}

check_invariants :: proc(t: ^testing.T, w: ^World) -> bool {
	a := &w.avatar
	ok := true
	ok &= testing.expect(t, a.buns >= 0 && a.buns <= a.maximum_buns, "buns out of range")
	ok &= testing.expect(t, a.health >= 0 && a.health <= a.maximum_health, "health out of range")
	ok &= testing.expect(t, a.armour >= 0 && a.jools >= 0, "negative armour/jools")
	ok &= testing.expect(t, a.floggers >= 0 && a.sprays >= 0 && a.lotions >= 0, "negative items")
	ok &= testing.expect(t, get_token(w, a.x, a.y) == .Knight, "knight not at avatar position")
	ok &= testing.expect(t, count_tokens(w, .Knight) == 1, "not exactly one knight")
	ok &= testing.expect(t, count_tokens(w, .Cancel) <= 1, "more than one cancel")
	ok &= testing.expect(t, w.message_count <= MESSAGE_CAPACITY, "too many messages")
	if a.health <= 0 {
		ok &= testing.expect(t, count_hilites(w) == 0, "dead but cells hilited")
	}
	return ok
}

move_priority :: proc(token: Token, buns: int) -> int {
	#partial switch token {
	case .Shoppe:
		return 6
	case .Bishop:
		return 5
	case .Bun:
		return 4 if buns < 6 else 1
	case .Butthole:
		return 3
	case .Pawn:
		return 2
	}
	return 0
}

// With cheat on, armour, health and buns are topped up each step so the knight lives long enough to kill bishops and shop.
run_soak :: proc(t: ^testing.T, steps: int, cheat: bool) -> (deaths, shop_visits, level: int) {
	w: World
	world_init(&w)
	for _ in 0 ..< steps {
		if cheat {
			w.avatar.armour = max(w.avatar.armour, 4)
			w.avatar.health = w.avatar.maximum_health
			w.avatar.buns = max(w.avatar.buns, 3)
			hilite(&w)
		}
		if w.avatar.health <= 0 {
			deaths += 1
			world_init(&w)
		}
		if w.avatar.shoppe {
			shop_visits += 1
			for item in Item_Id {
				for can_buy(&w, item) && roll(&w, 0, 1) == 0 {
					buy(&w, item)
				}
			}
			w.avatar.shoppe = false
		}
		if w.avatar.lotions > 0 && w.avatar.health < w.avatar.maximum_health {
			use_lotion(&w)
		}
		moves: [8][2]int
		n := 0
		for x in 0 ..< BOARD_WIDTH {
			for y in 0 ..< BOARD_HEIGHT {
				if w.cells[x][y].hilite && n < len(moves) {
					moves[n] = {x, y}
					n += 1
				}
			}
		}
		testing.expect(t, n > 0, "alive knight with nowhere to go")
		if n == 0 {
			return
		}
		// Mostly greedy, so the soak actually reaches bishops and the shoppe.
		m := moves[roll(&w, 0, n - 1)]
		if roll(&w, 0, 9) < 8 {
			best := -1
			for i in 0 ..< n {
				p := move_priority(get_token(&w, moves[i].x, moves[i].y), w.avatar.buns)
				if p > best {
					best = p
					m = moves[i]
				}
			}
		}
		attempt_move(&w, m.x, m.y)
		level = max(level, w.avatar.xp_level)
		if !check_invariants(t, &w) {
			testing.fail_now(t, "invariant broken")
		}
	}
	return
}

@(test)
test_soak_mortal :: proc(t: ^testing.T) {
	deaths, _, _ := run_soak(t, 20000, false)
	testing.expect(t, deaths > 0, "soak never reached a death")
}

@(test)
test_soak_immortal :: proc(t: ^testing.T) {
	deaths, shop_visits, level := run_soak(t, 20000, true)
	log.infof("immortal soak: deaths %d shops %d level %d", deaths, shop_visits, level)
	testing.expect(t, shop_visits > 0, "soak never reached the shoppe")
	testing.expect(t, level > 0, "soak never levelled up")
}

// Answers recorded from the original Lua under LÖVE (tools/gen_lua_reference.sh).
ISO_REFERENCE := #load("testdata/iso_reference.txt", string)

@(test)
test_iso_matches_lua :: proc(t: ^testing.T) {
	plots, maps := 0, 0
	rest := ISO_REFERENCE
	for line in strings.split_lines_iterator(&rest) {
		fields := strings.fields(line, context.temp_allocator)
		if len(fields) != 5 {
			continue
		}
		a, _ := strconv.parse_int(fields[1])
		b, _ := strconv.parse_int(fields[2])
		c, _ := strconv.parse_int(fields[3])
		d, _ := strconv.parse_int(fields[4])
		switch fields[0] {
		case "P":
			px, py := plot_xy(a, b)
			testing.expectf(t, px == c && py == d, "plot_xy(%d,%d) = %d,%d; Lua %d,%d", a, b, px, py, c, d)
			plots += 1
		case "M":
			mx, my := map_xy(a, b)
			testing.expectf(t, mx == c && my == d, "map_xy(%d,%d) = %d,%d; Lua %d,%d", a, b, mx, my, c, d)
			maps += 1
		}
	}
	testing.expect_value(t, plots, 64)
	testing.expect_value(t, maps, 4256)
	free_all(context.temp_allocator)
}

@(test)
test_cell_centres_round_trip :: proc(t: ^testing.T) {
	// The middle of every tile's diamond should map back to its own cell.
	for x in 0 ..< BOARD_WIDTH {
		for y in 0 ..< BOARD_HEIGHT {
			px, py := plot_xy(x, y)
			mx, my := map_xy(px + TILE_WIDTH / 2, py + TILE_HEIGHT / 2)
			testing.expectf(t, mx == x && my == y, "cell %d,%d came back as %d,%d", x, y, mx, my)
		}
	}
}

@(test)
test_mousemap_data_size :: proc(t: ^testing.T) {
	testing.expect_value(t, len(MOUSEMAP_DATA), MOUSEMAP_WIDTH * MOUSEMAP_HEIGHT)
}

@(test)
test_button_layout :: proc(t: ^testing.T) {
	// Positions from constants.lua.
	testing.expect_value(t, button_table[.Use_Lotion].x, 1184)
	testing.expect_value(t, button_table[.Use_Lotion].y, 624)
	testing.expect_value(t, button_table[.Play].x, 1184)
	testing.expect_value(t, button_table[.Leave].x, 592)
	testing.expect_value(t, button_table[.Leave].y, 0)
	testing.expect_value(t, button_table[.Upgrade_Buns].y, 120)
	testing.expect_value(t, button_table[.Buy_Lotion].y, 240)
	testing.expect_value(t, button_table[.Flogger].y, 360)
	testing.expect_value(t, button_table[.Armour].y, 480)
	testing.expect_value(t, button_table[.Spray].y, 600)
	testing.expect(t, button_contains(.Leave, 592, 0))
	testing.expect(t, button_contains(.Leave, 687, 95))
	testing.expect(t, !button_contains(.Leave, 688, 95))
	testing.expect(t, !button_contains(.Leave, 591, 0))
}

@(test)
test_button_enabled_and_tooltips :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	buf: [TOOLTIP_CAPACITY]u8
	for id in Button_Id {
		testing.expect(t, !button_enabled(&w, id))
	}
	w.avatar.lotions = 1
	testing.expect(t, button_enabled(&w, .Use_Lotion))
	testing.expect(t, !button_enabled(&w, .Play))
	w.avatar.health = 0
	testing.expect(t, !button_enabled(&w, .Use_Lotion))
	testing.expect(t, button_enabled(&w, .Play))
	w.avatar.health = 3
	w.avatar.shoppe = true
	testing.expect(t, !button_enabled(&w, .Use_Lotion))
	testing.expect(t, button_enabled(&w, .Leave))
	testing.expect(t, !button_enabled(&w, .Spray)) // no jools
	w.avatar.jools = 10
	testing.expect(t, button_enabled(&w, .Spray))
	testing.expect(t, button_enabled(&w, .Buy_Lotion))
	testing.expect(t, !button_enabled(&w, .Flogger))
	testing.expect_value(t, button_tooltip(&w, .Buy_Lotion, buf[:]), "Buy Lotion(-10 Jools)")
	testing.expect_value(t, button_tooltip(&w, .Upgrade_Buns, buf[:]), "Upgrade Buns(-15 Jools)")
	testing.expect_value(t, button_tooltip(&w, .Flogger, buf[:]), "Buy Flogger(-25 Jools)")
	testing.expect_value(t, button_tooltip(&w, .Armour, buf[:]), "Buy Armour(-6 Jools)")
	testing.expect_value(t, button_tooltip(&w, .Spray, buf[:]), "Buy Trap Spray(-1 Jools)")
	testing.expect_value(t, button_tooltip(&w, .Leave, buf[:]), "Leave Shoppe")
}

@(test)
test_ui_tooltips :: proc(t: ^testing.T) {
	w := bare_world(3, 3)
	place_token(&w, 5, 4, .Pawn)
	ui: UI
	px, py := plot_xy(5, 4)
	ui_mouse_moved(&ui, &w, px + 80, py + 40)
	testing.expect_value(t, ui.cursor_x, 5)
	testing.expect_value(t, ui.cursor_y, 4)
	testing.expect_value(t, ui_tooltip(&ui), "Pawn (enemy)")
	ui_mouse_moved(&ui, &w, px + 80, py + 1000) // off the board: clamped
	testing.expect_value(t, ui.cursor_y, BOARD_HEIGHT - 1)

	// Over an enabled button its tooltip wins; a disabled one is ignored.
	w.avatar.lotions = 1
	ui_mouse_moved(&ui, &w, 1200, 640)
	testing.expect_value(t, ui_tooltip(&ui), "Use Lotion")
	w.avatar.lotions = 0
	ui_mouse_moved(&ui, &w, 1200, 640)
	testing.expect(t, ui_tooltip(&ui) != "Use Lotion")

	// In the shoppe, no token tooltips.
	w.avatar.shoppe = true
	ui_mouse_moved(&ui, &w, px + 80, py + 40)
	testing.expect_value(t, ui_tooltip(&ui), "")
	w.avatar.jools = 50
	ui_mouse_moved(&ui, &w, 600, 130)
	testing.expect_value(t, ui_tooltip(&ui), "Upgrade Buns(-15 Jools)")
}
