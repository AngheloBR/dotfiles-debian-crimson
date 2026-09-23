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

# Resolucion del ESCRITORIO COMPLETO (con un monitor externo, X lo trata
# como una sola pantalla: 3840x1080). i3lock estira la imagen sobre todo,
# asi que hay que generarla de ese tamaño...
RES=$(xdpyinfo 2>/dev/null | awk -F'[ x]+' '/dimensions/{print $3"x"$4; exit}')
[ -z "$RES" ] && RES="1920x1080"
# ...y el candado va centrado en el monitor INTERNO, no en medio de los dos
GEO=$(xrandr --query | awk '/ connected primary/{print $4; exit}')
[ -z "$GEO" ] && GEO=$(xrandr --query | awk '/ connected [0-9]/{print $3; exit}')
MW=${GEO%%x*}; R=${GEO#*x}; MH=${R%%+*}; R=${R#*+}; MX=${R%%+*}; MY=${R#*+}
[ -z "$MW" ] && { MW=${RES%x*}; MH=${RES#*x}; MX=0; MY=0; }
# desplazamiento del centro del monitor respecto al centro del escritorio
OFF_X=$(( MX + MW/2 - ${RES%x*}/2 ))
OFF_Y=$(( MY + MH/2 - ${RES#*x}/2 ))

CACHE=~/.cache/lockscreen.png
HASH_FILE=~/.cache/lockscreen.md5
mkdir -p ~/.cache

# el hash lleva la resolucion y una version: se regenera si cambia el
# wallpaper, si se enchufa/quita un monitor o si cambia el dibujo
HNEW="$(md5sum "$WALLPAPER" | cut -d' ' -f1)-${RES}-${OFF_X}x${OFF_Y}-v3"
HOLD=$(cat "$HASH_FILE" 2>/dev/null)

if [ "$HNEW" != "$HOLD" ] || [ ! -f "$CACHE" ]; then
    FUENTE=~/.local/share/fonts/JetBrainsMonoNerd/JetBrainsMonoNerdFont-Regular.ttf
    CANDADO=$(printf '\U000f033e')   # nf-md-lock
    # blur fuerte + oscurecer al 65%, y encima el candado carmesi con halo
    # (arriba del centro: i3lock dibuja su circulo de "escribiendo" en el
    # centro exacto y no queremos que se pisen) + usuario@equipo en dorado
    # Lienzo del tamaño del escritorio y, encima, UNA copia del wallpaper
    # por monitor (ajustada a su geometria): asi no se estira entre
    # pantallas. Cada copia va con blur y oscurecida al 65%.
    CAPAS=()
    while read -r g; do
        [ -z "$g" ] && continue
        w=${g%%x*}; r=${g#*x}; h=${r%%+*}; r=${r#*+}; x=${r%%+*}; y=${r#*+}
        # '(' y ')' entre comillas: son argumentos de ImageMagick, no
        # subshells (con \( shellcheck cree que es una lista)
        CAPAS+=( '(' "$WALLPAPER" -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" \
                 -blur 0x10 -modulate '65,85' -repage "+${x}+${y}" ')' )
    done < <(xrandr --query | awk '/ connected [0-9]|connected primary/{for(i=3;i<=4;i++) if ($i ~ /^[0-9]+x[0-9]+\+/) {print $i; break}}')
    magick -size "$RES" xc:'#0f0f12' "${CAPAS[@]}" -layers flatten \
        -font "$FUENTE" -gravity center \
        \( +clone -fill none -pointsize 170 -fill '#D70A53' -annotate "+$OFF_X+$((OFF_Y-200))" "$CANDADO" \
           -blur 0x18 \) -compose lighten -composite \
        -pointsize 170 -fill '#D70A53' -annotate "+$OFF_X+$((OFF_Y-200))" "$CANDADO" \
        -pointsize 22 -fill '#E8B04B' -annotate "+$OFF_X+$((OFF_Y+190))" "$USER @ $(hostname)" \
        -pointsize 16 -fill '#b3b3b8' -annotate "+$OFF_X+$((OFF_Y+225))" "escribe tu contrasena y pulsa Enter" \
        "$CACHE"
    echo "$HNEW" > "$HASH_FILE"
fi

i3lock -n -i "$CACHE"
