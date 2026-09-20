#!/bin/bash
# estado-musica.sh — que esta sonando (MPRIS via playerctl), para polybar
# Rice Debian Crimson
#   sin args         -> modo "tail" de polybar: playerctl -F escucha eventos
#                       y escribe una linea cada vez que cambia algo
#   accion anterior  -> pista anterior     (botones de la barra)
#   accion pausa     -> reproducir/pausar
#   accion siguiente -> pista siguiente
#
# La linea lleva sus propios botones con %{A1:cmd:}...%{A} (accion de
# polybar al click izquierdo), asi cada icono hace UNA cosa clara y el
# titulo no reacciona a clicks. Cada accion notifica lo que hizo.

command -v playerctl >/dev/null || exit 0
I_PREV=$(printf '\U000f04ae')    # nf-md-skip_previous
I_NEXT=$(printf '\U000f04ad')    # nf-md-skip_next
I_PLAY=$(printf '\U000f040a')    # nf-md-play
I_PAUSE=$(printf '\U000f03e4')   # nf-md-pause
TAG="-h string:x-dunst-stack-tag:musica"

if [ "$1" = "accion" ]; then
    case "$2" in
        anterior)  playerctl previous;   sleep 0.3
                   dunstify $TAG "${I_PREV}  Anterior" "$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)" ;;
        siguiente) playerctl next;       sleep 0.3
                   dunstify $TAG "${I_NEXT}  Siguiente" "$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)" ;;
        pausa)     playerctl play-pause; sleep 0.2
                   if [ "$(playerctl status 2>/dev/null)" = "Playing" ]; then
                       dunstify $TAG "${I_PLAY}  Reproduciendo" "$(playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null)"
                   else
                       dunstify $TAG "${I_PAUSE}  En pausa"
                   fi ;;
    esac
    exit 0
fi

YO=~/.local/bin/estado-musica.sh
BTN_PREV="%{A1:$YO accion anterior:}%{F#b3b3b8}${I_PREV}%{F-}%{A}"
BTN_NEXT="%{A1:$YO accion siguiente:}%{F#b3b3b8}${I_NEXT}%{F-}%{A}"

playerctl -F metadata --format '{{status}}|{{artist}}|{{title}}' 2>/dev/null | \
while IFS='|' read -r estado artista titulo; do
    case "$estado" in
        Playing) boton="%{A1:$YO accion pausa:}%{F#E8B04B}${I_PAUSE}%{F-}%{A}" ;;
        Paused)  boton="%{A1:$YO accion pausa:}%{F#E8B04B}${I_PLAY}%{F-}%{A}" ;;
        *)       echo ""; continue ;;
    esac
    texto="$titulo"; [ -n "$artista" ] && texto="$artista - $titulo"
    [ ${#texto} -gt 36 ] && texto="${texto:0:35}…"
    echo "${BTN_PREV} ${boton} ${BTN_NEXT}  ${texto}"
done
