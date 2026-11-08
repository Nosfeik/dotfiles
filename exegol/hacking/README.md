# Exegol `hacking`

Mi perfil para el contenedor `hacking` de Exegol: Powerlevel10k con la caja ` hacking`, la paleta Nosfeik, Git en el prompt y los plugins de Exegol con su indicador de usuario, dominio y grabación. Adentro `ls` usa lsd, `cat` usa bat y `vim` abre Neovim.

## Instalarlo

El restore normal del repo nada más configura el host, esto se copia aparte a `~/.exegol/my-resources/setup/zsh/`, que es lo que Exegol monta en el contenedor:

| Del repo | A `~/.exegol/my-resources/setup/zsh/` |
|---|---|
| `exegol/hacking/zshrc` | `hacking/zshrc` |
| `exegol/hacking/p10k.zsh` | `hacking/p10k.zsh` |
| `exegol/hacking/green-colors.zsh` | `hacking/green-colors.zsh` |
| `exegol/hacking/burpsuite` | `hacking/burpsuite` (ejecutable) |
| `exegol/hacking/install-burp-runtime.sh` | `hacking/install-burp-runtime.sh` (ejecutable) |
| `.config/bat/config` | `hacking/config/bat/config` |
| `exegol/hacking/config/nvim/init.lua` | `hacking/config/nvim/init.lua` |
| `exegol/hacking/config/lsd/{config,colors}.yaml` | `hacking/config/lsd/` |

También:

- Copiar `~/.powerlevel10k` a `hacking/powerlevel10k` (se prepara con `scripts/manual-components.sh p10k`).
- Agregar una vez el bloque de [../zshrc](../zshrc) al `setup/zsh/zshrc` compartido. Ese bloque carga el perfil solo en `exegol-hacking`.
- Dentro del contenedor, enlazar `/root/.p10k.zsh` a `/opt/my-resources/setup/zsh/hacking/p10k.zsh` y `/root/.config/{bat,nvim,lsd}` a sus carpetas en `hacking/config/`.

Ojo con dos cosas. Neovim tiene su propio `init.lua` porque el contenedor trae la 0.7.2 y mi NvChad del host pide la 0.12, entonces no lo enlaces al del host. Y LSD adentro es la 0.23.1, que usa otro formato, así que no copies el YAML del host.

Después abre otra sesión o corre `exec zsh`.

## Uso

`xxx` es mi alias para `exegol start hacking`. Lo abro desde una terminal de la sesión gráfica, sin `sudo`, porque Exegol corre `xhost` para que las apps gráficas del contenedor puedan abrir ventanas. Con `sudo` pierde el acceso a la sesión. Mi usuario ya está en el grupo `docker`.

Para quitar el perfil, se borra el bloque `dotfiles: hacking` del `zshrc` compartido.

## Burp nítido en Wayland

Con escala 1.6 Burp se veía borroso por Xwayland. El lanzador `burpsuite` lo abre con JetBrains Runtime 21.0.11 y `-Dawt.toolkit.name=WLToolkit`, así corre nativo en Wayland y respeta la escala del monitor. La regla de Hyprland lo manda al workspace 3.

El runtime vive en `hacking/jbr-21` y no va en el repo. Para instalarlo, dentro del contenedor corre `install-burp-runtime.sh`, que baja esa versión y revisa su SHA-512.

En Burp hay que dejar apagado **Configure scaling settings**. Al abrirlo, Burp avisa que JetBrains Runtime no es una plataforma probada por PortSwigger, nada más se acepta. Si una extensión da problemas, se abre con el Java normal:

```sh
BURP_DISPLAY_BACKEND=x11 burpsuite
```
