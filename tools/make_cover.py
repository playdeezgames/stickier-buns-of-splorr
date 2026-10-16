#!/usr/bin/env python3
"""Draws the itch.io cover (630 by 500) into assets/cover.png from a game screenshot and the
game's own font. Run tools/make_screenshots.sh first. Needs Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parent.parent
shot = Image.open(root / "assets/screenshots/01-play.png").convert("RGB")
font_path = root / "web/assets/fonts/antiquity-print.ttf"

W, H = 630, 500
cover = Image.new("RGB", (W, H), (0, 0, 0))
# The board, cropped from the screenshot clear of the stats, messages and lotion button.
board = shot.crop((230, 60, 1184, 624))
scaled = board.resize((W, round(board.height * W / board.width)), Image.LANCZOS)
cover.paste(scaled, (0, H - scaled.height))

draw = ImageDraw.Draw(cover)
def title(text, size, y, colour):
    font = ImageFont.truetype(str(font_path), size)
    width = draw.textlength(text, font=font)
    x = (W - width) / 2
    draw.text((x + 3, y + 3), text, font=font, fill=(0, 0, 0))
    draw.text((x, y), text, font=font, fill=colour)

title("Stickier Buns", 56, 14, (255, 255, 84))
title("of SPLORR!!", 56, 76, (168, 0, 168))
cover.save(root / "assets/cover.png")
print("assets/cover.png")
