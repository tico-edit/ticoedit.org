#!/bin/sh
# Capture tico16 editing extra/tico16/CONFIG.SYS and write
# docs/images/tico16-config-sys.png.
#
#   extra/tico16/capture.sh
#
# Runs tico16's test build (tico_t.exe, which reads its keys from a
# script) in a headless DOSBox-X, dumps its text video memory, and draws
# that with the VGA font as DOSBox-X provides it (render.py). Needs a
# tico16 checkout (TICO16, default ~/dev/tico16) that builds with
# `make tico_t.exe`, Open Watcom (WATCOM, default ~/opt/watcom),
# dosbox-x, and Python 3 with Pillow.
set -e

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../.." && pwd)
TICO16=${TICO16:-$HOME/dev/tico16}
WATCOM=${WATCOM:-$HOME/opt/watcom}
export WATCOM
export INCLUDE=$WATCOM/h
export PATH=$WATCOM/binl64:$WATCOM/binl:$PATH

make -C "$TICO16" tico_t.exe >/dev/null

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
cp "$TICO16/tico_t.exe" "$HERE/CONFIG.SYS" "$WORK/"
(cd "$WORK" && wcl -q -zq -bt=dos -ms -0 -fe=font.exe "$HERE/font.c" >/dev/null)

# Move the cursor down into the [NORMAL] section, then dump the screen.
printf '%s' '{Down}{Down}{Down}{Down}{Down}{Down}{Down}{Down}{Down}' > "$WORK/KEYS.TXT"
printf '%s' '{Down}{Down}{Down}{Down}{Down}{Down}{Down}{Down}{Dump}' >> "$WORK/KEYS.TXT"
cat > "$WORK/STEPS.BAT" <<'EOS'
@echo off
font
set TICOKEYS=c:\keys.txt
set TICOVRAM=c:\vram.bin
tico_t CONFIG.SYS
EOS

SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy timeout 120 \
    dosbox-x -defaultconf -silent -nogui -nomenu -set "cpu cycles=max" \
    -c "mount c \"$WORK\"" -c "c:" -c "steps.bat" -c "exit" \
    >"$WORK/dosbox.log" 2>&1 || true

python3 "$HERE/render.py" "$WORK/VRAM.BIN" "$WORK/FONT.BIN" \
    "$ROOT/docs/images/tico16-config-sys.png"
echo "wrote $ROOT/docs/images/tico16-config-sys.png"
