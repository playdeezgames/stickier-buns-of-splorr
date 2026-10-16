package game

Butthole_Result :: enum {
	Nothing,
	Jools,
	Trap,
	Teleport,
	Armour,
	Flogger,
	Lotion,
}

butthole_weights := [Butthole_Result]int {
	.Nothing  = 10,
	.Jools    = 40,
	.Trap     = 20,
	.Teleport = 10,
	.Armour   = 40,
	.Flogger  = 5,
	.Lotion   = 10,
}

weights_total :: proc(weights: [$E]int) -> int {
	total := 0
	for v in weights {
		total += v
	}
	return total
}

// roll is in [0, total). Walks the enum in order, so the mapping is stable.
pick_weighted :: proc(weights: [$E]int, roll: int) -> E {
	remaining := roll
	last: E
	for v, k in weights {
		if v <= 0 {
			continue
		}
		last = k
		if remaining < v {
			return k
		}
		remaining -= v
	}
	return last
}
