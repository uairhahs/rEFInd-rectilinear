# Design tokens shared by the make_*.sh scripts.
# Change the look here; nothing else hard-codes colours or sizes.

# colours: Material 3 dynamic colour (make_scheme.sh writes scheme.sh). Primary
# and secondary each come from their own seed: a hex colour, or a wallpaper
# colour index (matugen's dominant-colour ranking, 0 = most dominant). The
# fidelity scheme's container tone keeps the seed itself as the fill and picks
# a contrasting glyph colour.
M3_SCHEME=scheme-fidelity
M3_PRIMARY_SEED='#c6a0f6'     # purple
M3_SECONDARY_SEED='#f4b8e4'   # pink
HERE_TOKENS=$(dirname "${BASH_SOURCE[0]}")
# shellcheck source=scheme.sh
[ -f "$HERE_TOKENS/scheme.sh" ] && . "$HERE_TOKENS/scheme.sh"

# shape decides colour: square containers are primary, round ones secondary
SQUARE_FILL=${M3_PRIMARY:-}; SQUARE_ON=${M3_ON_PRIMARY:-}
ROUND_FILL=${M3_SECONDARY:-};  ROUND_ON=${M3_ON_SECONDARY:-}

# icons: bold filled glyph inside a flat tonal round/square container
CANVAS=144
CONTAINER_PCT=92     # container diameter / side, % of canvas
GLYPH_BOX_PCT=52     # every glyph is fitted to this box, % of canvas

# OS icons: logos are fitted to the same box on the same canvas
OS_CANVAS=384
OS_CONTENT_PCT=$CONTAINER_PCT  # every big icon's drawn content fills this box (longest side): same padding for all

# cursor
CURSOR_FILL=${M3_ON_SURFACE:-}
CURSOR_OUTLINE=${M3_SURFACE:-}

# highlights: one translucent shape, no outline, tinted like the shapes it sits behind
TINT_BIG=$SQUARE_FILL
TINT_SMALL=$ROUND_FILL
INSET_PCT=3          # margin around the shape, % of canvas
FILL_OPACITY=0.22   # glass translucency
BIG_SELECTION_PX=144 # size rEFInd draws the big selection at
RADIUS_PX=6          # its corner radius, in on-screen pixels
