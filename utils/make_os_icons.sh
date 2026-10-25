#!/bin/bash
# Refit the stock OS icons (utils/os-src, left untouched) so every big icon has
# the same padding: trim to the drawn content, fit its longest side to
# OS_CONTENT_PCT of the canvas, centre. Generated icons use the same box.
# usage: make_os_icons.sh [ICONDIR]   (default: ../rectilinear/icons)
set -euo pipefail
HERE=$(dirname "$0")
# shellcheck source=tokens.sh
source "$HERE/tokens.sh"

ICONS=${1:-"$HERE/../rectilinear/icons"}
C=$OS_CANVAS BOX=$((OS_CANVAS * OS_CONTENT_PCT / 100))

for src in "$HERE"/os-src/*.png; do
  # content box from the alpha channel; ignores faint shadows and antialias haze
  bbox=$(magick "$src" -alpha extract -threshold 10% -format %@ info:)
  magick "$src" -crop "$bbox" +repage -filter Lanczos -resize "${BOX}x${BOX}" \
    -background none -gravity center -extent ${C}x${C} "$ICONS/$(basename "$src")"
done
