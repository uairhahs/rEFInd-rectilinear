#!/bin/bash
# Bake a badge into a copy of a big (OS) icon, for manual menu entries that
# need telling apart, e.g. a current and a fallback kernel on the same ESP.
#
# rEFInd and RefindPlus take a manual entry's badge from the volume it boots
# from, so entries on one volume always get the same badge (or none), and no
# stanza option sets one. Drawing the badge into the icon gets around that.
# It goes where RefindPlus draws real badges: a quarter of the icon's width,
# 8 screen px in from the bottom-right corner.
#
# usage: make_badged.sh BASE BADGE OUTPUT
#   BASE, BADGE  a PNG path, or an icon name in ../rectilinear/icons
#                (os_arch, tool_windows_rescue, vol_external, ...)
#   OUTPUT       a PNG path, or a bare name written to ../rectilinear/icons
# env: BIG_ICON_SIZE  your big_icon_size setting (default 128); only sets
#                     the corner inset, so a rough value is fine
#
# example, a fallback-kernel entry:
#   utils/make_badged.sh os_arch tool_windows_rescue os_arch_previous
#   menuentry "Arch (previous)" {
#       icon /EFI/refind/themes/rectilinear/icons/os_arch_previous.png
#       loader /EFI/Linux/arch-fallback.efi
#   }
# Requires ImageMagick 7.
set -euo pipefail

ICONS="$(dirname "$0")/../rectilinear/icons"
[ $# -eq 3 ] || {
	sed -n '11,17p' "$0" | sed 's/^# \{0,1\}//' >&2
	exit 2
}

resolve() { # NAME|PATH -> existing file
	if [ -f "$1" ]; then
		echo "$1"
	elif [ -f "$ICONS/${1%.png}.png" ]; then
		echo "$ICONS/${1%.png}.png"
	else
		echo "make_badged.sh: no such icon: $1" >&2
		exit 1
	fi
}
BASE=$(resolve "$1") BADGE=$(resolve "$2")
case $3 in */*) OUT=$3 ;; *) OUT="$ICONS/${3%.png}.png" ;; esac

W=$(magick identify -format %w "$BASE")
B=$((W / 4)) INSET=$((W * 8 / ${BIG_ICON_SIZE:-128}))
POS=$((W - INSET - B))
magick "$BASE" \( "$BADGE" -filter Lanczos -resize "${B}x${B}" \) \
	-geometry "+${POS}+${POS}" -compose Over -composite \
	-strip -define png:exclude-chunks=date,time "$OUT"
echo "$OUT"
