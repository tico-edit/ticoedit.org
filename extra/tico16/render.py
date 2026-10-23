#!/usr/bin/env python3
"""Draw a dump of DOS text video memory as a VGA would show it.

    render.py VRAM.BIN FONT.BIN OUT.PNG

VRAM.BIN is what tico16's test build appends to %TICOVRAM% on each
screen dump: rows, columns, cursor row and column (a byte each), then
the cells, a character and an attribute byte each.  The first dump in
the file is drawn.  FONT.BIN is the 8x16 VGA font from font.c.  Each
character is 9x16 pixels, as on a VGA in 80-column text mode, and the
picture is doubled to 1440x800 so it stays sharp when scaled.
"""

import sys
from PIL import Image

PALETTE = [
    (0x00, 0x00, 0x00), (0x00, 0x00, 0xAA), (0x00, 0xAA, 0x00), (0x00, 0xAA, 0xAA),
    (0xAA, 0x00, 0x00), (0xAA, 0x00, 0xAA), (0xAA, 0x55, 0x00), (0xAA, 0xAA, 0xAA),
    (0x55, 0x55, 0x55), (0x55, 0x55, 0xFF), (0x55, 0xFF, 0x55), (0x55, 0xFF, 0xFF),
    (0xFF, 0x55, 0x55), (0xFF, 0x55, 0xFF), (0xFF, 0xFF, 0x55), (0xFF, 0xFF, 0xFF),
]


def main(vram_path, font_path, out_path):
    data = open(vram_path, 'rb').read()
    font = open(font_path, 'rb').read()
    rows, cols, crow, ccol = data[0], data[1], data[2], data[3]
    cells = data[4:4 + rows * cols * 2]

    img = Image.new('RGB', (cols * 9, rows * 16))
    px = img.load()
    for row in range(rows):
        for col in range(cols):
            i = (row * cols + col) * 2
            ch, attr = cells[i], cells[i + 1]
            fg, bg = PALETTE[attr & 0x0F], PALETTE[(attr >> 4) & 0x07]
            for y in range(16):
                bits = font[ch * 16 + y]
                # the 9th column repeats the 8th for the line-drawing range
                bits9 = (bits << 1) | (bits & 1 if 0xC0 <= ch <= 0xDF else 0)
                for x in range(9):
                    on = bits9 & (0x100 >> x)
                    px[col * 9 + x, row * 16 + y] = fg if on else bg
    # the DOS underline cursor, in the cell's foreground color
    i = (crow * cols + ccol) * 2
    fg = PALETTE[cells[i + 1] & 0x0F]
    for y in (14, 15):
        for x in range(9):
            px[ccol * 9 + x, crow * 16 + y] = fg

    img = img.resize((img.width * 2, img.height * 2), Image.NEAREST)
    img.save(out_path, optimize=True)


if __name__ == '__main__':
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    main(*sys.argv[1:])
