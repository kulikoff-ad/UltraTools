#!/usr/bin/env python3
"""Render the UltraTools 1024x1024 app icon as an opaque RGB PNG.

Pure standard library (zlib + struct) so it runs anywhere. The mark is a
white "formatted list" glyph on a diagonal indigo -> cyan gradient, drawn
with signed-distance coverage and 2x supersampling.
"""
import math
import os
import struct
import zlib

SIZE = 1024
SS = 2                                   # supersampling factor
BIG = SIZE * SS
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "UltraTools", "Assets.xcassets",
                   "AppIcon.appiconset", "AppIcon.png")

TOP_LEFT = (0x43, 0x38, 0xCA)            # indigo
BOTTOM_RIGHT = (0x06, 0xB6, 0xD4)        # cyan

# Mark geometry in 1024-space, scaled to the render grid on the fly.
BAR_X, BAR_H = 320.0, 48.0
BAR_WIDTHS = [470.0, 350.0, 410.0]
CENTERS_Y = [352.0, 512.0, 672.0]
BULLET_CX, BULLET_R = 252.0, 26.0

BARS = [(BAR_X + w / 2.0, cy, w / 2.0, BAR_H / 2.0, BAR_H / 2.0)
        for cy, w in zip(CENTERS_Y, BAR_WIDTHS)]

SPAN = math.hypot(BIG, BIG)


def rounded_rect_sdf(x, y, cx, cy, hx, hy, r):
    dx = abs(x - cx) - (hx - r)
    dy = abs(y - cy) - (hy - r)
    ax, ay = max(dx, 0.0), max(dy, 0.0)
    return math.hypot(ax, ay) + min(max(dx, dy), 0.0) - r


def render_row(y):
    """Render one row of the supersampled image as RGB bytes."""
    row = bytearray()
    ny = (y / BIG) * 2.0 - 1.0
    for x in range(BIG):
        t = (x + y) / SPAN
        r = TOP_LEFT[0] + (BOTTOM_RIGHT[0] - TOP_LEFT[0]) * t
        g = TOP_LEFT[1] + (BOTTOM_RIGHT[1] - TOP_LEFT[1]) * t
        b = TOP_LEFT[2] + (BOTTOM_RIGHT[2] - TOP_LEFT[2]) * t

        nx = (x / BIG) * 2.0 - 1.0
        vig = 1.0 - 0.16 * (nx * nx + ny * ny)
        r, g, b = r * vig, g * vig, b * vig

        alpha = 0.0
        fx, fy = x + 0.5, y + 0.5

        for cx, cy, hx, hy, rad in BARS:
            cx, cy, hx, hy, rad = cx * SS, cy * SS, hx * SS, hy * SS, rad * SS
            if fx < cx - hx - 1.5 or fx > cx + hx + 1.5 or fy < cy - hy - 1.5 or fy > cy + hy + 1.5:
                continue
            d = rounded_rect_sdf(fx, fy, cx, cy, hx, hy, rad)
            cov = max(0.0, min(1.0, 0.5 - d))
            alpha += cov - alpha * cov

        bcx, bcy, br = BULLET_CX * SS, BULLET_R * SS, BULLET_R * SS
        for cy in CENTERS_Y:
            cy = cy * SS
            if abs(fx - bcx) > br + 1.5 or abs(fy - cy) > br + 1.5:
                continue
            d = math.hypot(fx - bcx, fy - cy) - br
            cov = max(0.0, min(1.0, 0.5 - d)) * 0.82
            alpha += cov - alpha * cov

        row.append(int(max(0.0, min(255.0, r * (1 - alpha) + 255.0 * alpha))))
        row.append(int(max(0.0, min(255.0, g * (1 - alpha) + 255.0 * alpha))))
        row.append(int(max(0.0, min(255.0, b * (1 - alpha) + 255.0 * alpha))))
    return row


def chunk(tag, data):
    return (struct.pack(">I", len(data)) + tag + data +
            struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF))


rows = []
area = SS * SS
for out_y in range(SIZE):
    subs = [render_row(out_y * SS + k) for k in range(SS)]
    out = bytearray()
    for out_x in range(SIZE):
        base = out_x * SS * 3
        for c in range(3):
            total = 0
            for sub in subs:
                for k in range(SS):
                    total += sub[base + k * 3 + c]
            out.append(total // area)
    rows.append(bytes(out))

raw = b"".join(b"\x00" + row for row in rows)
png = (b"\x89PNG\r\n\x1a\n" +
       chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0)) +
       chunk(b"IDAT", zlib.compress(raw, 9)) +
       chunk(b"IEND", b""))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "wb") as fh:
    fh.write(png)
print(f"wrote {OUT} ({len(png)} bytes, {SIZE}x{SIZE} RGB8, no alpha, ss={SS})")
