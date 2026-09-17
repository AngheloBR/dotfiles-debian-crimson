#!/bin/bash
# Script maestro de instalacion - Rice bspwm "Debian Crimson"
set -e

echo "=== Instalando paquetes base ==="
sudo apt update
sudo apt install -y \
  xorg xinit x11-xserver-utils \
  bspwm sxhkd \
  picom polybar rofi \
  kitty \
  feh dunst libnotify-bin \
  flameshot \
  lightdm lightdm-gtk-greeter i3lock \
  firefox-esr \
  thunar gvfs gvfs-backends thunar-archive-plugin thunar-volman \
  tumbler ffmpegthumbnailer file-roller papirus-icon-theme \
  zsh zsh-autosuggestions zsh-syntax-highlighting \
  xdg-user-dirs \
  fonts-jetbrains-mono \
  git stow curl wget unzip

echo "=== Paquetes extra solo para HARDWARE REAL (no VM) ==="
if ! systemd-detect-virt -q; then
  sudo apt install -y \
    network-manager \
    brightnessctl \
    pipewire pipewire-pulse pavucontrol \
    blueman
  echo "-> extras de laptop instalados (red, brillo, audio, bluetooth)"
fi

echo "=== Nerd Fonts (iconos) ==="
if ! fc-list | grep -q "JetBrainsMono Nerd Font"; then
  mkdir -p ~/.local/share/fonts
  cd /tmp
  wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd
  rm JetBrainsMono.zip
  fc-cache -fv
else
  echo "-> Nerd Font ya instalada, saltando"
fi

echo "=== Powerlevel10k ==="
if [ ! -d ~/.powerlevel10k ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
else
  echo "-> p10k ya existe, saltando"
fi

echo "=== Carpetas de usuario en espanol ==="
LANG=es_ES.UTF-8 xdg-user-dirs-update

echo "=== Zsh como shell por defecto ==="
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

echo ""
echo "TODO LISTO. Faltan dos cosas manuales:"
echo "  1. ./instalador.sh   (enlaza las configs con stow)"
echo "  2. Reiniciar sesion y lanzar: startx"
