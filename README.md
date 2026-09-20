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
├── polybar/     barra superior (escritorios, Wi-Fi, bluetooth, cpu, mem,
│                bateria, volumen, mic, power) — iconos Material Nerd Font
├── kitty/       terminal (JetBrainsMono Nerd Font, transparencia)
├── nvim/        LazyVim con tema "Debian Crimson" custom
├── rofi/        lanzador de apps
├── dunst/       notificaciones
├── picom/       compositor glx + blur (hardware real)
├── picom-vm/    versión ligera para VMs
├── gtk/         tema oscuro Adwaita-dark + Papirus
├── zsh/         .zshrc + powerlevel10k
├── scripts/     ~/.local/bin: menus rofi (power, ajustes F9, bluetooth),
│                estado-* para polybar, multimedia.sh (teclas Fn),
│                ajustar-monitores.sh, aviso-bateria.sh, fondo.sh,
│                bloquear.sh (lock con blur + candado; auto via xss-lock),
│                wifi-menu.sh (redes con señal/clave desde rofi),
│                portapapeles.sh (historial del clipboard, super+v),
│                screen-clean (desactiva teclado/touchpad para limpiar)
├── gammastep/   luz nocturna (3800K de noche, ubicacion fija Lima)
├── xdg/         apps por defecto (mimeapps.list) + nvim/feh .desktop propios
└── wallpapers/  fondos (generar-fondos.sh los fabrica con ImageMagick)
```

## Instalación en un Debian 13 limpio

```bash
git clone https://github.com/AngheloBR/dotfiles-debian-crimson ~/.dotfiles
cd ~/.dotfiles
./instalar-paquetes.sh   # apt + nerd fonts + nvim 0.12 + p10k
./instalador.sh          # stow (detecta VM vs hardware real)
reboot
```

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
| `super + 1..0` | cambiar escritorio |
| `F10` (candado) | bloquear pantalla (con blur) |
| `F4` / `F8` / `F9` | mic mute / modo avion / menu de ajustes |
| F9 → Cambiar fondo | elige entre los fondos de `wallpapers/` |
| `Print` / `shift + Print` | flameshot gui / captura completa |
| Teclas multimedia | volumen, brillo, mute (con notificación) |
| `super + v` | historial del portapapeles (ultima opcion: borrar) |
| `super + shift + n` / `super + ctrl + n` | reabrir ultima notificacion / cerrar todas |
| `super + Escape` | recargar sxhkd |

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
