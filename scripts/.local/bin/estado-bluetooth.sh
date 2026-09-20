#!/bin/bash
# estado-bluetooth.sh — icono bluetooth para polybar (Rice Debian Crimson)
#   sin adaptador  -> sin salida (modulo oculto, ej. en una VM)
#   apagado        -> icono tachado gris
#   encendido      -> icono dorado
#   algo conectado -> icono "conectado" dorado + nombre del dispositivo
#
# Una sola llamada a bluetoothctl para el caso comun (apagado/sin
# adaptador); solo si esta encendido preguntamos por conectados.

ICON_ON=$(printf '\U000f00af')    # nf-md-bluetooth
ICON_OFF=$(printf '\U000f00b2')   # nf-md-bluetooth_off
ICON_CON=$(printf '\U000f00b1')   # nf-md-bluetooth_connect

ESTADO=$(bluetoothctl show 2>/dev/null)
[ -z "$ESTADO" ] && exit 0            # sin adaptador

if ! grep -q "Powered: yes" <<< "$ESTADO"; then
    echo "%{F#45474e}${ICON_OFF}%{F-}"
    exit 0
fi

# nombre del primer dispositivo conectado (si hay)
NOMBRE=$(bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d' ' -f3-)
if [ -n "$NOMBRE" ]; then
    echo "%{F#E8B04B}${ICON_CON}%{F-} ${NOMBRE:0:12}"
else
    echo "%{F#E8B04B}${ICON_ON}%{F-}"
fi
