#!/bin/bash
# fondo.sh — el fondo de pantalla del Rice "Debian Crimson", en UN sitio
#   fondo.sh          aplica el fondo elegido (bspwmrc, ajustar-monitores)
#   fondo.sh ruta     imprime la ruta del fondo actual (la usa bloquear.sh)
#   fondo.sh elegir   menu rofi con los fondos de ~/.dotfiles/wallpapers
#
# La eleccion se guarda en ~/.cache/fondo-actual (es estado de esta
# maquina, no config: por eso no vive en el repo). Sin eleccion, fondo.png.

DIR=~/.dotfiles/wallpapers
GUARDADO=~/.cache/fondo-actual
ICON=$(printf '\U000f02e9')   # nf-md-image

ruta_actual() {
    local r
    r=$(cat "$GUARDADO" 2>/dev/null)
    [ -f "$r" ] && echo "$r" || echo "$DIR/fondo.png"
}

case "$1" in
    ruta)
        ruta_actual ;;
    elegir)
        ELEC=$(cd "$DIR" && ls *.png | sed 's/\.png$//' | \
            rofi -dmenu -i -p " ${ICON}  Fondo " \
            -theme-str "listview { columns: 1; lines: 6; } element { orientation: horizontal; }")
        [ -z "$ELEC" ] && exit 0
        mkdir -p ~/.cache
        echo "$DIR/$ELEC.png" > "$GUARDADO"
        feh --bg-scale "$DIR/$ELEC.png" && \
            dunstify -h string:x-dunst-stack-tag:fondo "${ICON}  Fondo: $ELEC" ;;
    *)
        feh --bg-scale "$(ruta_actual)" ;;
esac
