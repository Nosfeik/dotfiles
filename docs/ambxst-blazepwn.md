# Ambxst con Blazepwn

Uso Ambxst 1.3.14 con [Roadie](ambxst-roadie.md) y el tema Blazepwn como preset nativo, nada de mods para los colores. Antes era GreenBlack y lo dejé en `colors/GreenBlack/` por si lo quiero regresar.

El preset está en `.config/ambxst/colors/Blazepwn/{dark,light}.json`. En oscuro usa lo mismo que Kitty, Spotify y mi Obsidian: fondo `#16181d`, texto `#dce2ec` y acento `#60a5fa`. Los rojos y amarillos para errores y avisos los dejé como vienen en Catppuccin. OLED lo tengo apagado porque si no el fondo se vuelve negro puro.

## Activarlo

Después de restaurar los configs:

1. `ambxst reload` y abrir `ambxst run wallpapers`.
2. En el selector de esquema elegir **Blazepwn**, modo oscuro y OLED apagado.
3. Si los bordes salen con error de color, `hyprctl reload` y revisar `hyprctl configerrors`.

Ambxst guarda la selección en `~/.cache/ambxst/wallpapers.json` (`activeColorPreset`). Aunque esté en cache ahí van las preferencias de wallpaper, pero no lo versiono porque trae mis rutas. Ambxst genera solo `colors.json`, el CSS de GTK y los colores de Hyprland, eso no lo edito a mano.

## Otras apps

- **GTK 3/4:** `adw-gtk3` en modo oscuro con los colores que genera Ambxst. `gtk-4.0/gtk.css` es un archivo normal y no un enlace a Colloid, así Ambxst no sobrescribe el tema. En `nwg-look/config` dejé `export-gtk4-symlinks=false` para que no lo vuelva a cambiar por un enlace.
- **Qt:** `.config/qt{5,6}ct/` con Fusion y la paleta Blazepwn. `QT_QPA_PLATFORMTHEME=qt5ct:qt6ct` va en el entorno de Hyprland. Esta paleta es fija, si cambio de tema la tengo que cambiar también en qt5ct/qt6ct.
- **Kitty, Neovim y Spotify** tienen su propia config, está en [terminal-blazepwn.md](terminal-blazepwn.md).
- Discord, Burp y las páginas web usan su propio tema, eso no lo toco.

Un detalle: el launcher de Ambxst fuerza `qt6ct` en su proceso, entonces una app Qt 5 que abras desde ahí puede necesitar `QT_QPA_PLATFORMTHEME=qt5ct:qt6ct <app>`.

## Regresar

En Wallpapers elegir otro esquema, por ejemplo **Tonal Spot**, que vuelve a sacar los colores del wallpaper. En qt5ct/qt6ct se desmarca la paleta y se quita `QT_QPA_PLATFORMTHEME` de `hypr/user/env.lua`.

Para cambiar colores no uso `ambxst mods rollback`, porque regresa toda la generación anterior y puede volver a prender mods.
