package game

Item_Id :: enum {
	Bun_Upgrade,
	Lotion,
	Flogger,
	Armour,
	Spray,
}

item_price :: proc(w: ^World, item: Item_Id) -> int {
	switch item {
	case .Bun_Upgrade:
		return w.avatar.maximum_buns
	case .Lotion:
		return 10
	case .Flogger:
		return 25
	case .Armour:
		return w.avatar.armour + 1
	case .Spray:
		return 1
	}
	return 0
}

// Same rule as the shop buttons' enablers.
can_buy :: proc(w: ^World, item: Item_Id) -> bool {
	return w.avatar.shoppe && w.avatar.jools >= item_price(w, item)
}

// Like the Lua, does not check affordability; callers use can_buy.
buy :: proc(w: ^World, item: Item_Id) {
	price := item_price(w, item)
	w.avatar.jools -= price
	add_message(w, "-%d Jools", price)
	switch item {
	case .Bun_Upgrade:
		w.avatar.maximum_buns += 1
		add_message(w, "+1 Maximum Buns(%d)", w.avatar.maximum_buns)
	case .Lotion:
		w.avatar.lotions += 1
		add_message(w, "+1 Lotion(%d)", w.avatar.lotions)
	case .Flogger:
		w.avatar.floggers += 1
		add_message(w, "+1 Flogger(%d)", w.avatar.floggers)
	case .Armour:
		w.avatar.armour += 1
		add_message(w, "+1 Armour(%d)", w.avatar.armour)
	case .Spray:
		w.avatar.sprays += 1
		add_message(w, "+1 Trap Spray(%d)", w.avatar.sprays)
	}
}
