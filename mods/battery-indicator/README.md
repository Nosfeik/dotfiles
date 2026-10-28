# Battery Indicator

Archivado como opción para Ambxst 1.3.7. La instalación actual usa Ambxst
1.3.14 con Roadie y la batería original. No se ha adaptado este mod a esa base;
no cambiar el rango de compatibilidad ni el hash sin revisar el nuevo contrato.

Mod independiente `local.battery-indicator`. Sustituye solamente
`modules/bar/BatteryIndicator.qml`: conserva el espacio de 36×36 y el contrato
de BarContent, horizontal y vertical. No cambia Pentest ni políticas de energía.

El gráfico usa rectángulos para contorno, terminal y relleno exacto; el check
usa Shape y el rayo Phosphor. Verde por encima de 50%, amarillo por encima de
20% hasta 50%, rojo hasta 20%. Los umbrales viven en `BatteryState.js` y los
colores son los tokens de Ambxst. Los avisos de 20%/10% siguen siendo los del
servicio Battery original. No hay acciones de click.

Porcentaje y carga vienen del servicio Battery/UPower existente. AC se consulta
con `UPower.onBattery`, por separado. Hover muestra porcentaje y estado mediante
StyledToolTip; si falta información muestra batería neutral, nunca un 0% falso.
El relleno transiciona durante media `Config.animDuration`; solo el rayo pulsa
suavemente entre opacidad 0.82 y 1 cada 3.6 s con la duración nativa actual.

El límite de ASUS se observa mediante **un** proceso GJS de usuario, sin polling,
con señales de `xyz.ljones.Platform.ChargeControlEndThreshold` en asusd. No inicia
el daemon ni escribe propiedades. Al cerrar Ambxst, EOF termina el puente.
Si esa fuente no está disponible, QML lee sysfs cada 60 s y al cambiar AC; no
lanza comandos. Se necesita una sola batería identificable. El check exige AC,
límite conocido menor que 100, porcentaje entre `límite − 0.5` y menos de 100,
estado UPower PendingCharge o FullyCharged y tasa de cambio menor que 0.1 W en
valor absoluto. Si el firmware reporta Discharging/Unknown, no infiero el límite.
El límite nunca rellena artificialmente la batería al 100%.

## Instalar y retirar

`gjs` es una dependencia oficial, incluida en `packages/ambxst.txt`. Desde el repo:

```sh
python3 scripts/check-battery-indicator.py
ambxst mods install ./mods/battery-indicator
ambxst mods enable local.battery-indicator
ambxst reload
```

Para actualizar una instalación local: `ambxst mods update local.battery-indicator`
y `ambxst reload`. Para volver al indicador original:

```sh
ambxst mods disable local.battery-indicator
ambxst reload
# Opcional, después de deshabilitarlo:
ambxst mods remove local.battery-indicator
```

`ambxst mods rollback` seguido de `ambxst reload` recupera la generación anterior
completa (puede incluir este mod). Ambxst conserva además su rollback automático
si una generación falla durante los primeros ocho segundos.

## Cambios upstream y pruebas

El overlay tiene `replace: true` y `expectedSha256`. Si cambia el BatteryIndicator
original, la composición se detiene. Antes de actualizar el hash hay que revisar
el diff de ese archivo **y** su contrato con BarContent, adaptar el reemplazo y
probarlo. Solo entonces registrar el resultado de:

```sh
sha256sum "$HOME/.local/src/ambxst/modules/bar/BatteryIndicator.qml"
```

Actualizar también compatibilidad/commit probado del manifiesto. No saltarse la
comprobación ni editar una generación o el source base.

`scripts/check-battery-indicator.py` valida el manifiesto con el parser oficial,
hash, sintaxis QML y lógica de estado. Prueba el puente en un D-Bus privado con
asusd simulado: cambios, caída/recuperación y salida limpia, sin tocar hardware.
Requiere Go, Python/PyGObject y herramientas Qt de desarrollo ya disponibles aquí.
`python3 mods/battery-indicator/tests/render-fixtures.py` renderiza el componente
real en un entorno offscreen temporal, con paletas nativas clara/oscura y escalas
1, 1.6 y 2. No activa fixtures en la barra. Capturas en
[`docs/assets/battery-indicator`](../../docs/assets/battery-indicator).
