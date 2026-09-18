#!/bin/bash
# powermenu.sh — menu de apagado del Rice Debian Crimson
# Lo abre el boton power de la polybar.

ELEC=$(printf 'Bloquear\nSuspender\nReiniciar\nApagar\nSalir' | \
    rofi -dmenu -i -p " $(printf '\uf011')  " \
    -theme-str "listview { columns: 1; lines: 5; } element { orientation: horizontal; }")

case "$ELEC" in
    "Bloquear")  exec ~/.local/bin/bloquear.sh ;;
    "Suspender") systemctl suspend ;;
    "Reiniciar") systemctl reboot ;;
    "Apagar")    systemctl poweroff ;;
    "Salir")     bspc quit ;;
esac
