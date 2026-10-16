package game

// Order matters: the page loads images by this index (see web/index.html).
Sprite_Id :: enum {
	Bishop,
	Blur,
	Bun,
	Butthole,
	Cancel,
	Cursor,
	Dark,
	Dark_Hilite,
	Leave,
	Leave_Hover,
	Light,
	Lotion,
	Lotion_Hover,
	Light_Hilite,
	Knight,
	Pawn,
	Shoppe,
	Upgrade_Buns,
	Upgrade_Buns_Hover,
	Buy_Lotion,
	Buy_Lotion_Hover,
	Flogger,
	Flogger_Hover,
	Armour,
	Armour_Hover,
	Spray,
	Spray_Hover,
	Play,
	Play_Hover,
}

Sprite_Info :: struct {
	file:     string, // relative to assets/images/
	offset_x: i32,
	offset_y: i32,
}

// Offsets match spritemanager.lua.
sprite_table := [Sprite_Id]Sprite_Info {
	.Bishop             = {"bishop.png", 40, -30},
	.Blur               = {"blur.png", 0, 0},
	.Bun                = {"bun.png", 40, -20},
	.Butthole           = {"butthole.png", 40, 20},
	.Cancel             = {"cancel.png", 40, 20},
	.Cursor             = {"cursor.png", 0, 0},
	.Dark               = {"darktile.png", 0, 0},
	.Dark_Hilite        = {"darktilehilite.png", 0, 0},
	.Leave              = {"leave.png", 0, 0},
	.Leave_Hover        = {"leavehover.png", 0, 0},
	.Light              = {"lighttile.png", 0, 0},
	.Lotion             = {"lotion.png", 0, 0},
	.Lotion_Hover       = {"lotionhover.png", 0, 0},
	.Light_Hilite       = {"lighttilehilite.png", 0, 0},
	.Knight             = {"knight.png", 40, -30},
	.Pawn               = {"pawn.png", 40, -30},
	.Shoppe             = {"shoppe.png", 40, -30},
	.Upgrade_Buns       = {"upgradebuns.png", 0, 0},
	.Upgrade_Buns_Hover = {"upgradebunshover.png", 0, 0},
	.Buy_Lotion         = {"buylotion.png", 0, 0},
	.Buy_Lotion_Hover   = {"buylotionhover.png", 0, 0},
	.Flogger            = {"flogger.png", 0, 0},
	.Flogger_Hover      = {"floggerhover.png", 0, 0},
	.Armour             = {"armour.png", 0, 0},
	.Armour_Hover       = {"armourhover.png", 0, 0},
	.Spray              = {"spray.png", 0, 0},
	.Spray_Hover        = {"sprayhover.png", 0, 0},
	.Play               = {"play.png", 0, 0},
	.Play_Hover         = {"playhover.png", 0, 0},
}

// Fonts: size in pixels, from constants.lua. Family loaded by the page.
Font_Id :: enum {
	Message,
	Statistics,
}
font_sizes := [Font_Id]i32 {
	.Message    = 12,
	.Statistics = 24,
}
