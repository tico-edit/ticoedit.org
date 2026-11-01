#!/usr/bin/env python3
"""Capture tico68 editing extra/tico68/Hello.c and write
docs/images/tico68-hello-c.png.

    extra/tico68/capture.py [--system 6|7] [--keep DIR]

Runs the application under Mini vMac, as a 4 MB Macintosh Plus, with the
emulator harness from a tico68 checkout (TICO68, default ~/dev/tico68)
that has been built with `make`. See its docs/TESTING.md for what that
needs: Mini vMac, Xvfb, xdotool, hfsutils, Pillow and a boot disk, of
which only a copy is used.
"""

import argparse
import os
import subprocess
import sys
import tempfile
import time

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SITE = os.path.dirname(os.path.dirname(HERE))
TICO68 = os.environ.get("TICO68", os.path.expanduser("~/dev/tico68"))
sys.path.insert(0, os.path.join(TICO68, "tests", "emu"))
import macemu  # noqa: E402
import mkfixtures  # noqa: E402
import run  # noqa: E402

BOOT_WAIT = {"6": 25, "7": 45}
CARET = (25, 62)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--system", choices=["6", "7"], default="6")
    ap.add_argument("--keep")
    args = ap.parse_args()
    run.SYSTEM = args.system

    work = args.keep or tempfile.mkdtemp(prefix="tico68-shot")
    os.makedirs(work, exist_ok=True)
    scratch = os.path.join(work, "hfs")
    os.makedirs(scratch, exist_ok=True)
    env = dict(os.environ, HOME=scratch)
    env["PATH"] = os.path.join(run.RETRO68, "bin") + ":" + env["PATH"]

    def hfs(*cmd):
        subprocess.run(cmd, env=env, check=True, stdout=subprocess.DEVNULL)

    boot = os.path.join(work, "boot.dsk")
    subprocess.run(["cp", "--reflink=auto", run.BOOT, boot], check=True)
    hfs("hmount", boot)
    hfs("hattrib", "-b", ":System Folder" if args.system == "6"
        else ":System Folder 7.0.1")
    hfs("humount")

    # The test disk, so the Finder puts tico68 where the tests expect it.
    data = os.path.join(work, "data.dsk")
    hfs(sys.executable, os.path.join(TICO68, "tests", "emu", "mkfixtures.py"),
        data, scratch)
    with open(os.path.join(HERE, "Hello.c"), "rb") as f:
        text = f.read().replace(b"\n", b"\r")
    bin_path = os.path.join(scratch, "hello.bin")
    with open(bin_path, "wb") as f:
        f.write(mkfixtures.macbinary("Hello.c", b"TEXT", b"Tc68", text))
    hfs("hmount", data)
    hfs("hcopy", "-m", os.path.join(TICO68, "build", "mac", "tico68.bin"),
        ":tico68")
    hfs("hcopy", "-m", bin_path, ":Hello.c")
    hfs("humount")

    with macemu.Mac(work, [boot, data]) as m:
        time.sleep(BOOT_WAIT[args.system])
        m.save("booted")
        m.click(473, 115, repeat=2)     # open the data disk
        time.sleep(4)
        if args.system == "6":
            # Hello.c moves tico68 from where the tests have it
            m.click(174, 170, repeat=2)
            time.sleep(6)
        else:
            run.start_app(m)
        m.save("launched")
        m.cmd("w")              # the empty window it starts with
        time.sleep(1)
        run.open_file(m, "Hello.c")
        m.move(350, 8)          # the pointer, out of the way
        time.sleep(1)
        # the caret blinks: wait until it's on, at the start of line 1
        for _ in range(40):
            shot = m.shot()
            if shot.getpixel(CARET)[0] < 128:
                break
            time.sleep(0.05)
        else:
            sys.exit("no caret: see the screenshots in " + work)

    out = os.path.join(SITE, "docs", "images", "tico68-hello-c.png")
    shot.resize((macemu.W * 2, macemu.H * 2), Image.NEAREST).save(out)
    print("wrote", out)
    print("screenshots in", work)


if __name__ == "__main__":
    main()
