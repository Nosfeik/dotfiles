# Manifests

`configs.txt` y `assets.txt` son la lista exacta de lo que copia el restaurador. No recorre carpetas, entonces si agrego un archivo nuevo al repo no se restaura hasta que lo pongo aquí. Así no se cuela nada que no revisé.

Las rutas son relativas al repo y se copian a la misma ruta en `$HOME`. La excepción es `.fonts/*`, que va a `~/.local/share/fonts/dotfiles/*`. El script rechaza rutas que se salgan del repo.

`assets.txt` está largo porque trae todo el árbol de iconos Kora.

`ambxst-mods.json` tiene los mods que uso con su versión, de dónde salen y el hash del manifest.

Lo que nunca va aquí: caches, credenciales, historial, sockets, la sesión de Spotify ni `config-xpui.ini`. El perfil de `exegol/` tampoco, ese se copia aparte al contenedor.
