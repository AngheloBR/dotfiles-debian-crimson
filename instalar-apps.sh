#!/bin/bash
# ═══════════════════════════════════════════════════════
#  instalar-apps.sh — programas de usuario (NO son el rice)
#  Rice "Debian Crimson"
#
#  Va aparte de instalar-paquetes.sh a proposito: el rice es el
#  escritorio (barra, atajos, scripts) y debe poder instalarse solo.
#  Esto es lo que usa anghelo encima, y pesa mucho mas.
#
#  Uso:  ./instalar-apps.sh        (despues de instalar-paquetes.sh)
#  Es re-ejecutable: lo ya instalado se salta.
# ═══════════════════════════════════════════════════════
set -e

echo "=== Preparar apt para Steam (32 bits + contrib/non-free) ==="
# Steam es de 32 bits y vive en non-free. Sin estos dos pasos, el
# paquete ni aparece en los repos.
if ! dpkg --print-foreign-architectures | grep -q i386; then
  sudo dpkg --add-architecture i386
fi
if ! grep -q 'contrib' /etc/apt/sources.list 2>/dev/null; then
  sudo sed -i 's/ main non-free-firmware/ main contrib non-free non-free-firmware/' /etc/apt/sources.list
fi
sudo apt update

echo "=== Apps de los repos de Debian ==="
sudo apt install -y \
  gimp \
  vlc \
  steam-installer

echo "=== Flatpak + Flathub ==="
# Discord, OnlyOffice y Obsidian se distribuyen como .deb que NO se
# actualizan con apt: Discord incluso se niega a arrancar hasta que
# bajas el nuevo a mano. En Flatpak se actualizan solos y van aislados.
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub \
  com.discordapp.Discord \
  org.onlyoffice.desktopeditors \
  md.obsidian.Obsidian

echo "=== AnyDesk (repo propio: se actualiza con apt) ==="
# OJO: AnyDesk solo funciona bien en X11 — es una de las razones de que
# este rice no se haya pasado a Wayland (ver CONTEXTO.md).
if [ ! -f /etc/apt/keyrings/anydesk.asc ]; then
  sudo install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo tee /etc/apt/keyrings/anydesk.asc >/dev/null
fi
echo "deb [signed-by=/etc/apt/keyrings/anydesk.asc] http://deb.anydesk.com/ all main" \
  | sudo tee /etc/apt/sources.list.d/anydesk.list >/dev/null
sudo apt update
sudo apt install -y anydesk

echo "=== JetBrains Toolbox (gestiona los IDEs y se actualiza solo) ==="
if [ ! -d ~/.local/share/JetBrains/Toolbox ] && [ ! -x ~/.local/bin-apps/jetbrains-toolbox ]; then
  mkdir -p ~/.local/opt ~/.local/bin-apps
  # la version se consulta a la API de JetBrains: nada de URLs fijas que
  # caducan a los tres meses
  TB_URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['TBA'][0]['downloads']['linux']['link'])")
  tmpd=$(mktemp -d)
  curl -fL -o "$tmpd/tb.tar.gz" "$TB_URL"
  tar xzf "$tmpd/tb.tar.gz" -C "$tmpd"
  rm -rf ~/.local/opt/jetbrains-toolbox
  mv "$tmpd"/jetbrains-toolbox-* ~/.local/opt/jetbrains-toolbox
  ln -sf ~/.local/opt/jetbrains-toolbox/bin/jetbrains-toolbox ~/.local/bin-apps/jetbrains-toolbox
  rm -rf "$tmpd"
  echo "-> Toolbox instalado. Ejecutalo una vez para que se registre."
else
  echo "-> Toolbox ya esta"
fi

echo ""
echo "==============================================="
echo " LISTO. Lo que queda es MANUAL (a proposito):"
echo "==============================================="
echo ""
echo "  Android Studio — https://developer.android.com/studio"
echo "    Google genera el enlace con JavaScript, asi que no se puede"
echo "    automatizar sin que se rompa en la proxima version. Descarga"
echo "    el .tar.gz y:"
echo "      tar xzf android-studio-*-linux.tar.gz -C ~/.local/opt/"
echo "      ~/.local/opt/android-studio/bin/studio.sh"
echo "    El emulador ira acelerado: /dev/kvm ya esta y el usuario"
echo "    pertenece al grupo kvm."
echo "    Ojo con el espacio: Studio + SDK + un emulador = 20-30 GB."
echo ""
echo "  Antigravity (IDE de Google) — https://antigravity.google"
echo "    Sin verificar en este repo todavia: mira si ofrece .deb."
echo ""
echo "  ~/.local/bin-apps esta en el PATH desde el .zshrc del rice."
echo ""
echo "  Si alguna de estas apps se porta mal en bspwm (JetBrains,"
echo "  Android Studio y Steam son los tipicos: splash screens y"
echo "  dialogos que no deberian ir en mosaico), hay que añadir su"
echo "  'bspc rule' al bspwmrc. Ver CONTEXTO.md, pendiente 3."
