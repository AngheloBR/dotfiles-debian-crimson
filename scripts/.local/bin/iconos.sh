#!/bin/bash
# iconos.sh — buscador de iconos Nerd Font en rofi (super + .)
# Rice Debian Crimson
#
# La lista (~/.local/share/crimson/iconos.txt, 10.700 iconos) viene del
# glyphnames.json oficial de Nerd Fonts: "icono  nombre  U+codepoint".
# Escribes "wifi" o "battery" y ves los que coinciden; Enter copia el
# ICONO al portapapeles; shift+Enter copia el escape para bash
# (printf '\U000fXXXX'), que es como van en los scripts del rice.

LISTA=~/.local/share/crimson/iconos.txt
ICON=$(printf '\U000f0b7f')   # nf-md-shape_plus
[ -f "$LISTA" ] || { dunstify -u critical "iconos: falta $LISTA"; exit 1; }

SEL=$(rofi -dmenu -i -p " ${ICON}  Icono " -kb-accept-alt "Shift+Return" \
      -theme-str "window { width: 760px; } listview { columns: 1; lines: 12; } element { orientation: horizontal; } element-text { horizontal-align: 0; }" \
      < "$LISTA"); RC=$?
[ -z "$SEL" ] && exit 0
GLIFO=${SEL%%  *}; NOMBRE=$(awk -F'  ' '{print $2}' <<< "$SEL"); CP=$(awk -F'  ' '{print $3}' <<< "$SEL" | sed 's/U+//')
if [ "$RC" -eq 10 ]; then        # shift+Enter: escape para printf
    if [ ${#CP} -gt 4 ]; then ESC="\\U$(printf '%08s' "$CP" | tr ' ' 0)"; else ESC="\\u$CP"; fi
    printf "%s" "$ESC" | xclip -selection clipboard
    dunstify -h string:x-dunst-stack-tag:icono "${GLIFO}  $NOMBRE" "copiado: printf '$ESC'"
else
    printf '%s' "$GLIFO" | xclip -selection clipboard
    dunstify -h string:x-dunst-stack-tag:icono "${GLIFO}  $NOMBRE" "icono copiado  ·  U+$CP"
fi
