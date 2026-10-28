# Roadie

Instalado por mí el 27/10/2026: **drpezzer.roadie 4.1.1**, único mod activo,
con Ambxst **1.3.14**, base `83e8462a6b03d4a7d428d5c7365e4ec03f3b63a9`.
El registro del gestor identifica la revisión
`70e90804200bebedc2ae8c59f330307d6431b166` del repo
<https://github.com/drpezzer/ambxst-mods>, subdirectorio `packages/roadie`.

Guardo origen, revisión y SHA-256 del manifiesto instalado en
`manifests/ambxst-mods.json`. Es un inventario para restaurar, no el estado interno
del gestor. No copio `~/.local/share/ambxst/mods`, generaciones, PIDs ni caches a Git.

## Preferencias actuales

- `.config/ambxst/roadie.json`: `modUpdatesHandedOver=true`; el resto usa los
  defaults de Roadie 4.1.1. Se ajustan desde **Settings → Roadie**.
- Barra: frame activo de 7 px y `systrayExclude: ["blueman"]`.
- Theme: `trueMatugenIcons=false`, `trueMonochromeTint=false`; GreenBlack sigue
  siendo la paleta de usuario. No está instalado el mod de batería personalizado.
- Los binds nativos incorporan fullscreen, maximize y fake fullscreen.

Roadie añade transiciones, ajustes de barra/Notch, audio y Bluetooth, entre
otras funciones. También incluye opciones de idle y despedida: este respaldo
solo registra la instalación existente, no cambia ni prueba energía, tapa,
suspensión, GPU o apagado. El proceso `ambxst-veil` pertenece a sus transiciones;
no es una segunda shell Ambxst completa.

## Restaurar

Primero preparo una versión compatible de Ambxst. **El bootstrap histórico
`scripts/manual-components.sh ambxst` sigue fijado a 1.3.7** y no basta para
Roadie 4.1.1 (requiere `>=1.3.14 <2.0.0`). Hay que completar la actualización
oficial y comprobar `ambxst version` antes de instalar este mod; el snapshot
comprobado aquí corresponde exactamente a 1.3.14. No fuerzo el bypass.

Para recuperar la revisión registrada, en un directorio nuevo fuera del repo:

```bash
git clone https://github.com/drpezzer/ambxst-mods.git "$HOME/.local/src/ambxst-roadie"
git -C "$HOME/.local/src/ambxst-roadie" checkout --detach 70e90804200bebedc2ae8c59f330307d6431b166
sha256sum "$HOME/.local/src/ambxst-roadie/packages/roadie/ambxst.mod.json"
# Comparar con manifestSha256 en manifests/ambxst-mods.json antes de instalar.
ambxst mods install "$HOME/.local/src/ambxst-roadie/packages/roadie"
ambxst mods enable drpezzer.roadie
ambxst reload
ambxst mods list
```

La instalación local queda fijada al checkout. Para seguir las actualizaciones
del autor, la fuente usada en la máquina actual es:

```bash
ambxst mods install https://github.com/drpezzer/ambxst-mods/tree/main/packages/roadie
```

`main` puede traer una versión posterior: reviso compatibilidad y cambios.
No uso un SHA en una URL `/tree/…` para fijarlo: el instalador de esta versión
lo pasa a `git clone --branch`, que espera una rama/tag. Tampoco restauro a mano
`~/.config/ambxst/mods.json`, porque contiene referencias a generaciones locales.

Las preferencias se copian con el manifiesto normal de configs. Si el directorio
del checkout ya existe, reviso su estado antes de actualizarlo; no lo sobrescribo.
Los mods Pentest y Battery Indicator archivados no se instalan con estos pasos.

Para retirar Roadie: `ambxst mods disable drpezzer.roadie` y `ambxst reload`.
`ambxst mods rollback` recupera la generación anterior completa, no solo un ajuste.
