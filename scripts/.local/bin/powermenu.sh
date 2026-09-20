#!/bin/bash
# powermenu.sh — menu de apagado del Rice Debian Crimson
# Lo abre el boton power de la polybar.

I_LOCK=$(printf '\U000f033e')     # nf-md-lock
I_SLEEP=$(printf '\U000f04b2')    # nf-md-sleep
I_REBOOT=$(printf '\U000f0709')   # nf-md-restart
I_OFF=$(printf '\U000f0425')      # nf-md-power
I_EXIT=$(printf '\U000f0343')     # nf-md-logout

ELEC=$(printf '%s  Bloquear\n%s  Suspender\n%s  Reiniciar\n%s  Apagar\n%s  Salir' \
        "$I_LOCK" "$I_SLEEP" "$I_REBOOT" "$I_OFF" "$I_EXIT" | \
    rofi -dmenu -i -p " ${I_OFF}  " \
    -theme-str "listview { columns: 1; lines: 5; } element { orientation: horizontal; }")

# se compara por la palabra, no por el icono
case "$ELEC" in
    *Bloquear)  exec ~/.local/bin/bloquear.sh ;;
    *Suspender) systemctl suspend ;;
    *Reiniciar) systemctl reboot ;;
    *Apagar)    systemctl poweroff ;;
    *Salir)     bspc quit ;;
esac
