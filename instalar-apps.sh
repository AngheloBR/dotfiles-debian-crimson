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

echo "=== Apps de los repos de Debian ==="
sudo apt install -y \
  gimp \
  vlc

echo "=== Flatpak + Flathub ==="
# Discord, OnlyOffice y Obsidian se distribuyen como .deb que NO se
# actualizan con apt: Discord incluso se niega a arrancar hasta que
# bajas el nuevo a mano. En Flatpak se actualizan solos y van aislados.
# Steam tambien: en apt exige activar i386 y añadir contrib/non-free al
# sistema; el Flatpak trae sus librerias de 32 bits dentro, aisladas.
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --noninteractive flathub \
  com.discordapp.Discord \
  org.onlyoffice.desktopeditors \
  md.obsidian.Obsidian \
  com.valvesoftware.Steam

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

echo "=== Android Studio (lo principal para apps Android) ==="
# Android Studio ES IntelliJ IDEA con el SDK de Android, el emulador y las
# herramientas de Google encima: para hacer apps Android NO hace falta
# ademas IntelliJ.
#
# No se automatiza la descarga del tarball a proposito: Google publica la
# version como "Quail 4 | 2026.1.4 Patch 1" pero la URL necesita el numero
# de compilacion interno (2026.1.4.13), que no aparece en ningun feed. Una
# URL fija caducaria en la siguiente version.
if [ -d ~/.local/opt/android-studio ] || flatpak info com.google.AndroidStudio >/dev/null 2>&1; then
  echo "-> ya esta instalado"
else
  echo ""
  echo "  1) Tarball oficial  (RECOMENDADO: emulador y adb por USB sin pegas)"
  echo "  2) Flatpak          (se actualiza solo, pero el sandbox complica"
  echo "                       el emulador y los moviles por USB)"
  echo "  3) Saltar"
  read -r -p "  Opcion [1/2/3]: " OPCION_AS
  case "$OPCION_AS" in
    2)
      flatpak install -y --noninteractive flathub com.google.AndroidStudio
      ;;
    1|"")
      echo ""
      echo "  Descarga el .tar.gz de https://developer.android.com/studio"
      echo "  y cuando lo tengas en ~/Descargas, ejecuta:"
      echo ""
      echo "    mkdir -p ~/.local/opt"
      echo "    tar xzf ~/Descargas/android-studio-*-linux.tar.gz -C ~/.local/opt/"
      echo "    ~/.local/opt/android-studio/bin/studio.sh"
      echo ""
      echo "  En el primer arranque descarga el SDK (8-12 GB). El emulador"
      echo "  ira acelerado: /dev/kvm ya esta y el usuario pertenece al grupo."
      ;;
  esac
fi

echo "=== JetBrains Toolbox (OPCIONAL: solo si usaras PyCharm/IntelliJ) ==="
# Para Android NO hace falta (Android Studio ya lo cubre). Tiene sentido
# para Python (PyCharm) u otros lenguajes. Si estudias, JetBrains regala
# las versiones Ultimate: jetbrains.com/student
if [ -x ~/.local/bin-apps/jetbrains-toolbox ]; then
  echo "-> Toolbox ya esta"
else
  read -r -p "  Instalar JetBrains Toolbox? [s/N]: " R_TB
  if [ "$R_TB" = "s" ] || [ "$R_TB" = "S" ]; then
    mkdir -p ~/.local/opt ~/.local/bin-apps
    # la version se consulta a la API de JetBrains: nada de URLs fijas
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
    echo "-> saltado"
  fi
fi

echo ""
echo "==============================================="
echo " LISTO"
echo "==============================================="
echo ""
echo "  Antigravity (IDE de Google) — https://antigravity.google"
echo "    Sin verificar en este repo: mira si ofrece .deb."
echo ""
echo "  ~/.local/bin-apps esta en el PATH desde el .zshrc del rice."
echo ""
echo "  Espacio: Android Studio + SDK + un emulador son 25-35 GB."
echo ""
echo "  Si alguna app se porta mal en bspwm (Android Studio, JetBrains y"
echo "  Steam son los tipicos: splash screens y dialogos que no deberian"
echo "  ir en mosaico), añadir su 'bspc rule' al bspwmrc."
echo "  Ver CONTEXTO.md, pendiente 3."
