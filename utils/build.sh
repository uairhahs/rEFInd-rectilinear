#!/bin/bash
# Rebuild every generated asset, then the preview. Run after changing
# tokens.sh, the glyphs or the font.
set -euo pipefail
HERE=$(dirname "$0")

"$HERE/make_scheme.sh"   # colours from the wallpaper; everything below uses them
"$HERE/make_selection.sh"
"$HERE/make_icons.sh"
"$HERE/make_os_icons.sh"
"$HERE/make_os_fallbacks.sh"
"$HERE/make_font.sh" "$HERE/SpaceMono-Regular.ttf" 28 "$HERE/../rectilinear/fonts/space-mono-28.png"
# 2x sheet for HiDPI screens: RefindPlus scales icons there but draws fonts as-is.
"$HERE/make_font.sh" "$HERE/SpaceMono-Regular.ttf" 56 "$HERE/../rectilinear/fonts/space-mono-56.png"
"$HERE/make_preview.sh"

# Reproducible output: drop the timestamps ImageMagick writes into every PNG, so
# a rebuild only changes files whose pixels changed.
magick mogrify -strip -define png:exclude-chunks=date,time \
  "$HERE"/../rectilinear/icons/*.png "$HERE"/../rectilinear/fonts/*.png "$HERE"/../preview.png
