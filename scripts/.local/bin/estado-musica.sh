#!/bin/bash
# estado-musica.sh — que esta sonando (MPRIS via playerctl), para polybar
# Rice Debian Crimson
#
# Modo "tail" de polybar: playerctl -F se queda escuchando y escribe una
# linea cada vez que cambia algo (evento), sin intervalos ni polling.
# Firefox, mpv, spotify... todos hablan MPRIS. Sin nada sonando: vacio.

command -v playerctl >/dev/null || exit 0
I_PLAY=$(printf '\U000f040a')    # nf-md-play
I_PAUSE=$(printf '\U000f03e4')   # nf-md-pause

playerctl -F metadata --format '{{status}}|{{artist}}|{{title}}' 2>/dev/null | \
while IFS='|' read -r estado artista titulo; do
    case "$estado" in
        Playing) icono="%{F#E8B04B}${I_PLAY}%{F-}" ;;
        Paused)  icono="%{F#45474e}${I_PAUSE}%{F-}" ;;
        *)       echo ""; continue ;;
    esac
    texto="$titulo"; [ -n "$artista" ] && texto="$artista - $titulo"
    [ ${#texto} -gt 40 ] && texto="${texto:0:39}…"
    echo "$icono $texto"
done
