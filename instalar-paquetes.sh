#!/bin/bash
# ═══════════════════════════════════════════════════════
#  Script maestro de instalacion — Rice "Debian Crimson"
#  Hardware real / VM detectado automaticamente.
# ═══════════════════════════════════════════════════════
set -e

echo "=== Paquetes base ==="
sudo apt update
sudo apt install -y \
  xorg x11-xserver-utils x11-xkb-utils x11-utils xinput xdg-utils \
  bspwm sxhkd \
  picom polybar rofi \
  kitty \
  feh dunst libnotify-bin pulseaudio-utils \
  flameshot maim \
  lightdm lightdm-gtk-greeter i3lock imagemagick \
  firefox-esr \
  thunar gvfs gvfs-backends thunar-archive-plugin thunar-volman \
  tumbler ffmpegthumbnailer file-roller papirus-icon-theme \
  zsh zsh-autosuggestions zsh-syntax-highlighting \
  xdg-user-dirs \
  fonts-jetbrains-mono \
  ripgrep fd-find fzf lazygit xclip shellcheck shfmt \
  mpv zathura playerctl fastfetch udiskie nftables \
  git stow curl wget unzip

echo "=== Extras de HARDWARE REAL (no VM) ==="
if ! systemd-detect-virt -q; then
  sudo apt install -y \
    network-manager \
    brightnessctl \
    pipewire pipewire-pulse pavucontrol \
    bluez blueman gammastep xss-lock tlp \
    cups system-config-printer printer-driver-escpr sane-airscan simple-scan
  sudo systemctl enable --now cups
  # tlp: ahorro de bateria (governor, USB autosuspend, Wi-Fi power save...)
  # con sus defaults; no coexiste con power-profiles-daemon
  sudo systemctl enable --now tlp
fi

echo "=== Nerd Fonts (iconos) ==="
if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
  mkdir -p ~/.local/share/fonts
  tmpd=$(mktemp -d)
  wget -q -O "$tmpd/JB.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -oq "$tmpd/JB.zip" -d ~/.local/share/fonts/JetBrainsMonoNerd
  rm -rf "$tmpd"
  fc-cache -fv > /dev/null
  echo "-> Nerd Font instalada"
else
  echo "-> Nerd Font ya existe"
fi

echo "=== Powerlevel10k ==="
if [ ! -d ~/.powerlevel10k ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
fi

echo "=== Neovim >= 0.12 (LazyVim exige >= 0.11.2) ==="
mkdir -p ~/.local/opt ~/.local/bin
if ! ~/.local/bin/nvim --version 2>/dev/null | grep -q 'NVIM v0\.1[2-9]'; then
  tmpd=$(mktemp -d)
  curl -fL -o "$tmpd/nvim.tar.gz" \
    https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  tar xzf "$tmpd/nvim.tar.gz" -C "$tmpd"
  rm -rf ~/.local/opt/nvim
  mv "$tmpd/nvim-linux-x86_64" ~/.local/opt/nvim
  ln -sf ~/.local/opt/nvim/bin/nvim ~/.local/bin/nvim
  rm -rf "$tmpd"
  echo "-> nvim $(${HOME}/.local/bin/nvim --version | head -1) instalado en ~/.local/opt"
fi
# nvim del sistema (0.10 de Debian) queda, ~/.local/bin gana el PATH

echo "=== Firewall (nftables) ==="
sudo cp "$(dirname "$0")/sistema/etc/nftables.conf" /etc/nftables.conf
sudo systemctl enable --now nftables

echo "=== Pantalla de login (lightdm-gtk-greeter) ==="
REPO="$(cd "$(dirname "$0")" && pwd)"
sudo install -D -m644 "$REPO/sistema/etc/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
sudo install -D -m644 "$REPO/sistema/etc/lightdm/lightdm.conf.d/50-crimson.conf" /etc/lightdm/lightdm.conf.d/50-crimson.conf
sudo install -D -m644 "$REPO/wallpapers/debian.png" /usr/share/backgrounds/crimson/debian.png
# el greeter es GTK y corre como "lightdm": mismo css del rice para que sea carmesi
sudo install -D -m644 -o lightdm -g lightdm "$REPO/gtk/.config/gtk-3.0/gtk.css" /var/lib/lightdm/.config/gtk-3.0/gtk.css
sudo install -D -m644 -o lightdm -g lightdm "$REPO/gtk/.config/gtk-3.0/settings.ini" /var/lib/lightdm/.config/gtk-3.0/settings.ini

echo "=== Carpetas de usuario en espanol ==="
LANG=es_ES.UTF-8 xdg-user-dirs-update

echo "=== Zsh como shell por defecto ==="
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

echo ""
echo "==============================="
echo " TODO LISTO. Pasos finales:"
echo "==============================="
echo "  1. ./instalador.sh      (enlaza configs con stow)"
echo "  2. Cierra sesion y reinicia (para que zsh entre en efecto)"
echo "  3. Arranca bspwm desde lightdm"
echo "  4. Abre terminal y: nvim  -> LazyVim descarga plugins solo"
