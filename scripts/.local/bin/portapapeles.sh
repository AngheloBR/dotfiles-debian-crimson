#!/bin/bash
# portapapeles.sh — historial del portapapeles (Rice Debian Crimson)
#   daemon -> lo arranca bspwmrc: guarda cada cosa nueva que copias
#   menu   -> super+v: elige una entrada y vuelve al portapapeles
#   borrar -> vacia el historial
#
# No hay clipmenu/greenclip en Debian 13 y copyq es un programa Qt
# enorme; con xclip (ya instalado) basta. Cada entrada es un archivo en
# ~/.cache/portapapeles/ (asi las copias de varias lineas no se rompen).
# Se guardan las ultimas 30; se ignoran vacios, repetidos y >100 KB.
# El daemon mira el portapapeles cada segundo: xclip es diminuto, el
# coste es despreciable (no hay "avisame cuando cambie" en X11 puro).

DIR=~/.cache/portapapeles
MAX=30
ICON=$(printf '\U000f018f')   # nf-md-clipboard_text
I_DEL=$(printf '\U000f01b4')  # nf-md-delete
mkdir -p "$DIR"

case "$1" in
    daemon)
        ULTIMO=""
        while true; do
            ACTUAL=$(timeout 1 xclip -o -selection clipboard 2>/dev/null)
            if [ -n "${ACTUAL// /}" ] && [ "$ACTUAL" != "$ULTIMO" ] && [ ${#ACTUAL} -le 102400 ]; then
                HASH=$(printf '%s' "$ACTUAL" | md5sum | cut -c1-12)
                # si ya existia (copiado antes), solo lo sube al principio
                rm -f "$DIR"/*-"$HASH"
                printf '%s' "$ACTUAL" > "$DIR/$(date +%s%N)-$HASH"
                ULTIMO="$ACTUAL"
                # recortar a MAX (los mas viejos primero por nombre = timestamp).
                # ls es seguro aqui: los nombres los pone este script (digitos-hash)
                # shellcheck disable=SC2012
                ls -1 "$DIR" | head -n -$MAX | sed "s|^|$DIR/|" | xargs -r rm -f
            fi
            sleep 1
        done ;;
    menu)
        mapfile -t ARCHIVOS < <(ls -1r "$DIR" 2>/dev/null)
        if [ ${#ARCHIVOS[@]} -eq 0 ]; then
            dunstify -h string:x-dunst-stack-tag:clip "${ICON}  Portapapeles vacio"; exit 0
        fi
        # una linea por entrada: primera linea del contenido, recortada a 70
        LINEAS=$(for f in "${ARCHIVOS[@]}"; do
            head -c 300 "$DIR/$f" | tr '\n\t' '  ' | cut -c1-70
        done)
        # ultima linea del menu: borrar todo (indice = numero de entradas)
        N=$(( ${#ARCHIVOS[@]} + 1 )); [ $N -gt 10 ] && N=10
        IDX=$(printf '%s\n%s  Borrar historial' "$LINEAS" "$I_DEL" | \
            rofi -dmenu -i -format i -p " ${ICON}  Portapapeles " \
            -theme-str "listview { columns: 1; lines: $N; } element { orientation: horizontal; } element-text { horizontal-align: 0; }")
        [ -z "$IDX" ] && exit 0
        if [ "$IDX" -eq ${#ARCHIVOS[@]} ]; then exec "$0" borrar; fi
        xclip -i -selection clipboard < "$DIR/${ARCHIVOS[$IDX]}"
        dunstify -h string:x-dunst-stack-tag:clip "${ICON}  Copiado al portapapeles" ;;
    borrar)
        rm -f "$DIR"/*
        # vaciar tambien el portapapeles actual: si no, el daemon lo
        # volveria a guardar al segundo siguiente
        printf '' | xclip -i -selection clipboard
        dunstify -h string:x-dunst-stack-tag:clip "${I_DEL}  Historial del portapapeles borrado" ;;
    *)
        echo "uso: portapapeles.sh {daemon|menu|borrar}" >&2; exit 1 ;;
esac
