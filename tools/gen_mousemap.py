#!/usr/bin/env python3
"""Bakes src/assets/images/mousemap.png into odin/game/mousemap.bin.

One byte per pixel, row-major (y * 160 + x): 0 centre, 1 upper-left, 2 upper-right,
3 lower-left, 4 lower-right. A pixel is a corner when it matches that corner pixel's colour,
exactly as src/mousemap.lua classifies it.
"""
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parent.parent
im = Image.open(root / "src/assets/images/mousemap.png").convert("RGB")
w, h = im.size
px = im.load()
corners = [px[0, 0], px[w - 1, 0], px[0, h - 1], px[w - 1, h - 1]]
out = bytearray()
for y in range(h):
    for x in range(w):
        c = px[x, y]
        out.append(corners.index(c) + 1 if c in corners else 0)
(root / "odin/game/mousemap.bin").write_bytes(out)
print(f"wrote {len(out)} bytes ({w}x{h})")
