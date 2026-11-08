# Paquetes

Listas sacadas de esta laptop con `pacman -Qqe` y compañía. Nada más va lo que instalé yo, no las más de mil dependencias.

| Lista | Qué tiene |
|---|---|
| `base.txt` | Kernel, firmware, AMD, arranque, Btrfs/LVM, red |
| `desktop.txt` | GNOME y GDM de fallback, Nautilus, Bluetooth y audio |
| `hyprland.txt` | Hyprland, hypridle, Mesa, portales y el agente de polkit |
| `asus.txt` | asusctl, rog-control-center y power-profiles-daemon |
| `terminal.txt` | Kitty, Zsh, LSD, plugins, y tree-sitter-cli, ripgrep y unzip para NvChad |
| `fonts-theme.txt` | GTK y fuentes del sistema |
| `utilities.txt` | Herramientas de diagnóstico y editores |
| `ambxst.txt` | Lo que pide Ambxst que no está en las otras listas |
| `apps.txt` | Firefox y Obsidian |
| `aur.txt` | Brave Origin Nightly, Discord Canary, elecwhat, Spotify, VS Code, Murrine y las fuentes que pide Ambxst |
| `optional/` | Lo que no instalo por defecto: idiomas de OCR, `sassc` para reconstruir Colloid y lo de Exegol (Docker, pipx, xhost) |
| `versions.tsv` | Las versiones que tenía, como referencia. No es un lockfile |

```bash
./scripts/install.sh packages           # enseña la lista
./scripts/install.sh packages --apply   # pacman -Syu --needed
./scripts/install.sh aur                # enseña la lista del AUR
./scripts/install.sh aur --apply        # necesita yay
```

Algunas notas:

- Arch es rolling, entonces estas listas instalan lo que esté disponible ese día. No hagas actualizaciones parciales ni fuerces nada más Hyprland 0.56.2 sobre librerías nuevas.
- `asusctl` y `rog-control-center` ya están en los repos oficiales.
- Ambxst, axctl y Powerlevel10k no son paquetes, van en [lo que se instala a mano](../docs/manual-installs.md). Los temas, iconos y fuentes se restauran desde el repo.
- No hay nada de NVIDIA, PRIME, TLP ni undervolt. La dGPU la apago desde ROG Control Center.
- `yay` lo instalo a mano antes de la lista del AUR.
