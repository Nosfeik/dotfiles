# Roadie

[Roadie](https://github.com/drpezzer/ambxst-mods/tree/main/packages/roadie) es un mod de Ambxst que agrega transiciones, más opciones para la barra y el Notch, audio y Bluetooth. Tengo la 4.1.1 sobre Ambxst 1.3.14.

En `manifests/ambxst-mods.json` guardo de dónde sale, la revisión y el SHA-256 del manifest, nada más para saber qué tenía instalado. Lo que Ambxst guarda en `~/.local/share/ambxst/mods` no va en el repo.

## Mis ajustes

- `.config/ambxst/roadie.json` tiene `modUpdatesHandedOver=true`, lo demás está como viene. Se cambia desde **Settings → Roadie**.
- Barra con frame de 7 px y `systrayExclude: ["blueman"]`.
- En Theme tengo `trueMatugenIcons=false` y `trueMonochromeTint=false`, la paleta es Blazepwn.

## Instalar

Roadie 4.1.1 pide Ambxst `>=1.3.14 <2.0.0`. El script `manual-components.sh ambxst` sigue fijado a la 1.3.7, entonces primero hay que actualizar Ambxst y revisar con `ambxst version`.

Así lo instalo, siguiendo las actualizaciones del autor:

```bash
ambxst mods install https://github.com/drpezzer/ambxst-mods/tree/main/packages/roadie
ambxst mods enable drpezzer.roadie
ambxst reload
```

Si quiero exactamente la revisión que tengo registrada, clono el repo y hago checkout a esa revisión:

```bash
git clone https://github.com/drpezzer/ambxst-mods.git ~/.local/src/ambxst-roadie
git -C ~/.local/src/ambxst-roadie checkout --detach 70e90804200bebedc2ae8c59f330307d6431b166
sha256sum ~/.local/src/ambxst-roadie/packages/roadie/ambxst.mod.json   # comparar con manifests/ambxst-mods.json
ambxst mods install ~/.local/src/ambxst-roadie/packages/roadie
```

Ojo, no sirve poner el SHA en la URL `/tree/...` porque el instalador lo pasa a `git clone --branch`, que espera una rama o tag. Tampoco copio `~/.config/ambxst/mods.json` a mano, porque apunta a generaciones locales.

Para quitarlo: `ambxst mods disable drpezzer.roadie` y `ambxst reload`.
