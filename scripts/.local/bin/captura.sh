#!/bin/bash
# captura.sh — capturas de pantalla al PORTAPAPELES y a archivo
# Rice Debian Crimson
#   captura.sh ventana    la ventana enfocada          (super + Print)
#   captura.sh region     arrastrar un rectangulo      (super + shift + Print)
#   captura.sh pantalla   todo el monitor              (shift + Print)
# (Print a secas sigue abriendo flameshot, para anotar con flechas/texto)
#
# maim captura, xclip la deja en el portapapeles como image/png (pegar
# con ctrl+v en Firefox, Telegram, Discord...) y ademas se guarda en
# ~/Imagenes/Capturas/AAAA-MM-DD_HH-MM-SS.png por si se quiere despues.
# La copia de texto (portapapeles.sh) no se entera: solo lee texto.

DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo ~/Imágenes)/Capturas"
mkdir -p "$DIR"
ARCHIVO="$DIR/$(date '+%Y-%m-%d_%H-%M-%S').png"
ICON=$(printf '\U000f0100')   # nf-md-camera
TAG=(-h "string:x-dunst-stack-tag:captura")

case "$1" in
    ventana)  maim -u -i "$(bspc query -N -n focused)" "$ARCHIVO" ;;
    region)   maim -u -s -b 2 -c 0.843,0.039,0.325 "$ARCHIVO" ;;   # borde carmesi al seleccionar
    pantalla) maim -u "$ARCHIVO" ;;
    *) echo "uso: captura.sh {ventana|region|pantalla}" >&2; exit 1 ;;
esac

# maim falla si se cancela la seleccion con Esc: no avisar de nada
[ -s "$ARCHIVO" ] || { rm -f "$ARCHIVO"; exit 0; }

xclip -selection clipboard -t image/png -i "$ARCHIVO"
dunstify "${TAG[@]}" -I "$ARCHIVO" "${ICON}  Captura en el portapapeles" "$(basename "$ARCHIVO")  ·  $1"
