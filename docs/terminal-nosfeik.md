# Terminal y Spotify con Nosfeik

Nosfeik es la misma paleta de mi Obsidian y de mi blog:

| Rol | Color |
|---|---|
| Fondo | `#16181d` |
| Texto | `#dce2ec` |
| Secundario | `#8792a8` |
| Acento | `#60a5fa` |
| Bordes | `#475a8b` |

Antes usaba GreenBlack (`#101010`, `#a8d5bf`, `#00e69a`). Para pasar a Nosfeik cambié cada color verde por su equivalente azul, entonces cada uno sigue cumpliendo su función (acento, texto, secundario, selección). GreenBlack lo dejé de respaldo, abajo explico cómo regresar.

| Qué | Dónde |
|---|---|
| Kitty | `.config/kitty/{kitty.conf,color.ini}`, Hack Nerd Font 12 y paleta ANSI azul |
| Zsh/P10k | `.zshrc` y `.p10k.zsh`: prompt, carpetas, resaltado, sugerencias y fzf |
| LSD/Bat | `.config/lsd/` y `.config/bat/config` |
| NvChad | `.config/nvim/` con el tema `nosfeik` (y `green_black` y `xerux_black` de respaldo) |
| Spotify | `.config/spicetify/Themes/`, `nosfeik.ini`, `.local/bin/spotify` y el acceso del menú |
| WhatsApp | `.config/elecwhat/config.json` y `themes/nosfeik.css` |
| Barra | `Pictures/Icon/Arch-launcher-nosfeik.png` como ícono del launcher |
| Exegol | `exegol/hacking/`, la misma paleta dentro del contenedor |

## NvChad

Uso NvChad v2.5 con Neovim 0.12.5. El `nvim-treesitter` del lockfile pide Neovim ≥0.12 y `tree-sitter-cli` ≥0.26.1, por eso en `packages/terminal.txt` van tree-sitter-cli, ripgrep (para Telescope) y unzip (para Mason).

Después de restaurar `.config/nvim` abro `nvim`, se instala lazy.nvim con los plugins y luego corro:

```vim
:Lazy restore
:MasonInstallAll
:TSInstallAll
```

`:Lazy restore` deja los plugins en las versiones del lockfile, si quiero quedarme ahí no uso `:Lazy update`. El tema se cambia en `lua/chadrc.lua`.

## Spotify

Lo tengo con Spotify `1.2.96.518` y Spicetify `2.46.2`.

1. Restaurar configs y correr `./scripts/manual-components.sh spicetify --apply`, que baja Spicetify 2.46.2 y revisa su SHA-256.
2. Abrir `/usr/bin/spotify`, iniciar sesión y cerrarlo.
3. `./scripts/bootstrap-spotify.py --apply`.
4. Abrir Spotify desde el menú o con `~/.local/bin/spotify`.

El bootstrap hace una copia de `/opt/spotify` en `~/.local/share/spotify` y le aplica Spicetify a esa copia, así no necesita sudo. Antes respalda la config anterior en `~/.local/state/dotfiles-backups/spotify-*`. El wrapper siempre lee `spotify-flags.conf` para que corra en Wayland.

En `nosfeik.ini` hay que dejar `expose_apis=1` y `experimental_features=1`, porque en la 2.46.2 así se carga el tema. El tema nada más trae CSS y colores, nada de extensiones.

Si cambio colores:

```bash
spicetify -n refresh
# y en Spotify Ctrl+Shift+R
```

Para regresar a GreenBlack o a los grises de XeruxBlack:

```bash
spicetify config current_theme GreenBlack   # o XeruxBlack
spicetify -n refresh
```

Cuando se actualiza el paquete de Spotify lo abro y cierro una vez, reviso que Spicetify sea compatible y corro `./scripts/bootstrap-spotify.py --refresh-client --apply`. La copia anterior queda archivada y `/opt/spotify` no se toca.

## WhatsApp

Uso elecwhat, que carga `.config/elecwhat/themes/nosfeik.css` desde `config.json`. `green-black.css` se queda de respaldo. El perfil de Electron (cookies, sesión) no va en el repo. Después de restaurar hay que reiniciar elecwhat.

## Burp en la barra

Burp abre con la clase `burp-StartBurp`, y Ambxst busca el ícono comparando la clase con el ejecutable, el nombre o los `Keywords` del `.desktop`, no con `StartupWMClass`. Por eso en la barra salía sin logo. Lo arreglé con un override en `.local/share/applications/burpsuite.desktop` que agrega la clase en `Keywords` y en `StartupWMClass`, sin parchear Ambxst.

## Exegol

La config del contenedor está en [exegol/hacking](../exegol/hacking/README.md).
