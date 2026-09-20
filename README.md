# 🔴 Dotfiles — Debian Crimson

Rice de **Debian 13 (trixie) + bspwm** con paleta carmesí/dorado.
Minimalista, en español, gestionado con GNU **stow**.

![Barra](docs/barra.png)

![Wallpaper](wallpapers/debian.png)

## Paleta

| Color | Hex | Uso |
|---|---|---|
| Negro profundo | `#0f0f12` | fondos |
| Gris oscuro | `#2b2b2e` | bordes inactivos |
| Texto | `#d6d6d6` | foreground |
| **Carmesí Debian** | `#D70A53` | foco / acento |
| Dorado | `#E8B04B` | iconos / reloj |

## Qué incluye

```
dotfiles/
├── bspwm/       gestor de ventanas
├── sxhkd/       atajos de teclado (+ teclas multimedia c/ notifs)
├── polybar/     barra superior (escritorios, musica, actualizaciones, vpn,
│                Wi-Fi, bluetooth, temperatura, cpu, mem, bateria, volumen,
│                mic, luz nocturna, power) — iconos Material Nerd Font
├── kitty/       terminal (JetBrainsMono Nerd Font, transparencia)
├── nvim/        LazyVim con tema "Debian Crimson" custom + shellcheck
├── rofi/        lanzador de apps
├── dunst/       notificaciones
├── picom/       compositor glx + blur (hardware real)
├── picom-vm/    versión ligera para VMs
├── gtk/         Adwaita-dark + Papirus + gtk.css con la paleta (sin azules)
├── thunar/      acciones de click derecho (terminal aqui, nvim, copiar ruta,
│                extraer, comprimir, poner como fondo)
├── zsh/         .zshrc + powerlevel10k + fzf (Ctrl+R/Ctrl+T/Alt+C)
├── scripts/     ~/.local/bin: menus rofi (power, ajustes F9, bluetooth),
│                estado-* para polybar, multimedia.sh (teclas Fn),
│                ajustar-monitores.sh, aviso-bateria.sh, fondo.sh,
│                bloquear.sh (lock con blur + candado; auto via xss-lock),
│                wifi-menu.sh (redes con señal/clave desde rofi),
│                vpn.sh, actualizaciones.sh, luz-nocturna.sh, estado-*.sh,
│                portapapeles.sh (historial del clipboard, super+v),
│                atajos.sh (chuleta de atajos, super+F1),
│                screen-clean (desactiva teclado/touchpad para limpiar)
├── gammastep/   luz nocturna (3800K de noche, ubicacion fija Lima)
├── xdg/         nvim/feh .desktop propios (apps por defecto: sistema/etc/xdg)
├── zathura/     lector de PDF en la paleta (modo oscuro con "i")
├── fastfetch/   logo Debian propio en carmesi/dorado, claves con iconos
├── sistema/     archivos de /etc (nftables.conf, lightdm-gtk-greeter.conf):
│                los copia instalar-paquetes.sh
└── wallpapers/  fondos (generar-fondos.sh los fabrica con ImageMagick)
```

## Instalación en un Debian 13 limpio

Instala Debian 13 (netinst) con **solo "Utilidades estándar del sistema"**
(sin escritorio). Dos cosas del instalador que importan:

- **Deja la contraseña de root VACÍA**: así tu usuario entra en `sudo`.
  Si pones contraseña de root, `sudo` ni siquiera se instala y nada de
  lo de abajo funciona.
- Teclado **latinoamericano**, idioma español.

Al primer login en la consola:

```bash
sudo apt install -y git
git clone https://github.com/AngheloBR/dotfiles-debian-crimson ~/.dotfiles
cd ~/.dotfiles
./instalar-paquetes.sh   # apt + nerd fonts + nvim 0.12 + p10k + firewall + lightdm
./instalador.sh          # stow (detecta VM vs hardware real)
sudo reboot
```

Tras reiniciar, lightdm muestra el login del rice; entra y ya estás en
bspwm. En una VM no hay batería, Wi-Fi ni bluetooth: esos módulos de la
barra se ocultan solos.

Después de reiniciar, abre kitty y ejecuta `nvim` — LazyVim instala
sus plugins solo en el primer arranque.

## Atajos principales

| Atajo | Acción |
|---|---|
| `super + Enter` | kitty (terminal) |
| `super + d` | rofi (lanzador) |
| `super + e` | thunar (archivos) |
| `super + b` | firefox |
| `super + w` / `super + shift + w` | cerrar / matar ventana |
| `super + 1..8` | cambiar escritorio |
| `F10` (candado) | bloquear pantalla (con blur) |
| `F4` / `F8` / `F9` | mic mute / modo avion / menu de ajustes (Wi-Fi, BT, VPN, audio, impresoras, escaner, brillo, luz nocturna, fondo, monitores, limpiar, actualizar, atajos, dotfiles, recargas) |
| F9 → Cambiar fondo | elige entre los fondos de `wallpapers/` |
| `Print` / `shift + Print` | flameshot gui / captura completa |
| Teclas multimedia | volumen, brillo, mute (con notificación) |
| `super + v` | historial del portapapeles (ultima opcion: borrar) |
| `super + shift + n` / `super + ctrl + n` | reabrir ultima notificacion / cerrar todas |
| `super + F1` | chuleta con todos los atajos (leida del sxhkdrc) |
| `super + Escape` | recargar sxhkd |

## Comprobar el repo

`./comprobar.sh` valida todo antes de commitear o reinstalar: shellcheck de
los scripts, sintaxis de cada config, que cada paquete stow este en el
instalador, que cada paquete apt exista en Debian y que ningun script use un
binario que el instalador no aporte.

## Dependencias manuales

Algunas cosas no van por apt y el script las instala aparte:

- **Neovim 0.12+** → `~/.local/opt/nvim` (el 0.10 de Debian 13 es
  demasiado viejo para LazyVim ≥ 0.11.2)
- **Nerd Font JetBrainsMono** → `~/.local/share/fonts`
- **powerline10k** → `~/.powerlevel10k`

`LISTA-PAQUETES.txt` lista solo los paquetes instalados **a mano**
(`apt-mark showmanual`), sin dependencias: es lo que hay que revisar
si `instalar-paquetes.sh` se queda corto.

## Filosofía

- Debian por **estabilidad** (no updates constantes)
- Minimalismo: solo lo que se usa
- Todo versado en git — si rompo algo, `git checkout .` y listo
- Aprender entendiendo el *porqué* de cada config

## Notas técnicas

- **PATH en la sesión gráfica**: lightdm arranca bspwm con un PATH sin
  `~/.local/bin`. El `bspwmrc` lo exporta al principio; sin eso ningún
  script del rice (ni polybar) arranca.
- **Iconos Nerd Font**: en scripts bash van como `printf '\U000fXXXX'`
  (ASCII puro, no se pierden al copiar). En `config.ini` de polybar y en
  `config.rasi` de rofi tienen que ir literales; cada uno lleva su
  codepoint en un comentario al lado por si hay que restaurarlo.
- **Reiniciar polybar**: `polybar-msg cmd restart` (IPC), no `pkill`.
- **Actualizaciones en la barra**: cuenta contra las listas locales de apt;
  para que se refresquen solas hace falta
  `APT::Periodic::Update-Package-Lists "1";` en `/etc/apt/apt.conf.d/20auto-upgrades`.
- **VPN**: el modulo detecta cualquier VPN por su interfaz (tun/wg/tailscale0/wt0)
  y el menu ofrece lo que haya: conexiones de NetworkManager, tailscale, netbird,
  wg-quick. Importar: `nmcli con import type openvpn file X.ovpn`.
- **Login (lightdm)**: fondo debian.png, Adwaita-dark + el gtk.css del rice copiado
  al home del usuario lightdm (por eso el cuadro sale carmesi). Probar sin cerrar
  sesion: `dm-tool add-nested-seat` (paquete xserver-xephyr).
- **HDMI**: `monitor-hotplug.sh` escucha `bspc subscribe monitor_add/remove` y llama a
  `ajustar-monitores.sh` al enchufar/desenchufar. Si el cable sigue puesto y solo se
  apaga el monitor, nadie puede detectarlo (el pin de deteccion no cambia): F9 → Detectar.
- **Firewall** (nftables) con dos perfiles: **privada** (casa, amigos, celular: ping,
  mDNS para impresora) y **publica** (calle: invisible). Se elige solo al conectar
  segun la red este en `/etc/nftables.d/redes-privadas.txt`; F9 → Firewall lo fuerza
  o marca la red actual como privada. Icono en la barra: escudo dorado/carmesi.
  Las VMs de KVM tienen red en ambos perfiles (flush por tabla, no global: libvirt
  tiene su propia tabla de NAT).
- **USB**: udiskie monta pendrives solo y avisa; F9 → Expulsar USB.
- **Bateria**: `tlp` con sus defaults (`sudo tlp-stat -s` para ver el modo).
  LazyVim no comprueba updates al arrancar: `:Lazy update` a mano.
