#!/bin/sh
# Capture tico showing extra/themes/sample.rs in a 92x48 xterm with a built-in
# theme and write docs/images/themes/tico-builtin-NAME.png.
#
#   extra/themes/capture.sh                 # every tico-builtin-* theme
#   extra/themes/capture.sh gruvbox nord    # just those two
#
# Needs the same tools as extra/crt/capture.sh, except rsvg-convert.
set -e

HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../.." && pwd)
OUT=$ROOT/docs/images/themes
D=:78

[ -d /opt/X11/bin ] && PATH=/opt/X11/bin:$PATH

if [ $# -eq 0 ]; then
  set -- $(tico --tico-list-themes | awk '$1 ~ /^tico-builtin-/ { sub(/^tico-builtin-/, "", $1); print $1 }')
fi

WORK=$(mktemp -d)
mkdir "$WORK/home"

# The window is 1012x1056, so the screen has to be taller than usual.
Xvfb $D -screen 0 1280x1200x24 -nolisten tcp >"$WORK/xvfb.log" 2>&1 &
XVFB=$!
trap 'kill $XVFB 2>/dev/null; rm -rf "$WORK"' EXIT
sleep 3
if ! kill -0 $XVFB 2>/dev/null; then
  cat "$WORK/xvfb.log" >&2
  exit 1
fi

# Run from here so the title bar shows just sample.rs.
cd "$HERE"
for name in "$@"; do
  HOME=$WORK/home DISPLAY=$D xterm -u8 -geometry 92x48+0+0 -bw 0 -b 0 \
    -fa 'DejaVu Sans Mono' -fs 13 -bg black -fg white \
    -e tico -I --tico-theme "tico-builtin-$name" sample.rs &
  XT=$!
  sleep 4
  id=$(DISPLAY=$D xwininfo -root -tree | awk '/"XTerm"/ { print $1; exit }')
  DISPLAY=$D import -window "$id" "$OUT/tico-builtin-$name.png"
  kill $XT
  sleep 1
  echo "wrote docs/images/themes/tico-builtin-$name.png"
done
