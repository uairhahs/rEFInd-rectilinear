#!/bin/bash
# Export the wallpaper at a screen's exact resolution. With banner_scale fillscreen,
# rEFInd/RefindPlus resize a background that doesn't match the screen at boot, which
# can leave artefacts; a native-size image is copied as-is. The source is scaled to
# cover the screen and centre-cropped to its aspect ratio.
# usage: make_background.sh WIDTHxHEIGHT [OUT] [SOURCE]
#   OUT    default: ../rectilinear/background.png
#   SOURCE default: wallpaper.jpg (any format ImageMagick reads)
set -euo pipefail
HERE=$(dirname "$0")
SIZE=${1:?usage: make_background.sh WIDTHxHEIGHT [OUT] [SOURCE]}
[[ $SIZE =~ ^[0-9]+x[0-9]+$ ]] || { echo "size must look like 1920x1080" >&2; exit 1; }
OUT=${2:-"$HERE/../rectilinear/background.png"}
SRC=${3:-"$HERE/wallpaper.jpg"}

# 8-bit RGB without alpha or metadata: the smallest PNG the boot manager's decoder handles.
magick "$SRC" -colorspace sRGB -filter Lanczos -resize "${SIZE}^" \
  -gravity center -extent "$SIZE" -strip -define png:exclude-chunks=date,time \
  -define png:color-type=2 -depth 8 "$OUT"
echo "wrote $OUT ($SIZE)"
