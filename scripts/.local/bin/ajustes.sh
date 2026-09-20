#!/bin/bash
# ajustes.sh — menu de ajustes rapidos (tecla F9 del Lenovo)
# Rice Debian Crimson
#
# Este menu NO repite logica: cada opcion delega en el script que ya
# sabe hacerlo (red-wifi.sh, bluetooth-menu.sh, ajustar-monitores.sh).

I_COG=$(printf '\U000f0493')      # nf-md-cog
I_WIFI=$(printf '\U000f0928')     # nf-md-wifi_strength_4
I_BT=$(printf '\U000f00af')       # nf-md-bluetooth
I_AUDIO=$(printf '\U000f04c3')    # nf-md-speaker
I_SOL=$(printf '\U000f0599')      # nf-md-white_balance_sunny
I_MON=$(printf '\U000f0379')      # nf-md-monitor
I_EDIT=$(printf '\U000f03eb')     # nf-md-pencil
I_RELOAD=$(printf '\U000f0453')   # nf-md-reload
I_BAR=$(printf '\U000f0322')      # nf-md-laptop
I_WM=$(printf '\U000f0709')       # nf-md-restart

ELEC=$(printf '%s  Wi-Fi on/off\n%s  Bluetooth on/off\n%s  Audio (pavucontrol)\n%s  Brillo 50%%\n%s  Detectar monitores\n%s  Editar dotfiles\n%s  Recargar sxhkd\n%s  Reiniciar polybar\n%s  Reiniciar bspwm' \
        "$I_WIFI" "$I_BT" "$I_AUDIO" "$I_SOL" "$I_MON" "$I_EDIT" "$I_RELOAD" "$I_BAR" "$I_WM" | \
    rofi -dmenu -i -p " ${I_COG}  Ajustes " \
    -theme-str "listview { columns: 1; lines: 9; } element { orientation: horizontal; }")

case "$ELEC" in
    *"Wi-Fi on/off")       ~/.local/bin/red-wifi.sh toggle ;;
    *"Bluetooth on/off")   ~/.local/bin/bluetooth-menu.sh toggle ;;
    *"Audio (pavucontrol)") pavucontrol >/dev/null 2>&1 & ;;
    *"Brillo 50%")         brightnessctl -q set 50% && dunstify -h int:value:50 "${I_SOL}  Brillo 50%" ;;
    *"Detectar monitores") ~/.local/bin/ajustar-monitores.sh && dunstify "${I_MON}  Monitores ajustados" ;;
    *"Editar dotfiles")    kitty -e ~/.local/bin/nvim ~/.dotfiles >/dev/null 2>&1 & ;;
    *"Recargar sxhkd")     pkill -USR1 -x sxhkd && dunstify "${I_RELOAD}  sxhkd recargado" ;;
    # polybar tiene IPC (enable-ipc en config.ini): se reinicia sola,
    # sin pkill ni sleep, releyendo la config
    *"Reiniciar polybar")  polybar-msg cmd restart >/dev/null && dunstify "${I_BAR}  polybar reiniciada" ;;
    *"Reiniciar bspwm")    bspc wm -r ;;
esac
