package game

TOOLTIP_CAPACITY :: 96

// Mouse-derived state: which cell and button the pointer is over, and the tooltip to show.
UI :: struct {
	cursor_x, cursor_y: int,
	hover:              [Button_Id]bool,
	tooltip_buf:        [TOOLTIP_CAPACITY]u8,
	tooltip_len:        int,
}

ui_tooltip :: proc(ui: ^UI) -> string {
	return string(ui.tooltip_buf[:ui.tooltip_len])
}

ui_set_tooltip :: proc(ui: ^UI, text: string) {
	ui.tooltip_len = copy(ui.tooltip_buf[:], text)
}

// Button tooltip first, then (outside the shoppe) the token under the cursor.
ui_update_tooltip :: proc(ui: ^UI, w: ^World) {
	for id in Button_Id {
		if ui.hover[id] && button_enabled(w, id) {
			ui.tooltip_len = len(button_tooltip(w, id, ui.tooltip_buf[:]))
			return
		}
	}
	if w.avatar.shoppe {
		ui_set_tooltip(ui, "")
		return
	}
	ui_set_tooltip(ui, token_table[w.cells[ui.cursor_x][ui.cursor_y].token].tooltip)
}

ui_mouse_moved :: proc(ui: ^UI, w: ^World, x, y: int) {
	for id in Button_Id {
		ui.hover[id] = button_contains(id, x, y)
	}
	ui.cursor_x, ui.cursor_y = map_xy(x, y)
	ui_update_tooltip(ui, w)
}
