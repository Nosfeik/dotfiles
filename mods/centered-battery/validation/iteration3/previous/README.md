# Centered Battery

Mod local para Ambxst **1.3.14**, API de Mods 1, probado sobre
`83e8462a6b03d4a7d428d5c7365e4ec03f3b63a9` con Quickshell 0.3.2 / Qt 6.12.
Implementa el concepto **04 — Núcleo Centrado**: contorno horizontal redondeado,
interior oscuro y núcleo turquesa redondeado que crece de izquierda a derecha.
No tiene fondo exterior, círculo, porcentaje permanente, sombra ni brillo.

## Instalar y activar

En **Settings → Mods**, instala la carpeta `centered-battery` o el archivo
`centered-battery-1.1.0.zip`, selecciona **Centered Battery**, habilítalo y reinicia
Ambxst desde su control de reinicio. El gestor instala los paquetes deshabilitados.

Equivalente por terminal:

```sh
ambxst mods install /home/nosfeik/Dev/dotfiles/mods/centered-battery
ambxst mods enable local.centered-battery
ambxst reload
```

No requiere comandos, dependencias ni procesos propios. No habilites simultáneamente
el antiguo `local.battery-indicator`: ambos sustituyen el mismo dibujo y se declara
el conflicto en el manifest. Roadie 4.1.1 sí es compatible.

## Iteración visual 1.1.0

La silueta pasa de 30 × 14 a 33,6 × 16 píxeles lógicos (+12% de ancho, +2 de alto)
con el mismo espacio de 36 en la barra. El núcleo completo pasa de 20 × 8 a
24 × 10,5; el padding horizontal baja de 4 a 3,5 y el vertical de 3 a 2,75.
La terminal pasa de 3 × 6 a 3,6 × 7 y sigue solapada un píxel con el cuerpo.
El contorno mantiene 1,25 de grosor y aclara su tono normal un 6%; el turquesa,
el interior, el hover y la advertencia temática conservan sus colores anteriores.
No cambia ningún archivo de tema, la altura de la barra ni el tamaño de sus vecinos.

`tests/Compare.qml` genera la comparación de estados en `validation/iteration2/comparison.png`.
`tests/fixtures/CenteredBatteryGraphic.qml` congela la versión 1.0 exclusivamente
para esa comparación; no se instala como componente de la barra.

Para volver a la generación anterior, usa `ambxst mods rollback` y `ambxst reload`.
Se probó que este rollback restaura el paquete 1.0.0. El archivo
`centered-battery-1.0.0.zip` también se conserva junto al nuevo ZIP. Si el gestor
ya depuró la generación anterior, deshabilita y elimina el mod con los comandos
de abajo e importa ese ZIP. No uses las copias de validación para sobrescribir
el repositorio ni el estado del gestor.

## Integración

- Un overlay **añade** `modules/bar/CenteredBatteryGraphic.qml`. Quickshell descubre
  el componente en el mismo módulo que `BatteryIndicator`; no se necesita `qmldir`.
- Un parche unificado cambia únicamente el bloque visual de `BatteryIndicator.qml`.
  Conserva literalmente `MouseArea`, `StyledToolTip`, popup y controles de perfiles.
- `BarContent.qml` y `modules/services/Battery.qml` no se modifican. Se conservan
  las instancias horizontal/vertical existentes, su posición y el área de clic de 36.
- El dibujo mide hasta 33,6 × 16 píxeles lógicos y se reduce proporcionalmente si falta
  espacio. Permanece horizontal también en una barra vertical.
- `Battery.percentage` determina el ancho real: `24 * porcentaje / 100`, sin redondear
  ni imponer un segmento mínimo. Los extremos 0 y 100 están limitados al interior.
- `Battery.isCharging` activa el rayo sin cambiar las dimensiones. Con carga completa
  y sin carga activa, el rayo desaparece, conforme al servicio existente.
- A partir de 10% el núcleo es turquesa, como en la referencia; por debajo de 10%
  usa `Colors.red`. Esto solo afecta al dibujo: las alertas del servicio conservan
  sus umbrales originales, incluido el aviso crítico al 10%.
- El contorno gris claro con una línea oscura en su borde conserva definición sobre
  fondos claros y oscuros. Hover/popup aclaran solamente el contorno. Los colores
  turquesa, gris e interior oscuro son los del diseño solicitado; advertencias,
  tooltip, popup y perfiles siguen el tema de Ambxst.
- El ancho usa `Config.animDuration`; con valor cero no se anima. No hay temporizadores,
  polling, Canvas, efectos de sombra ni procesos de consulta en el mod.
- Sin batería se conserva el icono y el acceso al perfil de energía.

La instalación local tiene Roadie activo, que convierte el popup base `BarPopup`
en `BarPopout`. El parche conserva ambas variantes porque no toca esa sección.
El gestor compone una generación separada; el repositorio original queda intacto.

## Desactivar, desinstalar y recuperar

En **Settings → Mods**, deshabilita Centered Battery y reinicia Ambxst. El indicador
anterior reaparece y los demás mods siguen activos. Después puedes eliminarlo.

```sh
ambxst mods disable local.centered-battery
ambxst reload
# Una vez que la nueva generación haya arrancado:
ambxst mods remove local.centered-battery
```

Si la interfaz no arranca, el gestor tiene una ventana de recuperación automática
de ocho segundos. También puedes ejecutar:

```sh
ambxst mods rollback
ambxst reload
```

Si la generación anterior tampoco sirve, `ambxst mods base` selecciona la base sin
mods; después ejecuta `ambxst reload`. Como alternativa temporal, detén la instancia
con `ambxst quit` y ejecuta `AMBXST_MODS_DISABLED=1 ambxst`.
No copies archivos encima del repositorio ni edites generaciones a mano.

La compatibilidad se limita a la versión instalada. Tras actualizar Ambxst,
comprueba el parche y adapta el rango solo después de validarlo; no es necesario
activar el bypass de compatibilidad.

## Validación reproducible

```sh
/usr/lib/qt6/bin/qmllint payload/modules/bar/CenteredBatteryGraphic.qml
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  /usr/lib/qt6/bin/qmltestrunner -input tests
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  /usr/lib/qt6/bin/qml tests/Preview.qml
ambxst mods check-compatibility /home/nosfeik/.local/src/ambxst
```

`Preview.qml` escribe `validation/states.png`. Las pruebas y el generador de vista
previa solo se ejecutan manualmente; no forman parte del funcionamiento de la barra.
Consulta `validation/iteration2/RESULTS.md` para los resultados y límites de la comprobación.

Formato y ciclo de vida basados en la
[documentación oficial de Mods](https://github.com/Axenide/Ambxst/blob/main/docs/mods/README.md)
y en el esquema y código del gestor de la versión instalada.
