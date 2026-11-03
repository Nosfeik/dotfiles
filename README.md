# dotfiles

Mi configuración de Arch en la **ROG Zephyrus G16 (GA605KP)**. Uso Hyprland con config en Lua, Ambxst como shell, Kitty, Zsh con Powerlevel10k, LSD y NvChad. Todo va con el tema **GreenBlack** (`#101010` de fondo, `#a8d5bf` de texto y `#00e69a` de acento), igual en la terminal, Neovim, Spotify y la barra.

Esto es mi respaldo y la guía que sigo cuando reinstalo la laptop, no está pensado para usarse tal cual en otra máquina.

## Qué hay aquí

| Carpeta | Qué tiene |
|---|---|
| `.config/` | Hyprland, Ambxst, Kitty, GTK/Qt, NvChad, LSD, bat, Spicetify |
| `.zshrc`, `.p10k.zsh` | Shell y prompt |
| `.local/bin/` | `lid-power.sh`, wrapper de Spotify y `batcat` |
| `.fonts/`, `.icons/`, `.themes/`, `Pictures/` | Hack Nerd Font, Meslo, Montserrat, iconos Kora, cursor GoogleDot, Colloid (ya no lo uso, lo dejo de respaldo), wallpapers e ícono del launcher |
| `packages/` | Listas de pacman/AUR sacadas de esta máquina |
| `manifests/` | Lista explícita de lo que copia el restaurador |
| `scripts/` | Instalador, restaurador, firewall y bootstraps |
| `system/etc/` | Drop-in de logind para la tapa y config de zram |
| `exegol/` | Mi perfil de Exegol (prompt, aliases, Burp en Wayland) |
| `mods/` | Mods de Ambxst que hice, ahorita no los tengo activos |
| `docs/` | Notas más a detalle de cada cosa |

## Versiones

Hyprland 0.56.2, Ambxst 1.3.14, axctl v0.0.26, Spicetify 2.46.2, NvChad v2.5 (necesita Neovim ≥0.12).

## Hardware y decisiones

- Ryzen AI 7 350 con Radeon 860M. La RTX 5070 la dejo apagada con **GPU Mode = Integrated** en ROG Control Center, no uso PRIME.
- OLED 2560×1600 a 240 Hz con escala 1.6.
- Charge limit al 80 %, Quiet en batería y Balanced en AC con `power-profiles-daemon`. Dejo las curvas de ASUS, nada de undervolt ni TDP manual.
- No uso TLP.
- Teclado `us` y `latam`, cambio entre los dos con SUPER+Espacio.
- GTK con **adw-gtk3** y los colores que genera Ambxst. Qt usa la misma paleta con qt5ct/qt6ct.
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

## Exegol

`xxx` abre `exegol start hacking`. El perfil del contenedor está en [exegol/hacking](exegol/hacking/README.md) y se restaura aparte. Imágenes, Java y credenciales no van en el repo.

## Lo que no va en el repo

VPNs (`~/.vpn/`, `.ovpn`, certificados), llaves, historial, `weather.json`, `assistant.json` y todo el runtime de Spotify/Neovim. Está en el `.gitignore`, y la neta no hago `git add -f` para brincarlo.

## Docs

- [Tema GreenBlack](docs/terminal-green.md)
- [GreenBlack en Ambxst](docs/ambxst-green-black.md) y [Roadie](docs/ambxst-roadie.md)
- [Instalaciones manuales](docs/manual-installs.md)
- [Firewall](docs/firewall.md)
- [Auditoría del sistema](docs/audit.md)
- [Pentest Mode](mods/pentest-mode) y [Battery Indicator](mods/battery-indicator/README.md), archivados

## Créditos

[Ambxst](https://github.com/Axenide/Ambxst), [Colloid](https://github.com/vinceliuice/Colloid-gtk-theme), [Powerlevel10k](https://github.com/romkatv/powerlevel10k) y [NvChad](https://github.com/NvChad/NvChad). Las licencias de lo que incluyo están en `vendor/`.
