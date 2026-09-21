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
  feh dunst libnotify-bin \
  network-manager pipewire pipewire-pulse pulseaudio-utils pavucontrol \
  flameshot maim \
  lightdm lightdm-gtk-greeter i3lock imagemagick \
  thunar gvfs gvfs-backends thunar-archive-plugin thunar-volman \
  tumbler ffmpegthumbnailer file-roller papirus-icon-theme gnome-themes-extra \
  zsh zsh-autosuggestions zsh-syntax-highlighting \
  xdg-user-dirs \
  fonts-jetbrains-mono \
  ripgrep fd-find fzf lazygit xclip shellcheck shfmt gcc make \
  mpv zathura playerctl fastfetch udiskie nftables \
  tesseract-ocr tesseract-ocr-spa tesseract-ocr-eng xdotool \
  git stow curl wget unzip

# (network-manager y pipewire van en base: los scripts de la barra usan
#  nmcli y pactl tambien en una VM; gcc/make los necesita LazyVim para
#  compilar los parsers de treesitter)

echo "=== Extras de HARDWARE REAL (no VM) ==="
if ! systemd-detect-virt -q; then
  sudo apt install -y \
    brightnessctl \
    bluez blueman gammastep xss-lock tlp \
    cups system-config-printer printer-driver-escpr sane-airscan simple-scan \
    obs-studio
  sudo systemctl enable --now cups
  # tlp: ahorro de bateria (governor, USB autosuspend, Wi-Fi power save...)
  # con sus defaults; no coexiste con power-profiles-daemon
  sudo systemctl enable --now tlp
fi

echo "=== Firefox actual (repo oficial de Mozilla, no el ESR de Debian) ==="
if [ ! -f /etc/apt/keyrings/packages.mozilla.org.asc ]; then
  sudo install -d -m 0755 /etc/apt/keyrings
  wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
fi
sudo install -m644 "$(dirname "$0")/sistema/etc/apt/sources.list.d/mozilla.sources" /etc/apt/sources.list.d/mozilla.sources
sudo install -m644 "$(dirname "$0")/sistema/etc/apt/preferences.d/mozilla" /etc/apt/preferences.d/mozilla
sudo apt update
# firefox-l10n-es-mx: interfaz en español (latinoamericano)
sudo apt install -y firefox firefox-l10n-es-mx
# fuera el ESR si quedo de una instalacion anterior
dpkg -l firefox-esr 2>/dev/null | grep -q '^ii' && sudo apt purge -y firefox-esr && sudo apt autoremove -y

echo "=== Repo de Claude Desktop (solo el repo; la app: apt install claude-desktop) ==="
sudo install -m644 "$(dirname "$0")/sistema/usr/share/keyrings/claude-desktop-archive-keyring.asc" /usr/share/keyrings/
sudo install -m644 "$(dirname "$0")/sistema/etc/apt/sources.list.d/claude-desktop.list" /etc/apt/sources.list.d/
sudo apt update

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
  echo "-> nvim $("${HOME}/.local/bin/nvim" --version | head -1) instalado en ~/.local/opt"
fi
# nvim del sistema (0.10 de Debian) queda, ~/.local/bin gana el PATH

echo "=== Agentes de IA en la terminal (instaladores oficiales, en ~/.local y ~/.opencode) ==="
# Claude Code: ~/.local/bin/claude (symlink que .gitignore ignora)
if ! command -v claude >/dev/null && [ ! -x ~/.local/bin/claude ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
# opencode: ~/.opencode/bin (el .zshrc ya lo tiene en el PATH)
if [ ! -x ~/.opencode/bin/opencode ]; then
  curl -fsSL https://opencode.ai/install | bash
fi

echo "=== Firewall (nftables) con perfiles privada/publica ==="
REPO="$(cd "$(dirname "$0")" && pwd)"
sudo install -d /etc/nftables.d
sudo install -m644 "$REPO"/sistema/etc/nftables.d/*.nft /etc/nftables.d/
[ -f /etc/nftables.d/redes-privadas.txt ] || sudo install -m644 "$REPO/sistema/etc/nftables.d/redes-privadas.txt" /etc/nftables.d/
sudo install -m644 "$REPO/sistema/etc/nftables.conf" /etc/nftables.conf
sudo install -m755 "$REPO/sistema/usr/local/sbin/firewall-perfil" /usr/local/sbin/firewall-perfil
sudo install -m755 "$REPO/sistema/etc/NetworkManager/dispatcher.d/50-firewall-perfil" /etc/NetworkManager/dispatcher.d/
sudo install -m440 "$REPO/sistema/etc/sudoers.d/firewall-perfil" /etc/sudoers.d/firewall-perfil
sudo systemctl enable --now nftables
sudo /usr/local/sbin/firewall-perfil auto
# libvirt (si esta): que use nftables como nosotros, no iptables. Asi su
# tabla de NAT para las VMs convive con la nuestra sin pisarse.
if [ -f /etc/libvirt/network.conf ]; then
  sudo sed -i 's/^#\?firewall_backend *=.*/firewall_backend = "nftables"/' /etc/libvirt/network.conf
  sudo systemctl restart libvirtd
  # red NAT "default" de las VMs en 192.168.50.0/24 (ver sistema/libvirt)
  if ! virsh -c qemu:///system net-dumpxml default 2>/dev/null | grep -q '192.168.50.1'; then
    virsh -c qemu:///system net-destroy default 2>/dev/null || true
    virsh -c qemu:///system net-undefine default 2>/dev/null || true
    virsh -c qemu:///system net-define "$REPO/sistema/libvirt/red-default.xml"
    virsh -c qemu:///system net-autostart default
    virsh -c qemu:///system net-start default
  fi
fi

echo "=== Pantalla de login (lightdm-gtk-greeter) ==="
sudo install -D -m644 "$REPO/sistema/etc/lightdm/lightdm-gtk-greeter.conf" /etc/lightdm/lightdm-gtk-greeter.conf
sudo install -D -m644 "$REPO/sistema/etc/lightdm/lightdm.conf.d/50-crimson.conf" /etc/lightdm/lightdm.conf.d/50-crimson.conf
sudo install -D -m644 "$REPO/wallpapers/debian.png" /usr/share/backgrounds/crimson/debian.png
# el greeter es GTK y corre como "lightdm": mismo css del rice para que sea carmesi
sudo install -D -m644 -o lightdm -g lightdm "$REPO/gtk/.config/gtk-3.0/gtk.css" /var/lib/lightdm/.config/gtk-3.0/gtk.css
sudo install -D -m644 -o lightdm -g lightdm "$REPO/gtk/.config/gtk-3.0/settings.ini" /var/lib/lightdm/.config/gtk-3.0/settings.ini

echo "=== Apps por defecto (nivel sistema) ==="
sudo install -D -m644 "$REPO/sistema/etc/xdg/mimeapps.list" /etc/xdg/mimeapps.list

echo "=== Carpetas de usuario (en el idioma del sistema) ==="
xdg-user-dirs-update

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
