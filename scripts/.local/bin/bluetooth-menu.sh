#!/bin/bash
# bluetooth-menu.sh — ver dispositivos y conectarse
# Rice Debian Crimson. Lo abre el click en el icono bluetooth de polybar.
#
# Opciones del menu:
#   - Encender/Apagar el adaptador
#   - Cada dispositivo conocido (click = conectar/desconectar)
#   - Buscar y emparejar nuevos (abre blueman-manager)

ICON=$(printf '\uf294')

# estado del adaptador para la primera opcion
if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    ACCION="Apagar Bluetooth"
else
    ACCION="Encender Bluetooth"
fi

# armar el menu: accion + dispositivos conocidos + blueman
OPCIONES="$ACCION"
while read -r mac nombre; do
    if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
        OPCIONES="${OPCIONES}
${nombre} (conectado) :: ${mac}"
    else
        OPCIONES="${OPCIONES}
${nombre} :: ${mac}"
    fi
done < <(bluetoothctl devices 2>/dev/null | sed 's/^Device //')
OPCIONES="${OPCIONES}
Buscar y emparejar (blueman)"

ELEC=$(printf '%s' "$OPCIONES" | rofi -dmenu -i -p " ${ICON} Bluetooth " \
    -theme-str "listview { columns: 1; lines: 8; } element { orientation: horizontal; }")

[ -z "$ELEC" ] && exit 0

case "$ELEC" in
    "Encender Bluetooth")
        bluetoothctl power on >/dev/null 2>&1 && \
            dunstify -h string:x-dunst-stack-tag:bt "Bluetooth encendido" ;;
    "Apagar Bluetooth")
        bluetoothctl power off >/dev/null 2>&1 && \
            dunstify -h string:x-dunst-stack-tag:bt "Bluetooth apagado" ;;
    "Buscar y emparejar (blueman)")
        blueman-manager >/dev/null 2>&1 & ;;
    *" :: "*)
        # linea de dispositivo: "Nombre (estado) :: MAC"
        MAC=$(printf '%s' "$ELEC" | awk -F':: ' '{print $NF}')
        NOMBRE=$(printf '%s' "$ELEC" | awk -F' :: ' '{print $1}')
        if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
            bluetoothctl disconnect "$MAC" >/dev/null 2>&1
            dunstify -h string:x-dunst-stack-tag:bt "Bluetooth: desconectado de $NOMBRE"
        else
            dunstify -h string:x-dunst-stack-tag:bt "Bluetooth: conectando a $NOMBRE..."
            if bluetoothctl connect "$MAC" >/dev/null 2>&1; then
                dunstify -h string:x-dunst-stack-tag:bt "Bluetooth: conectado a $NOMBRE"
            else
                dunstify -u critical -h string:x-dunst-stack-tag:bt "Bluetooth: no se pudo conectar a $NOMBRE"
            fi
        fi
        ;;
esac
