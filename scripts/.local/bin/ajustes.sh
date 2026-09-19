#!/bin/bash
# ajustes.sh — menu de ajustes rapidos (tecla F9 del Lenovo)
# Rice Debian Crimson

ELEC=$(printf 'Wi-Fi on/off\nBluetooth on/off\nAudio (pavucontrol)\nBrillo 50%%\nEditar dotfiles\nRecargar sxhkd\nReiniciar polybar\nReiniciar bspwm' | \
    rofi -dmenu -i -p " $(printf '\uf013') Ajustes " \
    -theme-str "listview { columns: 1; lines: 8; } element { orientation: horizontal; }")

case "$ELEC" in
    "Wi-Fi on/off")
        if LANG=C nmcli radio wifi | grep -q enabled; then
            nmcli radio wifi off && \
                dunstify -h string:x-dunst-stack-tag:avion "Modo avion: Wi-Fi APAGADO"
        else
            nmcli radio wifi on && \
                dunstify -h string:x-dunst-stack-tag:avion "Modo avion: Wi-Fi ENCENDIDO"
        fi ;;
    "Bluetooth on/off")
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            bluetoothctl power off >/dev/null && dunstify "Bluetooth apagado"
        else
            bluetoothctl power on >/dev/null && dunstify "Bluetooth encendido"
        fi ;;
    "Audio (pavucontrol)")
        pavucontrol >/dev/null 2>&1 & ;;
    "Brillo 50%")
        brightnessctl -q set 50% && dunstify -h int:value:50 "Brillo" ;;
    "Editar dotfiles")
        kitty -e ~/.local/bin/nvim ~/.dotfiles >/dev/null 2>&1 & ;;
    "Recargar sxhkd")
        pkill -USR1 -x sxhkd && dunstify "sxhkd recargado" ;;
    "Reiniciar polybar")
        pkill -x polybar; sleep 1
        setsid polybar main >/dev/null 2>&1 < /dev/null &
        setsid polybar hdmi >/dev/null 2>&1 < /dev/null & ;;
    "Reiniciar bspwm")
        bspc wm -r ;;
esac
