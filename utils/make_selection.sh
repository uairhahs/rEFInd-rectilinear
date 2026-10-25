#!/bin/bash
# Selection highlights: one light translucent shape, no outline. All values come from tokens.sh; the OS row uses RADIUS_PX, the tools
# row is the same shape at radius 50 (a circle). Requires rsvg-convert.
# usage: make_selection.sh [OUTDIR]   (default: ../rectilinear/icons)
set -euo pipefail

HERE=$(dirname "$0")
. "$HERE/tokens.sh"
OUT=${1:-"$HERE/../rectilinear/icons"}
mkdir -p "$OUT"

make() { # SIZE FILE RADIUS_PCT TINT
  local side=$((100 - 2*INSET_PCT))
  rsvg-convert -w "$1" -h "$1" -o "$2" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect x="$INSET_PCT" y="$INSET_PCT" width="$side" height="$side" rx="$3"
        fill="$4" fill-opacity="$FILL_OPACITY"/>
</svg>
SVG
}

make 432 "$OUT/selection_big.png" "$(awk -v r="$RADIUS_PX" -v s="$BIG_SELECTION_PX" 'BEGIN { print r / s * 100 }')" "$TINT_BIG"
make 192 "$OUT/selection_small.png" 50 "$TINT_SMALL"
