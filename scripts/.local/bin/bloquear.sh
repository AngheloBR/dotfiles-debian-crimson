#!/bin/bash
# ═══════════════════════════════════════════════════════
#  bloquear.sh — Lock del Rice "Debian Crimson"
#  Blur + atenuado del wallpaper activo (imagemagick)
#  Fallback: i3lock con negro carmesi si falta algo.
# ═══════════════════════════════════════════════════════

# mismo fondo que pone bspwmrc/ajustar-monitores.sh (antes se sacaba con
# un grep sobre bspwmrc: fragil, se rompia con cualquier cambio de formato)
WALLPAPER="$HOME/.dotfiles/wallpapers/fondo.png"

if ! command -v i3lock >/dev/null; then
    echo "i3lock no instalado" >&2; exit 1
fi

# Sin imagemagick o sin wallpaper: color solido y listo
if ! command -v magick >/dev/null || [ ! -f "$WALLPAPER" ]; then
    i3lock -c 0f0f12
    exit 0
fi

# Resolucion real de la pantalla (soporta multimonitor despues)
RES=$(xdpyinfo 2>/dev/null | awk -F'[ x]+' '/dimensions/{print $3"x"$4; exit}')
[ -z "$RES" ] && RES="1920x1080"

CACHE=~/.cache/lockscreen.png
HASH_FILE=~/.cache/lockscreen.md5
mkdir -p ~/.cache

HNEW=$(md5sum "$WALLPAPER" | cut -d' ' -f1)
HOLD=$(cat "$HASH_FILE" 2>/dev/null)

if [ "$HNEW" != "$HOLD" ] || [ ! -f "$CACHE" ]; then
    # blur fuerte + oscurecer al 65% (para que se lea el candado/hora)
    magick "$WALLPAPER" \
        -resize "${RES}^" -gravity center -extent "$RES" \
        -blur 0x10 \
        -modulate 65,85 \
        "$CACHE"
    echo "$HNEW" > "$HASH_FILE"
fi

i3lock -i "$CACHE"
