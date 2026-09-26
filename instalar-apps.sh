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
# nmap: escaner de redes (carrera de redes y seguridad).
# android-sdk-platform-tools-common: reglas udev para que el movil por USB
# se pueda usar con adb sin ser root (si no: "no permissions").
sudo apt install -y \
  gimp \
  vlc \
  nmap \
  android-sdk-platform-tools-common

echo "=== Wireshark (capturar trafico sin ser root) ==="
# Al instalarse pregunta si los usuarios normales pueden capturar. Se
# responde que SI de antemano: dumpcap (el que captura) recibe permisos
# de red y basta con estar en el grupo "wireshark". Asi no hay que abrir
# toda la interfaz grafica como root. El grupo aplica al siguiente login.
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt install -y wireshark
sudo dpkg-reconfigure -f noninteractive wireshark-common
sudo usermod -aG wireshark "$USER"

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

echo "=== GNS3 (laboratorios de redes) ==="
# GNS3 no esta en Debian. La GUI y el servidor van con pipx: cada
# programa Python en su propio entorno, sin mezclarse con el sistema.
# --system-site-packages: la GUI usa el PyQt6 de apt (no lo trae pip).
# ubridge (conecta los nodos entre si) y dynamips (routers Cisco IOS)
# tampoco estan en Debian 13: se compilan de su codigo oficial y van a
# /usr/local/bin. vpcs (PCs de prueba) si esta en apt.
# Las VMs de los labs usan el KVM que instala instalar-paquetes.sh.
sudo apt install -y pipx python3-pyqt6 python3-pyqt6.qtsvg python3-pyqt6.qtwebsockets \
  vpcs libpcap-dev libelf-dev cmake
for PAQ in gns3-server gns3-gui; do
  pipx list --short 2>/dev/null | grep -q "^$PAQ " || pipx install --system-site-packages "$PAQ"
done
if ! command -v ubridge >/dev/null; then
  tmpd=$(mktemp -d)
  git clone -q --depth 1 -b v1.2.3 https://github.com/GNS3/ubridge "$tmpd/ubridge"
  make -C "$tmpd/ubridge"
  # su "make install" copia a /usr/local/bin y le da permisos de red (setcap)
  sudo make -C "$tmpd/ubridge" install
  rm -rf "$tmpd"
fi
if ! command -v dynamips >/dev/null; then
  tmpd=$(mktemp -d)
  git clone -q --depth 1 -b v0.2.25 https://github.com/GNS3/dynamips "$tmpd/dynamips"
  cmake -S "$tmpd/dynamips" -B "$tmpd/build"
  make -C "$tmpd/build" -j"$(nproc)"
  sudo make -C "$tmpd/build" install
  rm -rf "$tmpd"
fi
# lanzador para rofi (pipx no crea ninguno)
cat > ~/.local/share/applications/gns3.desktop <<EOF
[Desktop Entry]
Type=Application
Name=GNS3
Comment=Simulador de redes
Exec=$HOME/.local/bin/gns3 %f
Icon=gns3
Categories=Network;Education;
Terminal=false
EOF

echo "=== Android Studio (lo principal para apps Android) ==="
# Android Studio ES IntelliJ IDEA con el SDK de Android, el emulador y las
# herramientas de Google encima: para hacer apps Android NO hace falta
# ademas IntelliJ.
#
# La web de descargas trae la URL completa (con el numero de compilacion
# interno) y, en la tabla, el sha256 justo despues del nombre de cada
# archivo. Ojo: el PRIMER hash de la pagina es el del .exe de Windows.
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
      PAGINA=$(curl -fsSL https://developer.android.com/studio)
      AS_URL=$(grep -oE 'https://[^"]*/android-studio-[a-z0-9-]+-linux\.tar\.gz' <<<"$PAGINA" | head -1)
      AS_ARCHIVO=${AS_URL##*/}
      AS_SHA=$(grep -oE "$AS_ARCHIVO|[0-9a-f]{64}" <<<"$PAGINA" | grep -A1 -xF "$AS_ARCHIVO" | grep -m1 -xE '[0-9a-f]{64}')
      if [ -z "$AS_URL" ] || [ -z "$AS_SHA" ]; then
        echo "  No se pudo leer la web (cambio de formato?). Descargalo de"
        echo "  https://developer.android.com/studio y descomprimelo en ~/.local/opt/"
      else
        tmpd=$(mktemp -d)
        echo "  Descargando $AS_ARCHIVO (~1,5 GB)..."
        curl -fL -o "$tmpd/$AS_ARCHIVO" "$AS_URL"
        # si el hash no coincide, set -e para aqui y no se instala nada
        echo "$AS_SHA  $tmpd/$AS_ARCHIVO" | sha256sum -c
        mkdir -p ~/.local/opt
        tar xzf "$tmpd/$AS_ARCHIVO" -C ~/.local/opt/
        rm -rf "$tmpd"
        # lanzador para rofi (no va en el repo: apunta a esta instalacion)
        cat > ~/.local/share/applications/android-studio.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Android Studio
Comment=IDE oficial para apps Android
Exec=$HOME/.local/opt/android-studio/bin/studio %f
Icon=$HOME/.local/opt/android-studio/bin/studio.svg
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-studio
EOF
        echo "-> Android Studio en ~/.local/opt. En el primer arranque descarga"
        echo "   el SDK (8-12 GB). Se actualiza desde el propio programa."
      fi
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
