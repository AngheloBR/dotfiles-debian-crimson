#!/bin/bash
# ═══════════════════════════════════════════════════════
#  bloquear.sh — Lock del Rice "Debian Crimson"
#  Blur + atenuado del wallpaper activo (imagemagick)
#  Fallback: i3lock con negro carmesi si falta algo.
#
#  Lo llaman: la tecla F10, el powermenu y xss-lock (que lo
#  dispara antes de suspender y tras 10 min sin actividad).
#  i3lock va con -n (no hacer fork) para que xss-lock sepa
#  cuando se desbloqueo la pantalla.
# ═══════════════════════════════════════════════════════

# el fondo que este puesto ahora mismo (fondo.sh es la unica fuente)
WALLPAPER=$(~/.local/bin/fondo.sh ruta)

if ! command -v i3lock >/dev/null; then
    echo "i3lock no instalado" >&2; exit 1
fi

# Sin imagemagick o sin wallpaper: color solido y listo
if ! command -v magick >/dev/null || [ ! -f "$WALLPAPER" ]; then
    i3lock -n -c 0f0f12
    exit 0
fi

# Resolucion real de la pantalla (soporta multimonitor despues)
RES=$(xdpyinfo 2>/dev/null | awk -F'[ x]+' '/dimensions/{print $3"x"$4; exit}')
[ -z "$RES" ] && RES="1920x1080"

CACHE=~/.cache/lockscreen.png
HASH_FILE=~/.cache/lockscreen.md5
mkdir -p ~/.cache

# el hash lleva un sufijo de version: si cambia el dibujo (candado, texto)
# se regenera aunque el wallpaper sea el mismo
HNEW="$(md5sum "$WALLPAPER" | cut -d' ' -f1)-v2"
HOLD=$(cat "$HASH_FILE" 2>/dev/null)

if [ "$HNEW" != "$HOLD" ] || [ ! -f "$CACHE" ]; then
    FUENTE=~/.local/share/fonts/JetBrainsMonoNerd/JetBrainsMonoNerdFont-Regular.ttf
    CANDADO=$(printf '\U000f033e')   # nf-md-lock
    # blur fuerte + oscurecer al 65%, y encima el candado carmesi con halo
    # (arriba del centro: i3lock dibuja su circulo de "escribiendo" en el
    # centro exacto y no queremos que se pisen) + usuario@equipo en dorado
    magick "$WALLPAPER" \
        -resize "${RES}^" -gravity center -extent "$RES" \
        -blur 0x10 \
        -modulate 65,85 \
        -font "$FUENTE" -gravity center \
        \( +clone -fill none -pointsize 170 -fill '#D70A53' -annotate +0-200 "$CANDADO" \
           -blur 0x18 \) -compose lighten -composite \
        -pointsize 170 -fill '#D70A53' -annotate +0-200 "$CANDADO" \
        -pointsize 22 -fill '#E8B04B' -annotate +0+190 "$USER @ $(hostname)" \
        -pointsize 16 -fill '#b3b3b8' -annotate +0+225 "escribe tu contrasena y pulsa Enter" \
        "$CACHE"
    echo "$HNEW" > "$HASH_FILE"
fi

i3lock -n -i "$CACHE"
