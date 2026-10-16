package game

import "core:fmt"

BUTTON_SIZE :: 96
BUTTON_SPACE :: BUTTON_SIZE / 4
SHOP_BUTTON_X :: (SCREEN_WIDTH - BUTTON_SIZE) / 2

// Order is the draw order.
Button_Id :: enum {
	Use_Lotion,
	Play,
	Leave,
	Upgrade_Buns,
	Buy_Lotion,
	Flogger,
	Armour,
	Spray,
}

Button_Info :: struct {
	sprite, hover_sprite: Sprite_Id,
	x, y:                 int, // all buttons are BUTTON_SIZE square
}

// Layout from constants.lua: the shop buttons stack down the middle of the screen.
button_table := [Button_Id]Button_Info {
	.Use_Lotion   = {.Lotion, .Lotion_Hover, SCREEN_WIDTH - BUTTON_SIZE, SCREEN_HEIGHT - BUTTON_SIZE},
	.Play         = {.Play, .Play_Hover, SCREEN_WIDTH - BUTTON_SIZE, SCREEN_HEIGHT - BUTTON_SIZE},
	.Leave        = {.Leave, .Leave_Hover, SHOP_BUTTON_X, 0},
	.Upgrade_Buns = {.Upgrade_Buns, .Upgrade_Buns_Hover, SHOP_BUTTON_X, (BUTTON_SIZE + BUTTON_SPACE) * 1},
	.Buy_Lotion   = {.Buy_Lotion, .Buy_Lotion_Hover, SHOP_BUTTON_X, (BUTTON_SIZE + BUTTON_SPACE) * 2},
	.Flogger      = {.Flogger, .Flogger_Hover, SHOP_BUTTON_X, (BUTTON_SIZE + BUTTON_SPACE) * 3},
	.Armour       = {.Armour, .Armour_Hover, SHOP_BUTTON_X, (BUTTON_SIZE + BUTTON_SPACE) * 4},
	.Spray        = {.Spray, .Spray_Hover, SHOP_BUTTON_X, (BUTTON_SIZE + BUTTON_SPACE) * 5},
}

// The shop buttons buy these.
button_item :: proc(id: Button_Id) -> (item: Item_Id, ok: bool) {
	#partial switch id {
	case .Upgrade_Buns:
		return .Bun_Upgrade, true
	case .Buy_Lotion:
		return .Lotion, true
	case .Flogger:
		return .Flogger, true
	case .Armour:
		return .Armour, true
	case .Spray:
		return .Spray, true
	}
	return {}, false
}

button_enabled :: proc(w: ^World, id: Button_Id) -> bool {
	#partial switch id {
	case .Use_Lotion:
		return !w.avatar.shoppe && w.avatar.lotions > 0 && w.avatar.health > 0
	case .Play:
		return w.avatar.health == 0
	case .Leave:
		return w.avatar.shoppe
	}
	item, _ := button_item(id)
	return can_buy(w, item)
}

button_tooltip :: proc(w: ^World, id: Button_Id, buf: []u8) -> string {
	#partial switch id {
	case .Use_Lotion:
		return fmt.bprintf(buf, "Use Lotion")
	case .Play:
		return fmt.bprintf(buf, "Play Again")
	case .Leave:
		return fmt.bprintf(buf, "Leave Shoppe")
	}
	item, _ := button_item(id)
	price := item_price(w, item)
	#partial switch id {
	case .Upgrade_Buns:
		return fmt.bprintf(buf, "Upgrade Buns(-%d Jools)", price)
	case .Buy_Lotion:
		return fmt.bprintf(buf, "Buy Lotion(-%d Jools)", price)
	case .Flogger:
		return fmt.bprintf(buf, "Buy Flogger(-%d Jools)", price)
	case .Armour:
		return fmt.bprintf(buf, "Buy Armour(-%d Jools)", price)
	case .Spray:
		return fmt.bprintf(buf, "Buy Trap Spray(-%d Jools)", price)
	}
	return ""
}

button_contains :: proc(id: Button_Id, x, y: int) -> bool {
	b := button_table[id]
	return x >= b.x && y >= b.y && x < b.x + BUTTON_SIZE && y < b.y + BUTTON_SIZE
}

// Play restarts the game (keeping the random source); the shop buttons buy.
button_press :: proc(w: ^World, id: Button_Id) {
	switch id {
	case .Use_Lotion:
		use_lotion(w)
	case .Play:
		world_init(w)
	case .Leave:
		w.avatar.shoppe = false
	case .Upgrade_Buns, .Buy_Lotion, .Flogger, .Armour, .Spray:
		item, _ := button_item(id)
		buy(w, item)
	}
}
