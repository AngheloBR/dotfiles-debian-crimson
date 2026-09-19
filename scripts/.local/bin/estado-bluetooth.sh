#!/bin/bash
# estado-bluetooth.sh — icono bluetooth para polybar
# Rice Debian Crimson
#   sin adaptador  -> sin salida (modulo oculto)
#   apagado       -> icono gris "off"
#   encendido      -> icono dorado "on"
#   algo conectado -> icono dorado "con"

# sin adaptador bluetooth (ej. VM) -> ocultar modulo
ADAPTADORES=$(bluetoothctl list 2>/dev/null)
[ -z "$ADAPTADORES" ] && exit 0

ICON_BT=$(printf '\uf294')

if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    if bluetoothctl devices Connected 2>/dev/null | grep -q "^Device"; then
        echo "%{F#E8B04B}${ICON_BT}%{F-} con"
    else
        echo "%{F#E8B04B}${ICON_BT}%{F-} on"
    fi
else
    echo "%{F#45474e}${ICON_BT}%{F-} off"
fi
