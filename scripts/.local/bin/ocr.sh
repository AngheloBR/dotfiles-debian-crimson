#!/bin/bash
# ocr.sh — selecciona una region de la pantalla y su TEXTO va al portapapeles
# Rice Debian Crimson (super + ctrl + Print)
#
# Para copiar texto de una imagen, un video, un PDF escaneado, una captura
# ajena... maim recorta la region, tesseract (OCR) la lee en español e
# ingles a la vez, y xclip deja el texto en el portapapeles.
# --psm 6: "bloque de texto uniforme", el modo que mejor va para trozos
# de pantalla. Ampliar x3 antes mejora mucho el acierto con letra pequeña.

command -v tesseract >/dev/null || { dunstify -u critical "OCR: falta tesseract-ocr"; exit 1; }
ICON=$(printf '\U000f0b0d')   # nf-md-text_recognition
TAG=(-h "string:x-dunst-stack-tag:ocr")
TMP=$(mktemp --suffix=.png)
trap 'rm -f "$TMP"' EXIT

maim -u -s -b 2 -c 0.910,0.690,0.294 "$TMP" || exit 0     # Esc = cancelar
[ -s "$TMP" ] || exit 0

TEXTO=$(magick "$TMP" -resize 300% -colorspace Gray -sharpen 0x1 png:- 2>/dev/null | \
        tesseract stdin stdout -l spa+eng --psm 6 2>/dev/null | sed -e 's/[[:space:]]*$//' | grep -v '^$')
if [ -z "$TEXTO" ]; then
    dunstify "${TAG[@]}" "${ICON}  OCR: no se reconocio texto"; exit 0
fi
printf '%s' "$TEXTO" | xclip -selection clipboard
dunstify "${TAG[@]}" "${ICON}  Texto copiado ($(wc -l <<< "$TEXTO") lineas)" "$(head -c 200 <<< "$TEXTO")"
