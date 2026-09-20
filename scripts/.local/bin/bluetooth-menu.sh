#!/bin/bash
# bluetooth-menu.sh — bluetooth del Rice Debian Crimson
#   sin args -> menu rofi (click en el icono de polybar):
#               encender/apagar, conectar/desconectar conocidos, blueman
#   toggle   -> solo alterna el adaptador (lo usa el menu F9)

I_BT=$(printf '\U000f00af')       # nf-md-bluetooth
I_BT_OFF=$(printf '\U000f00b2')   # nf-md-bluetooth_off
I_LINK=$(printf '\U000f0337')     # nf-md-link
I_LINK_OFF=$(printf '\U000f0338') # nf-md-link_off
I_SEARCH=$(printf '\U000f00b0')   # nf-md-bluetooth_audio (buscar)

encendido() { bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; }

alternar() {
    if encendido; then
        bluetoothctl power off >/dev/null 2>&1 && \
            dunstify -h string:x-dunst-stack-tag:bt "${I_BT_OFF}  Bluetooth apagado"
    else
        bluetoothctl power on >/dev/null 2>&1 && \
            dunstify -h string:x-dunst-stack-tag:bt "${I_BT}  Bluetooth encendido"
    fi
}

if [ "$1" = "toggle" ]; then alternar; exit 0; fi

# ── armar el menu ──
if encendido; then ACCION="${I_BT_OFF}  Apagar Bluetooth"; else ACCION="${I_BT}  Encender Bluetooth"; fi

OPCIONES="$ACCION"
while read -r mac nombre; do
    if bluetoothctl info "$mac" 2>/dev/null | grep -q "Connected: yes"; then
        OPCIONES="${OPCIONES}
${I_LINK}  ${nombre} (conectado) :: ${mac}"
    else
        OPCIONES="${OPCIONES}
${I_LINK_OFF}  ${nombre} :: ${mac}"
    fi
done < <(bluetoothctl devices 2>/dev/null | sed 's/^Device //')
OPCIONES="${OPCIONES}
${I_SEARCH}  Buscar y emparejar (blueman)"

ELEC=$(printf '%s' "$OPCIONES" | rofi -dmenu -i -p " ${I_BT}  Bluetooth " \
    -theme-str "listview { columns: 1; lines: 8; } element { orientation: horizontal; }")

[ -z "$ELEC" ] && exit 0

case "$ELEC" in
    *"Encender Bluetooth"|*"Apagar Bluetooth") alternar ;;
    *"Buscar y emparejar"*) blueman-manager >/dev/null 2>&1 & ;;
    *" :: "*)
        # linea de dispositivo: "icono  Nombre (estado) :: MAC"
        MAC=$(printf '%s' "$ELEC" | awk -F':: ' '{print $NF}')
        NOMBRE=$(printf '%s' "$ELEC" | awk -F' :: ' '{print $1}' | sed 's/^[^ ]*  //; s/ (conectado)$//')
        if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
            bluetoothctl disconnect "$MAC" >/dev/null 2>&1
            dunstify -h string:x-dunst-stack-tag:bt "${I_LINK_OFF}  Desconectado de $NOMBRE"
        else
            dunstify -h string:x-dunst-stack-tag:bt "${I_BT}  Conectando a $NOMBRE..."
            if bluetoothctl connect "$MAC" >/dev/null 2>&1; then
                dunstify -h string:x-dunst-stack-tag:bt "${I_LINK}  Conectado a $NOMBRE"
            else
                dunstify -u critical -h string:x-dunst-stack-tag:bt "${I_BT_OFF}  No se pudo conectar a $NOMBRE"
            fi
        fi ;;
esac
