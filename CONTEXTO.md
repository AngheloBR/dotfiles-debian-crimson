# CONTEXTO.md — memoria del proyecto "Debian Crimson"

> **Para la IA que lea esto**: es el contexto completo del rice. Léelo entero
> junto a `AGENTS.md` antes de tocar nada. Recoge quién es el dueño, qué está
> construido, **por qué** se decidió cada cosa, lo que ya se descartó (no
> volver a proponerlo), lo pendiente y cómo continuar.
>
> **Para anghelo**: este archivo sobrevive a una instalación limpia porque vive
> en el repo (GitHub). Tras reinstalar: clona y pide que lo lean.
>
> Estado: 2026-09-25 · commit `20a6c9b` · 69 commits · 101 archivos

---

## 1. Quién es el dueño

- **anghelo** (usuario `anghelo`, host `debian`), Perú.
  `es_PE.UTF-8`, zona horaria `America/Lima`, teclado **latam**.
- Estudia **redes y seguridad informática**. Usará o usa: GNS3, Wireshark,
  nmap, AnyDesk, RustDesk, OBS, virt-manager/KVM, LXD.
- Viene de Fedora; eligió **Debian por estabilidad** (harto de actualizaciones
  constantes). Esa es la razón de fondo de casi todas las decisiones.
- **Quiere entender lo que hace**: explicar el porqué de cada cambio, en
  español, sin asumir conocimiento previo.
- Espera que las decisiones rutinarias se tomen sin consultarle, pero que se
  le pregunte antes de nada destructivo.
- Trabaja así: cambiar → **probar de verdad** → commit en español con el
  porqué → anotar la lección si la hubo.

## 2. Hardware (valores reales, comprobados)

| | |
|---|---|
| Equipo | Lenovo IdeaPad 1 15ALC7 |
| CPU | AMD Ryzen 7 5700U (8c/16t) |
| GPU | AMD Lucienne integrada, driver `amdgpu` — **sin NVIDIA** |
| RAM | 13 GB |
| Disco | NVMe 954 GB |
| Pantalla | `eDP` 1920x1080, 15" |
| Monitor externo | `HDMI-A-0` 1920x1080 (opcional, no siempre conectado) |
| Wi-Fi | `wlp2s0` (sin ethernet) |
| Batería / adaptador | `BAT0` / `ADP0` |
| Sensor de temperatura | `k10temp` (AMD) |
| Teclas físicas propias | F4 mic · F8 modo avión · F9 ajustes · F10 candado |

**Aunque estos nombres sean los reales, el repo NO los escribe a fuego**: se
detectan (ver §6). Lo aprendimos probando en una VM, donde el monitor se llama
`Virtual-1` y nada arrancaba.

## 3. El repo

Dotfiles del rice **"Debian Crimson"**: Debian 13 (trixie) + X11 + bspwm,
español, minimalista, con **GNU stow**.

- **Privado** en `github.com/AngheloBR/dotfiles-debian-crimson`.
  Para clonar: `gh auth login` primero.
- `~/.config/*`, `~/.zshrc`, `~/.local/bin` son **enlaces simbólicos** al repo:
  editar aquí cambia el sistema en vivo. **`~/.dotfiles` no se borra ni se
  mueve: es el sistema.**
- `CLAUDE.md` es un symlink a `AGENTS.md` (mismo contenido, dos nombres).
- `.gitignore` excluye los symlinks locales `scripts/.local/bin/nvim` y
  `scripts/.local/bin/claude` (apuntan a binarios de esta máquina).

### Paleta (regla no negociable)
fondo `#0f0f12` · carmesí `#D70A53` (foco/selección) · dorado `#E8B04B`
(iconos/reloj) · borde inactivo `#2b2b2e` · apagado `#45474e` ·
texto `#d6d6d6` / `#b3b3b8`. **Nada de azules ni temas ajenos.**

### Qué enlaza cada paquete stow (16)

| Paquete | Enlaza a |
|---|---|
| `bspwm` | `~/.config/bspwm/bspwmrc` |
| `sxhkd` | `~/.config/sxhkd/sxhkdrc` (47 atajos) |
| `polybar` | `~/.config/polybar/config.ini` (20 módulos) |
| `kitty` | `~/.config/kitty/kitty.conf` |
| `rofi` | `~/.config/rofi/config.rasi` |
| `dunst` | `~/.config/dunst/dunstrc` |
| `gtk` | `~/.gtkrc-2.0` + `~/.config/gtk-3.0/{settings.ini,gtk.css}` |
| `thunar` | `~/.config/Thunar/uca.xml` (acciones de click derecho) |
| `zsh` | `~/.zshrc` + `~/.p10k.zsh` |
| `git` | `~/.gitconfig` |
| `scripts` | `~/.local/bin/` (33 scripts) + `~/.local/share/crimson/iconos.txt` |
| `gammastep` | `~/.config/gammastep/config.ini` (luz nocturna, Lima fija) |
| `xdg` | `~/.local/share/applications/{nvim,feh}.desktop` |
| `zathura` | `~/.config/zathura/zathurarc` |
| `fastfetch` | `~/.config/fastfetch/{config.jsonc,logo.txt}` |
| `claude-code` | `~/.claude/settings.json` (hook de voz) |
| `nvim` | `~/.config/nvim/` (LazyVim) |
| `picom` / `picom-vm` | `~/.config/picom/picom.conf` — **el instalador elige uno** según `systemd-detect-virt` |

No son paquetes stow: `sistema/` (archivos de `/etc`), `wallpapers/`, `docs/`.

### Archivos de sistema que copia `instalar-paquetes.sh` (16)

```
/etc/nftables.conf                              firewall: arranca en perfil publica
/etc/nftables.d/comun.nft                       reglas comunes (puentes de VMs)
/etc/nftables.d/perfil-privada.nft              casa: ping + mDNS
/etc/nftables.d/perfil-publica.nft              calle: invisible
/etc/nftables.d/redes-privadas.txt              SSIDs de confianza (JABR)
/usr/local/sbin/firewall-perfil                 script root: privada|publica|auto|apagar
/etc/sudoers.d/firewall-perfil                  ese script sin contraseña
/etc/NetworkManager/dispatcher.d/50-firewall-perfil   aplica el perfil al conectar
/etc/lightdm/lightdm-gtk-greeter.conf           login: fondo, fuente, cuadro a la izquierda
/etc/lightdm/lightdm.conf.d/50-crimson.conf     usuario preseleccionado
/etc/xdg/mimeapps.list                          apps por defecto (nivel sistema)
/etc/apt/sources.list.d/mozilla.sources         Firefox actual (no ESR)
/etc/apt/preferences.d/mozilla                  pin 1000 para que gane a Debian
/etc/apt/sources.list.d/claude-desktop.list     repo de Claude Desktop
/usr/share/keyrings/claude-desktop-archive-keyring.asc
sistema/libvirt/red-default.xml                 red NAT de KVM en 192.168.50.0/24
```

## 4. Los 33 scripts (`~/.local/bin`)

**Módulos de la barra** (imprimen una línea y salen; vacío = módulo oculto):
`red-wifi.sh` · `estado-bluetooth.sh` · `estado-microfono.sh` ·
`estado-temperatura.sh` (avisa a 90 °C) · `estado-musica.sh` (MPRIS, modo
tail, con botones) · `firewall.sh` · `vpn.sh` · `actualizaciones.sh` ·
`luz-nocturna.sh` · `no-molestar.sh` · `leer.sh estado`

**Menús rofi**: `ajustes.sh` (F9, 28 opciones) · `wifi-menu.sh` (señal, clave,
olvidar) · `bluetooth-menu.sh` · `powermenu.sh` · `iconos.sh` (10 706 iconos
Nerd Font) · `atajos.sh` (chuleta leída del sxhkdrc) · `fondo.sh`

**Acciones**: `captura.sh` (ventana/región/pantalla → portapapeles + archivo) ·
`ocr.sh` (región → texto) · `color.sh` (píxel → #hex) · `multimedia.sh`
(volumen/brillo/mic con notificación) · `bloquear.sh` (blur + candado
dibujado, multimonitor) · `limpiar-sistema.sh` · `screen-clean` (desactiva
entrada 60 s) · `leer.sh` (Piper+mpv con pausa) · `portapapeles.sh menu`

**Demonios que arranca `bspwmrc`**: `aviso-bateria.sh` (20 %/10 %) ·
`inhibir-bloqueo.sh` (no bloquear con vídeo) · `portapapeles.sh daemon` ·
`monitor-hotplug.sh` (escucha udev) · `aviso-dotfiles.sh` (cambios sin subir)

**Auxiliares**: `monitor-interno.sh` (monitor primario) ·
`ajustar-monitores.sh` (acomoda monitores + relanza polybar + fondo) ·
`leer-respuesta.sh` (hook Stop de Claude Code)

## 5. Qué está construido

**Escritorio**: bspwm (8 escritorios con iconos, foco sigue al ratón,
`single_monocle`, preselección carmesí), sxhkd, picom (glx+blur), dunst,
lightdm personalizado, rofi, kitty, LazyVim (nvim 0.12 en `~/.local/opt`,
**no** el 0.10 de Debian), zsh + p10k + fzf.

**Barra (20 módulos)**: logo Debian, escritorios, voz, música, fecha, bandeja
del sistema, no-molestar, actualizaciones, firewall, VPN, Wi-Fi, bluetooth,
temperatura, CPU, memoria, batería, volumen, micrófono, luz nocturna, power.

**Automatismos**: candado al suspender y a los 10 min (no si hay vídeo) ·
batería 20/10 % · CPU > 90 °C · HDMI automático por evento del kernel ·
auto-montaje USB (udiskie) · luz nocturna · aviso de repo sin subir.

**Seguridad**: firewall nftables con **dos perfiles automáticos por red**
(privada/pública), modo `apagar` de emergencia en el escudo de la barra.
VMs y contenedores (KVM, LXD, Docker, Podman, Waydroid) con red en ambos:
las reglas van por prefijo de puente, cubrir uno de mas no cuesta nada.

**Voz**: Piper local (voz `es_MX-claude-high`) lee las respuestas de Claude
Code vía hook `Stop`; mpv reproduce y permite pausar/reanudar (`super+shift+s`).

**Verificación**: `./comprobar.sh` valida shellcheck de los 33 scripts,
sintaxis de todas las configs, paquetes stow vs instalador, existencia de los
82 paquetes apt y binarios sin paquete. Debe decir **TODO OK**.

## 6. Decisiones y su porqué (no deshacer sin motivo)

| Decisión | Por qué |
|---|---|
| **stow, no `cp`** | una sola copia: editar la config *es* editar el repo; con `cp` el repo se desactualiza a las semanas |
| **Nada de nombres de hardware a fuego** | `eDP`/`BAT0`/`k10temp` se detectan (`monitor-interno.sh`, globs en `/sys`, `${env:BATERIA}`) |
| **Iconos Material (U+F0xxx)** | los del BMP (Font Awesome) se pierden al copiar. En scripts: `printf '\U000fXXXX'`; en polybar/rofi van literales con el codepoint en un comentario |
| **Módulos internos de polybar** | fecha y volumen sin scripts ni polling (volumen por eventos de pipewire) |
| **`polybar-msg cmd restart`** | IPC nativo, no `pkill` + sleep |
| **Duplicación de iconos/colores: se acepta** | una librería común haría que ningún script se entienda suelto. **Valorado y descartado**, no reproponer |
| **X11, no Wayland** | AnyDesk es solo X11 y RustDesk va parcial: el control remoto entrante es justo lo que Wayland restringe por diseño. Con AMD, Wayland iría bien — el problema es el software de su carrera |
| **bspwm, no un DE** | ya tiene todo lo que da un DE (udiskie, tlp, dunst, xss-lock, CUPS, F9, bandeja), pieza a pieza y entendiéndolas |
| **Firefox de Mozilla** | Debian solo trae ESR |
| **LXD para sandbox, no KVM** | comparte kernel: 100 % de CPU, arranca en 1 s |
| **Commits en español** | el repo es también material de aprendizaje |

## 7. Descartado explícitamente (NO volver a proponer)

**Waydroid** (se probó, no se usa: no respaldarlo ni reinstalarlo) ·
calendario en la barra · terminal desplegable · apps fijadas a escritorios ·
toggle de gaps · listar ventanas con rofi (`super+shift+Tab` no dispara con
teclado latam) · disco en la barra · indicador de Caps Lock (el teclado se
ilumina solo) · vatios de consumo · KDE Connect · grabar con ffmpeg (usa OBS) ·
repo charm.sh · librería común para iconos/colores · niri (no está en Debian;
habría que compilarlo y mantenerlo a mano, contra la razón de usar Debian).

## 8. Pendientes reales

1. **Respaldo de `~`** — ver §9. Deja de ser opcional antes de reinstalar.
2. **Cifrado LUKS** — solo se puede al instalar. **Aprovechar la reinstalación.**
3. **Reglas de bspwm para GNS3 / virt-manager / Wireshark / AnyDesk** — cuando
   se instalen, no antes (regla 4: lo que no se usa, no entra).
4. **Guardar/restaurar disposiciones de ventanas** (`bspc wm -d` / `-l`) para
   laboratorios de redes — idea aceptada, sin implementar.
5. **Probar Wayland en la VM** — como aprendizaje, no para la laptop.

## 9. REINSTALACIÓN LIMPIA (plan acordado)

**Objetivo**: dejar la laptop **solo con Debian**, usando el disco entero.
Hoy Fedora ocupa 758 de 954 GB sin encenderse:

```
nvme0n1 954 GB
├─p1  600 MB  vfat   /boot/efi
├─p2    2 GB  ext4   (probable /boot de Fedora)
├─p3  758 GB  btrfs  "fedora"   ← sin montar, sin uso
└─p4  190 GB  ext4   /          ← Debian actual, 35 GB usados
```

### 9.1 RESPALDAR ANTES (tamaños reales)

Todo esto **se pierde** al formatear. A un disco externo o USB grande:

| Qué | Tamaño | Por qué importa |
|---|---|---|
| `~/Descargas` | **13 GB** | lo más grande; revisar qué merece la pena |
| `~/Escritorio` | **374 MB** | contiene `Crimson.tar.gz` (185 MB) y `PA DEBIAN` (190 MB) |
| **`~/Labs`** | 480 KB | **laboratorios de redes** (`alma-infra`, `demo`, `demo-f3`, `demo-grande`) con sus `lab.sqlite`, evidencias, backups y exports. Pequeño pero es trabajo propio |
| **`~/vms`** | 1,3 MB | claves y resultados de pruebas (`hk-test`: `testkey`, `histkey`, `results`) |
| `~/.mozilla` | 954 MB | marcadores, contraseñas, pestañas de Firefox |
| `~/.android` | 1 MB | `adbkey` (autorización de dispositivos). **Cuando firmes apps, aquí vivirá la keystore: perderla impide actualizar una app ya publicada** |
| **`~/.ssh`** | 8 KB | **claves privadas — irreemplazables** |
| `~/.config/gh` | 12 KB | token de GitHub (se puede rehacer con `gh auth login`) |
| `~/Imágenes` | 2 MB | incluye `~/Imágenes/Capturas` |
| VM `debian13` de libvirt | varios GB | en `/var/lib/libvirt/images/` (necesita sudo) |
| La partición `fedora` (p3) | rescatar antes de borrar | montar en **solo lectura** primero |

**No hace falta respaldar**: el rice (está en GitHub) ni lo que reinstala el
instalador (nvim 40 MB, piper 52 MB + voz 61 MB, p10k, fuentes Nerd 233 MB,
Claude Code 677 MB, opencode 239 MB).

### 9.2 Antes de borrar: el arranque

Comprobar **quién controla el arranque** antes de tocar particiones:

```bash
sudo efibootmgr -v ; sudo ls /boot/efi/EFI/
```

Si el GRUB activo es el de Fedora, resolverlo **antes**, no después.

### 9.3 Instalar Debian 13 (netinst)

- Idioma español, teclado **latinoamericano**, host `debian`, usuario `anghelo`.
- **Contraseña de root VACÍA** → así el usuario entra en `sudo`. Si se pone
  contraseña de root, `sudo` ni se instala y **nada del repo funciona**.
- Particionado: **borrar todas las particiones** y usar el disco entero.
  Recomendado: *"Guiado – utilizar todo el disco y configurar LVM cifrado"*
  (es el único momento para el cifrado). Dejar `/home` aparte es opcional; con
  LVM se puede redimensionar después.
- **Selección de programas: desmarcar TODO menos "Utilidades estándar del
  sistema"** (sin escritorio, sin servidor SSH).

### 9.4 Después de instalar

```bash
sudo apt install -y git gh
gh auth login                                    # el repo es privado
gh repo clone AngheloBR/dotfiles-debian-crimson ~/.dotfiles
cd ~/.dotfiles
./instalar-paquetes.sh   # 82 paquetes + Mozilla + nerd fonts + nvim 0.12 + p10k
                         # + piper + firewall + lightdm + Claude Code + opencode
./instalador.sh          # stow (detecta VM vs hardware real para picom)
sudo reboot
# y cuando se quiera, los programas de usuario (van aparte a proposito):
./instalar-apps.sh       # GIMP, VLC, Steam, Discord, OnlyOffice, Obsidian,
                         # AnyDesk, JetBrains Toolbox
```

### Programas de usuario (`instalar-apps.sh`)

| App | Como se instala |
|---|---|
| GIMP, VLC | apt |
| Steam | apt, **tras** `dpkg --add-architecture i386` y añadir `contrib non-free` |
| Discord, OnlyOffice, Obsidian | **Flatpak** (sus `.deb` no se actualizan con apt; Discord se niega a arrancar hasta actualizarlo a mano) |
| AnyDesk | repo propio (se actualiza con apt). **Solo X11** |
| JetBrains Toolbox | tarball a `~/.local/opt`, versión consultada a su API |
| **Android Studio** | el script ofrece: **tarball oficial** (recomendado: emulador y adb por USB sin pegas) o **Flatpak** `com.google.AndroidStudio` (se actualiza solo, pero el sandbox complica emulador y USB). No se automatiza el tarball: el feed de Google da la versión como *"Quail 4 \| 2026.1.4 Patch 1"* y la URL necesita el número de compilación interno, que no publica |
| **JetBrains Toolbox** | **opcional**, el script pregunta. Para Android NO hace falta: **Android Studio ES IntelliJ IDEA** con el SDK y las herramientas de Google. Tiene sentido para PyCharm (scripts de redes) u otros lenguajes |
| **Antigravity** (IDE de Google) | **sin verificar**: mirar si ofrece `.deb` |

> **Licencia de estudiante**: JetBrains regala las versiones Ultimate con
> correo universitario (`jetbrains.com/student`). No usar Community si se
> puede tener Ultimate gratis.

`~/.local/bin-apps` está en el PATH desde el `.zshrc`.

### 9.5 Lo que hay que rehacer a mano (no está en el repo)

- **Wi-Fi**: las 2 redes guardadas se pierden → reconectar (el menú de la barra).
- **Firefox**: restaurar `~/.mozilla` o iniciar sesión en Sync.
- **Claves SSH**: restaurar `~/.ssh` con permisos `700`/`600`.
- **Impresora Epson**: F9 → Impresoras (driver `printer-driver-escpr` ya va en
  el instalador).
- **LXD**: `sudo lxd init --auto` lo hace el instalador; los contenedores hay
  que recrearlos.
- **VMs de libvirt**: copiar los discos a `/var/lib/libvirt/images/` y
  `virsh define`.
- **Claude Desktop**: `sudo apt install claude-desktop` (el repo ya queda
  configurado).
- **Sesión de Claude Code / opencode**: volver a autenticarse.

## 10. Cómo trabajar (flujo)

1. Cambiar el archivo en `~/.dotfiles` (afecta al sistema en vivo).
2. **Probar de verdad**: recargar el programa, mirar el resultado, capturar si
   hace falta. No dar por bueno lo no probado.
3. `./comprobar.sh` → **TODO OK**.
4. Commit en español, descriptivo, explicando el **porqué**; `git push`.
5. Si hubo lección, anotarla en `GUIA-RICE-DEBIAN-BSPWM.txt` §7.
6. Si cambió algo de este contexto, actualizar **este archivo**.

| Para | Comando |
|---|---|
| Tras `git pull` con archivos nuevos | `./instalador.sh` (usa `stow -R`) |
| Recargar atajos | `pkill -USR1 -x sxhkd` (o `super+Escape`) |
| Recargar barra | `polybar-msg cmd restart` |
| Monitores | `~/.local/bin/ajustar-monitores.sh` (o F9) |
| bspwm | `bspc wm -r` — **no con ventanas importantes abiertas** |
| Si el firewall deja sin red | escudo de la barra → APAGAR, o `sudo firewall-perfil apagar` |
| Ver qué hizo el HDMI | `cat ~/.cache/monitor-hotplug.log` |

## 11. Lecciones que más han mordido

Las **28** están en `GUIA-RICE-DEBIAN-BSPWM.txt` §7. Las peores:

- **lightdm arranca bspwm con un PATH sin `~/.local/bin`** → hay que exportarlo
  al principio de `bspwmrc`. Tuvo a polybar sin arrancar sin dar ningún error.
- **`pkill -f` / `pgrep -f` miran la línea de comando completa**, incluida la de
  la shell que los ejecuta: se suicidan. Usar patrones anclados o `-x`.
- **`flush ruleset` en nftables borra la tabla de libvirt** → VMs sin red. Usar
  `flush table inet filter`. Y libvirt en Debian 13 usa iptables por defecto:
  poner `firewall_backend = "nftables"` en `/etc/libvirt/network.conf`.
- **En X11, Shift+Tab es `ISO_Left_Tab`**, no Tab con shift.
- **Iconos del plano 15 (Material) sobreviven al copiar; los del BMP no.**
- **No usar `flock` alrededor de algo que arranca demonios**: el hijo hereda el
  descriptor y deja el candado cogido para siempre (pasó con polybar).
- **Al quitar el cable HDMI, X marca la salida "disconnected" pero no la apaga**
  y bspwm no avisa: el evento fiable es el del kernel (`udevadm monitor`).
- **El hook `Stop` de Claude Code salta antes de que se escriba el transcript**:
  hay que esperar a que el archivo deje de crecer.
- **stow enlaza archivo por archivo en `~/.local/bin`**: tras un `git pull` con
  scripts nuevos hay que volver a ejecutar `./instalador.sh`.
- **`xdpyinfo` da el escritorio completo con dos monitores** (3840x1080): el
  candado salía centrado entre las dos pantallas.

## 12. Versiones de referencia (2026-09-25)

Debian 13 trixie · bspwm 0.9.10 · polybar 3.7.2 · picom 12.5 · rofi 1.7.5 ·
dunst 1.12.2 · nvim 0.12.5 (`~/.local/opt`) · zsh 5.9 · Firefox 156 (Mozilla) ·
piper 1.2.0 + voz `es_MX-claude-high` · kernel 6.12 · xinput/X11 (no Wayland).
