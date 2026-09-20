#!/bin/bash
# multimedia.sh — teclas multimedia con notificacion (Rice Debian Crimson)
#
# Antes cada tecla del sxhkdrc repetia el mismo pactl + dunstify.
# Ahora todo vive aqui y sxhkd solo llama:
#   multimedia.sh vol +      subir volumen 5%
#   multimedia.sh vol -      bajar volumen 5%
#   multimedia.sh vol mute   silenciar/activar salida
#   multimedia.sh mic        silenciar/activar microfono
#   multimedia.sh brillo +   subir brillo 10%
#   multimedia.sh brillo -   bajar brillo 10%
#
# "x-dunst-stack-tag" hace que la notificacion se REEMPLACE en vez de
# apilarse cuando pulsas la tecla varias veces seguidas.

ICON_VOL=$(printf '\U000f057e')    # nf-md-volume_high
ICON_MUTE=$(printf '\U000f075f')   # nf-md-volume_mute
ICON_MIC=$(printf '\U000f036c')    # nf-md-microphone
ICON_MIC_OFF=$(printf '\U000f036d') # nf-md-microphone_off
ICON_BRILLO=$(printf '\U000f0599') # nf-md-white_balance_sunny

notificar_volumen() {
    if [ "$(LANG=C pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')" = "yes" ]; then
        dunstify -h string:x-dunst-stack-tag:volumen "$ICON_MUTE  Volumen silenciado"
    else
        VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '[0-9]+(?=%)' | head -1)
        dunstify -h string:x-dunst-stack-tag:volumen -h int:value:"$VOL" "$ICON_VOL  Volumen ${VOL}%"
    fi
}

case "$1 $2" in
    "vol +")    pactl set-sink-volume @DEFAULT_SINK@ +5%  && notificar_volumen ;;
    "vol -")    pactl set-sink-volume @DEFAULT_SINK@ -5%  && notificar_volumen ;;
    "vol mute") pactl set-sink-mute @DEFAULT_SINK@ toggle && notificar_volumen ;;
    "mic ")
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        if [ "$(LANG=C pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')" = "yes" ]; then
            dunstify -h string:x-dunst-stack-tag:mic "$ICON_MIC_OFF  Microfono SILENCIADO"
        else
            dunstify -h string:x-dunst-stack-tag:mic "$ICON_MIC  Microfono activo"
        fi ;;
    "brillo +"|"brillo -")
        if [ "$2" = "+" ]; then brightnessctl -q set +10%; else brightnessctl -q set 10%-; fi
        NIVEL=$(brightnessctl -m | cut -d, -f4 | tr -d '%')
        dunstify -h string:x-dunst-stack-tag:brillo -h int:value:"$NIVEL" "$ICON_BRILLO  Brillo ${NIVEL}%" ;;
    *)
        echo "uso: multimedia.sh {vol +|vol -|vol mute|mic|brillo +|brillo -}" >&2
        exit 1 ;;
esac
