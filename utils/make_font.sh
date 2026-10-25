#!/bin/bash
# Build a rEFInd font sheet (ASCII 32-126 + fallback glyph, 96 cells) from a
# monospaced TTF/OTF using ImageMagick.
# usage: make_font.sh FONT HEIGHT OUT.png [CELL_WIDTH]
set -euo pipefail

FONT=$1 H=$2 OUT=$3
W=${4:-$((H*58/100))}   # cell width; ~0.58em suits most monospace faces
PT=$((H*72/100))
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT

cells=()
for i in $(seq 32 127); do
  c=$i; [ "$i" = 127 ] && c=63            # 96th glyph: "?" for out-of-range chars
  f="$T/$(printf %03d "$i").png"
  if [ "$c" = 32 ]; then
    magick -size ${W}x${H} xc:none "$f"
  else
    txt=$(printf "\\$(printf %03o "$c")")
    [ "$c" = 92 ] && txt='\\'             # ImageMagick treats "\" as an escape
    magick -size ${W}x${H} xc:none -font "$FONT" -pointsize "$PT" -fill black \
      -gravity center -annotate +0+0 "$txt" "$f"
  fi
  cells+=("$f")
done
magick "${cells[@]}" +append "$OUT"
identify "$OUT"
