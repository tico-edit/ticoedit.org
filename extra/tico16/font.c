/*
 * font.c: write the VGA BIOS's 8x16 text font (256 characters, 16 bytes
 * each) to FONT.BIN, so render.py can draw a tico16 screen with it.
 * Built with Open Watcom by capture.sh and run under DOSBox-X.
 */

#include <stdio.h>
#include <dos.h>
#include <i86.h>

int main(void)
{
    union REGPACK r;
    unsigned char __far *font;
    FILE *fp;
    unsigned i;

    r.w.ax = 0x1130;
    r.h.bh = 6;                 /* the 8x16 font, at ES:BP */
    intr(0x10, &r);
    font = MK_FP(r.w.es, r.w.bp);
    fp = fopen("FONT.BIN", "wb");
    if (fp == NULL)
        return 1;
    for (i = 0; i < 256 * 16; i++)
        fputc(font[i], fp);
    fclose(fp);
    return 0;
}
