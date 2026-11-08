# Lo que se instala a mano

Hay cosas que no vienen de pacman ni del AUR. Para esas uso `scripts/manual-components.sh` con versiones fijas. Sin `--apply` nada más enseña lo que va a hacer, y si algo ya está instalado con otra versión se detiene en lugar de sobrescribirlo.

## Ambxst y axctl

Los binarios van en `/usr/local/bin/ambxst` y `/usr/local/bin/axctl`, y la shell en `~/.local/src/ambxst`. No los instalo con el `install.sh` de Ambxst porque ese siempre baja `latest` y actualiza el checkout, prefiero versiones fijas. El script baja Ambxst [1.3.7](https://github.com/Axenide/Ambxst/releases/tag/1.3.7) y axctl [v0.0.26](https://github.com/Axenide/axctl/releases/tag/v0.0.26) y revisa sus hashes. Solo funciona en x86_64. El tag de Ambxst no lleva `v`.

```bash
./scripts/manual-components.sh ambxst --apply
ambxst version
axctl --version
```

Después hay que actualizar Ambxst a la 1.3.14, que es la que pide Roadie.

### El Lua que genera Ambxst

Mi `hyprland.lua` carga `~/.local/share/ambxst/hyprland.lua`, pero ese archivo lo genera Ambxst la primera vez que corre. `ambxst install hyprland` no lo genera, nada más agrega el import. En una instalación nueva, con assets, system y configs ya restaurados, salgo de GNOME y desde una TTY corro:

```bash
./scripts/bootstrap-ambxst.sh --apply
```

Eso abre un Hyprland temporal con Kitty y Ambxst. Cuando aparece el archivo lo reviso y salgo:

```bash
test -s ~/.local/share/ambxst/hyprland.lua
luac -p ~/.local/share/ambxst/hyprland.lua
ambxst quit
hyprctl dispatch 'hl.dsp.exit()'
```

Luego ya entro normal a Hyprland desde GDM.

## Powerlevel10k

Lo tengo clonado en `~/.powerlevel10k`:

```bash
./scripts/manual-components.sh p10k --apply
```

`.p10k.zsh` es mi prompt tal cual. En `.zshrc` las rutas usan `$HOME` y `~/.local/bin` va en el PATH.

## NvChad y Spicetify

Las configs vienen en el repo, pero los plugins y el Spotify modificado se preparan en cada máquina. Los pasos están en [terminal-blazepwn.md](terminal-blazepwn.md). Spicetify también va con versión y SHA-256 fijos:

```bash
./scripts/manual-components.sh spicetify --apply
./scripts/bootstrap-spotify.py --apply
```

Antes del último paso hay que abrir Spotify una vez, iniciar sesión y cerrarlo. No usa sudo, trabaja sobre una copia en `~/.local/share/spotify`.

## Plugin sudo de Zsh

Es el plugin `sudo` de Oh My Zsh (Esc, Esc te pone `sudo` al inicio del comando), pero solo el plugin, sin todo Oh My Zsh. La copia está en `vendor/zsh-sudo` con su licencia MIT, y `./scripts/install.sh system --apply` la pone en `/usr/share/zsh/plugins/zsh-sudo/`.

## Colloid

Ya no lo uso, pero lo dejé de respaldo. El restore copia el tema ya instalado de `.themes/Colloid-Dark` y no lo recompila. Si lo quiero reconstruir desde el código:

```bash
sudo pacman -S --needed sassc
./scripts/manual-components.sh colloid --apply
cd ~/.local/src/Colloid-gtk-theme
./install.sh -d "$(mktemp -d)" -c dark
```

La licencia GPL-3.0 está en `vendor/Colloid-LICENSE`.
