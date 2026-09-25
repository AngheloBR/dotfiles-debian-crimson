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
├── polybar/     barra superior (escritorios, musica, bandeja del sistema,
│                actualizaciones, vpn,
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
├── git/         .gitconfig (nombre, email, credenciales via gh)
├── scripts/     ~/.local/bin: menus rofi (power, ajustes F9, bluetooth),
│                estado-* para polybar, multimedia.sh (teclas Fn),
│                ajustar-monitores.sh (+ monitor-interno.sh), aviso-bateria.sh, fondo.sh,
│                bloquear.sh (lock con blur + candado; auto via xss-lock),
│                wifi-menu.sh (redes con señal/clave desde rofi),
│                vpn.sh, actualizaciones.sh, luz-nocturna.sh, estado-*.sh,
│                portapapeles.sh (historial del clipboard, super+v),
│                atajos.sh (chuleta de atajos, super+F1), captura.sh, ocr.sh,
│                color.sh, iconos.sh (+ share/crimson/iconos.txt), no-molestar.sh,
│                screen-clean (desactiva teclado/touchpad para limpiar)
├── gammastep/   luz nocturna (3800K de noche, ubicacion fija Lima)
├── xdg/         nvim/feh .desktop propios (apps por defecto: sistema/etc/xdg)
├── zathura/     lector de PDF en la paleta (modo oscuro con "i")
├── fastfetch/   logo Debian propio en carmesi/dorado, claves con iconos
├── claude-code/ settings.json (hook que lee las respuestas en voz alta)
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

Al primer login en la consola. El repo es **privado**: hay que autenticarse
en GitHub antes de clonar (`gh auth login` abre el navegador o da un codigo
para meterlo desde otro dispositivo):

```bash
sudo apt install -y git gh
gh auth login          # GitHub.com → HTTPS → Login with a web browser
gh repo clone AngheloBR/dotfiles-debian-crimson ~/.dotfiles
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
| `Print` | flameshot (anotar) |
| `shift + Print` / `super + Print` / `super + shift + Print` | pantalla / ventana / region → portapapeles + `~/Imagenes/Capturas` |
| Teclas multimedia | volumen, brillo, mute (con notificación) |
| `super + v` | historial del portapapeles (ultima opcion: borrar) |
| `super + ctrl + Print` | OCR: el texto de una region de pantalla → portapapeles |
| `super + shift + c` | click en un pixel → su `#hex` al portapapeles |
| `super + .` | buscador de iconos Nerd Font (Enter icono, shift+Enter escape printf) |
| `super + shift + d` | no molestar (pausa notificaciones; campana en la barra) |
| `super + shift + v` | leer el portapapeles en voz alta (Piper, local) |
| `super + shift + s` / `x` / `z` | voz: pausar-reanudar / cortar / repetir 10 s
  (los mismos tres botones salen en la barra mientras lee) |
| `super + shift + n` / `super + ctrl + n` | reabrir ultima notificacion / cerrar todas |
| `super + F1` | chuleta con todos los atajos (leida del sxhkdrc) |
| `super + Escape` | recargar sxhkd |

## `~/.dotfiles` es el sistema: no se borra

Con stow, `~/.config/*`, `~/.zshrc` y `~/.local/bin` son **enlaces** a esta
carpeta; los archivos reales solo existen aqui. Ventaja: editar la config es
editar el repo, nunca hay dos copias. Precio: si borras `~/.dotfiles`, el
rice desaparece (bspwm pelado, sin barra, sin scripts). Recuperar:

```bash
gh auth login && gh repo clone AngheloBR/dotfiles-debian-crimson ~/.dotfiles
cd ~/.dotfiles && ./instalador.sh
```

GitHub solo se actualiza con `git commit` + `git push`: al iniciar sesion,
`aviso-dotfiles.sh` avisa si hay cambios sin subir (o commits sin bajar).

## Actualizar una instalacion

```bash
cd ~/.dotfiles && git pull && ./instalador.sh
```

El `instalador.sh` hace falta si el pull trae scripts nuevos (stow enlaza
archivo por archivo en `~/.local/bin`). Si cambio el bspwmrc: `bspc wm -r`.

## Contexto del proyecto

`CONTEXTO.md` es la memoria: perfil, hardware, todo lo construido, las
decisiones y su porqué, lo descartado, lo pendiente y la situacion del disco.
Sobrevive a una instalacion limpia porque vive en el repo: tras reinstalar,
clona y pidele a la IA que lo lea.

## Comprobar el repo

`./comprobar.sh` valida todo antes de commitear o reinstalar: shellcheck de
los scripts, sintaxis de cada config, que cada paquete stow este en el
instalador, que cada paquete apt exista en Debian y que ningun script use un
binario que el instalador no aporte.

## Dependencias manuales

Algunas cosas no van por apt y el script las instala aparte:

- **Neovim 0.12+** → `~/.local/opt/nvim` (el 0.10 de Debian 13 es
  demasiado viejo para LazyVim ≥ 0.11.2)
- **Piper (voz)** → `~/.local/opt/piper` + voz es_MX en `~/.local/share/piper-voces`.
  El hook `Stop` de Claude Code (paquete `claude-code`) manda cada respuesta a
  `leer-respuesta.sh`. Quitarlo: `/hooks` dentro de Claude Code.
- **Firefox** → del repo oficial de Mozilla (`sistema/etc/apt/`), no el ESR
- **Claude Desktop** → solo el repo (`apt install claude-desktop` cuando se quiera)
- **Claude Code y opencode** → instaladores oficiales a `~/.local/bin` y `~/.opencode`
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
  VMs y contenedores (KVM virbr*, LXD lxdbr*, Incus, LXC, Docker, Podman, Waydroid) tienen
  red en ambos perfiles (flush por tabla, no global: cada herramienta pone su NAT).
  **Emergencia** (sin red tras un cambio): click en el escudo → APAGAR firewall, o
  `sudo firewall-perfil apagar`; se reactiva solo al cambiar de red.
- **USB**: udiskie monta pendrives solo y avisa; F9 → Expulsar USB.
- **zsh avisa** con dunst si un comando tardo > 30 s y la terminal no tiene el foco.
- **CPU > 90 °C**: notificacion critica (una vez por episodio).
- **Bateria**: `tlp` con sus defaults (`sudo tlp-stat -s` para ver el modo).
  LazyVim no comprueba updates al arrancar: `:Lazy update` a mano.
