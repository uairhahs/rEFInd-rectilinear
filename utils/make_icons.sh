#!/bin/bash
# Render the function/arrow icons, utility OS icons and mouse cursor from utils/glyphs.
# Every icon is the same construction: a filled glyph, fitted to GLYPH_BOX_PCT
# and centred by its drawn bounds, inside one round or square container
# whose colour comes from its shape (square: primary, round: secondary). All values live in tokens.sh.
# Requires rsvg-convert and ImageMagick.
# usage: make_icons.sh [OUTDIR]   (default: ../rectilinear/icons)
set -euo pipefail

HERE=$(dirname "$0")
. "$HERE/tokens.sh"
OUT=${1:-"$HERE/../rectilinear/icons"}
mkdir -p "$OUT"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
# container for a canvas of size $1, in the slot's shape (M3 Expressive buttons are
# round or square, never decorative): the tools row is a circle, OS-size icons are a
# rounded square with the same corner radius as the big selection.
container() {
  awk -v c="$1" -v os="$OS_CANVAS" -v pct="$CONTAINER_PCT" -v rpx="$RADIUS_PX" -v sel="$BIG_SELECTION_PX" 'BEGIN {
    side = c * pct / 100; off = (c - side) / 2
    if (c == os) printf "<rect x=\"%.2f\" y=\"%.2f\" width=\"%.2f\" height=\"%.2f\" rx=\"%.2f\"", off, off, side, side, c * rpx / sel
    else         printf "<circle cx=\"%.2f\" cy=\"%.2f\" r=\"%.2f\"", c / 2, c / 2, side / 2
  }'
}

icon() { # GLYPH OUTFILE [SIZE]
  local C=${3:-$CANVAS} d fill on
  local BOX=$((C * GLYPH_BOX_PCT / 100)) SHAPE; SHAPE=$(container "$C")
  d=$(grep -o ' d="[^"]*"' "$HERE/glyphs/$1.svg" | head -1)
  # shape decides colour (tokens.sh): square OS-size tiles primary, circles secondary
  if [ "$C" = "$OS_CANVAS" ]; then fill=$SQUARE_FILL on=$SQUARE_ON; else fill=$ROUND_FILL on=$ROUND_ON; fi
  rsvg-convert -w "$C" -h "$C" -o "$T/container.png" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $C $C">
  $SHAPE fill="$fill"/>
</svg>
SVG
  rsvg-convert -w 960 -h 960 -o "$T/g.png" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 -960 960 960"><path fill="#fff"$d/></svg>
SVG
  magick "$T/g.png" -trim +repage -resize "${BOX}x${BOX}" -background none -gravity center -extent ${C}x${C} \
    -alpha extract "$T/a.png"
  magick -size ${C}x${C} "xc:$on" "$T/a.png" -alpha off -compose CopyOpacity -composite "$T/glyph.png"
  magick "$T/container.png" "$T/glyph.png" -compose Over -composite "$OUT/$2.png"
}

icon info                   func_about
icon format_list_numbered   func_bootorder
icon chevron_left           arrow_left
icon chevron_right          arrow_right
icon memory                 func_firmware
icon download               func_install
icon lock                   func_csr_rotate
icon restart_alt            func_reset
icon power_settings_new     func_shutdown
icon logout                 func_exit
icon visibility_off         func_hidden

# tools row (rEFInd tool_* names)
icon terminal               tool_shell
icon memory_alt             tool_memtest
icon hard_drive             tool_part
icon key                    tool_mok_tool
icon system_update_alt      tool_fwupdate
icon cloud_download         tool_netboot
icon support                tool_rescue
icon settings_backup_restore tool_apple_rescue
icon settings_backup_restore tool_windows_rescue

# volume badges (rEFInd vol_* names)
icon memory                 vol_efi
icon usb                    vol_external
icon hard_drive             vol_internal
icon lan                    vol_net
icon album                  vol_optical

# utility OS icons (no distro logo of their own), same construction at OS-icon size
icon lan                    os_network "$OS_CANVAS"
icon search                 os_refind "$OS_CANVAS"
icon build                  boot_linux "$OS_CANVAS"   # "Arch Repair" entry

# OS logos from vector sources: trimmed to drawn bounds, fitted to the logo box
# and centred, the same rule the other distro icons follow
logo() { # SVG OUTFILE
  local C=$OS_CANVAS BOX=$((OS_CANVAS * OS_CONTENT_PCT / 100))
  rsvg-convert -w $((C*4)) -h $((C*4)) -o "$T/logo.png" "$1"
  magick "$T/logo.png" -trim +repage -resize "${BOX}x${BOX}" -background none -gravity center \
    -extent ${C}x${C} "$OUT/$2.png"
}

logo "$HERE/logos/cachyos.svg" os_cachy_default
logo "$HERE/logos/steamos.svg" os_steam

# mouse cursor: sharp tilted pointer, straight edge to the right-hand point and a
# long concave sweep back, rounded corners and a soft shadow. rEFInd uses the
# image's top-left as the click point, so the tip sits just inside that corner.
rsvg-convert -w 128 -h 128 -o "$OUT/mouse.png" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
  <defs><filter id="s" x="-20%" y="-20%" width="150%" height="150%">
    <feDropShadow dx="0" dy="3" stdDeviation="2.5" flood-color="#000" flood-opacity="0.4"/>
  </filter></defs>
  <path d="M11 10 L86 81 C62 67 26 79 11 118 Z" filter="url(#s)"
        fill="$CURSOR_FILL" stroke="$CURSOR_OUTLINE" stroke-width="7" stroke-linejoin="round"/>
</svg>
SVG
