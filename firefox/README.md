# Firefox

Tema Nosfeik para la interfaz de Firefox y mi `user.js`. El perfil tiene un nombre random (`xxxxxxxx.default-release`), por eso no lo copia el restaurador y lo pongo a mano.

| Archivo | Qué hace |
|---|---|
| `chrome/userChrome.css` | Tema de la barra, pestañas, urlbar y menús |
| `chrome/userContent.css` | Colores de `about:home`, `about:newtab` y demás páginas internas |
| `user.js` | Activa el `userChrome`, quita telemetría y ruido, no guarda historial y deja abrir dominios de labs (`.htb`, `.thm`, etc.) sin mandarlos al buscador |

La página de inicio (`index.html` y `logo.png`) vive en `.config/firefox-startpage/` y esa sí la copia el restaurador.

## Restaurar

Abrir Firefox una vez para que cree el perfil, cerrarlo y:

```bash
P=$(find ~/.config/mozilla/firefox -maxdepth 1 -name '*.default-release' | head -1)
mkdir -p "$P/chrome"
cp firefox/user.js "$P/"
cp firefox/chrome/*.css "$P/chrome/"
```

`userChrome.css` solo se lee al arrancar, entonces hay que cerrar Firefox completo (Ctrl+Q) para ver cambios.

## Ojo

- En Firefox 160 los menús cambiaron de variables: ahora son `--panel-background-color` y `--panel-text-color`. Si una actualización vuelve a dejar el menú ☰ en gris, lo primero es revisar esos nombres.
- La fuente de la urlbar es `JetBrainsMono Nerd Font` (`ttf-jetbrains-mono-nerd`).
- `.config/firefox-startpage/autoconfig/` y `brave/startpage.json` son para poner la página como nueva pestaña. Van en `/usr/lib/firefox/` y en las policies de Brave, y eso se copia con sudo, no lo hace el restaurador.
