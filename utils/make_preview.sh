#!/bin/bash
# Composite a preview of the theme from its real assets (background, icons,
# selection, font sheet) using rEFInd's layout: 128px OS icons with a 144px
# selection, 48px tool icons with a 64px selection, centred label below.
# This is a mock-up, not a screenshot of rEFInd. Requires ImageMagick.
# usage: make_preview.sh [OUT]   (default: ../preview.png)
set -euo pipefail

HERE=$(dirname "$0")
THEME="$HERE/../rectilinear"
OUT=${1:-"$HERE/../preview.png"}
ICONS="$THEME/icons"

BIG=128 BIG_SEL=144 BIG_PITCH=151 BIG_Y=540
SMALL=48 SMALL_SEL=64 SMALL_PITCH=72 SMALL_Y=660
LABEL_Y=722
BADGE=32   # drive badge drawn on the lower-right corner of each OS tile
OS=(os_win os_cachy os_linux os_arch os_ubuntu os_fedora os_debian)
TOOLS=(func_bootorder func_about func_hidden func_reset func_exit func_firmware)
SELECTED=2
LABEL="Boot Linux from linux"

args=("$THEME/background.png")

place() { # FILE SIZE CENTER_X CENTER_Y
  args+=( \( "$1" -resize "${2}x${2}" \) -geometry "+$(($3-$2/2))+$(($4-$2/2))" -composite )
}
centre() { echo $((960 + ($1*2 - $2 + 1) * $3 / 2)); }   # index count pitch -> x

n=${#OS[@]}
for i in "${!OS[@]}"; do
  x=$(centre "$i" "$n" "$BIG_PITCH")
  [ "$i" = "$SELECTED" ] && place "$ICONS/selection_big.png" "$BIG_SEL" "$x" "$BIG_Y"
  place "$ICONS/${OS[$i]}.png" "$BIG" "$x" "$BIG_Y"
  place "$ICONS/vol_internal.png" "$BADGE" "$((x + BIG/2 - BADGE/2))" "$((BIG_Y + BIG/2 - BADGE/2))"
done
n=${#TOOLS[@]}
for i in "${!TOOLS[@]}"; do
  place "$ICONS/${TOOLS[$i]}.png" "$SMALL" "$(centre "$i" "$n" "$SMALL_PITCH")" "$SMALL_Y"
done

# label: glyphs cut from the font sheet (alpha only), rEFInd draws them in white
FONT="$THEME/fonts/space-mono-28.png"
CW=$(( $(identify -format %w "$FONT") / 96 )); CH=$(identify -format %h "$FONT")
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
magick "$FONT" -alpha extract "$T/alpha.png"
cells=()
for ((k=0; k<${#LABEL}; k++)); do
  c=$(printf '%d' "'${LABEL:k:1}")
  cells+=( \( "$T/alpha.png" -crop "${CW}x${CH}+$(((c-32)*CW))+0" +repage \) )
done
magick "${cells[@]}" +append "$T/label.png"
w=$(identify -format %w "$T/label.png")
args+=( "$T/label.png" -geometry "+$((960-w/2))+$((LABEL_Y-CH/2))" -compose Screen -composite )

magick "${args[@]}" "$OUT"
echo "wrote $OUT"
