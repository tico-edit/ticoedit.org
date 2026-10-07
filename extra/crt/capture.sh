#!/bin/sh
# Capture tico editing extra/crt/hello/hello.EXT in an 80x24 xterm, frame the
# screenshot in the CRT (crt.svg.in) and write docs/images/hello-EXT-crt.png.
#
#   extra/crt/capture.sh            # every hello.* file
#   extra/crt/capture.sh rs pl      # just hello.rs and hello.pl
#
# Needs XQuartz (Xvfb, xterm, xwininfo), ImageMagick (import), librsvg
# (rsvg-convert) and tico on PATH. Xvfb also needs /tmp/.X11-unix to exist and
# be owned by root: sudo mkdir -m 1777 /tmp/.X11-unix
set -e

CRT=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$CRT/../.." && pwd)
OUT=$ROOT/docs/images
X11=/opt/X11/bin
D=:77

if [ $# -eq 0 ]; then
  set -- $(cd "$CRT/hello" && ls hello.* | sed 's/^hello\.//')
fi

WORK=$(mktemp -d)
mkdir "$WORK/home"
cp "$ROOT/docs/images/toucan-icon.svg" "$WORK/"

$X11/Xvfb $D -screen 0 1280x1024x24 -nolisten tcp >"$WORK/xvfb.log" 2>&1 &
XVFB=$!
trap 'kill $XVFB 2>/dev/null; rm -rf "$WORK"' EXIT
sleep 3
if ! kill -0 $XVFB 2>/dev/null; then
  cat "$WORK/xvfb.log" >&2
  exit 1
fi

cd "$CRT/hello"
for ext in "$@"; do
  # HOME points at an empty dir so your own ~/.ticorc and ~/.nanorc don't
  # change the theme or settings in the screenshot.
  HOME=$WORK/home DISPLAY=$D $X11/xterm -geometry 80x24+0+0 -bw 0 -b 0 \
    -fa 'Bitstream Vera Sans Mono' -fs 13 -bg black -fg white \
    -e tico -I "hello.$ext" &
  XT=$!
  sleep 4
  id=$(DISPLAY=$D $X11/xwininfo -root -tree | awk '/"tico"/ { print $1; exit }')
  DISPLAY=$D import -window "$id" "$WORK/hello-$ext.png"
  kill $XT
  sleep 1
  sed "s/@SHOT@/hello-$ext.png/" "$CRT/crt.svg.in" >"$WORK/hello-$ext-crt.svg"
  rsvg-convert "$WORK/hello-$ext-crt.svg" -o "$OUT/hello-$ext-crt.png"
  echo "wrote docs/images/hello-$ext-crt.png"
done
