# dotfiles

Mi configuración de Arch en la **ROG Zephyrus G16 (GA605KP)**. Uso Hyprland con config en Lua, Ambxst como shell, Kitty, Zsh con Powerlevel10k, LSD y NvChad. Todo va con el tema **Blazepwn**, la misma paleta azul de mi Obsidian y mi blog (`#16181d` de fondo, `#dce2ec` de texto y `#60a5fa` de acento), igual en la terminal, Neovim, Spotify y la barra. Antes usaba GreenBlack, lo dejé de respaldo.

Esto es mi respaldo y la guía que sigo cuando reinstalo la laptop, no está pensado para usarse tal cual en otra máquina.

## Qué hay aquí

| Carpeta | Qué tiene |
|---|---|
| `.config/` | Hyprland, Ambxst, Kitty, GTK/Qt, NvChad, LSD, bat, Spicetify |
| `.zshrc`, `.p10k.zsh` | Shell y prompt |
| `.local/bin/` | `lid-power.sh`, wrapper de Spotify y `batcat` |
| `.fonts/`, `.icons/`, `.themes/`, `Pictures/` | Hack Nerd Font, Meslo, Montserrat, iconos Kora, cursor Bibata Modern Ice, GoogleDot y Colloid (ya no los uso, los dejo de respaldo), wallpapers e ícono del launcher |
| `packages/` | Listas de pacman/AUR sacadas de esta máquina |
| `manifests/` | Lista explícita de lo que copia el restaurador |
| `scripts/` | Instalador, restaurador, firewall y bootstraps |
| `system/etc/` | Drop-in de logind para la tapa y config de zram |
| `exegol/` | Mi perfil de Exegol (prompt, aliases, Burp en Wayland) |
| `mods/` | Mods de Ambxst que hice: Centered Battery, Notification Fixes y OSD Fix |
| `docs/` | Notas más a detalle de cada cosa |
| `legacy/` | Configs viejas que ya no restauro |

## Versiones

Hyprland 0.56.2, Ambxst 1.3.14, axctl v0.0.26, Spicetify 2.46.2, NvChad v2.5 (necesita Neovim ≥0.12).

## Hardware y decisiones

- Ryzen AI 7 350 con Radeon 860M. La RTX 5070 la dejo apagada con **GPU Mode = Integrated** en ROG Control Center, no uso PRIME.
- OLED 2560×1600 a 240 Hz con escala 1.6.
- Charge limit al 80 %, Quiet en batería y Balanced en AC, eso lo cambia asusd solo (`asusctl profile get` enseña los dos). Dejo las curvas de ASUS, nada de undervolt ni TDP manual.
- No uso TLP.
- Teclado `us` y `latam`, cambio entre los dos con SUPER+Espacio.
- GTK con **adw-gtk3** y los colores que genera Ambxst. Qt usa la misma paleta con qt5ct/qt6ct.

La uso para pentesting, HTB/CPTS, programar y notas en Obsidian, no para gaming.

## Hyprland

El Lua que genera Ambxst (`~/.local/share/ambxst/hyprland.lua`) **no lo edito**, se regenera. Mi `hyprland.lua` lo carga primero y luego mis overrides en `user/`:

```text
.config/hypr/
├── hyprland.lua
├── hypridle.conf
└── user/  env · binds · windowrules · startup · input · gestures · lid
```

Para validar después de mover algo:

```bash
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
hyprctl reload
hyprctl configerrors
```

### Teclas de la laptop (ROG Zephyrus G16 GA605KP)

Esto es específico de la **ROG Zephyrus G16 GA605KP** (2025, Ryzen AI 7 350 + RTX 5070). Otros modelos de ASUS, incluso otras Zephyrus, pueden mandar códigos distintos en las teclas Fn o no tener Aura RGB, entonces en otra laptop hay que volver a revisar qué manda cada tecla antes de copiar estos binds.

Lo que manda cada tecla lo saqué leyendo `/dev/input` mientras las presionaba, casi todas salen del teclado `ITE Tech. Inc. ITE Device(8910)` como `KEY_*` normales. El nombre del touchpad (`asuf1209:00-2808:0219-touchpad`) también es de este modelo. Los binds están al final de `user/binds.lua`:

| Tecla | Llega como | Qué hace |
|---|---|---|
| Fn+F1 | `XF86AudioMute` | Mute |
| Fn+F2 / F3 | nada, lo hace el firmware | Luz del teclado (`asus::kbd_backlight`) |
| Fn+F4 | `XF86Launch3` | Siguiente efecto de Aura (`asusctl aura effect --next-mode`) |
| Fn+F5 | `XF86Launch4` | Siguiente perfil Quiet / Balanced / Performance y lo enseña en el OSD |
| Fn+F6 | Super+Shift+S | Screenshot, igual que Super+S |
| Fn+F7 / F8 | `XF86MonBrightnessDown/Up` | Brillo con OSD |
| Fn+F9 | Super+P | Proyectar pantalla, sin bind porque nada más uso la de la laptop |
| Fn+F10 | `XF86TouchpadToggle` | Apaga y prende el touchpad, con `hyprctl reload` vuelve a prender |
| Tecla ROG | `XF86Launch1` | Abre ROG Control Center, si ya está en el tray solo enseña la ventana |
| Mic, volumen, media | `XF86Audio*` | Lo normal con `wpctl` y `playerctl` |

Algunas cosas que no son obvias:

- **Brillo:** uso `brightnessctl -e4` por la curva, pero Ambxst no se entera de esos cambios y no sacaba el OSD. Por eso el bind llama después a `qs ipc ... call brightness pull ""` para que vuelva a leer el brillo.
- **Perfil del ventilador:** el OSD lo agrega el mod [osd-fix](mods/osd-fix) y lee el perfil directo de `asusctl`, porque `power-profiles-daemon` a veces dice otro perfil que asusd. El bind llama a `qs ipc ... call rog announce` (no `show`, que `qs ipc` lo toma como su propio comando).
- **Super+Shift+S:** Ambxst lo usa para abrir sus herramientas, pero Fn+F6 manda justo esa combinación y Hyprland no distingue el Shift derecho del izquierdo. Lo cambié a screenshot y las herramientas siguen en el botón de la barra.
- Los `qs ipc` usan `--pid` con `$XDG_RUNTIME_DIR/ambxst-qs.pid`, que lo escribe Ambxst, así no dependen de la ruta de la generación de mods.

En `user/windowrules.lua` ROG Control Center abre en floating. Ojo que cambió su clase a `org.opengamingcollective.rog-control-center`, si una actualización la vuelve a cambiar deja de agarrar la regla.

## Idle y tapa

hypridle es lo único que hace acciones por inactividad (en Ambxst dejé `idle.listeners = []`):

| Tiempo | Acción |
|---|---|
| 5 min | `ambxst lock` |
| 10 min | apaga la pantalla |
| 30 min | `ambxst suspend` |

Con la tapa:

- **En batería** se apaga completo por logind, porque casi siempre la meto a la mochila y no quiero depender de s2idle.
- **En AC** bloquea y apaga el OLED, al abrir prende la pantalla y sigue bloqueada.

Esto lo hacen `system/etc/systemd/logind.conf.d/20-lid.conf` y `.local/bin/lid-power.sh`. hypridle arranca desde `startup.lua`, entonces no habilito `hypridle.service` porque se duplica.

## Instalar desde cero

Instalé con archinstall: UEFI, systemd-boot, GDM con GNOME de fallback, LVM + Btrfs. Ya con el sistema base:

```bash
git clone https://github.com/Nosfeik/dotfiles ~/Dev/dotfiles
cd ~/Dev/dotfiles
```

Los scripts sin `--apply` nada más muestran lo que van a hacer, entonces primero reviso y luego aplico:

```bash
./scripts/install.sh packages --apply     # ojo, hace pacman -Syu
./scripts/install.sh aur --apply          # necesita yay
./scripts/manual-components.sh ambxst --apply
./scripts/manual-components.sh p10k --apply
./scripts/install.sh assets --apply
./scripts/install.sh system --apply
./scripts/install.sh configs --apply
./scripts/install.sh services --apply
./scripts/manual-components.sh spicetify --apply
```

Después:

1. Abrir Spotify una vez, iniciar sesión, cerrarlo y correr `./scripts/bootstrap-spotify.py --apply`.
2. En Neovim: `:Lazy restore`, `:MasonInstallAll` y `:TSInstallAll`.
3. Configurar ROG Control Center a mano (Integrated, 80 %, perfiles de arriba).
4. Desde GNOME, `nwg-look -a` para que GSettings agarre adw-gtk3, Kora y el cursor.
5. Salir de GNOME y desde una TTY:

```bash
./scripts/firewall.sh --apply        # UFW: deny incoming, allow outgoing
./scripts/bootstrap-ambxst.sh --apply # solo la primera vez, genera el Lua de Ambxst
systemctl reboot
```

En GDM elegir Hyprland.

El restaurador hace backup de lo que reemplaza en `~/.local/state/dotfiles-backups/` y no copia nada si Hyprland o Ambxst están corriendo. Más detalle en [manifests/](manifests/README.md).

## Mods de Ambxst

Tengo cinco activos, la lista con versiones y hashes está en [manifests/ambxst-mods.json](manifests/ambxst-mods.json):

| Mod | De dónde sale |
|---|---|
| Roadie 4.1.1 | [drpezzer/ambxst-mods](https://github.com/drpezzer/ambxst-mods/tree/main/packages/roadie), config en `.config/ambxst/roadie.json` |
| Centered Battery 1.3.1 | [mods/centered-battery](mods/centered-battery) |
| Notification Fixes 1.1.0 | [mods/notif-empty-actions](mods/notif-empty-actions), oculta las acciones vacías de las notificaciones (la de kitty) y muestra los íconos que llegan como ruta. Necesita Roadie |
| OSD Fix 1.1.0 | [mods/osd-fix](mods/osd-fix), el OSD de volumen y brillo se cerraba solo si el cursor estaba abajo de la pantalla porque el hover cubría toda la franja, ahora solo cuenta el pill. También agrega el OSD del perfil del ventilador para Fn+F5 |
| Pentest 1.1.0 | [Nosfeik/ambxst-pentest](https://github.com/Nosfeik/ambxst-pentest), repo aparte. Super+Shift+P lo oculta y lo muestra, el bind ya va en `binds.json` |

Después de restaurar los configs y con Ambxst corriendo, los instalo en este orden porque Notification Fixes depende de Roadie:

```bash
ambxst mods install https://github.com/drpezzer/ambxst-mods/tree/main/packages/roadie
ambxst mods install ./mods/centered-battery
ambxst mods install ./mods/notif-empty-actions
ambxst mods install ./mods/osd-fix
git clone https://github.com/Nosfeik/ambxst-pentest ~/Dev/ambxst-pentest
ambxst mods install ~/Dev/ambxst-pentest
for m in drpezzer.roadie local.centered-battery local.notif-empty-actions local.osd-fix nosfeik.pentest; do
    ambxst mods enable "$m"
done
ambxst reload
```

Todos están probados contra Ambxst 1.3.14 (`83e8462a`). Si Ambxst se actualiza hay que revisar que los parches sigan aplicando antes de hacer reload.

## Exegol

`xxx` abre `exegol start hacking`. El perfil del contenedor está en [exegol/hacking](exegol/hacking/README.md) y se restaura aparte. Imágenes, Java y credenciales no van en el repo.

## Lo que no va en el repo

VPNs (`~/.vpn/`, `.ovpn`, certificados), llaves, historial, `weather.json`, `assistant.json` y todo el runtime de Spotify/Neovim. Está en el `.gitignore`, y la neta no hago `git add -f` para brincarlo.

## Docs

- [Terminal y Spotify con Blazepwn](docs/terminal-blazepwn.md)
- [Ambxst con Blazepwn](docs/ambxst-blazepwn.md) y [Roadie](docs/ambxst-roadie.md)
- [Lo que se instala a mano](docs/manual-installs.md)
- [Firewall](docs/firewall.md)
- [Perfil de Exegol](exegol/hacking/README.md)

## Créditos

[Ambxst](https://github.com/Axenide/Ambxst), [Colloid](https://github.com/vinceliuice/Colloid-gtk-theme), [Powerlevel10k](https://github.com/romkatv/powerlevel10k) y [NvChad](https://github.com/NvChad/NvChad). Las licencias de lo que incluyo están en `vendor/`.
