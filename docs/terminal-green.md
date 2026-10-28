# Terminal y Spotify GreenBlack

Sincronización del 26/10/2026 de los ajustes realizados el 21–22/10. Fondo
`#101010`, acento `#00e69a`, texto `#a8d5bf` y texto secundario `#6b9e87`.
Desde el 27/10, Ambxst nativo y las aplicaciones GTK/Qt compatibles comparten
la paleta mediante [configuración de usuario](ambxst-green-black.md).

| Componente | Configuración versionada |
|---|---|
| Kitty | `.config/kitty/{kitty.conf,color.ini}`: negro opaco, Hack Nerd Font 12, paleta ANSI verde |
| Zsh/P10k | `.zshrc`, `.p10k.zsh`: prompt, carpetas, resaltado, sugerencias y fzf verdes |
| LSD/Bat | `.config/lsd/`, `.config/bat/config`: metadatos RGB y Bat ANSI |
| NvChad | `.config/nvim/`: starter, módulos Lua, `green_black`, alternativa `xerux_black` y lockfile |
| Spotify | `.config/spicetify/Themes/`, `green-black.ini`, `.local/bin/spotify` y acceso del menú |
| Exegol | `exegol/hacking/`: prompt y herramientas con la misma paleta; Neovim independiente |

## Restauración del host

Sigue el orden general del README. El restaurador copia solo las rutas explícitas
de `manifests/configs.txt`, hace respaldo y exige una sesión sin Hyprland activo.
No ejecutes `configs --apply` desde el escritorio en uso solo para cambiar colores.
Después de restaurar, abre Kitty y ejecuta `exec zsh` en las shells antiguas.

`.zshrc` incorpora los colores actuales manteniendo el PATH heredado, las rutas
basadas en `$HOME` y la carga única de Powerlevel10k del repo. No copia el PATH
absoluto ni la carga duplicada del archivo vivo.

### NvChad

El snapshot usa NvChad v2.5 y se comprobó con Neovim 0.12.5. Aunque NvChad admite
versiones anteriores, el `nvim-treesitter` fijado en este lockfile requiere
Neovim ≥0.12 y `tree-sitter-cli` ≥0.26.1. La lista `packages/terminal.txt` añade
tree-sitter-cli, ripgrep (búsquedas de Telescope) y unzip (Mason). Son requisitos
de restauración; no representan una afirmación de que todos estuvieran instalados
en la auditoría de septiembre. GCC/Make ya pertenecen a base-devel.

Tras restaurar `.config/nvim`, abre `nvim`. El starter instala lazy.nvim y los
plugins en el directorio de datos del usuario. Para recuperar las revisiones
del snapshot, ejecuta dentro de Neovim:

```vim
:Lazy restore
:MasonInstallAll
:TSInstallAll
```

Las descargas necesitan red. Mason prepara `lua-language-server` y `stylua`;
Tree-sitter instala los lenguajes definidos en `lua/plugins/init.lua`. El tema
se elige en `lua/chadrc.lua`. No se incluyen caches, parsers compilados, servidores
LSP ni plugins de terceros en Git. No uses `:Lazy update` si quieres conservar
exactamente el lockfile del respaldo.

Fuentes: [NvChad](https://nvchad.com/docs/quickstart/install/),
[requisitos del Tree-sitter fijado](https://github.com/nvim-treesitter/nvim-treesitter/blob/29212d826054bb2948fa9d3a99eca9bf6a050eb2/README.md).

### Spotify

Combinación comprobada: Spotify `1.2.96.518` y Spicetify `2.46.2`. El paquete AUR
`spotify` ya está en `packages/aur.txt`; los paquetes de Arch se instalan en sus
versiones disponibles, así que comprueba compatibilidad si esa versión cambia.

1. Restaura configs y prepara Spicetify con
   `./scripts/manual-components.sh spicetify --apply`. Descarga el artefacto
   oficial v2.46.2, verifica SHA-256 e instala en `~/.local/share/spicetify-cli`,
   con enlace en `~/.local/bin`. Una instalación de versión distinta se conserva
   y requiere revisión; no se actualiza implícitamente.
2. Abre `/usr/bin/spotify`, inicia sesión y ciérralo para crear `prefs`.
3. Revisa `./scripts/bootstrap-spotify.py` y ejecuta
   `./scripts/bootstrap-spotify.py --apply`.
4. Abre Spotify desde el menú o `~/.local/bin/spotify`.

El bootstrap crea una copia escribible de `/opt/spotify` en
`~/.local/share/spotify`; aplica las preferencias del preset con la CLI y ejecuta
`backup apply` en una copia nueva, o `apply` en una ya modificada. Conserva una
copia de la configuración previa bajo `~/.local/state/dotfiles-backups/spotify-*`.
No inicia Spotify ni interrumpe la reproducción: exige cerrar el cliente primero.
El wrapper tiene fallback a `/opt/spotify/spotify` antes del bootstrap y siempre
lee `spotify-flags.conf` para mantener Wayland. El acceso del menú expande `$HOME`
y conserva los argumentos; no depende del PATH de una terminal interactiva.

`green-black.ini` no contiene rutas personales ni sección `[Backup]`.
`config-xpui.ini`, `prefs`, estado de sesión y archivos binarios quedan locales.
Conserva `expose_apis=1` y `experimental_features=1`: en Spicetify 2.46.2 esa ruta
inserta el cargador de módulos necesario para este cliente. El tema aporta CSS y
colores; no incluye extensiones ni aplicaciones personalizadas.

Para reaplicar después de editar únicamente los colores:

```bash
spicetify -n refresh
# En Spotify: Ctrl+Shift+R.
```

Para volver a los grises: `spicetify config current_theme XeruxBlack` y
`spicetify -n refresh`, después recarga la interfaz. Actualiza también
`green-black.ini` si quieres que el siguiente bootstrap conserve esa elección.

Tras actualizar el paquete Spotify, abre una vez `/usr/bin/spotify` y ciérralo.
Comprueba primero la compatibilidad de Spicetify. Luego revisa
`./scripts/bootstrap-spotify.py --refresh-client` y aplícalo con `--apply`.
El cliente local anterior se archiva antes de sustituirlo por una copia del nuevo
paquete. No se borra `/opt/spotify` ni se cambian sus permisos.

Referencias: [release fijada](https://github.com/spicetify/cli/releases/tag/v2.46.2),
[comandos de Spicetify](https://spicetify.app/docs/cli/commands).

## Exegol

Sigue la tabla de [restauración del perfil hacking](../exegol/hacking/README.md).
Se mantiene el punto de personalización compartido, y el perfil específico carga
`green-colors.zsh`. El tema de LSD usa la ruta del contenedor y su formato 0.23.1.
Neovim 0.7.2 usa un archivo normal propio; ya no es un enlace al NvChad del host.
El restore general no inicia contenedores ni modifica sus recursos persistentes.

## Comprobaciones

```bash
python -B -m unittest discover -s scripts -p 'test_restore.py'
python -B -m unittest discover -s scripts -p 'test_spotify.py'
python -B scripts/restore.py configs       # plan; sin --apply
./scripts/bootstrap-spotify.py            # plan; sin --apply
desktop-file-validate .local/share/applications/spotify.desktop
git diff --check
```

Las pruebas de restauración y Spotify trabajan con directorios temporales. No
reinstalan el escritorio ni usan tu sesión de Spotify. La instalación de plugins
y las actualizaciones del cliente siguen requiriendo comprobar sus versiones.

Validación realizada el 26/10/2026:

- 15 pruebas del restaurador y 6 del bootstrap/acceso de Spotify aprobadas.
- Sintaxis de Zsh, Bash y Lua, entrada `.desktop` y `git diff --check` correctos.
- NvChad cargado en XDG temporal con copia de los plugins instalados: tema
  `green_black`, fondo `#101010` y texto `#a8d5bf`; también se cargó el Lua de Exegol.
- Instalador de Spicetify ejecutado en un HOME temporal: descarga oficial,
  SHA-256, enlace relativo y segunda ejecución correctos.
- Bootstrap real de Spicetify sobre copia temporal del paquete Spotify y prefs
  sintéticas: primera aplicación, CSS verde, cargador de módulos y reaplicación
  correctos. No se abrió una sesión gráfica ni se reinstaló el sistema real.
