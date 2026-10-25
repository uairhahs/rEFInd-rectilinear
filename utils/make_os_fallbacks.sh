#!/bin/bash
# OS entries with no logo of their own use the theme's default icon
# (os_unknown.png) instead of rEFInd's stock art, so nothing generic is left
# in the old style. Add a name to GENERIC to give it the default look.
# usage: make_os_fallbacks.sh [ICONDIR]   (default: ../rectilinear/icons)
set -euo pipefail

ICONS=${1:-"$(dirname "$0")/../rectilinear/icons"}
GENERIC=(os_efi os_hwtest os_legacy os_refit os_clover os_gummiboot os_systemd)

for n in "${GENERIC[@]}"; do
  cp -f "$ICONS/os_unknown.png" "$ICONS/$n.png"
done

# rEFInd looks icons up by os_<name>.png; alias names share one image
cp -f "$ICONS/os_cachy_default.png" "$ICONS/os_cachy.png"   # official Cachy logo
cp -f "$ICONS/os_win.png" "$ICONS/os_win8.png"              # same as the other Windows icons
