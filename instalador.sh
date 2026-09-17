#!/bin/bash
# Instalador de dotfiles - detecta VM vs hardware real

cd "$(dirname "$0")"

# Paquetes comunes
stow bspwm sxhkd polybar kitty rofi dunst gtk xinit zsh

# Picom segun entorno
stow -D picom-vm picom-real 2>/dev/null  # limpiar previos
if systemd-detect-virt -q; then
    echo "VM detectada -> picom ligero"
    stow picom-vm
else
    echo "Hardware real -> picom completo"
    stow picom-real
fi

echo "Instalacion completa ✔"
