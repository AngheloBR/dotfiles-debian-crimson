#!/bin/bash
# atajos.sh — chuleta de atajos de teclado (Rice Debian Crimson), super+F1
#
# No hay lista aparte que mantener: lee ~/.config/sxhkd/sxhkdrc y usa el
# comentario que hay encima de cada atajo como descripcion. Si añades un
# atajo con su comentario, aparece aqui solo. Las llaves {a,b} se dejan
# tal cual: es la notacion de sxhkd y se entiende ("una de las dos").

ICON=$(printf '\U000f030c')   # nf-md-keyboard

awk '
    # comentario: se acumula (varias lineas -> una descripcion)
    /^#/ {
        linea = $0; sub(/^#[ \t]*/, "", linea)
        if (linea != "") desc = (desc == "" ? linea : desc " " linea)
        next
    }
    # linea en blanco: cierra el bloque (los titulos de seccion se pierden aqui, bien)
    /^[ \t]*$/ { desc = ""; next }
    # linea indentada: es el comando, no interesa
    /^[ \t]/ { next }
    # cualquier otra: es un atajo
    {
        tecla = $0
        gsub(/super/, "Super", tecla); gsub(/shift/, "Shift", tecla)
        gsub(/ctrl/, "Ctrl", tecla);  gsub(/alt/, "Alt", tecla)
        gsub(/Return/, "Enter", tecla)
        printf "%-32s %s\n", tecla, desc
        desc = ""
    }
' ~/.config/sxhkd/sxhkdrc | \
rofi -dmenu -i -p " ${ICON}  Atajos " \
    -theme-str "window { width: 1240px; } listview { columns: 1; lines: 14; } element { orientation: horizontal; padding: 6px 10px; } element-text { horizontal-align: 0; }" \
    >/dev/null
