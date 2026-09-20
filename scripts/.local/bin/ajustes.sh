#!/bin/bash
# ajustes.sh — menu de ajustes rapidos (tecla F9 del Lenovo)
# Rice Debian Crimson
#
# Este menu NO repite logica: cada opcion delega en el script que ya
# sabe hacerlo (wifi-menu.sh, bluetooth-menu.sh, vpn.sh, fondo.sh...).
# Las opciones van en bloques: red / dispositivos / pantalla / sistema.

I_COG=$(printf '\U000f0493')      # nf-md-cog
I_WIFI=$(printf '\U000f0928')     # nf-md-wifi_strength_4
I_BT=$(printf '\U000f00af')       # nf-md-bluetooth
I_VPN=$(printf '\U000f0582')      # nf-md-shield_check
I_AUDIO=$(printf '\U000f04c3')    # nf-md-speaker
I_PRINT=$(printf '\U000f042a')    # nf-md-printer
I_SCAN=$(printf '\U000f0c56')     # nf-md-scanner
I_SOL=$(printf '\U000f0599')      # nf-md-white_balance_sunny
I_NOCHE=$(printf '\U000f0594')    # nf-md-weather_night
I_FONDO=$(printf '\U000f02e9')    # nf-md-image
I_MON=$(printf '\U000f0379')      # nf-md-monitor
I_CLEAN=$(printf '\U000f0322')    # nf-md-laptop
I_UPD=$(printf '\U000f06b0')      # nf-md-package_variant
I_KEYS=$(printf '\U000f030c')     # nf-md-keyboard
I_EDIT=$(printf '\U000f03eb')     # nf-md-pencil
I_RELOAD=$(printf '\U000f0453')   # nf-md-reload
I_WM=$(printf '\U000f0709')       # nf-md-restart

OPC=(
    "${I_WIFI}  Redes Wi-Fi"
    "${I_BT}  Bluetooth on/off"
    "${I_VPN}  VPN"
    "${I_AUDIO}  Audio (pavucontrol)"
    "${I_PRINT}  Impresoras"
    "${I_SCAN}  Escanear documento"
    "${I_SOL}  Brillo 50%"
    "${I_NOCHE}  Luz nocturna on/off"
    "${I_FONDO}  Cambiar fondo"
    "${I_MON}  Detectar monitores"
    "${I_CLEAN}  Limpiar pantalla (60 s)"
    "${I_UPD}  Actualizar sistema"
    "${I_KEYS}  Chuleta de atajos"
    "${I_EDIT}  Editar dotfiles"
    "${I_RELOAD}  Recargar sxhkd"
    "${I_RELOAD}  Reiniciar polybar"
    "${I_WM}  Reiniciar bspwm"
)

ELEC=$(printf '%s\n' "${OPC[@]}" | rofi -dmenu -i -p " ${I_COG}  Ajustes " \
    -theme-str "listview { columns: 1; lines: 12; } element { orientation: horizontal; }")

case "$ELEC" in
    *"Redes Wi-Fi")         ~/.local/bin/wifi-menu.sh ;;
    *"Bluetooth on/off")    ~/.local/bin/bluetooth-menu.sh toggle ;;
    *"VPN")                 ~/.local/bin/vpn.sh menu ;;
    *"Audio (pavucontrol)") pavucontrol >/dev/null 2>&1 & ;;
    # system-config-printer: añadir/quitar impresoras (CUPS) por red o USB
    *"Impresoras")          system-config-printer >/dev/null 2>&1 & ;;
    # simple-scan: escaner (sane-airscan encuentra multifunciones por Wi-Fi)
    *"Escanear documento")  simple-scan >/dev/null 2>&1 & ;;
    *"Brillo 50%")          brightnessctl -q set 50% && dunstify -h int:value:50 "${I_SOL}  Brillo 50%" ;;
    *"Luz nocturna on/off") ~/.local/bin/luz-nocturna.sh toggle ;;
    *"Cambiar fondo")       ~/.local/bin/fondo.sh elegir ;;
    *"Detectar monitores")  ~/.local/bin/ajustar-monitores.sh && dunstify "${I_MON}  Monitores ajustados" ;;
    # desactiva teclado/touchpad/raton 60 s (screen-clean) en una kitty
    # flotante con la cuenta atras; al terminar se cierra sola
    *"Limpiar pantalla"*)   kitty --class limpiar -e ~/.local/bin/screen-clean --duration 60 >/dev/null 2>&1 & ;;
    *"Actualizar sistema")  ~/.local/bin/actualizaciones.sh instalar ;;
    *"Chuleta de atajos")   ~/.local/bin/atajos.sh ;;
    *"Editar dotfiles")     kitty -e nvim ~/.dotfiles >/dev/null 2>&1 & ;;
    *"Recargar sxhkd")      pkill -USR1 -x sxhkd && dunstify "${I_RELOAD}  sxhkd recargado" ;;
    # polybar tiene IPC (enable-ipc en config.ini): se reinicia sola,
    # sin pkill ni sleep, releyendo la config
    *"Reiniciar polybar")   polybar-msg cmd restart >/dev/null && dunstify "${I_RELOAD}  polybar reiniciada" ;;
    *"Reiniciar bspwm")     bspc wm -r ;;
esac
