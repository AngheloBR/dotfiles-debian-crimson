#!/bin/bash
# color.sh — click en cualquier pixel y su color #hex va al portapapeles
# Rice Debian Crimson (super + shift + c)
#
# xdotool selectwindow espera a que hagas click (cambia el cursor a una
# cruz); en ese instante getmouselocation da las coordenadas, maim captura
# ese unico pixel y ImageMagick dice su color. La notificacion lo muestra.

command -v xdotool >/dev/null || { dunstify -u critical "color: falta xdotool"; exit 1; }
ICON=$(printf '\U000f0765')   # nf-md-eyedropper
xdotool selectwindow >/dev/null 2>&1 || exit 0
eval "$(xdotool getmouselocation --shell)"      # define X e Y
HEX=$(maim -u -g "1x1+${X}+${Y}" 2>/dev/null | magick - -format '%[hex:p{0,0}]' info: 2>/dev/null | cut -c1-6)
[ -z "$HEX" ] && exit 1
printf '#%s' "$HEX" | xclip -selection clipboard
# el cuadrado de color en la notificacion: una imagen de 64x64 con ese color
SW=$(mktemp --suffix=.png); magick -size 64x64 "xc:#$HEX" "$SW"
dunstify -h string:x-dunst-stack-tag:color -I "$SW" "${ICON}  #${HEX}" "copiado al portapapeles  ·  ${X},${Y}"
sleep 6; rm -f "$SW"
